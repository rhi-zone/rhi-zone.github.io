# Ecosystem-common CLAUDE.md region propagation — 2026-06-14

## What changed

The ecosystem-common region (between `<!-- BEGIN ECOSYSTEM RULES -->` and
`<!-- END ECOSYSTEM RULES -->` in the canonical `CLAUDE.md` of `rhizone/github-io`,
commit `b2e5e3c`) was updated. The data-over-code principle bullet became conditional:

> **Prefer data over code at a seam — where a faithful serialization is actually viable.**
> … The preference is conditional, not absolute: when a seam carries irreducibly
> heterogeneous, one-off glue whose only data form is a leaky lowest-common-denominator
> schema (or a "descriptor" that just wraps a closure), a code seam is the honest choice.

The propagator (`tooling/propagate-claude-md.sh`) replaces the **entire** region from
canonical, so propagation also resynced one stale Meta bullet that target repos still
carried in an older form ("Verify before you assert…" → "Confidence only when earned by
tangible evidence…"). Both bullets are part of the same canonical region; the resync is
the propagator working as designed (the region is meant to be byte-identical across repos).

## Method

`propagate-claude-md.sh` operates on a single target file — it does not discover repos,
commit, or push. Target repos were discovered by grepping for the BEGIN marker across
`~/git` (excluding `.claude/worktrees/`), git status was checked per repo, the propagator
was run on each clean repo, and commit/push was done by hand following the ecosystem-wide
refactor rules. Rust repos whose pre-commit hooks call `cargo fmt` were committed through
`direnv exec` so the nix-provided `cargo` was on PATH.

Commit message (CLAUDE.md): `docs(claude): sync ecosystem-common region (data-over-code principle)`

## Targets: 54 repos carried the region (excluding canonical github-io)

### Updated, committed, and pushed (43)

ascent-interpreter, claude-code-hub, exoplace/aeriea, exoplace/aspect, exoplace/github-io,
exoplace/hologram, exoplace/noncanon, keybinds, ooxml, paragarden/divergence,
paragarden/existence, paragarden/github-io, paragarden/legacy, pteraworld/annotated-law,
pterror/chub-mirrorer, pterror/chub-stage-factory, pterror/matrix-gen,
pterror/software-taxonomy, pterror/statosphere-guide, pterror/statosphere-studio,
rhizone/concord, rhizone/crescent, rhizone/defocus, rhizone/deskspace, rhizone/fractal*,
rhizone/gels, rhizone/interconnect, rhizone/moonlet, rhizone/motif, rhizone/myenv,
rhizone/nanites, rhizone/normalize, rhizone/paraphase, rhizone/playmate, rhizone/portals,
rhizone/reincarnate, rhizone/rescribe, rhizone/rhi.zone, rhizone/server-less,
rhizone/sketchpad, rhizone/tiltshift, rhizone/unshape, rhizone/wick, rhizone/zone

(11 of these — exoplace/noncanon, ooxml, pterror/matrix-gen, rhizone/concord, deskspace,
gels, nanites, normalize, reincarnate, sketchpad, tiltshift — initially failed commit
because their `cargo fmt` pre-commit hook couldn't find `cargo`; recommitted via `direnv exec`.)

### Updated and committed locally, but NOT pushed (2)

- **private-recipient-a** — push rejected: remote is `git@github.com:private-account/private-recipient-a.git`
  (a different GitHub account); this machine lacks push access. Committed on `main` locally.
- **rhizone/fractal** — no git remote configured at all (`git remote -v` empty). Committed on
  `master` locally; nothing to push to. (*marked with * above.)

### Deferred — dirty at propagation time, TODO.md note added (9)

Per the ecosystem-wide refactor rule, dirty repos were not force-updated. A note was
appended to each repo's `TODO.md` describing the pending region sync and the exact command
to run once clean.

| Repo | Why dirty | TODO note committed? |
|------|-----------|----------------------|
| private-recipient-b | `.claude/settings.local.json`, `apps/cli/src/index.ts` | yes (pushed) |
| pterror/fuwafuwa | worktree submodule pointer | yes (pushed) |
| rhizone/dusklight | **CLAUDE.md itself** mid-edit (in-flight region additions) | yes (pushed) |
| pteraworld | `TODO.md` (user WIP), untracked `annotated-law/` | no — TODO.md held user WIP |
| pterror/ashwren | `TODO.md` (user WIP), brain state files | no — TODO.md held user WIP |
| paragarden/postmortem | `TODO.md` (user WIP), untracked `.normalize/` | no — TODO.md held user WIP |
| rhizone/rainbow | `TODO.md` (user WIP), untracked `.normalize/` | no — TODO.md held user WIP |
| paragarden/solarium | untracked `TODO.md`, `.normalize/`, `maybe-rules.md` | no — TODO.md is untracked WIP |
| rhizone/scribble | untracked `TODO.md` | no — TODO.md is untracked WIP |

The note was appended to the on-disk `TODO.md` of all 9. For the 3 repos where `TODO.md`
was otherwise clean, the note was committed and pushed. For the other 6, `TODO.md` already
carried the user's own uncommitted work, so committing it would have swept that WIP into our
commit — the note is left on disk uncommitted instead, to be committed by whoever resumes
that repo. **dusklight** is the notable case: its `CLAUDE.md` had uncommitted edits to the
same region, so propagating would have clobbered in-flight work; its TODO note flags that the
region needs syncing after the in-flight edit is committed.

## Verification

Confirmed the new wording is present in the committed `HEAD:CLAUDE.md` of sample repos
across three orgs: `rhizone/wick`, `exoplace/hologram`, `paragarden/divergence`. Diffs in
sampled repos showed exactly 4 changed content lines (the two region bullets), no collateral
edits.
