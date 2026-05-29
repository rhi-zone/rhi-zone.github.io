# ADR-0111: Deterministic replay: all RNG through a seeded PRNG, no Math.random or Date.now in simulation

- Status: Accepted
- Date: 2026-05-29

**Context.** The game records an action log and supports replay and multiple saves. Wall-clock time and ambient randomness are the easy defaults for any JS game.

**Decision.** All randomness routes through a single seeded PRNG (Timeline.random). Math.random and Date.now are forbidden in simulation code. Same seed + same action sequence = same world state, making replay exact.

**Alternatives rejected.**
- *Use Math.random / Date.now directly in simulation code* — Non-seeded randomness and wall-clock reads make world state non-reproducible, breaking deterministic replay and the action-log/multi-save model.

**Consequences.** Replay correctness becomes a hard contract every subsystem honors (e.g. NPC life-event generation must run through backgroundRng on the sleep cycle so replays match). Any feature reaching for time/randomness must thread the PRNG. NPC state is persisted, not regenerated, but event rolls must still be deterministic. Mined from: /home/me/git/paragarden/existence/CLAUDE.md (71), /home/me/git/paragarden/existence/CLAUDE.md (188).
