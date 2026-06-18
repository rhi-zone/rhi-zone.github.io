# CLAUDE.md

Behavioral rules for Claude Code in the rhi ecosystem docs repository.

## Ecosystem

Project list, paths, and descriptions live in [docs/about.md](docs/about.md). When the ecosystem changes, update both.

## Responsibilities

### Ecosystem-Wide Refactors

1. Check git status of all affected repos.
2. Clean repos: make the changes directly.
3. Dirty repos: add to that repo's TODO.md.
4. Use conventional commits with scope indicating affected projects.

Propagate `.claude/commands/` skills across the ecosystem:

```bash
~/git/rhizone/github-io/tooling/sync-skills.sh [--check] [--prune] [--no-push]
```

**Canonical skill location: github-io's own committed `.claude/commands/`** — one
directory, two roles. It is *both* the ecosystem's authoring source of truth *and*
github-io's own harness load path (project scope). Editing a committed file there is
immediately live for github-io with no symlink. github-io is NOT special: like every
receiver, it loads its skills from committed in-repo files. There is no
`tooling/claude-commands/` warehouse (retired) and no `~/.claude` copy.

`sync-skills.sh` reads bytes only from this committed dir (git-tracked files only —
an untracked file is never distributed) and fans them out to the recipients listed in:
- `tooling/skill-recipients.txt` — all 37 recipient repos (baseline + cross-cutting skills)
- `tooling/skill-recipients-rhizone.txt` — rhi-zone dev-substrate subset (also gets dev-tier skills)
- `tooling/skill-tiers.txt` — per-skill tier (`all` | `dev`); a skill absent here is hub-only

It is idempotent/convergent, skips dirty receivers FIRST (no mutation of a dirty tree —
those get a TODO.md line), is non-destructive by default (orphans reported; removed only
under `--prune`), runs `normalize init`, commits, and pushes clean repos. `--check` is a
dry-run drift report (stale/missing/orphan) that exits non-zero — a CI/`/loop` guard.

**FORBIDDEN: never create a `~/.claude/commands/` or `~/.claude/skills/` entry for an
ecosystem skill.** `~/.claude` is global-by-construction with personal-over-project
precedence, so a single such entry shadows the committed copy of *every* repo you ever
open — not just github-io's. That is exactly the defect this redesign removed. Skills
live only in each repo's committed `.claude/commands/`. No `link-skills` helper exists.

<!-- FENCED FUTURE STEP — do NOT start until R1–R4 of the skill-loading redesign land
     and stabilize (see docs/artifacts/skill-loading-audit/synthesis.md §Resolution 3). -->
> **Fenced follow-up: migrate `.claude/commands/<name>.md` → `.claude/skills/<name>/SKILL.md`.**
> Orthogonal to the correctness fix; deliberately deferred. When taken: convert each skill
> to the modern directory-per-skill format (front-matter `SKILL.md`), load-test each
> converted skill before deleting its legacy `commands/` file, do it as its own
> commit-per-repo ecosystem refactor, and defer dirty repos to their TODO.md. Until then the
> ecosystem stays on flat `.claude/commands/*.md` (with the few directory-shaped skills
> tolerated as-is). Do not half-migrate: a mixed `commands/`+`skills/` ecosystem is the
> failure mode this fence exists to prevent.

### Keeping Docs in Sync

When projects change, update:
- `docs/projects/` pages
- `docs/about.md` project table
- `README.md` project table
- `.vitepress/config.ts` sidebar/nav
- `docs/index.md` hero page features
- `docs/projects/index.md` project table
- `~/git/rhizone/profile/profile/README.md` (org profile)

### Scaffolding and Repo Operations

Scaffolding, repo creation, and rename procedures: see [scaffolding/README.md](scaffolding/README.md).

New repos get a CLAUDE.md by running the propagator (`tooling/propagate-harness.sh <target-repo>`) on a repo whose CLAUDE.md is missing the markers. The propagator syncs the ecosystem region between the `<!-- BEGIN ECOSYSTEM RULES -->` / `<!-- END ECOSYSTEM RULES -->` markers — *appending* the region if the markers are absent, *replacing* the region in place if they are present (convergent). It also installs/updates the behavioral hook files and wires `.claude/settings.json`. Append repo-specific rules below the `<!-- END ECOSYSTEM RULES -->` marker. (For an ecosystem-wide rollout, `tooling/propagate-harness-all.sh` discovers all marker-bearing repos and drives the per-repo propagator.)

### Control Surface & Harness Management

These rules govern github-io's role as the repo that edits the agent harness config, runs propagation, and coordinates the ecosystem. They are management policy — github-io acts on them; receiver repos only inherit propagated rules, so these stay out of the propagated region.

