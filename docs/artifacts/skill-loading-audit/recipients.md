# Skill-Propagation Recipient Audit

**Date:** 2026-06-16
**Purpose:** Enumerate all ecosystem repos that are (or should be) skill-propagation recipients, their current `.claude/commands/` inventories, git cleanliness, and per-repo seeding targets for the 5 stranded skills.

## Methodology

- **Source A:** project table in `docs/about.md` + referenced disk paths
- **Source B:** filesystem scan of `~/git/*/` for git repos containing `.claude/commands/`
- Commands used: `git ls-files .claude/commands/` (committed skills only), `git status --porcelain`
- Repos with `.claude/` but no `commands/` subdirectory are listed as NO_COMMANDS and are NOT current recipients.

## Stranded Skills Under Seeding Policy

The 5 skills to be seeded:

| Skill | Target Orgs |
|-------|-------------|
| `survey-open-threads` | ALL recipient repos |
| `think-with-the-engineering-taste` | ALL recipient repos |
| `design-an-interface` | rhi-zone developer-substrate repos ONLY |
| `domain-model` | rhi-zone developer-substrate repos ONLY |
| `improve-codebase-architecture` | rhi-zone developer-substrate repos ONLY |

## Hub Repo (Not a Recipient)

| Repo | Path | Status | Current `.claude/commands/` skills |
|------|------|--------|-----------------------------------|
| **github-io** | `~/git/rhizone/github-io` | DIRTY (untracked `.claude/commands/`, `tooling/claude-commands/think-with-the-engineering-taste.md`) | *(none committed — symlink-based)* |

Notes: github-io is the hub/source. Its `.claude/commands/` is untracked (symlink target). Being transformed separately; not a normal recipient.

---

## Recipient Repos

Legend for "Existing Skills" column — abbreviations used:
- `D2` = `design-it-twice.md`
- `HO` = `handoff.md`
- `PO` = `polish.md`
- `SUM` = `SUMMARY.md` (normalize-specific)
- `CHR` = `character.md` (para-garden worldbuilding skill)
- `BS` = `build-stage.md`
- `DS` = `design-stage.md`

Legend for "Skills to Seed" column:
- `SOT` = `survey-open-threads`
- `TWET` = `think-with-the-engineering-taste`
- `DAI` = `design-an-interface`
- `DM` = `domain-model`
- `ICA` = `improve-codebase-architecture`

### rhi-zone repos

All rhi-zone repos are developer-substrate repos and receive all 5 stranded skills.

| Repo | Path | Clean/Dirty | Existing `.claude/commands/` | Skills to Seed | Notes |
|------|------|-------------|------------------------------|----------------|-------|
| concord | `~/git/rhizone/concord` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| crescent | `~/git/rhizone/crescent` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| defocus | `~/git/rhizone/defocus` | DIRTY | D2, HO, PO | SOT, TWET, DAI, DM, ICA | dirty: normalize cache/index files |
| deskspace | `~/git/rhizone/deskspace` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| dusklight | `~/git/rhizone/dusklight` | CLEAN | HO, PO | SOT, TWET, DAI, DM, ICA | missing D2 — already a gap |
| gels | `~/git/rhizone/gels` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| interconnect | `~/git/rhizone/interconnect` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| moonlet | `~/git/rhizone/moonlet` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| motif | `~/git/rhizone/motif` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| myenv | `~/git/rhizone/myenv` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| nanites | `~/git/rhizone/nanites` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| normalize | `~/git/rhizone/normalize` | CLEAN | SUM, D2, HO, PO | SOT, TWET, DAI, DM, ICA | has extra SUMMARY.md |
| paraphase | `~/git/rhizone/paraphase` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| playmate | `~/git/rhizone/playmate` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| portals | `~/git/rhizone/portals` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| rainbow | `~/git/rhizone/rainbow` | CLEAN | HO, PO | SOT, TWET, DAI, DM, ICA | missing D2 — already a gap |
| reincarnate | `~/git/rhizone/reincarnate` | CLEAN | *(none — no commands/ dir)* | SOT, TWET, DAI, DM, ICA | has `.claude/` (settings) but NO commands dir — needs init |
| rescribe | `~/git/rhizone/rescribe` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| scribble | `~/git/rhizone/scribble` | DIRTY | HO, PO | SOT, TWET, DAI, DM, ICA | dirty: untracked TODO.md; missing D2 |
| server-less | `~/git/rhizone/server-less` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| sketchpad | `~/git/rhizone/sketchpad` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | external/related repo, in rhi-zone |
| tiltshift | `~/git/rhizone/tiltshift` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| unshape | `~/git/rhizone/unshape` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| wick | `~/git/rhizone/wick` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |
| zone | `~/git/rhizone/zone` | CLEAN | D2, HO, PO | SOT, TWET, DAI, DM, ICA | — |

