# Candidate D — Vendored / Referenced Plugin

**Framing:** Rebuild the rhi skill set on a different core noun — a **plugin** — instead
of loose per-repo command/skill files. Explore whether a plugin can be made genuinely
self-contained per Requirement 1, and design the most self-contained plugin-based
mechanism that the Claude Code plugin system actually permits.

All plugin behavior below is taken from the Claude Code plugin docs
(`code.claude.com/docs/en/plugins`, `.../plugins-reference`), fetched 2026-06-16.
Load-bearing facts are quoted verbatim; the verdict in §(g) rests on two of them.

---

## (g) VERDICT FIRST — can a plugin be self-contained?

Requirement 1 demands: *every repo, including github-io, loads skills from committed
in-repo files; a fresh clone works with zero `~/.claude` setup.* "Anything that CAN be
repo-specific but isn't makes the repo non-self-contained."

The plugin system offers several delivery mechanisms. They split cleanly on one axis —
**does the plugin load in place from the repo, or is it copied/installed into a
machine-local location?**

### Marketplace install — FAILS Requirement 1 (decisive)

> "For security and verification purposes, Claude Code copies *marketplace* plugins to
> the user's local **plugin cache** (`~/.claude/plugins/cache`) rather than using them
> in-place." (plugins-reference, "File locations")

A marketplace install — even a `--scope project` install that writes `enabledPlugins`
into the committed `.claude/settings.json` — still requires the plugin *bytes* to be
fetched and copied into `~/.claude/plugins/cache` on each machine. `enabledPlugins` is a
*reference*; resolving it runs `claude plugin install` / marketplace fetch. A fresh clone
does **not** have the cached bytes. This is exactly the failure mode the requirement
names: the skill content lives only in an unversioned machine-local location
(`~/.claude/plugins/cache`), reachable only after an install step. **Disqualified.**

### `--plugin-dir` / `--plugin-url` flags — FAILS Requirement 1

These load a plugin for *that session only*, passed on the command line. Nothing about a
fresh clone causes them to fire; they are not declared in any committed file the harness
reads at startup. Self-containment would depend on every contributor remembering a flag.
**Disqualified** (also: `--plugin-url` fetches remote bytes, same cache problem).

### Project-scope `@skills-dir` plugin — PASSES Requirement 1 ✅

> "Any folder under a skills directory that contains a `.claude-plugin/plugin.json`
> manifest is loaded as a plugin named `<name>@skills-dir` on the next session, with no
> marketplace and no install step. … the plugin is **discovered in place rather than
> copied into the plugin cache**." (plugins-reference, "Skills-directory plugins")

> | Skills directory | Scope | Loads |
> | `<cwd>/.claude/skills/` | project | Only after you accept the workspace trust dialog for that folder |

> "A project-scope plugin is checked into the repository and reaches every collaborator
> who clones it. Because that content comes from the repository rather than from you, it
> loads only after the same trust gate that governs `.claude/settings.json`."

This is the one mechanism where plugin bytes live in committed in-repo files and load on
a fresh clone with **zero `~/.claude` setup** — discovered in place, no install, no cache,
no marketplace. The only gate is the workspace trust dialog, which already gates
committed `.claude/settings.json` hooks today, so it introduces no new
non-self-containment.

**VERDICT: A plugin CAN be self-contained — but only via the project-scope `@skills-dir`
mechanism (a `.claude-plugin/plugin.json` committed under `<repo>/.claude/skills/`).
Every other plugin delivery path (marketplace install, `--plugin-dir`, `--plugin-url`,
user-scope install) routes through a machine-local cache or a per-session flag and
therefore FAILS Requirement 1.** The plugin noun does not buy self-containment for free;
it buys it only when you deliberately pick the in-place loader and decline the cache.

Two caveats that the design must absorb:

1. **No repo-root walk-up.** "Project-scope `@skills-dir` plugins load only from the
   `.claude/skills/` of the directory where you start Claude Code. They do not walk up to
   the repository root the way plain skills and commands do." → must launch Claude Code
   from the repo root (already the norm), or `/reload-plugins` after `cd`.
2. **Namespacing is mandatory and lossy.** Plugin skills are *always* namespaced:
   `/my-first-plugin:hello`. There is no opt-out. Today's invocations (`/handoff`,
   `/polish`, `/design-it-twice`) would all become `/rhi:handoff`, `/rhi:polish`, etc.

---

## (a) The design

**One versioned plugin, `rhi`, is the single source of truth for the ecosystem skill
set.** Its canonical form lives once in github-io at `tooling/rhi-plugin/`:

```
tooling/rhi-plugin/
├── .claude-plugin/plugin.json        # name: "rhi", version, author
└── skills/
    ├── handoff/SKILL.md
    ├── polish/SKILL.md
    ├── design-it-twice/SKILL.md
    ├── design-an-interface/SKILL.md
    ├── domain-model/SKILL.md
    ├── survey-open-threads/SKILL.md
    ├── think-with-the-engineering-taste/SKILL.md
    └── improve-codebase-architecture/
        ├── SKILL.md
        └── DEEPENING.md / INTERFACE-DESIGN.md / LANGUAGE.md   (supporting files)
```

