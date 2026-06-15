# Candidate A — Subtract / Minimize Indirection

Framing: find the design with the fewest moving parts. Attack the indirection
itself. The committed in-repo skill files ARE the source of truth — no separate
canonical layer, no symlink layer.

---

## (a) The design

**Collapse three layers into one.** Today there are three places a skill can
live:

1. `tooling/claude-commands/` — the declared "canonical" versioned dir (github-io only)
2. `~/.claude/commands/` — machine-local, symlinks or real files
3. `.claude/commands/` — committed real files (receiver repos only)

Every special case in the audit is a consequence of having more than one layer:

- github-io is "different" only because its skills live in layers 1+2 instead of layer 3.
- The source-vs-receiver asymmetry exists only because the source reads from a
  *different* place (`tooling/claude-commands/` via `~/.claude`) than receivers
  load from (`.claude/`).
- `handoff.md` / `polish.md` are unversioned only because layer 2 can hold a real
  file with no layer-1 backing.
- The 5 stranded skills are stranded only because the find-by-presence rule keys
  off layer-3 *presence*, which is itself a workaround for the source not living
  in layer 3.

**The subtraction: delete layers 1 and 2 entirely.** Skills live in exactly one
place, in every repo including github-io:

```
.claude/skills/<name>/SKILL.md     # committed, real files, this and only this
```

This is what the harness loads from on a fresh clone with zero `~/.claude` setup
(harness fact #4). github-io stops being special: it becomes a receiver of its
own skills, loading them the same way every other repo does. There is no
canonical dir that differs from the deployed dir, because the deployed dir IS the
canonical dir. There is no symlink layer, because nothing needs to bridge a
canonical location to a load location — they are the same location.

**Source of truth for the *set* of ecosystem skills = github-io's own
`.claude/skills/`.** github-io is the hub not because it has a special canonical
folder, but because its committed `.claude/skills/` is, by convention, the
superset every other repo syncs from. The hub's skills are loaded by the hub's
own harness (so they're dogfooded and can't silently rot), AND they are the
propagation source. One directory, two roles, zero duplication.

### Why `.claude/skills/<name>/SKILL.md` over `.claude/commands/<name>.md`

Harness fact #4: commands are *merged into* skills; `SKILL.md` is the modern
canonical form; `commands/<name>.md` is legacy-supported. Picking the legacy form
would mean committing to a representation the harness already treats as
deprecated, and would force a future second migration. Subtract that future work
now: standardize on `.claude/skills/<name>/SKILL.md` everywhere.

A secondary win specific to this framing: the `skills/<name>/` *directory* form
uniformly handles both single-file skills (`design-it-twice`, `polish`,
`handoff`, `survey-open-threads`, `think-with-the-engineering-taste`) and
multi-file skills (`improve-codebase-architecture` has 4 files;
`design-an-interface` and `domain-model` are already dir-shaped). Today
`tooling/claude-commands/` mixes bare `.md` files and directories — two shapes.
`.claude/skills/<name>/` is one shape: a directory per skill, `SKILL.md` plus any
sidecar files. One shape = fewer concepts.

---

## (b) Concrete realization

### File layout — identical in every repo (github-io included)

```
<repo>/
  .claude/
    settings.json                 # committed, hooks only (unchanged)
    settings.local.json           # gitignored, permissions/secrets (unchanged)
    skills/
      design-it-twice/SKILL.md
      handoff/SKILL.md
      polish/SKILL.md
      ...
```

No `tooling/claude-commands/`. No `~/.claude/commands/` entries required for any
repo to function. A user MAY still have personal skills in `~/.claude/skills/`,
but per harness fact #4 those *shadow* project skills (personal precedence over
project) — that's a personal override, explicitly out of scope for
self-containment, and the design neither needs nor creates any such symlink.

### The sync tool (replaces `propagate-skill.sh`)

The propagator's job shrinks to: copy directories from the hub to receivers. It
no longer reads from `~/.claude`; it reads from github-io's committed
`.claude/skills/`. The find-by-presence rule is replaced by an explicit
per-repo manifest so NEW skills propagate.

