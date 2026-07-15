#!/usr/bin/env bash
# scaffold.sh — stateful, non-interactive scaffolding tool an agent can drive
# step-by-step.
#
# Why: scaffolding a new repo is a long, multi-step sequence (copy template,
# substitute placeholders, create Cargo workspace, propagate harness, create
# GitHub repo, ...). An agent driving it needs a way to resume after each
# step without re-deriving where it left off, and the user needs a visible
# signal that scaffolding is mid-flight.
#
# How: state lives in <target>/SCAFFOLD.state (key=value), NOT gitignored —
# its presence in `git status` is the "scaffolding in progress" signal. Each
# invocation of `next` checks whether the CURRENT_STEP is actually done (by
# probing the filesystem/git state it should have produced), advances past
# any already-done steps, then prints the next unfinished step's
# instructions and exits. The final step deletes SCAFFOLD.state.
#
# Usage:
#   scaffold.sh init <template> <org> <project-name> <description>
#   scaffold.sh next [target-dir]
#   scaffold.sh status [target-dir]
#
# <target-dir> defaults to the current directory for next/status, so the
# common flow is: cd into the target, then run `scaffold.sh next` repeatedly.
#
# Templates: rust (implemented), typescript (stub — not yet implemented).

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GITHUB_IO="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_REPO="$HOME/git/0000000_pterror"
SCAFFOLDING_SRC="$GITHUB_IO/scaffolding"

# ---------------------------------------------------------------------------
# Org mapping (GitHub org -> disk path segment under ~/git/)
# ---------------------------------------------------------------------------

org_path() {
    case "$1" in
        rhi-zone) printf 'rhizone' ;;
        exo-place) printf 'exoplace' ;;
        ptera-world) printf 'pteraworld' ;;
        para-garden) printf 'paragarden' ;;
        pterror) printf 'pterror' ;;
        *) return 1 ;;
    esac
}

die() {
    printf '[scaffold] ERROR: %s\n' "$1" >&2
    exit 1
}

# ---------------------------------------------------------------------------
# SCAFFOLD.state read/write helpers
# ---------------------------------------------------------------------------

state_file() { printf '%s/SCAFFOLD.state' "$1"; }

state_get() {
    # state_get <state-file> <key>
    awk -F= -v k="$2" '$1==k { sub(/^[^=]*=/, ""); print; found=1 } END { if (!found) exit 1 }' "$1"
}

state_set_current_step() {
    # state_set_current_step <state-file> <n>
    awk -v n="$2" -F= 'BEGIN{OFS="="} $1=="CURRENT_STEP"{$2=n} {print}' "$1" > "$1.tmp"
    mv "$1.tmp" "$1"
}

# ---------------------------------------------------------------------------
# init
# ---------------------------------------------------------------------------

cmd_init() {
    [ $# -eq 4 ] || die "usage: scaffold.sh init <template> <org> <project-name> <description>"
    template="$1"; org="$2"; project_name="$3"; description="$4"

    case "$template" in
        rust|typescript) ;;
        *) die "unknown template '$template' (known: rust, typescript)" ;;
    esac

    org_dir="$(org_path "$org")" || die "unknown org '$org' (known: rhi-zone, exo-place, ptera-world, para-garden, pterror)"

    command -v git >/dev/null 2>&1 || die "git not found"
    command -v gh >/dev/null 2>&1 || die "gh not found"
    if [ "$template" = rust ]; then
        command -v bun >/dev/null 2>&1 || die "bun not found (needed for docs site)"
    fi
    [ -d "$TEMPLATE_REPO" ] || die "template repo not found at $TEMPLATE_REPO (needed for .git copy)"

    target="$HOME/git/$org_dir/$project_name"
    sf="$(state_file "$target")"

    if [ -e "$target" ] && [ ! -f "$sf" ]; then
        die "target '$target' already exists and has no SCAFFOLD.state — refusing to touch a non-scaffold directory"
    fi

    if [ -f "$sf" ]; then
        printf '[scaffold] SCAFFOLD.state already exists at %s — leaving it in place. Run `scaffold.sh status %s` to see progress.\n' "$sf" "$target" >&2
        exit 0
    fi

    mkdir -p "$target"

    total_steps="$(steps_total "$template")"

    cat > "$sf" <<EOF
TEMPLATE=$template
ORG=$org
ORG_PATH=$org_dir
PROJECT_NAME=$project_name
PROJECT_DESCRIPTION=$description
TARGET=$target
CURRENT_STEP=1
TOTAL_STEPS=$total_steps
EOF

    printf '[scaffold] Initialized SCAFFOLD.state at %s\n' "$sf"
    printf '[scaffold] Run `scaffold.sh next %s` (or cd there and `scaffold.sh next`) to begin.\n\n' "$target"
    print_step "$sf" 1
}

