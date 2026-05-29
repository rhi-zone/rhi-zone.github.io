# ADR-0121: Events adjust targets, not NT values directly; values approach targets exponentially

- Status: Accepted
- Date: 2026-05-29

**Context.** Moltbook interactions need to move fuwafuwa's mood, but mood should never snap discontinuously between sessions or within one.

**Decision.** All session events shift NT targets (cumulative, bounded); the value follows the target via exponential approach and never snaps. Drift rate is modulated by personality-derived inertia.

**Alternatives rejected.**
- *Apply events directly to NT values* — values would snap discontinuously; the design requires values to follow targets smoothly so mood drifts rather than jumps, and so long gaps settle to resting state naturally

**Consequences.** Mid-session value recomputation is optional because targets alone guide behavior; after long gaps values arrive near targets ('resting'). Constrains all event tables to express adjustments in target-space. Mined from: /home/me/git/pterror/fuwafuwa/docs/wiki/emotional-layer.md (130), /home/me/git/pterror/fuwafuwa/docs/wiki/emotional-layer.md (90).
