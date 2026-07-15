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
# Templates: rust, bun (ESM monorepo w/ bun workspaces), godot (Godot 4 project),
# docs (writing/documentation-only, VitePress), static (minimal static HTML site).

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
        rust|bun|godot|docs|static) ;;
        *) die "unknown template '$template' (known: rust, bun, godot, docs, static)" ;;
    esac

    org_dir="$(org_path "$org")" || die "unknown org '$org' (known: rhi-zone, exo-place, ptera-world, para-garden, pterror)"

    command -v git >/dev/null 2>&1 || die "git not found"
    command -v gh >/dev/null 2>&1 || die "gh not found"
    if [ "$template" != "static" ]; then
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
        rust) printf '16' ;;
        bun) printf '19' ;;
        godot) printf '17' ;;
        docs) printf '15' ;;
        static) printf '14' ;;
    esac
}

# step_done_<template> <state-file> <step-n> -> 0 if that step's expected state exists
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
        10) grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients.txt" 2>/dev/null ;;
        11) [ -f "$target/CLAUDE.md" ] && grep -q 'README.md' "$target/CLAUDE.md" ;;
        12) [ -d "$target/.direnv" ] ;;
        13) git -C "$target" log --oneline -1 >/dev/null 2>&1 ;;
        14) gh repo view "$org/$project_name" >/dev/null 2>&1 ;;
        15) gh api "repos/$org/$project_name/pages" >/dev/null 2>&1 ;;
        16) [ ! -f "$target/SCAFFOLD.state" ] ;;
        *) return 1 ;;
    esac
}

step_done_bun() {
    sf="$1"; n="$2"
    target="$(state_get "$sf" TARGET)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    org="$(state_get "$sf" ORG)"
    case "$n" in
        1) [ -d "$target/.git" ] ;;
        2) [ -f "$target/.envrc" ] ;;
        3) [ -f "$target/flake.nix" ] && ! grep -q 'PROJECT_NAME' "$target/flake.nix" ;;
        4) [ -f "$target/package.json" ] ;;
        5) [ -f "$target/tsconfig.json" ] ;;
        6) [ -f "$target/packages/$project_name-core/package.json" ] ;;
        7) [ -f "$target/.gitignore" ] && grep -q 'node_modules' "$target/.gitignore" ;;
        8) [ -f "$target/.github/workflows/ci.yml" ] ;;
        9) [ -f "$target/docs/.vitepress/config.ts" ] ;;
        10) [ -d "$target/node_modules" ] ;;
        11) [ -f "$target/README.md" ] && [ "$(wc -l < "$target/README.md")" -gt 5 ] ;;
        12) [ -f "$target/CLAUDE.md" ] ;;
        13) grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients.txt" 2>/dev/null ;;
        14) [ -f "$target/CLAUDE.md" ] && grep -q 'README.md' "$target/CLAUDE.md" ;;
        15) [ -d "$target/.direnv" ] ;;
        16) git -C "$target" log --oneline -1 >/dev/null 2>&1 ;;
        17) gh repo view "$org/$project_name" >/dev/null 2>&1 ;;
        18) gh api "repos/$org/$project_name/pages" >/dev/null 2>&1 ;;
        19) [ ! -f "$target/SCAFFOLD.state" ] ;;
        *) return 1 ;;
    esac
}