# ---------------------------------------------------------------------------
# Step tables per template
# ---------------------------------------------------------------------------

steps_total() {
    case "$1" in
        rust) printf '15' ;;
        typescript) printf '0' ;;
    esac
}

# step_done <state-file> <step-n> -> 0 if that step's expected state exists
step_done_rust() {
    sf="$1"; n="$2"
    target="$(state_get "$sf" TARGET)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    org="$(state_get "$sf" ORG)"
    case "$n" in
        1) [ -d "$target/.git" ] ;;
        2) [ -f "$target/flake.nix" ] ;;
        3) [ -f "$target/flake.nix" ] && ! grep -q 'PROJECT_NAME' "$target/flake.nix" ;;
        4) [ -x "$target/.githooks/pre-commit" ] && [ "$(git -C "$target" config core.hooksPath 2>/dev/null || true)" = ".githooks" ] ;;
        5) [ -f "$target/Cargo.toml" ] ;;
        6) [ -f "$target/docs/.vitepress/config.ts" ] ;;
        7) [ -d "$target/docs/node_modules" ] ;;
        8) [ -f "$target/README.md" ] && [ "$(wc -l < "$target/README.md")" -gt 5 ] ;;
        9) [ -f "$target/CLAUDE.md" ] ;;
        10) [ -f "$target/CLAUDE.md" ] && grep -q 'README.md' "$target/CLAUDE.md" ;;
        11) [ -d "$target/.direnv" ] ;;
        12) git -C "$target" log --oneline -1 >/dev/null 2>&1 ;;
        13) gh repo view "$org/$project_name" >/dev/null 2>&1 ;;
        14) gh api "repos/$org/$project_name/pages" >/dev/null 2>&1 ;;
        15) [ ! -f "$target/SCAFFOLD.state" ] ;;
        *) return 1 ;;
    esac
}

step_check() {
    sf="$1"; n="$2"
    template="$(state_get "$sf" TEMPLATE)"
    case "$template" in
        rust) step_done_rust "$sf" "$n" ;;
        typescript) return 1 ;;
    esac
}

# print_step <state-file> <step-n>  — print the instruction block for step n
print_step() {
    sf="$1"; n="$2"
    template="$(state_get "$sf" TEMPLATE)"
    target="$(state_get "$sf" TARGET)"
    org="$(state_get "$sf" ORG)"
    org_dir="$(state_get "$sf" ORG_PATH)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    description="$(state_get "$sf" PROJECT_DESCRIPTION)"
    total="$(state_get "$sf" TOTAL_STEPS)"

    if [ "$template" = typescript ]; then
        printf 'TypeScript template not yet implemented\n' >&2
        exit 1
    fi

    title=""
    body=""
    case "$n" in
        1)
            title="Create directory and copy .git"
            body=$(cat <<EOF
mkdir -p "$target"
cp -r "$TEMPLATE_REPO/.git" "$target/.git"
EOF
)
            ;;
        2)
            title="Copy scaffolding files"
            body=$(cat <<EOF
cp -r "$SCAFFOLDING_SRC/." "$target/"
# Then remove files that must not be copied verbatim / are template-authoring-only:
rm -f "$target/README.md" "$target/TODO.md" "$target/claude-md-failure-modes.md" "$target/maybe-rules.md"
rm -f "$target/flake.lock"
rm -rf "$target/.direnv" "$target/.normalize/index.sqlite" "$target/.normalize/memory"
EOF
)
            ;;
        3)
            title="Substitute placeholders"
            body=$(cat <<EOF
sed -i "s/PROJECT_NAME/$project_name/g" "$target/flake.nix" "$target/docs/package.json"
sed -i "s/PROJECT_DESCRIPTION/$description/g" "$target/flake.nix"
EOF
)
            ;;
        4)
            title="Configure git hooks"
            body=$(cat <<EOF
cd "$target" && git config core.hooksPath .githooks
chmod +x "$target/.githooks/pre-commit"
EOF
)
            ;;
        5)
            title="Create Cargo.toml workspace"
            body=$(cat <<EOF
Create the following files:

$target/Cargo.toml:
[workspace]
members = ["crates/*"]
resolver = "2"

$target/crates/$project_name-core/Cargo.toml:
[package]
name = "$project_name-core"
version = "0.1.0"
edition = "2024"

$target/crates/$project_name-core/src/lib.rs:
(empty file)
EOF
)
            ;;
        6)
            title="Create docs site"
            body=$(cat <<EOF
Create the following files:

$target/docs/.vitepress/config.ts:
  - Import and wrap config with vitepress-plugin-mermaid (withMermaid)
  - title: "$project_name", description: "$description"
  - themeConfig.nav / sidebar: minimal (Home link at least)
  - themeConfig.socialLinks: link to https://github.com/$org/$project_name
  - themeConfig.nav include { text: 'rhi', link: 'https://rhi.zone/' }

$target/docs/index.md:
  - Minimal VitePress landing page: title, one-line description ("$description"),
    and a short "what this is" paragraph. Use the default (non-hero) layout unless
    the project warrants a hero.
EOF
)
            ;;
        7)
            title="Install docs dependencies"
            body=$(cat <<EOF
cd "$target/docs" && bun install
EOF
)
            ;;
        8)
            title="Fill in README.md"
            body=$(cat <<EOF
Write $target/README.md covering:
  - What "$project_name" is (one paragraph, expand on "$description")
  - Why it exists / motivating use cases
  - Key design decisions (if any are already known)
This is the only place project goals are recorded — the scaffolding
conversation is not accessible from inside the new repo, so be concrete.
Must be more than 5 lines (not a placeholder stub).
EOF
)
            ;;
        9)
            title="Run harness propagation"
            body=$(cat <<EOF
"$GITHUB_IO/tooling/propagate-harness.sh" "$target"
EOF
)
            ;;
        10)
            title="Add README pointer to CLAUDE.md"
            body=$(cat <<EOF
Below the <!-- END ECOSYSTEM RULES --> marker in $target/CLAUDE.md, add:

Project goals and design context: [README.md](README.md)
EOF
)
            ;;
        11)
            title="direnv allow"
            body=$(cat <<EOF
cd "$target" && direnv allow
EOF
)
            ;;
        12)
            title="Initial commit"
            body=$(cat <<EOF
cd "$target"
git add -A
git commit -m "Initial scaffold for $project_name"
EOF
)
            ;;
        13)
            title="Create GitHub repo"
            body=$(cat <<EOF
gh repo create "$org/$project_name" --public --source "$target" --description "$description" --push
gh repo edit "$org/$project_name" --homepage "https://docs.rhi.zone/$project_name/"
gh repo edit "$org/$project_name" --add-topic rust
# Add other relevant topics as appropriate for the project domain.
EOF
)
            ;;
        14)
            title="Enable GitHub Pages"
            body=$(cat <<EOF
gh api "repos/$org/$project_name/pages" -X POST -f "build_type=workflow"
EOF
)
            ;;
        15)
            title="Clean up"
            body=$(cat <<EOF
rm "$target/SCAFFOLD.state"
EOF
)
            ;;
        *)
            printf 'Scaffolding complete.\n'
            return 0
            ;;
    esac

    printf '=== Step %s/%s: %s ===\n\n' "$n" "$total" "$title"
    printf '%s\n' "$body"
}