- No ecosystem changes without checking all affected repos.
- **Control surface stays self-contained and versioned.** Behavioral rules, hooks, and guidance live in-repo — versioned, diffable, propagatable. Never put them in the unversioned, machine-local `~/.claude/CLAUDE.md`; reach never justifies a non-self-contained home.
- **Permissions and secrets are the exception to self-containment — never committed, never global.** Self-containment governs the *behavioral* control surface (rules, hooks, skills); authority grants invert it on both axes. Not committed: a committed allow-list runs in every clone, turning the repo into literal malware that hands each contributor the access you granted yourself. Not global/user-level: a standing grant then fires in repos you don't own, where untrusted content abuses it (prompt-injected fetch → exfiltration). The only safe home is the gitignored, per-repo `.claude/settings.local.json` — this machine, these trusted repos; committed `settings.json` stays hooks/config only.
- **This is a PUBLIC repo: private project names must never appear in committed content** — including introspection logs, decisions, artifacts, and TODO. The names themselves are sensitive, so they live machine-local in a denylist at `.git/info/private-names` (one name per line, blank/`#` lines ignored; structurally uncommittable under `.git/`, and never staged). A committed, generic `.githooks/pre-commit` hook reads that denylist and aborts any commit whose staged content matches a listed name (the hook hardcodes no names). Maintain the denylist locally; new clones must run `git config core.hooksPath .githooks` once for the guard (and the existing build check) to fire.

### GitHub Org Mapping

| Org (GitHub) | Disk Path | Domain |
|--------------|-----------|--------|
| **rhi-zone** | `~/git/rhizone/` | substrates for developer/technical purposes (tooling, libraries, protocols, engines) |
| **exo-place** | `~/git/exoplace/` | substrates for end-user purposes (things end-users do or experience) |
| **ptera-world** | `~/git/pteraworld/` | personal projects |
| **para-garden** | `~/git/paragarden/` | concrete end-user works and artifacts (games, experiences, creative works) |
| **pterror** (personal account) | `~/git/pterror/` | personal / user-account work: data corpora, playgrounds, experiments, scratch |

The discriminator between rhi-zone and exo-place is **whose purpose the substrate serves**: developer/technical vs end-user. That exo-place's current members (aspect, hologram, noncanon) are entity/world systems is incidental, not definitional — any reusable substrate serving end-user purposes belongs in exo-place. para-garden holds concrete finished works; exo-place holds reusable substrates. Neither org houses raw data — personal / user-account work (data corpora, playgrounds, experiments, scratch) lives on **github:pterror** at `~/git/pterror/` (e.g. `software-taxonomy`, `math-playground`); do NOT place this work in ptera-world.

### Crate Naming Convention

Rust crates use NO prefix; names are available on crates.io:
- `normalize-core`, `moonlet-core`, `unshape-backend`
- `rescribe`, `server-less`, `wick` (standalone)
- Binary names match project names (`normalize`, `moonlet`, `rescribe`, `server-less`).

### Docs Site Conventions

Monorepo docs with their own site must include a navbar link back to rhi:

```ts
nav: [
  { text: 'rhi', link: 'https://rhi.zone/' },
]
```

