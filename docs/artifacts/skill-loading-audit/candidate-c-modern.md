# Candidate C — Modern-Format, Idempotent-Sync Design

Framing: optimize the dominant operation — *author/edit a skill once and have it appear, up to date, in every repo that should have it* — and make the sync tool idempotent, re-runnable, and convergent. Lean into the modern `.claude/skills/<name>/SKILL.md` form. The `~/.claude` symlink is demoted to a non-load-bearing personal convenience.

---

## (a) The Design

### Core decisions

1. **The skill source of truth is `.claude/skills/<name>/SKILL.md` committed in github-io itself.** github-io stops being special. It carries its own committed skills exactly like every receiver repo, loading them on a fresh clone with zero `~/.claude` setup. There is no separate `tooling/claude-commands/` canonical tree and no machine-local source of truth.

   *Why not keep `tooling/claude-commands/` as canonical and copy into `.claude/skills/`?* Two copies of the same bytes in one repo is itself a drift surface (today's `think-with-the-engineering-taste` proves it — present in tooling, missing from git). The harness already loads `.claude/skills/` on a fresh clone, so that directory is *both* the canonical home and the load path. Collapse the asymmetry: one place, committed, that the harness reads directly.

2. **Migrate fully to the modern `.claude/skills/<name>/SKILL.md` form; retire `.claude/commands/`.** Commands are merged into skills; `SKILL.md` is canonical; `commands/*.md` is legacy-supported. Per the ecosystem principle *retire-don't-deprecate*, we do not carry both. Every skill — even a former one-file `polish.md` — becomes a directory `polish/SKILL.md`. This makes the layout uniform (every skill is a directory; multi-file skills like `improve-codebase-architecture` and single-file skills look identical structurally), which is what makes the idempotent sync trivial: it diffs directory trees, not a mix of files and directories.

3. **A `skills.manifest` (committed, in github-io) is the registry of which skills exist and which repos should carry each.** This replaces find-by-presence. New skills are no longer stranded: they are declared in the manifest and the sync seeds them into the listed repos on the next run. Presence is *derived from the manifest*, not the cause of inclusion.

4. **The sync tool is idempotent and convergent.** Running it brings every target repo to exactly the manifest state: missing skills are seeded, changed skills are overwritten, removed skills are deleted. Re-running on an already-converged ecosystem makes zero changes and zero commits. Drift is detected by the same diff that drives convergence — a `--check` mode reports divergence without writing.

5. **The `~/.claude/commands/` (and `~/.claude/skills/`) symlink layer is optional personal convenience only.** It exists so the operator can invoke skills from arbitrary directories outside any repo. It points at github-io's committed `.claude/skills/`. No repo — including github-io — depends on it for loading. If `~/.claude` is empty, every repo still works.

---

## (b) Concrete Realization

### File layout (in github-io, and mirrored into receivers)

```
github-io/
  .claude/
    skills/
      design-an-interface/SKILL.md
      design-it-twice/SKILL.md
      domain-model/SKILL.md
      handoff/SKILL.md
      improve-codebase-architecture/
        SKILL.md
        DEEPENING.md
        INTERFACE-DESIGN.md
        LANGUAGE.md
      polish/SKILL.md
      survey-open-threads/SKILL.md
      think-with-the-engineering-taste/SKILL.md
    settings.json            # hooks only, committed (unchanged)
    settings.local.json      # permissions, gitignored (unchanged)
  tooling/
    skills.manifest          # the registry (committed)
    sync-skills.sh           # the idempotent sync (committed)
```

`tooling/claude-commands/` is **deleted**. Its contents move into `.claude/skills/` with the single-file `.md` skills promoted to `<name>/SKILL.md` directories.

### `skills.manifest` format

Plain, diffable, data-over-code. One block per skill; `*` means "all ecosystem repos" (resolved against `docs/about.md`'s project list, the existing project registry):

```
# skill            targets
design-it-twice     *
handoff             *
polish              *
survey-open-threads *
think-with-the-engineering-taste *
design-an-interface         rhizone/*
domain-model                rhizone/*
improve-codebase-architecture rhizone/*
```

The targets column is glob-over-org/repo, resolved against the canonical project list. github-io is always an implicit target of every skill it hosts (it is the source — its committed `.claude/skills/` *is* the manifest's realization for itself), so the manifest never needs to list github-io.

### What the idempotent sync does (`sync-skills.sh`)

For each skill declared in the manifest:
1. Resolve target repos from the glob against the project list.
2. For each target repo, compute the desired tree = github-io's `.claude/skills/<name>/`.
3. `rsync --delete`-equivalent the skill directory into `<repo>/.claude/skills/<name>/` so the target is byte-identical (extra stray files inside the skill dir are removed; this is what makes it convergent, not just additive).
4. Additionally, for skills **not** in a repo's target set but present in its `.claude/skills/`, remove them (manifest is authoritative — retire, don't accumulate).
5. After all skills for a repo are reconciled: if and only if the repo's working tree changed, `git add .claude/skills`, commit with a generated conventional message (`chore(skills): sync <added/updated/removed> from manifest`), and push if the tree is otherwise clean. Dirty repos are skipped with a logged note (and the operator is told to add a TODO.md entry, per the ecosystem dirty-repo rule).

Properties:
- **Idempotent:** a second run on a converged ecosystem detects no diff, writes nothing, commits nothing.
- **New skills seed automatically:** add a skill directory + a manifest line, run sync, it appears everywhere it's targeted. No manual per-repo seeding.
- **No find-by-presence:** inclusion is the manifest, so brand-new skills are never stranded.
- **github-io self-syncs trivially:** it is the source, so its `.claude/skills/` is already canonical; sync only validates the manifest matches what's committed there (a skill in the manifest with no `.claude/skills/<name>/` dir is a hard error).

### Fresh-clone load behavior

Clone any repo (including github-io) → `.claude/skills/<name>/SKILL.md` is committed and present → the harness loads it directly. Zero `~/.claude` setup. This is the hard requirement, satisfied symmetrically for the source repo and all receivers.

### How drift is detected

`sync-skills.sh --check` runs steps 1–4 in dry-run and exits non-zero if any target repo's `.claude/skills/` would change. Three drift classes are reported distinctly:
- **stale:** committed skill in a receiver differs from github-io canonical.
- **missing:** manifest-targeted skill absent in a receiver.
- **orphan:** skill present in a receiver but not targeted by the manifest.

A CI hook (or a `/loop`-able command) runs `--check` so drift surfaces as a failure rather than silently rotting. Because the canonical copy lives in github-io's own `.claude/skills/`, `--check` also catches "manifest lists a skill that doesn't exist on disk."

---

## (c) What it hides or assumes

- **Assumes the harness loads `.claude/skills/<name>/SKILL.md` from a fresh clone with no user setup** — stated as a harness fact in the brief. Whole design rests on it.
- **Assumes `SKILL.md` front-matter / format is the harness's expected modern shape** and that a former `commands/<name>.md` body can be moved into `SKILL.md` with at most a front-matter wrapper. The migration step must verify each converted skill still loads.
- **Hides per-repo customization.** The manifest model assumes a skill is byte-identical across all repos that carry it. If a repo ever needed a *divergent* version of a skill, this model has no seam for it (it would be reported as `stale` drift forever). That is an accepted constraint, not a bug — uniform skills are the common case.
- **Assumes the project list in `docs/about.md` is accurate and machine-parseable enough** to resolve `*` and `rhizone/*` globs. If it isn't, the manifest needs its own explicit repo list.
- **Hides the precedence hazard** (see symlink section): a personal `~/.claude` symlink *shadows* the committed project copy. The design makes the symlink optional, but if present and stale, it silently overrides the committed file. Surfaced, not eliminated.

---

## (d) Honest trade-offs

- **Big one-time migration cost** (delete `tooling/claude-commands/`, restructure every single-file skill to a directory, re-seed all receivers, convert `commands/` → `skills/` everywhere). The framing explicitly accepts cost elsewhere to make the steady-state common path trivial; this is where that cost lands.
- **Two skill copies across repos** (github-io canonical + each receiver's committed copy) — but this is *required* by self-containment (each repo must load from its own committed files). The sync keeps them convergent; the cost is N commits when a skill changes. Acceptable: the alternative (symlinks/submodules) breaks fresh-clone loading.
- **Manifest is a second artifact to keep honest.** Mitigated by `--check` making manifest/disk mismatch a hard error, so it can't silently drift from reality the way find-by-presence did.
- **Retiring `.claude/commands/` outright** risks breaking if any repo or tool still expects the legacy path. Mitigated because the harness legacy-supports it (so no hard break during migration) but we still remove it to honor retire-don't-deprecate — verified by load-testing each migrated skill before deleting the legacy file.
- **Loses the "edit the symlinked file and it's instantly live in tooling" trick** for github-io's own dev loop. Now you edit `.claude/skills/<name>/SKILL.md` directly. Strictly simpler, but it's a workflow change for the operator.

---

## (e) The symlink layer's role

`~/.claude/commands/` / `~/.claude/skills/` are **optional personal convenience, never load-bearing.** Their sole purpose: let the operator invoke skills when working *outside* any repo (e.g. in `~` or a non-ecosystem directory). They should be symlinks into github-io's committed `.claude/skills/`, so they always reflect canonical bytes and can never become an unversioned source of truth (the `handoff.md`/`polish.md` real-file failure mode is structurally impossible — there is nowhere for an unversioned real file to be canonical).

Critical harness fact: **personal `~/.claude` takes precedence over project `.claude/`**, so a symlink *shadows* the committed project copy. Consequences and rules:
- The symlink must point at github-io's canonical files (never be a standalone real file). A one-line `link-personal-skills.sh` recreates the whole symlink set from `.claude/skills/`, idempotently, so it can't drift into real files.
- Because it shadows, a *stale* symlink (pointing at a moved/renamed skill) could mask a repo's own committed copy. `sync-skills.sh --check` includes an optional `--check-personal` that warns if `~/.claude` symlinks are dangling or point outside github-io's `.claude/skills/`.
- Nothing in any repo's load path requires the symlink. Delete `~/.claude/commands` entirely and every repo, including github-io, still loads its skills from its own commit.

---

## (f) Migration plan

### The 5 stranded skills

`survey-open-threads`, `think-with-the-engineering-taste`, `design-an-interface`, `domain-model`, `improve-codebase-architecture` were never propagated because find-by-presence excludes anything not already present. Under this design they are simply **declared in `skills.manifest`** with their target globs (the first three `*`/as-appropriate, the design/domain/architecture ones `rhizone/*` since they're developer-substrate tooling). The next `sync-skills.sh` run seeds them into every targeted repo automatically. Stranding is structurally gone: inclusion is declaration, not pre-existing presence.

### The unversioned skills (`handoff.md`, `polish.md`)

These exist only as real files in `~/.claude/commands/` (and for `think-with-the-engineering-taste`, an untracked file in tooling). Migration:
1. Capture their current bytes from `~/.claude/commands/handoff.md`, `~/.claude/commands/polish.md`, and `tooling/claude-commands/think-with-the-engineering-taste.md` (the live content).
2. Write them as `github-io/.claude/skills/handoff/SKILL.md`, `.../polish/SKILL.md`, `.../think-with-the-engineering-taste/SKILL.md` (adding modern front-matter), and **commit them in github-io**. They now have a versioned home for the first time.
3. Replace the `~/.claude/commands/handoff.md` and `polish.md` real files with symlinks into the new committed `.claude/skills/` dirs (via `link-personal-skills.sh`), eliminating the unversioned-real-file class entirely.

### The `.claude/commands/` → `.claude/skills/` format migration (all repos)

1. In github-io: move every `tooling/claude-commands/*.md` and `*/SKILL.md` into `.claude/skills/<name>/SKILL.md` (single files promoted to dirs); commit; delete `tooling/claude-commands/`.
2. Build `skills.manifest` from the now-canonical set + intended targets.
3. Run `sync-skills.sh` once. For each receiver it: writes the modern `.claude/skills/<name>/SKILL.md` tree, **removes the legacy `.claude/commands/<name>.md`** for any skill that has been migrated (orphan-removal step), commits `chore(skills): migrate to .claude/skills and sync from manifest`, pushes if clean. Dirty receivers get a TODO.md entry instead.
4. Verify each migrated skill loads from a fresh clone (spot-check one receiver per org) before considering legacy removal final — honors validate-against-reality.
5. Update CLAUDE.md: replace the `tooling/claude-commands/` + `propagate-skill.sh` + find-by-presence prose with: canonical = `.claude/skills/`, registry = `skills.manifest`, propagation = `sync-skills.sh` (idempotent, convergent), symlink = optional convenience. Retire `propagate-skill.sh`.

Net result: every repo including github-io loads skills from committed `.claude/skills/` on a fresh clone; one manifest + one idempotent sync is the entire propagation surface; new skills can never be stranded; and there is no unversioned or machine-local canonical skill anywhere.