`tooling/sync-skills.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
HUB=~/git/rhizone/github-io/.claude/skills          # the one source of truth

# Each receiver declares which skills it wants, in-repo and versioned:
#   <repo>/.claude/skills.manifest   (newline-separated skill names; '*' = all)
for repo in $(find ~/git -name skills.manifest -path "*/.claude/*" \
              | sed 's#/.claude/skills.manifest##' | sort -u); do
  manifest="$repo/.claude/skills.manifest"
  if grep -qx '\*' "$manifest"; then
    wanted=$(ls "$HUB")
  else
    wanted=$(grep -vE '^\s*(#|$)' "$manifest")
  fi
  for name in $wanted; do
    rm -rf "$repo/.claude/skills/$name"
    cp -R "$HUB/$name" "$repo/.claude/skills/$name"
    git -C "$repo" add ".claude/skills/$name"
  done
  if git -C "$repo" diff --cached --quiet; then continue; fi
  git -C "$repo" commit -m "chore(skills): sync from hub"
  git -C "$repo" diff --quiet && git -C "$repo" push || true   # push only if clean
done
```

Key differences from today's script, each a subtraction:

- **No `$SOURCE=~/.claude/...`.** Source is the hub's committed dir. The
  CLAUDE.md/script "source of truth" conflict (audit §5.1) disappears because
  there is now only one candidate.
- **No find-by-presence.** Receivers opt in via a committed
  `.claude/skills.manifest`, so a brand-new hub skill propagates the moment a
  receiver lists it (or always, if the receiver uses `*`). The 5 stranded skills
  stop being stranded (audit §0/§4): they propagate to any repo whose manifest
  includes them.
- **No "update `~/.claude` first" manual prerequisite** (audit §5.5). You edit
  the file in github-io's `.claude/skills/` directly; that edit is already the
  source.

To *add or edit* a skill: edit the file under github-io's `.claude/skills/`,
commit it (it's immediately live in github-io's own harness — dogfooded), then
run `sync-skills.sh` to fan it out. Authoring and the hub's own loading are the
same act.

### Fresh-clone load behavior