**rhi-zone repos with NO `.claude/commands/` (not current recipients — no commands dir found):**

| Repo | Path | Clean/Dirty | Notes |
|------|------|-------------|-------|
| profile | `~/git/rhizone/profile` | CLEAN | org GitHub config — likely not a dev-work target |
| rhi.zone | `~/git/rhizone/rhi.zone` | CLEAN | static assets / Cloudflare Pages |
| fractal | `~/git/rhizone/fractal` | CLEAN | not documented in about.md |
| marinada | `~/git/rhizone/marinada` | CLEAN | not documented in about.md |
| github-io | `~/git/rhizone/github-io` | DIRTY | hub — treated separately |

### exo-place repos

exo-place repos are end-user-substrate repos. Receive only `survey-open-threads` + `think-with-the-engineering-taste`.

| Repo | Path | Clean/Dirty | Existing `.claude/commands/` | Skills to Seed | Notes |
|------|------|-------------|------------------------------|----------------|-------|
| aeriea | `~/git/exoplace/aeriea` | CLEAN | D2, HO, PO | SOT, TWET | end-user substrate |
| aspect | `~/git/exoplace/aspect` | CLEAN | D2, HO, PO | SOT, TWET | end-user substrate |
| hologram | `~/git/exoplace/hologram` | CLEAN | D2, HO, PO | SOT, TWET | end-user substrate |
| noncanon | `~/git/exoplace/noncanon` | CLEAN | D2, HO, PO | SOT, TWET | end-user substrate |

**exo-place repos with NO `.claude/commands/`:**

| Repo | Path | Clean/Dirty | Notes |
|------|------|-------------|-------|
| exo.place | `~/git/exoplace/exo.place` | CLEAN | redirect/static assets |
| github-io | `~/git/exoplace/github-io` | CLEAN | docs site |
| profile | `~/git/exoplace/profile` | CLEAN | org GitHub config |

### para-garden repos

para-garden holds concrete finished works. Receive only `survey-open-threads` + `think-with-the-engineering-taste`.

| Repo | Path | Clean/Dirty | Existing `.claude/commands/` | Skills to Seed | Notes |
|------|------|-------------|------------------------------|----------------|-------|
| divergence | `~/git/paragarden/divergence` | CLEAN | CHR | SOT, TWET | worldbuilding project |
| existence | `~/git/paragarden/existence` | CLEAN | D2, HO, PO | SOT, TWET | game |
| legacy | `~/git/paragarden/legacy` | CLEAN | CHR | SOT, TWET | worldbuilding project |
| postmortem | `~/git/paragarden/postmortem` | CLEAN | CHR | SOT, TWET | worldbuilding project |
| solarium | `~/git/paragarden/solarium` | DIRTY | HO, PO | SOT, TWET | dirty: untracked TODO.md, maybe-rules.md |

**para-garden repos with NO `.claude/commands/`:**

| Repo | Path | Clean/Dirty | Notes |
|------|------|-------------|-------|
| github-io | `~/git/paragarden/github-io` | CLEAN | docs site |
| profile | `~/git/paragarden/profile` | DIRTY | dirty: staged flake.lock; org GitHub config |

### ptera-world repos

ptera-world: personal projects. Receive only `survey-open-threads` + `think-with-the-engineering-taste`.

