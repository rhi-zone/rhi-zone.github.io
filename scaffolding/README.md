# Scaffolding Templates

Standard files for new repos in the rhi ecosystem.

## Current tool: `tooling/scaffold.sh`

`tooling/scaffold.sh` is the current, stateful scaffolding tool and should be used instead
of the manual copy/sed walkthrough further down (that walkthrough predates the script and
only ever covered the Rust case — the script supersedes it and also covers templates the
walkthrough never did, notably Godot). Run it via a subagent (Sonnet, general-purpose) —
these commands cannot run in the main session.

```bash
tooling/scaffold.sh init <template> <org> <project-name> <description>
tooling/scaffold.sh next [target-dir]     # print the next unfinished step's instructions
tooling/scaffold.sh status [target-dir]   # show progress
```

Templates: `rust` (Cargo workspace + VitePress docs), `bun` (ESM monorepo w/ bun
workspaces + VitePress docs), `godot` (Godot 4 project — `flake.nix` with `godot_4`,
`project.godot`, `scenes/`/`scripts/`/`assets/`/`tests/` dirs, Godot-appropriate
`.gitignore`, VitePress docs), `docs` (writing/documentation-only, VitePress, no code
artifacts), `static` (minimal static HTML site, no build step).

Orgs: `rhi-zone`, `exo-place`, `ptera-world`, `para-garden`, `pterror` — mapped to disk
paths per the table at the bottom of this doc.

State lives in `<target>/SCAFFOLD.state` (key=value; not gitignored, so its presence in
`git status` is the visible "scaffolding in progress" signal). Each `next` invocation
probes the filesystem/git state each step should have produced, silently advances past any
already-done steps, then prints the next unfinished step's instructions and exits — an
agent drives it by repeatedly running `next` and executing what it prints. The final step
of every template deletes `SCAFFOLD.state`. Idempotent to resume: re-running `next` after
an interruption picks up exactly where it left off.

Every template's step sequence ends the same way: fill in README.md, run
`tooling/propagate-harness.sh`, add the repo to the skill-recipients lists, `direnv allow`,
initial commit, `gh repo create --push`, enable GitHub Pages, clean up `SCAFFOLD.state`.

The reference material below (placeholders, file inventory, shared target-dir mechanism)
still describes what's inside `scaffolding/` and is accurate; the "Scaffolding New Repos"
walkthrough section is superseded by the script for the cases it covers.

## Files Included

| File | Purpose |
|------|---------|
| `.cargo/config.toml` | Target bloat reduction, mold linker hint, shared `target-dir` across worktrees |
| `.envrc` | direnv + nix-direnv integration |
| `.gitignore` | Standard ignores for Rust + Nix + Node |
| `.githooks/pre-commit` | fmt → clippy (fast checks first) |
| `.github/workflows/ci.yml` | CI: fmt, clippy, build, test |
| `.github/workflows/deploy-docs.yml` | VitePress docs to GitHub Pages |
| `flake.nix` | Nix dev shell with Rust + mold + bun |
| `docs/package.json` | VitePress with mermaid plugin |
| `README.md` | Project README template |

### Shared target-dir across worktrees

`.cargo/config.toml` sets `[build] target-dir = "target"`, which Cargo resolves relative
to the main checkout root (the parent of the `.cargo` directory holding the file). Agent
worktrees live nested inside the main checkout at `.claude/worktrees/<id>/`, so Cargo's
ancestor-directory config search finds the main checkout's `.cargo/config.toml` from any
worktree too — every worktree of a repo builds into the same `target/` in the main
checkout instead of each accumulating its own multi-GB copy. This is per-repo sharing
(worktrees of the *same* repo share one `target/`), not cross-repo. Cargo's build-directory
locking makes concurrent builds against the shared dir safe — they serialize rather than
corrupt, just with reduced parallelism across concurrent agents/worktrees. See the comment
in `.cargo/config.toml` for the mechanism; `CARGO_TARGET_DIR` overrides it per-shell if
ever needed.

## Placeholders