step_done_godot() {
    sf="$1"; n="$2"
    target="$(state_get "$sf" TARGET)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    org="$(state_get "$sf" ORG)"
    case "$n" in
        1) [ -d "$target/.git" ] ;;
        2) [ -f "$target/.envrc" ] ;;
        3) [ -f "$target/flake.nix" ] && ! grep -q 'PROJECT_NAME' "$target/flake.nix" ;;
        4) [ -f "$target/project.godot" ] ;;
        5) [ -d "$target/scenes" ] && [ -d "$target/scripts" ] ;;
        6) [ -f "$target/.gitignore" ] && grep -q '\.godot' "$target/.gitignore" ;;
        7) [ -f "$target/docs/.vitepress/config.ts" ] ;;
        8) [ -d "$target/docs/node_modules" ] ;;
        9) [ -f "$target/README.md" ] && [ "$(wc -l < "$target/README.md")" -gt 5 ] ;;
        10) [ -f "$target/CLAUDE.md" ] ;;
        11) grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients.txt" 2>/dev/null ;;
        12) [ -f "$target/CLAUDE.md" ] && grep -q 'README.md' "$target/CLAUDE.md" ;;
        13) [ -d "$target/.direnv" ] ;;
        14) git -C "$target" log --oneline -1 >/dev/null 2>&1 ;;
        15) gh repo view "$org/$project_name" >/dev/null 2>&1 ;;
        16) gh api "repos/$org/$project_name/pages" >/dev/null 2>&1 ;;
        17) [ ! -f "$target/SCAFFOLD.state" ] ;;
        *) return 1 ;;
    esac
}

step_done_docs() {
    sf="$1"; n="$2"
    target="$(state_get "$sf" TARGET)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    org="$(state_get "$sf" ORG)"
    case "$n" in
        1) [ -d "$target/.git" ] ;;
        2) [ -f "$target/.envrc" ] ;;
        3) [ -f "$target/flake.nix" ] && ! grep -q 'PROJECT_NAME' "$target/flake.nix" ;;
        4) [ -f "$target/.gitignore" ] ;;
        5) [ -f "$target/docs/.vitepress/config.ts" ] ;;
        6) [ -d "$target/docs/node_modules" ] ;;
        7) [ -f "$target/README.md" ] && [ "$(wc -l < "$target/README.md")" -gt 5 ] ;;
        8) [ -f "$target/CLAUDE.md" ] ;;
        9) grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients.txt" 2>/dev/null ;;
        10) [ -f "$target/CLAUDE.md" ] && grep -q 'README.md' "$target/CLAUDE.md" ;;
        11) [ -d "$target/.direnv" ] ;;
        12) git -C "$target" log --oneline -1 >/dev/null 2>&1 ;;
        13) gh repo view "$org/$project_name" >/dev/null 2>&1 ;;
        14) gh api "repos/$org/$project_name/pages" >/dev/null 2>&1 ;;
        15) [ ! -f "$target/SCAFFOLD.state" ] ;;
        *) return 1 ;;
    esac
}

step_done_static() {
    sf="$1"; n="$2"
    target="$(state_get "$sf" TARGET)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    org="$(state_get "$sf" ORG)"
    case "$n" in
        1) [ -d "$target/.git" ] ;;
        2) [ -f "$target/.envrc" ] ;;
        3) [ -f "$target/flake.nix" ] && ! grep -q 'PROJECT_NAME' "$target/flake.nix" ;;
        4) [ -f "$target/.gitignore" ] ;;
        5) [ -f "$target/index.html" ] && grep -q "$project_name" "$target/index.html" ;;
        6) [ -f "$target/README.md" ] && [ "$(wc -l < "$target/README.md")" -gt 5 ] ;;
        7) [ -f "$target/CLAUDE.md" ] ;;
        8) grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients.txt" 2>/dev/null ;;
        9) [ -f "$target/CLAUDE.md" ] && grep -q 'README.md' "$target/CLAUDE.md" ;;
        10) [ -d "$target/.direnv" ] ;;
        11) git -C "$target" log --oneline -1 >/dev/null 2>&1 ;;
        12) gh repo view "$org/$project_name" >/dev/null 2>&1 ;;
        13) gh api "repos/$org/$project_name/pages" >/dev/null 2>&1 ;;
        14) [ ! -f "$target/SCAFFOLD.state" ] ;;
        *) return 1 ;;
    esac
}

step_check() {
    sf="$1"; n="$2"
    template="$(state_get "$sf" TEMPLATE)"
    case "$template" in
        rust) step_done_rust "$sf" "$n" ;;
        bun) step_done_bun "$sf" "$n" ;;
        godot) step_done_godot "$sf" "$n" ;;
        docs) step_done_docs "$sf" "$n" ;;
        static) step_done_static "$sf" "$n" ;;
    esac
}

