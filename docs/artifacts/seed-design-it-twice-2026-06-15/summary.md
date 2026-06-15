# Seeding `design-it-twice` skill across the ecosystem — 2026-06-15

Hand-seeding of the new `design-it-twice.md` skill into every repo that participates in
the skill ecosystem. `propagate-skill.sh` only *updates* repos that already carry a given
skill file, so a brand-new skill must be seeded by hand, mirroring the propagator's
per-repo procedure exactly.

## Procedure mirrored from `tooling/propagate-skill.sh`

Per repo (faithful to the script):

```sh
cp ~/.claude/commands/design-it-twice.md <repo>/.claude/commands/design-it-twice.md
~/git/rhizone/normalize/target/debug/normalize init
git add .claude/commands/design-it-twice.md .gitignore .normalize/
direnv exec . git commit -m "feat(skills): add design-it-twice"   # direnv puts nix toolchain on PATH
git push                                                          # only if clean after commit
```

Source mirrored the propagator's `SOURCE=~/.claude/commands/design-it-twice.md`; that path
was first created as a symlink to the canonical
`~/git/rhizone/github-io/tooling/claude-commands/design-it-twice.md` (same pattern the other
canonical skills already use in `~/.claude/commands/`).

## Discriminator for the target set

The correct target set is **every repo that already carries the canonical propagated skills
in a tracked `.claude/commands/`**. The discriminator used:

> repos containing `.claude/commands/handoff.md` (equivalently `polish.md`)

`handoff.md` and `polish.md` are each carried by an **identical 35-repo set** (verified by
`diff`), and in those repos they are real tracked files (not symlinks). This is the actual
skill-ecosystem membership. `think-with-the-engineering-taste.md` was rejected as a
discriminator: it matched only github-io, far too narrow.

**Target count: 35 repos.** Of these, 29 were clean and 6 were dirty at seeding time.

## github-io itself

github-io is **not** in the 35-repo target set, and was correctly left untouched:

- github-io's canonical/tracked skill home is `tooling/claude-commands/`, where
  `design-it-twice.md` already lives committed (commit predating this task).
- github-io's own `.claude/commands/` is **entirely untracked** (`git status` shows
  `?? .claude/commands/`); it holds only `think-with-the-engineering-taste.md`, itself an
  untracked working copy. Nothing under github-io's `.claude/commands/` is tracked, so
  committing a seeded copy there would have committed a directory the repo intentionally
  keeps untracked. Correctly did nothing there.
- Note: `github-io/scaffolding` is a *separate nested repo* that DOES track
  `.claude/commands/handoff.md` and `polish.md`, so it IS a target-set member (handled
  below under deferred — it was dirty).

## Results

### Seeded and pushed — 28 repos

exo-place: aeriea, aspect, hologram, noncanon
para-garden: existence
ptera-world: annotated-law
pterror: matrix-gen
rhi-zone: concord, crescent, defocus, deskspace, gels, interconnect, moonlet, motif,
myenv, nanites, normalize, paraphase, playmate, portals, rescribe, server-less, sketchpad,
tiltshift, unshape, wick, zone

Notes:
- **lee-website**: required `npm ci` first — its pre-commit hook runs ESLint via
  `node_modules/.bin/eslint`, which only skips when `node` is absent; with node present
  (via direnv) it failed on missing deps. Installed deps (node_modules is gitignored, so the
  repo stayed clean), then the hook passed and it committed cleanly. **Committed but NOT
  pushed** — see unpushable below; counted there, not in the 28.
- **defocus**: a second `normalize init` pass regenerated
  `.normalize/cache/summary-freshness.json` *after* the commit, leaving the repo dirty. That
  cache churn was NOT swept into the commit (the commit contains only the skill +
  `.normalize/index.sqlite`, exactly as the propagator stages). Pushed the committed skill;
  the unrelated cache file remains dirty on disk.

### Committed but unpushable — 1 repo

- **lee-website** — remote `git@github.com:somebody1234/lee-website.git` returns
  `ERROR: Repository not found` (foreign/inaccessible remote). Committed (`0cf1437`), cannot
  push.
- (`rescribe` has a local-path remote `/home/me/git/ooxml` but its push succeeded, so it is
  not in this category.)

### Deferred (dirty at seeding time) — 6 repos

Per the ecosystem-wide-refactor rule, dirty repos were NOT seeded; a TODO.md note with the
exact seed command was added instead. The note is committed+pushed **only where TODO.md was
otherwise clean** (so developer WIP is not swept in); otherwise left on disk uncommitted.

| Repo | WIP at seed time | TODO note disposition |
|------|------------------|------------------------|
| `private-recipient-b` (pterror) | `M .claude/settings.local.json`, untracked docs/artifacts | note committed+pushed (`c3312d4`) — TODO.md was clean |
| `rhizone/dusklight` | `M CLAUDE.md` | note committed+pushed (`07c954b`) — TODO.md was clean |
| `github-io/scaffolding` | untracked `.claude/commands/`, tooling skill file | note committed+pushed (`e8a352c`) — created fresh TODO.md, staged only it |
| `rhizone/rainbow` | `M TODO.md` (pre-existing WIP) + untracked .normalize | note left on disk uncommitted — TODO.md carries developer WIP |
| `paragarden/solarium` | untracked TODO.md, maybe-rules.md, .normalize | note left on disk uncommitted — TODO.md is untracked WIP |
| `rhizone/scribble` | untracked TODO.md | note left on disk uncommitted — TODO.md is untracked WIP |

Seed command recorded in each note:

```sh
cp ~/.claude/commands/design-it-twice.md "$(git rev-parse --show-toplevel)/.claude/commands/design-it-twice.md"
~/git/rhizone/normalize/target/debug/normalize init
git add .claude/commands/design-it-twice.md .gitignore .normalize/
direnv exec . git commit -m "feat(skills): add design-it-twice"
git push
```

## Verification

`git show HEAD:.claude/commands/design-it-twice.md` confirmed the tracked skill in committed
HEAD across orgs: `exoplace/aspect`, `pterror/matrix-gen`, `rhizone/zone`, and
`lee-website` (committed-but-unpushed). All show the correct frontmatter.

Final tally among the 29 clean seeded repos: 28 pushed, 1 committed-but-unpushable
(lee-website). Plus 6 deferred dirty (3 with TODO note pushed, 3 left on disk).
