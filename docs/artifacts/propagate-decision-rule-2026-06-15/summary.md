# Ecosystem CLAUDE.md sync — decision-rule region (2026-06-15)

## What changed

Canonical CLAUDE.md (`~/git/rhizone/github-io/CLAUDE.md`, commit `050410c`) refined the
**"At a decision point…"** Meta bullet inside the `<!-- BEGIN/END ECOSYSTEM RULES -->`
region. New wording: "generate several genuinely independent candidate approaches, weigh
each, and decide where the call is yours or give a weighed recommendation where it's the
user's" — with guidance to decorrelate via parallel subagents, adversarial judging, then
synthesis. This region is meant to be byte-identical across every repo that carries it.

## Mechanics

`tooling/propagate-claude-md.sh <target-CLAUDE.md>` rewrites a single target file (replaces
its marker region with the canonical region). It does not discover repos, commit, or push.
Discovery: grep `<!-- BEGIN ECOSYSTEM RULES -->` across `~/git`. Commit + push by hand.
55 marker-carrying CLAUDE.md found; excluding canonical github-io (no-op) and a crescent
worktree copy (resolves to crescent), 54 distinct repos considered.

## Results

### Updated and pushed (43)

ascent-interpreter, claude-code-hub, exoplace/aspect, exoplace/github-io,
exoplace/hologram, exoplace/noncanon, exoplace/aeriea, keybinds, ooxml,
paragarden/divergence, paragarden/existence, paragarden/github-io, paragarden/legacy,
pteraworld/annotated-law, pterror/chub-mirrorer, pterror/matrix-gen,
pterror/chub-stage-factory, pterror/statosphere-guide, pterror/software-taxonomy,
pterror/statosphere-studio, rhizone/concord, rhizone/crescent, rhizone/defocus,
rhizone/deskspace, rhizone/gels, rhizone/interconnect, rhizone/moonlet, rhizone/motif,
rhizone/myenv, rhizone/nanites, rhizone/normalize, rhizone/paraphase, rhizone/playmate,
rhizone/portals, rhizone/reincarnate, rhizone/rescribe, rhizone/rhi.zone,
rhizone/sketchpad, rhizone/tiltshift, rhizone/unshape, rhizone/wick, rhizone/zone,
private-recipient-b.

Commit message: `docs(claude): sync ecosystem CLAUDE.md decision-rule region`. Each commit
touched only CLAUDE.md (verified) and was a clean single-bullet region diff. Repos with a
cargo fmt / bun / normalize pre-commit hook (several via `core.hooksPath=.githooks`) were
committed through `direnv exec <repo-dir>` so the nix toolchain was on PATH — no
`--no-verify`. rhizone/rescribe pushes to a remote named `ooxml` (not `origin`); pushed fine.

### Committed but unpushed (2)

- private-recipient-a — foreign remote `git@github.com:private-account/private-recipient-a.git`, no push
  access ("Could not read from remote repository … correct access rights … repository
  exists"). Commit landed; tree clean.
- rhizone/fractal — no remote configured. Commit landed (HEAD `86992a0`); tree clean.

### Deferred — dirty repos (9)

Propagator NOT run on these. A re-run note was added to each repo's TODO.md; the note was
committed + pushed only where TODO.md was otherwise clean, else left on disk uncommitted.

- rhizone/dusklight — CLAUDE.md ITSELF had in-flight edits inside the marker region
  (partial, older-wording sync). Rule-4 deferral: propagator not run, CLAUDE.md WIP left
  untouched (still ` M CLAUDE.md`). Note committed + pushed (TODO.md was clean).
- pterror/fuwafuwa — dirty `.claude/worktrees/…`. Note committed + pushed (TODO.md clean).
- paragarden/postmortem — TODO.md modified, `.normalize/`. Note left uncommitted on disk.
- paragarden/solarium — TODO.md untracked, `.normalize/`, maybe-rules.md. Note uncommitted.
- pteraworld — TODO.md modified, `annotated-law/`. Note left uncommitted on disk.
- pterror/ashwren — TODO.md modified, brain state files. Note left uncommitted on disk.
- rhizone/rainbow — TODO.md modified, `packages/core/.normalize/`. Note uncommitted.
- rhizone/scribble — TODO.md untracked. Note left uncommitted on disk.

Dirty repos were behind by more than this one edit (also missed the earlier "Prefer data
over code" refinement; scribble missed several bullets and was apparently not covered by the
prior 2026-06-14 run). The propagator replaces the whole region in one pass, so a single
re-run after WIP is committed reconciles everything.

### No action needed (1, inside the pushed batch)

private-recipient-b — its marker region already matched canonical (propagator dry-run = 0 changed
lines). Its dirty `docs/artifacts/…` files are unrelated WIP and were not touched.

### Failed (0)

No propagation or commit failures.

## Verification

New wording confirmed in committed `HEAD:CLAUDE.md` (grep "generate several genuinely
independent candidate approaches" → 1 match) across three orgs: rhizone/wick (rhi-zone),
exoplace/aspect (exo-place), pterror/software-taxonomy (pterror).