# ---------------------------------------------------------------------------
# print_step dispatch + per-template step tables
# ---------------------------------------------------------------------------

# print_step <state-file> <step-n>  — print the instruction block for step n
print_step() {
    sf="$1"; n="$2"
    template="$(state_get "$sf" TEMPLATE)"

    case "$template" in
        rust) print_step_rust "$sf" "$n" ;;
        bun) print_step_bun "$sf" "$n" ;;
        godot) print_step_godot "$sf" "$n" ;;
        docs) print_step_docs "$sf" "$n" ;;
        static) print_step_static "$sf" "$n" ;;
    esac
}

print_step_rust() {
    sf="$1"; n="$2"
    target="$(state_get "$sf" TARGET)"
    org="$(state_get "$sf" ORG)"
    org_dir="$(state_get "$sf" ORG_PATH)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    description="$(state_get "$sf" PROJECT_DESCRIPTION)"
    total="$(state_get "$sf" TOTAL_STEPS)"

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
            title="Add to propagation lists"
            body=$(cat <<EOF
grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients.txt" || echo "$org/$project_name" >> "$GITHUB_IO/tooling/skill-recipients.txt"
if [ "$org" = "rhi-zone" ]; then
    grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients-rhizone.txt" || echo "$org/$project_name" >> "$GITHUB_IO/tooling/skill-recipients-rhizone.txt"
fi
EOF
)
            ;;
        11)
            title="Add README pointer to CLAUDE.md"
            body=$(cat <<EOF
Below the <!-- END ECOSYSTEM RULES --> marker in $target/CLAUDE.md, add:

Project goals and design context: [README.md](README.md)
EOF
)
            ;;
        12)
            title="direnv allow"
            body=$(cat <<EOF
cd "$target" && direnv allow
EOF
)
            ;;
        13)
            title="Initial commit"
            body=$(cat <<EOF
cd "$target"
git add -A
git commit -m "Initial scaffold for $project_name"
EOF
)
            ;;
        14)
            title="Create GitHub repo"
            body=$(cat <<EOF
gh repo create "$org/$project_name" --public --source "$target" --description "$description" --push
gh repo edit "$org/$project_name" --homepage "https://docs.rhi.zone/$project_name/"
gh repo edit "$org/$project_name" --add-topic rust
# Add other relevant topics as appropriate for the project domain.
EOF
)
            ;;
        15)
            title="Enable GitHub Pages"
            body=$(cat <<EOF
gh api "repos/$org/$project_name/pages" -X POST -f "build_type=workflow"
EOF
)
            ;;
        16)
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

print_step_bun() {
    sf="$1"; n="$2"
    target="$(state_get "$sf" TARGET)"
    org="$(state_get "$sf" ORG)"
    org_dir="$(state_get "$sf" ORG_PATH)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    description="$(state_get "$sf" PROJECT_DESCRIPTION)"
    total="$(state_get "$sf" TOTAL_STEPS)"

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
mkdir -p "$target/.github/workflows" "$target/docs" "$target/.claude"
cp "$SCAFFOLDING_SRC/.envrc" "$target/.envrc"
cp "$SCAFFOLDING_SRC/.github/workflows/deploy-docs.yml" "$target/.github/workflows/deploy-docs.yml"
cp "$SCAFFOLDING_SRC/docs/package.json" "$target/docs/package.json"
cp -r "$SCAFFOLDING_SRC/.claude/." "$target/.claude/"
sed -i "s/PROJECT_NAME/$project_name/g" "$target/docs/package.json"
# Do NOT copy .cargo/ or .githooks/pre-commit — those are rust-specific
# (rustfmt/clippy). .gitignore is created fresh in step 7 with
# bun-appropriate content rather than copied here.
EOF
)
            ;;
        3)
            title="Create flake.nix"
            body=$(cat <<EOF
Write $target/flake.nix:

{
  description = "$project_name - $description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.\${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            bun
          ];
        };
      }
    );
}
EOF
)
            ;;
        4)
            title="Create package.json"
            body=$(cat <<EOF
Write $target/package.json:

{
  "name": "$project_name",
  "type": "module",
  "private": true,
  "workspaces": ["packages/*"],
  "scripts": {
    "typecheck": "tsc --build",
    "test": "bun test",
    "build": "bun run --filter '*' build"
  },
  "devDependencies": {
    "@typescript/native-preview": "latest",
    "bun-types": "latest"
  }
}
EOF
)
            ;;
        5)
            title="Create tsconfig.json"
            body=$(cat <<EOF
Write $target/tsconfig.json:

{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "noEmit": true,
    "types": ["bun-types"]
  }
}
EOF
)
            ;;
        6)
            title="Create initial package"
            body=$(cat <<EOF
Create the following files:

$target/packages/$project_name-core/package.json:
{
  "name": "$project_name-core",
  "version": "0.1.0",
  "type": "module",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "typecheck": "tsc --build",
    "test": "bun test"
  }
}