| Repo | Path | Clean/Dirty | Existing `.claude/commands/` | Skills to Seed | Notes |
|------|------|-------------|------------------------------|----------------|-------|
| annotated-law | `~/git/pteraworld/annotated-law` | CLEAN | D2, HO, PO | SOT, TWET | — |

### pterror repos

pterror: personal/user-account work (data corpora, playgrounds, experiments). Receive only `survey-open-threads` + `think-with-the-engineering-taste`.

| Repo | Path | Clean/Dirty | Existing `.claude/commands/` | Skills to Seed | Notes |
|------|------|-------------|------------------------------|----------------|-------|
| chub-stage-factory | `~/git/pterror/chub-stage-factory` | CLEAN | BS, DS | SOT, TWET | domain-specific skills; not rhi-zone |
| matrix-gen | `~/git/pterror/matrix-gen` | CLEAN | D2, HO, PO | SOT, TWET | — |

**pterror repos with NO `.claude/commands/`:**

| Repo | Path | Clean/Dirty | Notes |
|------|------|-------------|-------|
| ashwren | `~/git/pterror/ashwren` | DIRTY | dirty: brain/heartbeat-state.json, session.lock |
| fuwafuwa | `~/git/pterror/fuwafuwa` | DIRTY | dirty: .claude/worktrees/agent-a9d9eb96f24f320d4 |
| software-taxonomy | `~/git/pterror/software-taxonomy` | CLEAN | data corpus |
| statosphere-guide | `~/git/pterror/statosphere-guide` | CLEAN | not currently a recipient |
| statosphere-studio | `~/git/pterror/statosphere-studio` | CLEAN | not currently a recipient |

---

## Summary Counts

### Repos currently in skill-propagation (have `.claude/commands/`)

| Category | Count |
|----------|-------|
| rhi-zone (dev substrate) | 25 |
| exo-place | 4 |
| para-garden | 5 |
| ptera-world | 1 |
| pterror | 2 |
| **Total recipients** | **37** |

(Excluding github-io hub.)

### Clean vs Dirty among recipients

| Status | Count | Repos |
|--------|-------|-------|
| CLEAN | 33 | Can receive changes directly |
| DIRTY | 4 | Must defer to TODO.md: defocus (normalize cache), scribble (untracked TODO.md), solarium (untracked TODO.md + maybe-rules.md), *(all others clean)* |

Wait — re-counting dirty recipients:
- defocus: DIRTY
- scribble: DIRTY
- solarium: DIRTY

That's 3 dirty recipients out of 37 total (34 clean).

| Status | Count |
|--------|-------|
| CLEAN | 34 |
| DIRTY | 3 (defocus, scribble, solarium) |

### rhi-zone vs non-rhi-zone recipient split

| Category | Count |
|----------|-------|
| rhi-zone (all 5 skills) | 25 |
| non-rhi-zone (SOT + TWET only) | 12 |

### Repos needing `.claude/commands/` init before receiving skills

These repos are tracked in the ecosystem but have no `commands/` directory:

| Repo | Org | Notes |
|------|-----|-------|
| reincarnate | rhi-zone | CLEAN; has `.claude/settings.json`; just needs `commands/` dir |
| rhi.zone | rhi-zone | CLEAN; static assets — lower priority |
| fractal | rhi-zone | CLEAN; undocumented in about.md |
| marinada | rhi-zone | CLEAN; undocumented in about.md |

---

## Gap Notes

- **dusklight, rainbow, scribble**: missing `design-it-twice.md` vs the rhi-zone majority baseline — pre-existing gap, not introduced by this rollout.
- **reincarnate**: the only actively-developed rhi-zone project repo without any commands — should be init'd as part of rollout.
- **normalize**: has an extra `SUMMARY.md` — repo-specific, leave in place.
- **chub-stage-factory**: has bespoke `build-stage.md` + `design-stage.md` — repo-specific, leave in place.
- **divergence / legacy / postmortem**: have bespoke `character.md` — worldbuilding-specific, leave in place.
- **exo-place `github-io`**, **para-garden `github-io`**, **rhi-zone `profile`/`rhi.zone`**: no `commands/` and are org infrastructure (docs sites, static assets, org profiles) — not development-target repos, exclude from propagation list.
