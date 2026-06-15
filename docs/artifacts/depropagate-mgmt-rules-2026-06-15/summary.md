# Ecosystem-rules region sync — drop harness-management bullets (2026-06-15)

## What changed

Canonical `github-io/CLAUDE.md` (commit e678388) removed two bullets from the
shared `<!-- BEGIN/END ECOSYSTEM RULES -->` region:

- "No ecosystem changes without checking all affected repos."
- "Control surface stays self-contained and versioned."

They now live only in github-io's repo-specific area. The region is meant to be
byte-identical across all carriers, so every receiver had the two bullets
stripped. Propagated via `tooling/propagate-claude-md.sh` (single-target rewriter;
discovery/commit/push done by hand).

## Discriminator

- **Target** = any repo (excluding github-io itself, the canonical source) whose
  `CLAUDE.md` contains the `<!-- BEGIN ECOSYSTEM RULES -->` marker.
- **Clean** = `git status --porcelain` empty -> propagate, commit, push.
- **Dirty** = any uncommitted change -> do NOT sweep WIP; defer the region sync,
  append a re-run note to TODO.md. Commit+push the note only if TODO.md was
  otherwise clean; else leave it on disk uncommitted.
- **Live-region edits** (dusklight) = uncommitted edits *inside* the marker region
  itself -> hard defer; running the propagator would clobber live work.

## Counts

- Carriers discovered (grep of marker over `~/git`): 55 files
  - minus github-io canonical (1) and the crescent agent worktree copy (1, inside
    crescent's tree, covered by crescent) -> 53 distinct receiver repos
- Seeded (propagated + committed): 44
  - Pushed: 42
  - Committed-but-unpushed: 2 (see below)
- Deferred (dirty): 10 (one with a special live-region warning)

## Seeded and pushed (42)

ascent-interpreter, claude-code-hub, keybinds, ooxml, exoplace/aspect,
exoplace/github-io, exoplace/hologram, exoplace/noncanon, exoplace/aeriea,
paragarden/divergence, paragarden/existence, paragarden/github-io,
paragarden/legacy, pteraworld/annotated-law, pterror/matrix-gen,
pterror/chub-mirrorer, pterror/chub-stage-factory, pterror/statosphere-guide,
pterror/software-taxonomy, pterror/statosphere-studio, rhizone/concord,
rhizone/crescent, rhizone/deskspace, rhizone/gels, rhizone/interconnect,
rhizone/moonlet, rhizone/motif, rhizone/myenv, rhizone/nanites, rhizone/normalize,
rhizone/paraphase, rhizone/playmate, rhizone/portals, rhizone/reincarnate,
rhizone/rescribe, rhizone/rhi.zone, rhizone/server-less, rhizone/sketchpad,
rhizone/tiltshift, rhizone/unshape, rhizone/wick, rhizone/zone

## Committed but unpushed (2)

- private-recipient-a — push rejected (foreign remote / repo not accessible). Commit landed locally.
- rhizone/fractal — no git remote configured. Commit landed locally.

## Deferred — dirty repos (10)

Region sync NOT applied; re-run note appended to each repo's TODO.md.

| Repo | TODO.md note committed? | Reason |
|------|------------------------|--------|
| private-recipient-b | yes (pushed) | TODO.md was otherwise clean |
| pterror/fuwafuwa | yes (pushed) | TODO.md was otherwise clean |
| rhizone/defocus | yes (pushed) | TODO.md was otherwise clean |
| rhizone/dusklight | yes (pushed, via `direnv exec` for typecheck hook) | LIVE edits inside marker region — special warning note; TODO.md otherwise clean |
| paragarden/postmortem | no (left on disk) | TODO.md already modified |
| paragarden/solarium | no (left on disk) | TODO.md untracked |
| pteraworld | no (left on disk) | TODO.md already modified |
| pterror/ashwren | no (left on disk) | TODO.md already modified |
| rhizone/rainbow | no (left on disk) | TODO.md already modified |
| rhizone/scribble | no (left on disk) | TODO.md untracked |

## Notes / mechanics

- 6 clean repos (claude-code-hub, exoplace/github-io, paragarden/github-io,
  paragarden/legacy, pterror/software-taxonomy, rhizone/rhi.zone) had a
  direnv-blocked `.envrc`; none had a pre-commit hook, so a plain `git commit`
  succeeded (no `--no-verify`).
- dusklight has a `@dusklight/app typecheck` pre-commit hook needing the nix
  toolchain -> its TODO commit went through `direnv exec`.
- Every seeded repo changed exactly one file (CLAUDE.md); no WIP swept.

## Verification

Sampled committed `HEAD:CLAUDE.md` in 3 repos across 3 orgs:

- rhizone/normalize, exoplace/aspect, pterror/matrix-gen
- Removed bullets present: 0 in all three.
- Region intact: "No --no-verify" Hard Constraint, "oracle at the leaves"
  principle, "Validate against reality" principle, and END marker all present.