**Describe projects by capability + maturity, never by volume or activity.** A project's
status block leads with a qualitative **maturity stage** (Idea / Sketch / Growing / In
Development / Fleshed Out / Potentially Mature — reuse the page's existing label) + an
**implemented-vs-planned** capability description + a **version, only if the project
genuinely versions**. Never report status via volume/activity metrics — lines of code,
file/crate/package counts, commit counts — or hardcoded dates (last-commit/last-active):
they rot per-commit and measure the projection (the codebase) rather than the project (its
capability). If liveness is genuinely wanted, *generate* it from the repo at build time;
do not write it into prose. (Decision: ADR-0288.)

## Activity Logs

- `docs/introspection/log/` — weekly snapshots, named by end date (e.g. `2026-02-25.md`). Read the most recent first when evaluating direction or focus.
- `docs/introspection/log/daily/` — daily session summaries, `YYYY-MM-DD.md`, one day across all projects.
- `docs/introspection/log/synthesis-*.md` — cross-cutting pattern analysis over a date range.

Check these before asking "what should we work on?" or "what were we focused on?"

Daily log updates and session analysis: see [docs/introspection/README.md](docs/introspection/README.md).

<!-- BEGIN ECOSYSTEM RULES -->

## Ecosystem Design Principles

Cross-cutting principles distilled from the ecosystem's own decisions (synthesized in `docs/decisions/throughlines.md`). Apply them when building new repos and recording decisions. (Already-encoded principles — independent-tools / no-path-deps, the delegation model, CLAUDE.md-as-control-surface — live in their own sections and are not repeated here.)

- **Prefer data over code at a seam — where a faithful serialization is actually viable.** Serializable AST / struct / JSON over closures, embedded DSLs, or source text, so artifacts cache, replay, transport, and diff. The preference is conditional, not absolute: when a seam carries irreducibly heterogeneous, one-off glue whose only data form is a leaky lowest-common-denominator schema (or a "descriptor" that just wraps a closure), a code seam is the honest choice. Push to data where the representation stays faithful; don't force it where it doesn't.
- **Library-first; projection-from-one-definition.** The typed library is the source of truth; CLI / HTTP / MCP / WebSocket / JSON surfaces are generated projections, never hand-rolled per surface.
- **Capability security.** Hosts grant pre-opened handles; code only attenuates what it is given; nothing forges authority; allow-list over deny-list.
- **The LLM is an oracle at the leaves, never the control loop.** Determinism is a hard invariant: seeded RNG, event-log replay, build-time-only inference. Per-query LLM in the hot loop is a defect.
- **Trust comes from verifiable evidence, not authority.** Verbatim snippets, pinned-commit permalinks, claim→node citation — never a bare reference.
- **Retire, don't deprecate; collapse asymmetries to primitives.** Remove backward-compat aliases rather than carry them; reduce N special cases to their irreducible primitives.
- **Finish migrations before building on top; fence what you can't finish.** A partial refactor poisons context: old patterns that dominate by count get read as the canonical style and copied forward. Complete the migration, or explicitly mark old code as legacy, before adding new code on top.
- **Validate against reality; tests are the spec.** Load-bearing substrates are validated against real corpora; fixtures and tests define correctness, not aspirational specs.

### Relay discipline (blackboard protocol)

Reach for the blackboard when it earns its keep, not for every subagent. When a payload is large or evidence-heavy enough that passing it through the dispatcher's context would poison it — or when a downstream critic/step must read it by path so the dispatcher routes on a verdict without ingesting the evidence — the subagent writes its output to an artifact file and returns only a path + short digest. That is what stops conclusions being laundered in place of evidence. Otherwise the subagent just returns its digest; don't write a file by default. Persist to a tracked path only when the output is durable (in docs-shaped repos, `docs/artifacts/<session>/`); ephemeral relay scratch stays out of the tracked tree, and repos without that path use a repo-appropriate or scratch location.

## Hard Constraints

- No `--no-verify`. Fix the issue or fix the hook.
- No path dependencies in `Cargo.toml` — they couple repos and break independent publishing.
- No interactive git (no `git rebase -i`, no `git add -i`, no `--no-edit` on rebase).
- No suggesting project names. LLMs are bad at this; refine the conceptual space only.
- No tracking cross-project issues in conversation — they go in TODO.md in the affected repo.
- No assuming a tool is missing without checking `nix develop`.
- Commit completed work in the same turn it finishes. Uncommitted work is lost work.

## Meta

- Something unexpected is a signal. Stop and find out why. Do not accept the anomaly and proceed.
- Corrections from the user are conversation, not material for new rules. Rules are added when a failure mode is observed repeatedly.
- **Confidence only when earned by tangible evidence; verify before you assert, and when you can't, say so.** Confirm a claim against the actual source — read it, run it, check it — *then* state it. If you haven't verified, say "I haven't checked," then go check or ask. Never substitute a plausible-sounding claim for a verified one. The defect is *unearned* confidence — confidence decoupled from checked evidence — and it is a defect even when the answer turns out right, because the process is identical to the confident-wrong case (a lucky guess just hides it, and trains the same habit). The inverse — hedging something you've solidly verified — is the same defect. Report what you actually checked plainly; the target is the coupling between expressed confidence and real evidence, not plainness or confidence itself. (the root failure: confabulation — asserting past your evidence.)
- **At a decision point, generate several genuinely independent candidate approaches, weigh each, and decide where the call is yours or give a weighed recommendation where it's the user's.** For complex/architectural/high-stakes decisions this isn't optional and can't be single-shot: N options from one model pass share blind spots — reworded, not independent. Decorrelate via parallel subagents each from a different starting frame (design-it-twice / design-an-interface), then adversarial judging, then synthesis — before committing. When unsure whether a decision clears that bar, treat it as if it does. (failures: overconfidence; option-dumping; false-independence — single-shot options treated as decorrelated.)
- **Under challenge, re-read the source and report what it literally says.** Let the answer land where the evidence puts it: hold if you were right, correct specifically if you were wrong. The new position must come from re-checking, never from the pressure. (failure: backpedaling — moving to appease.)
- **Re-read the relevant context before acting on it.** Act from the current state, not a stale or half-formed read. (failure: stale-context action.)

<!-- END ECOSYSTEM RULES -->