$target/packages/$project_name-core/tsconfig.json:
{
  "extends": "../../tsconfig.json",
  "include": ["src"]
}

$target/packages/$project_name-core/src/index.ts:
(empty file)
EOF
)
            ;;
        7)
            title="Create .gitignore"
            body=$(cat <<EOF
Write $target/.gitignore:

# Build
dist/

# Nix
result
.direnv/

# Node
node_modules/
docs/.vitepress/cache/
docs/.vitepress/dist/

# Secrets
.envrc.local

# IDE
.idea/
.vscode/
*.swp

# Agent worktrees (temporary, never tracked)
.claude/worktrees/

# Normalize
.normalize/*
!.normalize/config.toml
!.normalize/duplicate-functions-allow
!.normalize/duplicate-types-allow
!.normalize/hotspots-allow
!.normalize/large-files-allow
!.normalize/memory/
EOF
)
            ;;
        8)
            title="Create CI workflow"
            body=$(cat <<EOF
Write $target/.github/workflows/ci.yml:

name: CI

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - name: Install dependencies
        run: bun install
      - name: Typecheck
        run: bun run typecheck
      - name: Test
        run: bun run test
      - name: Build
        run: bun run build
EOF
)
            ;;
        9)
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
        10)
            title="Install dependencies"
            body=$(cat <<EOF
cd "$target" && bun install
cd "$target/docs" && bun install
EOF
)
            ;;
        11)
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
        12)
            title="Run harness propagation"
            body=$(cat <<EOF
"$GITHUB_IO/tooling/propagate-harness.sh" "$target"
EOF
)
            ;;
        13)
            title="Add to propagation lists"
            body=$(cat <<EOF
grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients.txt" || echo "$org/$project_name" >> "$GITHUB_IO/tooling/skill-recipients.txt"
if [ "$org" = "rhi-zone" ]; then
    grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients-rhizone.txt" || echo "$org/$project_name" >> "$GITHUB_IO/tooling/skill-recipients-rhizone.txt"
fi
EOF
)
            ;;
        14)
            title="Add README pointer to CLAUDE.md"
            body=$(cat <<EOF
Below the <!-- END ECOSYSTEM RULES --> marker in $target/CLAUDE.md, add:

Project goals and design context: [README.md](README.md)
EOF
)
            ;;
        15)
            title="direnv allow"
            body=$(cat <<EOF
cd "$target" && direnv allow
EOF
)
            ;;
        16)
            title="Initial commit"
            body=$(cat <<EOF
cd "$target"
git add -A
git commit -m "Initial scaffold for $project_name"
EOF
)
            ;;
        17)
            title="Create GitHub repo"
            body=$(cat <<EOF
gh repo create "$org/$project_name" --public --source "$target" --description "$description" --push
gh repo edit "$org/$project_name" --homepage "https://docs.rhi.zone/$project_name/"
gh repo edit "$org/$project_name" --add-topic typescript
# Add other relevant topics as appropriate for the project domain.
EOF
)
            ;;
        18)
            title="Enable GitHub Pages"
            body=$(cat <<EOF
gh api "repos/$org/$project_name/pages" -X POST -f "build_type=workflow"
EOF
)
            ;;
        19)
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

print_step_godot() {
    sf="$1"; n="$2"
    target="$(state_get "$sf" TARGET)"
    org="$(state_get "$sf" ORG)"
    org_dir="$(state_get "$sf" ORG_PATH)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    description="$(state_get "$sf" PROJECT_DESCRIPTION)"
    total="$(state_get "$sf" TOTAL_STEPS)"

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
            title="Copy common scaffolding files"
            body=$(cat <<EOF
mkdir -p "$target/.github/workflows" "$target/docs" "$target/.claude"
cp "$SCAFFOLDING_SRC/.envrc" "$target/.envrc"
cp "$SCAFFOLDING_SRC/.github/workflows/deploy-docs.yml" "$target/.github/workflows/deploy-docs.yml"
cp "$SCAFFOLDING_SRC/docs/package.json" "$target/docs/package.json"
cp -r "$SCAFFOLDING_SRC/.claude/." "$target/.claude/"
sed -i "s/PROJECT_NAME/$project_name/g" "$target/docs/package.json"
# Do NOT copy .cargo/, .githooks/pre-commit, or ci.yml — those are
# rust/bun-specific. .gitignore is created fresh in step 6.
EOF
)
            ;;
        3)
            title="Create flake.nix"
            body=$(cat <<EOF
Write $target/flake.nix:

{
  description = "$project_name - $description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.\${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            godot_4
            bun
          ];
        };
      }
    );
}
EOF
)
            ;;
        4)
            title="Create project.godot"
            body=$(cat <<EOF
Write $target/project.godot (minimal Godot 4 project file):

; Engine configuration file.
config_version=5

[application]

config/name="$project_name"
config/description="$description"
run/main_scene=""
config/features=PackedStringArray("4.3", "Forward Plus")

[display]

window/size/viewport_width=1920
window/size/viewport_height=1080
EOF
)
            ;;
        5)
            title="Create directory structure"
            body=$(cat <<EOF
mkdir -p "$target/scenes" "$target/scripts" "$target/assets" "$target/tests"
# .gitkeep placeholders so the empty dirs are tracked until real content lands:
touch "$target/scenes/.gitkeep" "$target/scripts/.gitkeep" "$target/assets/.gitkeep" "$target/tests/.gitkeep"
EOF
)
            ;;
        6)
            title="Create .gitignore"
            body=$(cat <<EOF
Write $target/.gitignore:

# Godot
.godot/
.import/
export_presets.cfg
export.cfg
*.translation

# Nix
result
.direnv/

# Node (docs)
node_modules/
docs/.vitepress/cache/
docs/.vitepress/dist/

# Secrets
.envrc.local

# IDE
.idea/
.vscode/
*.swp
*~

# Normalize
.normalize/*
!.normalize/config.toml
!.normalize/duplicate-functions-allow
!.normalize/duplicate-types-allow
!.normalize/hotspots-allow
!.normalize/large-files-allow
!.normalize/memory/
EOF
)
            ;;
        7)
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
        8)
            title="Install docs dependencies"
            body=$(cat <<EOF
cd "$target/docs" && bun install
EOF
)
            ;;
        9)
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
        10)
            title="Run harness propagation"
            body=$(cat <<EOF
"$GITHUB_IO/tooling/propagate-harness.sh" "$target"
EOF
)
            ;;
        11)
            title="Add to propagation lists"
            body=$(cat <<EOF
grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients.txt" || echo "$org/$project_name" >> "$GITHUB_IO/tooling/skill-recipients.txt"
if [ "$org" = "rhi-zone" ]; then
    grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients-rhizone.txt" || echo "$org/$project_name" >> "$GITHUB_IO/tooling/skill-recipients-rhizone.txt"
fi
EOF
)
            ;;
        12)
            title="Add README pointer to CLAUDE.md"
            body=$(cat <<EOF
Below the <!-- END ECOSYSTEM RULES --> marker in $target/CLAUDE.md, add:

Project goals and design context: [README.md](README.md)
EOF
)
            ;;
        13)
            title="direnv allow"
            body=$(cat <<EOF
cd "$target" && direnv allow
EOF
)
            ;;
        14)
            title="Initial commit"
            body=$(cat <<EOF
cd "$target"
git add -A
git commit -m "Initial scaffold for $project_name"
EOF
)
            ;;
        15)
            title="Create GitHub repo"
            body=$(cat <<EOF
gh repo create "$org/$project_name" --public --source "$target" --description "$description" --push
gh repo edit "$org/$project_name" --homepage "https://docs.rhi.zone/$project_name/"
gh repo edit "$org/$project_name" --add-topic godot
gh repo edit "$org/$project_name" --add-topic gamedev
# Add other relevant topics as appropriate for the project domain.
EOF
)
            ;;
        16)
            title="Enable GitHub Pages"
            body=$(cat <<EOF
gh api "repos/$org/$project_name/pages" -X POST -f "build_type=workflow"
EOF
)
            ;;
        17)
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

print_step_docs() {
    sf="$1"; n="$2"
    target="$(state_get "$sf" TARGET)"
    org="$(state_get "$sf" ORG)"
    org_dir="$(state_get "$sf" ORG_PATH)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    description="$(state_get "$sf" PROJECT_DESCRIPTION)"
    total="$(state_get "$sf" TOTAL_STEPS)"

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
            title="Copy common scaffolding files"
            body=$(cat <<EOF
mkdir -p "$target/.github/workflows" "$target/docs" "$target/.claude"
cp "$SCAFFOLDING_SRC/.envrc" "$target/.envrc"
cp "$SCAFFOLDING_SRC/.github/workflows/deploy-docs.yml" "$target/.github/workflows/deploy-docs.yml"
cp "$SCAFFOLDING_SRC/docs/package.json" "$target/docs/package.json"
cp -r "$SCAFFOLDING_SRC/.claude/." "$target/.claude/"
sed -i "s/PROJECT_NAME/$project_name/g" "$target/docs/package.json"
# Do NOT copy .cargo/, .githooks/pre-commit, or ci.yml — this template has no
# code artifacts to lint/build/test. .gitignore is created fresh in step 4.
EOF
)
            ;;
        3)
            title="Create flake.nix"
            body=$(cat <<EOF
Write $target/flake.nix:

{
  description = "$project_name - $description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.\${system}; in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ bun ];
        };
      });
}
EOF
)
            ;;
        4)
            title="Create .gitignore"
            body=$(cat <<EOF
Write $target/.gitignore:

# Node
node_modules/
docs/.vitepress/cache/
docs/.vitepress/dist/

# Nix
result
.direnv/

# Secrets
.envrc.local

# IDE
.idea/
.vscode/
*.swp

# Agent worktrees (temporary, never tracked)
.claude/worktrees/

# Normalize
.normalize/*
!.normalize/config.toml
!.normalize/duplicate-functions-allow
!.normalize/duplicate-types-allow
!.normalize/hotspots-allow
!.normalize/large-files-allow
!.normalize/memory/
EOF
)
            ;;
        5)
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
        6)
            title="Install docs dependencies"
            body=$(cat <<EOF
cd "$target/docs" && bun install
EOF
)
            ;;
        7)
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
        8)
            title="Run harness propagation"
            body=$(cat <<EOF
"$GITHUB_IO/tooling/propagate-harness.sh" "$target"
EOF
)
            ;;
        9)
            title="Add to propagation lists"
            body=$(cat <<EOF
grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients.txt" || echo "$org/$project_name" >> "$GITHUB_IO/tooling/skill-recipients.txt"
if [ "$org" = "rhi-zone" ]; then
    grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients-rhizone.txt" || echo "$org/$project_name" >> "$GITHUB_IO/tooling/skill-recipients-rhizone.txt"
fi
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
gh repo edit "$org/$project_name" --add-topic documentation
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

print_step_static() {
    sf="$1"; n="$2"
    target="$(state_get "$sf" TARGET)"
    org="$(state_get "$sf" ORG)"
    org_dir="$(state_get "$sf" ORG_PATH)"
    project_name="$(state_get "$sf" PROJECT_NAME)"
    description="$(state_get "$sf" PROJECT_DESCRIPTION)"
    total="$(state_get "$sf" TOTAL_STEPS)"

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
            title="Copy common scaffolding files"
            body=$(cat <<EOF
mkdir -p "$target/.claude"
cp "$SCAFFOLDING_SRC/.envrc" "$target/.envrc"
cp -r "$SCAFFOLDING_SRC/.claude/." "$target/.claude/"
# No CI workflow, no docs deploy workflow, no docs/ tree — this is a plain
# static site with no build step.
EOF
)
            ;;
        3)
            title="Create flake.nix"
            body=$(cat <<EOF
Write $target/flake.nix:

{
  description = "$project_name - $description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.\${system}; in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ bun ];
        };
      });
}
EOF
)
            ;;
        4)
            title="Create .gitignore"
            body=$(cat <<EOF
Write $target/.gitignore:

# Nix
result
.direnv/

# Agent worktrees (temporary, never tracked)
.claude/worktrees/

# Normalize
.normalize/*
!.normalize/config.toml
!.normalize/duplicate-functions-allow
!.normalize/duplicate-types-allow
!.normalize/hotspots-allow
!.normalize/large-files-allow
!.normalize/memory/
EOF
)
            ;;
        5)
            title="Create index.html"
            body=$(cat <<EOF
Write $target/index.html — a minimal, self-contained HTML5 page:
  - <title>$project_name</title>
  - A short visible heading/body reflecting "$description"
  - No external framework or build step; inline any minimal CSS needed
EOF
)
            ;;
        6)
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
        7)
            title="Run harness propagation"
            body=$(cat <<EOF
"$GITHUB_IO/tooling/propagate-harness.sh" "$target"
EOF
)
            ;;
        8)
            title="Add to propagation lists"
            body=$(cat <<EOF
grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients.txt" || echo "$org/$project_name" >> "$GITHUB_IO/tooling/skill-recipients.txt"
if [ "$org" = "rhi-zone" ]; then
    grep -q "$org/$project_name" "$GITHUB_IO/tooling/skill-recipients-rhizone.txt" || echo "$org/$project_name" >> "$GITHUB_IO/tooling/skill-recipients-rhizone.txt"
fi
EOF
)
            ;;
        9)
            title="Add README pointer to CLAUDE.md"
            body=$(cat <<EOF
Below the <!-- END ECOSYSTEM RULES --> marker in $target/CLAUDE.md, add:

Project goals and design context: [README.md](README.md)
EOF
)
            ;;
        10)
            title="direnv allow"
            body=$(cat <<EOF
cd "$target" && direnv allow
EOF
)
            ;;
        11)
            title="Initial commit"
            body=$(cat <<EOF
cd "$target"
git add -A
git commit -m "Initial scaffold for $project_name"
EOF
)
            ;;
        12)
            title="Create GitHub repo"
            body=$(cat <<EOF
gh repo create "$org/$project_name" --public --source "$target" --description "$description" --push
gh repo edit "$org/$project_name" --homepage "https://docs.rhi.zone/$project_name/"
# Add relevant topics as appropriate for the project domain.
EOF
)
            ;;
        13)
            title="Enable GitHub Pages"
            body=$(cat <<EOF
gh api "repos/$org/$project_name/pages" -X POST -f "source[branch]=master" -f "source[path]=/"
EOF
)
            ;;
        14)
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

Templates: rust, bun, godot, docs, static
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