Clone any repo. `.claude/skills/<name>/SKILL.md` is a committed real file. The
harness loads project skills from `.claude/skills/<name>/SKILL.md` with zero
`~/.claude` setup (harness fact #4). github-io behaves identically to every
receiver. Self-containment holds for *every* repo, including the hub — closing
the asymmetry the audit flagged (§4, §summary).

---

## (c) What it hides or assumes

- **Assumes the harness loads `.claude/skills/<name>/SKILL.md` on fresh clone
  without user setup.** This is harness fact #4 as given. If a harness version
  only honored legacy `.claude/commands/`, this design would need the legacy
  path — but the brief states skills is modern-canonical and commands is merely
  legacy-supported, so the assumption is the documented forward path.
- **Hides the personal-shadow precedence.** Because personal `~/.claude` skills
  shadow project skills, a developer with a stale personal `handoff` symlink
  (like today's machine) would silently override the committed one. The design
  doesn't *prevent* that — it just stops *depending* on it. Migration (f)
  removes the existing shadows so the committed copies actually take effect.
- **Assumes manifests stay curated.** A repo that forgets to add a skill to its
  manifest won't get it. That's intended (opt-in), but it's a place where "what
  skills does repo X have?" must be answered by reading X's manifest, not
  inferred.
- **The hub's dual role is a convention, not enforced.** Nothing mechanically
  guarantees github-io's `.claude/skills/` is the superset; it's policy. A
  receiver could drift if edited directly instead of via sync. (Mitigation in d.)

---

## (d) Honest trade-offs

**Where it's strong:**

- Fewest concepts of any design: one directory role, no canonical layer, no
  symlink layer, no source/receiver asymmetry. Every audit special case
  (§5.1–5.5 tensions, the asymmetry, the stranding) is *dissolved* rather than
  patched — they were artifacts of layering.
- github-io dogfoods its own skills, so skill rot in the hub is immediately
  visible to the operator working in the hub.
- New-skill propagation is fixed by construction (manifest, not presence).
- Migration off legacy `commands/` is done once, now.

**Where it's thin:**

- **Duplication across repos.** Each receiver carries its own committed copy of
  every skill it wants. Edit a skill once in the hub, and N receiver copies must
  be re-synced and re-committed. This is the same cost receivers pay today (they
  already hold committed copies), but the design *embraces* duplication as the
  price of self-containment rather than hiding it behind a shared canonical dir.
  A symlink/submodule approach would deduplicate — but symlinks are exactly the
  indirection this framing removes, and they break self-containment (a symlink
  into another repo doesn't survive a lone clone).
- **Drift detection is out of band.** Nothing fails loudly if a receiver's copy
  diverges from the hub. A cheap mitigation (optional, not core): `sync-skills.sh
  --check` diffs each receiver copy against the hub and reports drift — but I'd
  keep it as a separate verb so the core sync stays minimal.
- **The hub's "superset" status is convention.** If you wanted it enforced you'd
  add a registry or CI check — but that re-introduces a concept. The framing says
  push on removal; I leave it as convention and accept the soft spot.

**Net:** trades storage duplication (cheap, already paid) for the elimination of
two entire layers and every special case they spawned.

---

## (e) The symlink layer

**Removed entirely.** There is no `~/.claude/commands/` symlink topology in this
design. Skills load from in-repo `.claude/skills/`, which the harness reads
directly. The only reason symlinks existed was to make the hub's
`tooling/claude-commands/` files visible to the harness (which only looks in
`~/.claude` and `.claude/`); once the canonical files live in the hub's own
`.claude/skills/`, the harness finds them with no bridge.

Personal `~/.claude/skills/` is still *permitted* (it shadows project skills by
harness precedence), but it is a personal override, never a load-bearing part of
any repo's self-containment. The propagator does not create, read, or depend on
any `~/.claude` entry.

---

## (f) Migrating the current state

### The 5 stranded skills

`survey-open-threads`, `think-with-the-engineering-taste`, `design-an-interface`,
`domain-model`, `improve-codebase-architecture` (the last three already
dir-shaped in `tooling/claude-commands/`).

1. Move each into github-io's `.claude/skills/<name>/SKILL.md` (rename the bare
   `survey-open-threads.md` → `survey-open-threads/SKILL.md`; the dir-shaped ones
   move as-is, their existing `SKILL.md` is already the entry, sidecars like
   `improve-codebase-architecture/{DEEPENING,INTERFACE-DESIGN,LANGUAGE}.md` ride
   along in the directory). Commit. They are now live in the hub's own harness
   and committed/versioned.
2. Add them to whichever receiver manifests should carry them, then run
   `sync-skills.sh`. They propagate immediately — the presence-gate that stranded
   them is gone.

### The unversioned skills (`handoff.md`, `polish.md`)

- `polish.md`: a committed copy exists in `tooling/claude-commands/polish.md`, but
  the *loaded* copy is a real file in `~/.claude/commands/`. Move
  `tooling/claude-commands/polish.md` → github-io `.claude/skills/polish/SKILL.md`,
  commit. Then **delete the real `~/.claude/commands/polish.md`** so the personal
  shadow no longer overrides the committed project copy.
- `handoff.md`: exists ONLY as a real file in `~/.claude/commands/` with no
  versioned backing anywhere (audit §2 table, §3). Copy its current bytes into
  github-io `.claude/skills/handoff/SKILL.md`, commit (this is the first time it
  is ever versioned), then **delete the real `~/.claude/commands/handoff.md`**.
  Receivers already carry committed `handoff.md` (audit §4) — re-sync them to the
  now-versioned hub copy and migrate their files from
  `.claude/commands/handoff.md` to `.claude/skills/handoff/SKILL.md`.

### Receiver legacy `commands/` files

Receivers today hold `design-it-twice.md`, `handoff.md`, `polish.md` under
`.claude/commands/`. One-time migration: `git mv` each to
`.claude/skills/<name>/SKILL.md`, add a `skills.manifest`, commit. After this the
legacy `.claude/commands/` directory is empty and removed ecosystem-wide.

### github-io itself

`tooling/claude-commands/` is deleted after its contents move to
`.claude/skills/`. The untracked `.claude/commands/think-with-the-engineering-taste.md`
is removed (its content lives at `.claude/skills/think-with-the-engineering-taste/SKILL.md`).
github-io's `.claude/skills/` is now both the hub source and what github-io's own
harness loads — one directory, fully committed, no symlinks, no canonical/deployed
split.

### CLAUDE.md updates (so docs match reality)

Replace the "Canonical skill location: `tooling/claude-commands/` … Symlink from
`~/.claude/commands/`" block with: skills live in `.claude/skills/<name>/SKILL.md`
in every repo; the hub copy in github-io is the propagation source; receivers
opt in via `.claude/skills.manifest`; run `tooling/sync-skills.sh`. Drop the "Do
not write skills to `.claude/` directly" rule — it inverts: you now write skills
*only* to `.claude/skills/`.
