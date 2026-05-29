# ADR-0128: Composable primitive conditions over enum modes

- Status: Accepted
- Date: 2026-05-29

**Context.** Configuration like response behavior could be expressed as named enum modes (e.g. response_mode: mention_or_random) or as composable boolean/numeric conditions.

**Decision.** Configuration uses composable boolean/numeric conditions rather than enum modes, so new combinations emerge without code changes.

**Alternatives rejected.**
- *Enum modes (e.g. response_mode: mention_or_random)* — enums force predefined combinations; you cannot express 'mention + random' without adding a new enum value / code change

**Consequences.** Behavior space is open-ended: users combine conditions freely. The maintainers do not have to enumerate and ship every behavior combination. This directly motivates the $if expression design. Mined from: /home/me/git/exoplace/hologram/docs/philosophy.md (71), /home/me/git/exoplace/hologram/docs/philosophy.md (82).
