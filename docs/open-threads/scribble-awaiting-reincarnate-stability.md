# Scribble: awaiting reincarnate stability

**Project(s) touched:** scribble, reincarnate

**Status:** Open — paused arc; project scaffolded but dormant, parked until reincarnate's toolchain stabilizes

**Surfaced in:** conversation resurfaced 2026-06-15 — the user revisited scribble, assessed its blocker, and distinguished it from reincarnate's TypeScript-lifting stall.

---

## The arc

**Scribble** (`github.com/rhi-zone/scribble`) is a *medium for authored content* — structured, live, editor=runtime, where liveness survives publication — delivered at video-level accessibility. It is not an authoring tool; it occupies the slot video and HTML occupy (the form content is published and consumed in), and its bet is to hold Godot-class structured-liveness at content-creator accessibility. See ADR-0286 (`docs/decisions/repo-local/introspection/0286-scribble-is-a-medium-for-authored-content-not-a-tool`) for the full positioning derivation and the named accessibility/power-frontier risk. It is designed as a reincarnate-native frontend with disjoint runtime implementations — DOM, Canvas 2D, and WebGPU — each with its own stdlib primitives (ADR-0147, accepted 2026-05-29). Desktop targets reincarnate's native backends (wgpu, cpal, winit) directly via reincarnate's platform layer.

The project was scaffolded (0 commits, untracked TODO.md draft) and has been dormant since mid-March 2026.

## What's established

- Scribble's architecture is settled: three disjoint runtime implementations, each with per-target Platform Implementations behind an engine-agnostic interface (`draw_image()`, `fill_rect()`, etc.) — the three-tier design from ADR-0229 and ADR-0230 (`docs/decisions/repo-local/reincarnate/`, both accepted 2026-05-29).
- The platform-layer dependency is **effectively unblocked in isolation.** The redesigned interface exists; the old `system/` interface (`draw_sprite()`, `show_message()`, `Ui`) was retired at the wrong abstraction level and replaced.
- Scribble is explicitly **not** blocked on reincarnate's TypeScript-lifting mess (the subtype-constraint / `_self: unknown` stall, ~16k TS errors). That is the GameMaker/Flash lifting side, which scribble does not touch. Do not conflate the two blockers.

## What's still open

The genuine reason scribble stays parked: **reincarnate's toolchain is currently broken / in flux**, and reincarnate as a whole is not in a stable state to commit a new dependent project to. The platform layer is ready in isolation; the overall shape of reincarnate is not yet settled. Building scribble on it now risks significant churn if reincarnate's shape shifts. (This is the current working read from 2026-06-15 — not a hard external fact, but the user's own assessment.)

The unblock condition: reincarnate's toolchain stabilizes and its overall shape settles enough that a new dependent project can be built on it with reasonable confidence.

## Related

- [/projects/scribble](/projects/scribble)
- [/projects/reincarnate](/projects/reincarnate)
- ADR-0286 (scribble is a medium for authored content, not a tool — positioning derivation): `docs/decisions/repo-local/introspection/0286-scribble-is-a-medium-for-authored-content-not-a-tool`
- ADR-0147 (scribble disjoint runtime implementations): `docs/decisions/repo-local/introspection/0147-scribble-runtimes-are-intentionally-disjoint-shared-model`
- ADR-0229, ADR-0230 (reincarnate platform layer redesign): `docs/decisions/repo-local/reincarnate/ADR-0229`, `ADR-0230`

## Working answer

Park scribble until reincarnate stabilizes. The platform-layer interface is ready; the blocker is reincarnate's overall toolchain health, not any missing capability scribble needs. Resume when reincarnate's shape is settled enough to absorb a new dependent project without churn risk.