- `PROJECT_NAME` — lowercase project name (e.g., `interconnect`)
- `PROJECT_DESCRIPTION` — short description

## Scaffolding New Repos (manual walkthrough, superseded — see `tooling/scaffold.sh` above)

Copy and substitute placeholders. Run via a subagent (Sonnet, general-purpose) — these commands cannot run in the main session.

```bash
cp -r ~/git/0000000_pterror/.git ~/git/rhizone/new-project/.git
cp -r scaffolding/. ~/git/rhizone/new-project/
sed -i 's/PROJECT_NAME/new-project/g' ~/git/rhizone/new-project/flake.nix ~/git/rhizone/new-project/docs/package.json
sed -i 's/PROJECT_DESCRIPTION/Description here/g' ~/git/rhizone/new-project/flake.nix
```

Copy git from `~/git/0000000_pterror` (template repo with proper history/config). Do NOT use `git init`.

Manual steps after copy:
- Create `Cargo.toml` workspace with a dummy crate (`crates/PROJECT_NAME-core/`) so the pre-commit hook (cargo fmt + clippy) passes on first commit.
- Create `docs/.vitepress/config.ts` + `docs/index.md` (required for VitePress build in pre-commit hook).
- Run `bun install` in `docs/` before first commit — hook runs `vitepress build`, needs node_modules.
- Confirm `.envrc` and `flake.nix` were copied (easy to miss). `.envrc` sources `.envrc.local` (gitignored) — secrets go there, never in `.envrc`.
- Fill in `README.md` with the project's goals and motivating use cases: why the project exists, what it's for, key design decisions. The scaffolding conversation is not accessible from inside the new repo.
- Run `tooling/propagate-harness.sh ~/git/ORG_PATH/new-project` to install `CLAUDE.md` (ecosystem region + behavioral hooks) and wire `.claude/settings.json`.
- In the repo-local section of the new `CLAUDE.md` (below the `END ECOSYSTEM RULES` marker), add a pointer to the README, e.g. `Project goals and design context: [README.md](README.md)`.
- Optionally add `TODO.md` with initial directions.

## Creating the GitHub Repo

Run via a subagent (Sonnet, general-purpose).

```bash
gh repo create ORG/PROJECT_NAME --public --source ~/git/ORG_PATH/PROJECT_NAME --description "PROJECT_DESCRIPTION" --push
gh repo edit ORG/PROJECT_NAME --homepage "https://docs.rhi.zone/PROJECT_NAME/"
gh repo edit ORG/PROJECT_NAME --add-topic rust --add-topic TOPIC1 --add-topic TOPIC2
```

Enable GitHub Pages (if the repo has a docs site):
```bash
gh api repos/ORG/PROJECT_NAME/pages -X POST -f "build_type=workflow"
```

After updating ecosystem docs:
```bash
cd ~/git/rhizone/github-io && git push
cd ~/git/rhizone/profile && git push
```

## Renaming Repos

Run via a subagent (Sonnet, general-purpose).

1. `gh repo rename NEW_NAME -R ORG/OLD_NAME --yes`
2. `git remote set-url origin https://github.com/ORG/NEW_NAME.git`
3. `mv ~/git/ORG_PATH/OLD_NAME ~/git/ORG_PATH/NEW_NAME`
4. `mv ~/.claude/projects/-home-me-git-ORG_PATH-OLD_NAME ~/.claude/projects/-home-me-git-ORG_PATH-NEW_NAME`
5. `gh repo edit ORG/NEW_NAME --homepage "..." --description "..."`
6. Update in-repo references (site config, package.json, CLAUDE.md, README).
7. Update ecosystem docs (CLAUDE.md, org profile).

## GitHub Org Mapping

| Org (GitHub) | Disk Path | Domain |
|--------------|-----------|--------|
| **rhi-zone** | `~/git/rhizone/` | infrastructure, tooling, libraries, protocols |
| **exo-place** | `~/git/exoplace/` | biomes, places, platforms |
| **ptera-world** | `~/git/pteraworld/` | personal projects |
| **para-garden** | `~/git/paragarden/` | concrete games, experiences, creative works |