# ---------------------------------------------------------------------------
# next
# ---------------------------------------------------------------------------

cmd_next() {
    dir="${1:-.}"
    sf="$(state_file "$dir")"
    [ -f "$sf" ] || die "no SCAFFOLD.state found in '$dir' — run 'scaffold.sh init' first"

    total="$(state_get "$sf" TOTAL_STEPS)"
    current="$(state_get "$sf" CURRENT_STEP)"

    # Advance past any already-completed steps.
    while [ "$current" -le "$total" ] && step_check "$sf" "$current"; do
        current=$((current + 1))
        state_set_current_step "$sf" "$current"
    done

    if [ "$current" -gt "$total" ]; then
        printf 'Scaffolding complete.\n'
        return 0
    fi

    print_step "$sf" "$current"
}

# ---------------------------------------------------------------------------
# status
# ---------------------------------------------------------------------------

cmd_status() {
    dir="${1:-.}"
    sf="$(state_file "$dir")"
    [ -f "$sf" ] || die "no SCAFFOLD.state found in '$dir'"

    total="$(state_get "$sf" TOTAL_STEPS)"
    current="$(state_get "$sf" CURRENT_STEP)"
    template="$(state_get "$sf" TEMPLATE)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    target="$(state_get "$sf" TARGET)"

    remaining=$((total - current + 1))
    if [ "$current" -gt "$total" ]; then
        remaining=0
    fi

    printf 'project:   %s (%s template)\n' "$project_name" "$template"
    printf 'target:    %s\n' "$target"
    printf 'step:      %s/%s\n' "$current" "$total"
    printf 'remaining: %s step(s)\n' "$remaining"
}

# ---------------------------------------------------------------------------
# dispatch
# ---------------------------------------------------------------------------

usage() {
    cat >&2 <<EOF
Usage:
  scaffold.sh init <template> <org> <project-name> <description>
  scaffold.sh next [target-dir]
  scaffold.sh status [target-dir]

Templates: rust, typescript (stub)
Orgs: rhi-zone, exo-place, ptera-world, para-garden, pterror
EOF
    exit 1
}

[ $# -ge 1 ] || usage
cmd="$1"; shift
case "$cmd" in
    init) cmd_init "$@" ;;
    next) cmd_next "$@" ;;
    status) cmd_status "$@" ;;
    *) usage ;;
esac