This collapses the eight loose files + dirs into **one plugin with one manifest and one
version number**. The whole skill set updates atomically and is diffable as a unit.

**Delivery = vendoring the plugin into each repo's `.claude/skills/`.** Because the only
self-contained loader is project-scope `@skills-dir`, every repo (github-io included)
commits the plugin under `.claude/skills/rhi/`:

```
<repo>/.claude/skills/rhi/
├── .claude-plugin/plugin.json
└── skills/...                         # full copy of the rhi skill set
```

On a fresh clone, Claude Code launched from the repo root discovers
`<repo>/.claude/skills/rhi/.claude-plugin/plugin.json`, loads it as `rhi@skills-dir`,
gated only by the workspace trust dialog. No `~/.claude`, no marketplace, no install.

**Propagation = copy the canonical plugin tree into every repo's `.claude/skills/rhi/`
and commit.** Same mechanics as today's `propagate-skill.sh`, but the unit is the whole
plugin directory, not one file, and the source of truth is the versioned
`tooling/rhi-plugin/` — never a `~/.claude` path.

---

## (b) Concrete realization

### plugin.json

```json
{
  "name": "rhi",
  "displayName": "rhi ecosystem skills",
  "version": "1.0.0",
  "description": "Canonical Claude Code skill set for the rhi ecosystem",
  "author": { "name": "rhi" }
}
```

`version` is explicit and bumped on every skill change so `/plugin update` semantics work
if anyone *also* installs via marketplace (see §c). For pure `@skills-dir` vendoring the
version is documentation, but it costs nothing and keeps the manifest honest.

### How repos consume it

1. github-io holds canonical `tooling/rhi-plugin/`.
2. github-io *also* carries the vendored copy at `.claude/skills/rhi/` (so github-io is
   self-contained — it does not get to be the exception).
3. A propagator copies `tooling/rhi-plugin/` → `<repo>/.claude/skills/rhi/` for every repo
   in the registry, commits, pushes where clean.

### Fresh-clone behavior

- `git clone <repo> && cd <repo> && claude` from the repo root.
- Trust dialog appears (same as today for committed hooks). Accept once.
- `rhi@skills-dir` loads in place. `/help` lists `/rhi:handoff`, `/rhi:polish`, … .
- Zero `~/.claude` setup. Requirement 1 satisfied for every repo uniformly.

### Propagator sketch (replaces `propagate-skill.sh`)

```bash
SRC=~/git/rhizone/github-io/tooling/rhi-plugin     # versioned, NOT ~/.claude
for repo in $(cat tooling/skill-repos.txt); do     # explicit registry, not find-by-presence
  rsync -a --delete "$SRC/" "$repo/.claude/skills/rhi/"
  git -C "$repo" add .claude/skills/rhi
  git -C "$repo" commit -m "chore(skills): sync rhi plugin to <version>"
  # push if clean
done
```

