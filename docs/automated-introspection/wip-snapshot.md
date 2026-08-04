# Work-in-progress snapshot

A point-in-time view of **active, in-motion work** across the ecosystem —
repos with unpushed commits or uncommitted changes right now. This is the
inverse of the [open-threads registry](../open-threads/): that registry tracks
work *parked for the foreseeable future*; this snapshot tracks what is *moving*.

Snapshots are dated and disposable — regenerate from `git status` + unpushed
commit counts across the ecosystem roots (`~/git/rhizone`, `~/git/exoplace`,
`~/git/paragarden`, `~/git/pterror`, `~/git/pteraworld`) rather than editing in
place. Routine cache/config churn (`.normalize/`, `.claude/` dirs, autonomous
bot state) is filtered out.

---

## Snapshot — 2026-06-05

### rhizone

| Repo | Unpushed | Dirty | In motion |
|------|----------|-------|-----------|
| **crescent** | 83 ahead | `?? .claude/worktrees/` | typechecker v7 (last: "verify v7 MR0 certificate digests") |
| **reincarnate** | 2 ahead | clean | type-inference invariants, Type::Template encoding, class-scope deferral docs |
| **marinada** | 1 ahead | clean | ad-hoc dispatch findings recorded in TODO |
| **fractal** | (no upstream) | `M docs/design/vs-hono-elysia.md`; `?? spike/adversarial/{A,B,C,D}/` | adversarial spike comparison; mount→path collapse |
| **dusklight** | 0 | `M CLAUDE.md` | ecosystem-rules sync in progress |
| **rainbow** | 0 | `M TODO.md` | TODO edits |
| **scribble** | 0 | `?? TODO.md` | TODO draft (untracked) |
| **github-io** (this repo) | 0 | `?? tooling/claude-commands/think-with-the-engineering-taste.md` + this open-threads work | open-threads triage/promotion (this change) |

### exoplace

| Repo | Unpushed | Dirty | In motion |
|------|----------|-------|-----------|
| **aeriea** | 7 ahead | body-proxy assets + `scripts/body/body_rig.gd`, `tools/body_proxy_build.gd` modified; `?? tools/_diag.{gd,tscn}` | BVH→MakeHuman retarget frame-of-reference fix; body-proxy rebuild |

### paragarden

| Repo | Unpushed | Dirty | In motion |
|------|----------|-------|-----------|
| **existence** | 9 ahead | `M js/game.js`, `M js/state.js`; `?? scripts/calib-{probe,sweep}.js` | affective amplitude axis (`reactivityFactor()`), calibration probes |
| **postmortem** | 0 | `M TODO.md` | TODO edits |
| **solarium** | 0 | `?? TODO.md`, `?? maybe-rules.md` | TODO + rules drafts (untracked) |
| **profile** | 0 | `A flake.lock` | flake lock staged |

### pterror

| Repo | Unpushed | Dirty | In motion |
|------|----------|-------|-----------|
| **math-playground** | (no upstream) | `?? erdos/850/filter/scratch_powerfulish.ts` | Erdős-850 WGSL 64-bit radical sieve; powerful-number scratch |
| **ashwren** | 0 | `M TODO.md` (+ bot state) | TODO edits (bot state churn ignored) |
| **fuwafuwa** | 0 | bot worktree only | autonomous loop (runtime churn, not human WIP) |

### pteraworld

No repos with unpushed commits or non-ignored dirty state.

---

### Notes

- **Heavy unpushed backlogs:** crescent (83) is the standout — forward typechecker
  progress, not stalled work. aeriea (7) and existence (9) are mid-feature.
- **Dirty `TODO.md` / draft files** across rainbow, scribble, postmortem,
  solarium, ashwren are in-flight planning notes, not lost work.
- **Bot repos** (fuwafuwa, ashwren) mutate state files as part of their
  autonomous loops; that churn is expected and excluded from "human WIP."
