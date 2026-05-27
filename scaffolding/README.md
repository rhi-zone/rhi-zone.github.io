# Scaffolding Templates

Standard files for new Rust monorepos in the rhi ecosystem.

## Files Included

| File | Purpose |
|------|---------|
| `.cargo/config.toml` | Target bloat reduction, mold linker hint |
| `.envrc` | direnv + nix-direnv integration |
| `.gitignore` | Standard ignores for Rust + Nix + Node |
| `.githooks/pre-commit` | fmt → clippy (fast checks first) |
| `.github/workflows/ci.yml` | CI: fmt, clippy, build, test |
| `.github/workflows/deploy-docs.yml` | VitePress docs to GitHub Pages |
| `flake.nix` | Nix dev shell with Rust + mold + bun |
| `docs/package.json` | VitePress with mermaid plugin |
| `CLAUDE.md` | Project-specific Claude instructions template |
| `README.md` | Project README template |

## Placeholders

- `PROJECT_NAME` — lowercase project name (e.g., `interconnect`)
- `PROJECT_DESCRIPTION` — short description

## Scaffolding New Repos

Copy and substitute placeholders. Run via a subagent (Sonnet, general-purpose) — these commands cannot run in the main session.

```bash
cp -r ~/git/0000000_pterror/.git ~/git/rhizone/new-project/.git
cp -r scaffolding/. ~/git/rhizone/new-project/
sed -i 's/PROJECT_NAME/new-project/g' ~/git/rhizone/new-project/flake.nix ~/git/rhizone/new-project/docs/package.json ~/git/rhizone/new-project/CLAUDE.md
sed -i 's/PROJECT_DESCRIPTION/Description here/g' ~/git/rhizone/new-project/flake.nix ~/git/rhizone/new-project/CLAUDE.md
```

Copy git from `~/git/0000000_pterror` (template repo with proper history/config). Do NOT use `git init`.

Manual steps after copy:
- Create `Cargo.toml` workspace with a dummy crate (`crates/PROJECT_NAME-core/`) so the pre-commit hook (cargo fmt + clippy) passes on first commit.
- Create `docs/.vitepress/config.ts` + `docs/index.md` (required for VitePress build in pre-commit hook).
- Run `bun install` in `docs/` before first commit — hook runs `vitepress build`, needs node_modules.
- Confirm `.envrc` and `flake.nix` were copied (easy to miss). `.envrc` sources `.envrc.local` (gitignored) — secrets go there, never in `.envrc`.
- Fill in CLAUDE.md `## Origin` section: why the project exists, naming rationale, key design decisions. The scaffolding conversation is not accessible from inside the new repo.
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