Note two deliberate departures from today's script:
- **Source of truth is the versioned dir**, not `~/.claude/commands/`.
- **Registry-driven**, not find-by-presence — this fixes the propagation gap (new skills
  reach all repos; today's `find` rule silently skips repos that lack a prior copy).

---

## (c) What it hides / assumes

- **Assumes Claude Code is launched from the repo root.** The `@skills-dir` no-walk-up
  rule makes subdirectory launches silently miss the plugin. Documented constraint.
- **Assumes the trust dialog is acceptable as the sole gate.** It already gates committed
  hooks, so no regression — but a brand-new clone shows it, and a CI/non-interactive
  context that can't answer the dialog gets no skills. Loose per-repo plain skills/commands
  have the *same* trust requirement, so this is not unique to plugins.
- **Hides the namespace change behind a one-time muscle-memory cost.** Every invocation
  gains a `rhi:` prefix. There is no way to keep bare `/polish`.
- **Optional marketplace mirror (not required, not self-contained):** github-io could
  *also* publish `tooling/rhi-plugin/` as a git marketplace for people outside the repos.
  That path is the copied-to-cache, install-required path and must be treated as a
  convenience mirror, never as the self-containment mechanism.

---

## (d) Honest trade-offs

**Wins**
- One plugin, one version, atomic updates — the cleanest "single source of truth" of any
  candidate. The whole skill set is a versioned unit.
- The propagation unit is a directory tree; supporting files (e.g.
  `improve-codebase-architecture`'s 4 files) travel as a coherent bundle, not file-by-file.
- Self-contained *to exactly the same degree* as the loose-files approach — both bottom
  out on committed `.claude/` content behind the trust gate.

**Costs / risks**
- **Forced namespacing** (`/rhi:polish`) is a real ergonomic tax and an irreversible
  rename of every invocation. This is the single biggest reason to question the plugin
  noun: the loose `.claude/commands/<name>.md` approach keeps bare `/polish`.
- **The plugin noun buys almost nothing here.** Because the only self-contained loader
  (`@skills-dir`) still requires the bytes to be committed under each repo's `.claude/`,
  we are *still vendoring per-repo files* — just under a `plugin.json` wrapper and with a
  namespace prefix. The marketplace/version machinery (the actual point of plugins) is
  unusable without breaking self-containment. We pay the plugin's costs (namespacing,
  manifest, no-walk-up) without getting its benefit (central install + auto-update).
- **No-walk-up footgun** is a new, plugin-specific failure mode loose skills don't have.
- **Duplication is unchanged.** Every repo still carries a full copy of the skill bytes;
  the plugin wrapper does not deduplicate. (A git-submodule of `tooling/rhi-plugin/` into
  each repo's `.claude/skills/rhi/` could dedupe the *source* while staying committed —
  but submodules add their own fresh-clone friction (`--recurse-submodules`) and are a
  separate decision; flagged, not adopted.)

**Net:** plugin-as-vendored-`@skills-dir` is *viable and self-contained*, but it is
strictly worse than loose vendored files for this ecosystem unless the ecosystem actually
wants central marketplace distribution to outside consumers — which contradicts
Requirement 1. The honest recommendation embedded in this candidate is: choose the plugin
noun only if external distribution is a real goal; otherwise the plugin wrapper is
overhead.

---

## (e) Symlink layer

The audit's central defect is that github-io loads skills via `~/.claude/commands/`
symlinks (machine-local), with two skills (`handoff.md`, `polish.md`) as *unversioned
real files* there. This candidate **eliminates the symlink-as-load-path entirely.**

- The harness loads `rhi@skills-dir` from the committed `<repo>/.claude/skills/rhi/`
  tree, in place. Nothing in `~/.claude` is on the load path for any repo.
- **Personal convenience symlink (optional, off the load path):** a developer who wants
  the rhi skills available in *non-repo* directories may symlink
  `~/.claude/skills/rhi → ~/git/rhizone/github-io/tooling/rhi-plugin`. Per the docs,
  `~/.claude/skills/` is **personal scope** ("In every project, since the location is
  yours alone") and, being a personal-scope `@skills-dir`, has none of the project-scope
  restrictions. This is purely a personal ergonomic; it is **never** the mechanism any
  repo relies on, and its absence on a fresh machine changes nothing for in-repo loading.
- Because precedence is personal-over-project, a personal `~/.claude/skills/rhi` would
  *shadow* the repo's vendored copy. That is acceptable only because both resolve to the
  same versioned source on the dev's machine; on any other machine the project copy loads.
  The rule: **the personal symlink may exist for convenience, but correctness depends only
  on the committed project copy.**

The symlink stops being load-bearing. That is the fix.

---

## (f) Migration of the 5 stranded + unversioned skills

Two distinct problems from the audit:

**Unversioned skills** — `handoff.md` (no presence in `tooling/` at all) and
`polish.md` (real file in `~/.claude/commands/`, not symlinked):
1. Capture the current bytes from `~/.claude/commands/handoff.md` and
   `~/.claude/commands/polish.md`.
2. Author them as `tooling/rhi-plugin/skills/handoff/SKILL.md` and
   `.../skills/polish/SKILL.md` (convert flat command → `SKILL.md` with frontmatter
   `description`; `commands/` is legacy, `skills/<name>/SKILL.md` is canonical per the
   harness facts).
3. Delete the unversioned `~/.claude/commands/handoff.md` and `…/polish.md`. From now on
   they exist only as committed plugin skills.

**Stranded / never-propagated skills** — `survey-open-threads`,
`think-with-the-engineering-taste`, `design-an-interface`, `domain-model`,
`improve-codebase-architecture` (and the uncommitted-in-`tooling`
`think-with-the-engineering-taste.md`):
1. Ensure each is a real committed entry under `tooling/rhi-plugin/skills/<name>/SKILL.md`
   (commit `think-with-the-engineering-taste`, which the audit found uncommitted).
2. The registry-driven propagator copies the *entire* plugin tree to every repo, so all
   five reach all repos in one sync — the find-by-presence gap is gone by construction
   (you copy the whole plugin, not per-file by prior presence).

**Net migration:** all 8 skills become directories under one committed plugin; the two
unversioned files gain a versioned home; the five stranded skills propagate everywhere on
the next sync. Invocation names all gain the `rhi:` prefix.

---

## Summary

| | This candidate |
|---|---|
| Core noun | one versioned plugin `rhi` |
| Self-contained loader | project-scope `@skills-dir` (committed `.claude/skills/rhi/`) |
| Loaders that FAIL Req 1 | marketplace install, `--plugin-dir`, `--plugin-url`, user-scope |
| Source of truth | `tooling/rhi-plugin/` in github-io (versioned) |
| Propagation | registry-driven copy of whole plugin tree |
| Symlink role | off the load path; personal convenience only |
| Cost | forced `rhi:` namespacing, no-walk-up footgun, no real plugin benefit |
| Verdict | self-containable **only** via vendored `@skills-dir`; plugin wrapper is overhead unless external distribution is a goal |
