# rhi Ecosystem Rename – Execution Checklist

Agent-executable checklist for the rhizome → rhi ecosystem migration.
This augments the checklist in NAMING.md with detailed technical validation steps.

## ⚠️ Critical Caveats

**This repo (rhizome-lab-github-io):**
- ✅ DO rename on GitHub (`gh repo rename`)
- ✅ DO update content inside (docs, README, etc.)
- ❌ DON'T `mv` the local folder (we're currently working in it!)
- ❌ DON'T rename ~/.claude/projects/rhizome-lab-github-io

**All other repos:**
- ✅ DO `mv ~/git/old-name ~/git/new-name`
- ✅ DO rename ~/.claude/projects/* entries
- ✅ DO rename on GitHub

## Pre-flight

- [ ] Tag all repos (`pre-rhi-rename`) for rollback safety
- [ ] Snapshot repo list + current names + current orgs
- [ ] Final review of NAMING-SUMMARY.md
- [ ] Identify repos needing org transfer (currently under pterror or other orgs)

## Repo & Org Ops

### Repos Under Different Orgs (Transfer First)
- [ ] Transfer burn-models (→ sketchpad) if not already in rhizome-lab
  - [ ] Via GitHub web UI: Settings → Transfer ownership → rhi-zone
  - [ ] OR via API: `gh api repos/{owner}/burn-models/transfer -f new_owner=rhi-zone`
  - [ ] Wait for transfer confirmation
- [ ] Transfer rescribe if not already in rhizome-lab (part of ecosystem - document unification)
- [ ] Note: ooxml and claude-code-hub remain external (not part of rhi ecosystem)

### All Repos (Rename)
- [ ] Execute `gh repo rename` for all repos in rhi-zone org
- [ ] **THIS REPO**: `gh repo rename rhizome-lab-github-io rhi-docs` (or chosen name)
  - DON'T mv the local folder!
- [ ] **OTHER REPOS**: `mv ~/git/old-name ~/git/new-name` for each
- [ ] Update all git remotes in local checkouts
- [ ] Update org README + pinned repos
- [ ] Update ~/.claude/projects/ directory names (EXCEPT rhizome-lab-github-io)

## Code Changes (Per Repo)

### Cargo Configuration
- [ ] Update `Cargo.toml` (workspace root + all crates):
  - [ ] `name` (rhizome- → rhi- prefix)
  - [ ] `repository` URL
  - [ ] `homepage` URL
  - [ ] `documentation` URL
- [ ] Update internal imports (use statements, mod paths)
- [ ] Update feature flags (crate name references)
- [ ] Update git deps (repo URLs in Cargo.toml)

### Tooling & CI
- [ ] Update CI configs (`.github/workflows`)
- [ ] Update tooling configs:
  - [ ] `flake.nix` (description, repo URLs)
  - [ ] `justfile` / `Makefile`
  - [ ] `.cargo/config.toml`
  - [ ] VitePress config (`docs/.vitepress/config.ts`)

### Documentation
- [ ] Update `README.md` (project name, links, badges)
- [ ] Update `CLAUDE.md` (project context, paths)
- [ ] Update docs content (VitePress sites where applicable)

## Ecosystem Docs (rhizome-lab-github-io)

- [ ] Rename all project references:
  - [ ] `docs/about.md`
  - [ ] `docs/projects/*`
  - [ ] `README.md`
  - [ ] `CLAUDE.md` (project table, paths)
- [ ] Update `.vitepress/config.ts` navigation
- [ ] Update `docs/index.md` hero features
- [ ] Rename org references (rhizome-lab → rhi-zone)

## Org-Wide GitHub Config

- [ ] Update `~/git/rhizome-lab-github/` (org config repo):
  - [ ] README.md
  - [ ] Issue/PR templates
  - [ ] Org profile

## Validation

### Search Sweep
- [ ] `rg rhizome-lab` (should only be historical references)
- [ ] `rg rhizome-` (catch stray prefixes)
- [ ] `rg` for each old project name (Moss, Canopy, Spore, etc.)

### Build Integrity
- [ ] `cargo build` all workspaces
- [ ] `cargo metadata` (check dependency graph consistency)
- [ ] `cargo clippy` passes
- [ ] `cargo test` passes (where applicable)

### CI & Deployment
- [ ] CI passes for all repos
- [ ] Docs sites deploy correctly
  - [ ] Main ecosystem docs (rhizome-lab-github-io)
  - [ ] Per-project docs (moss, spore, etc.)

### Git Infrastructure
- [ ] Git remotes point to rhi-zone org
- [ ] GitHub Actions secrets/vars still accessible
- [ ] Branch protection rules intact

## Final Steps

- [ ] Create old→new name mapping doc (for reference)
- [ ] Commit + push all repos
- [ ] Verify all docs sites live
- [ ] Update external references (if any):
  - [ ] Social media / announcements
  - [ ] External docs linking to projects

---

**Note**: This ecosystem does NOT publish to crates.io. All validation stops at build/test/CI - no publication steps needed.

## Rollback Plan

If issues arise:
1. Git tags (`pre-rhi-rename`) allow reverting code changes
2. `gh repo rename` can be reversed
3. Docs deployments can be rolled back via git

## See Also

- `NAMING.md` - Original checklist (lines 376-416)
- `NAMING-SUMMARY.md` - Complete naming decisions and rationale
