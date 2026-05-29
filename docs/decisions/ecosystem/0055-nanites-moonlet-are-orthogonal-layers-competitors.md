# ADR-0055: Nanites and moonlet are orthogonal layers, not competitors

- Status: Accepted
- Date: 2026-05-29

**Context.** Both nanites and moonlet relate to running work, raising whether one should subsume the other.

**Decision.** Nanites describes work (task as data); moonlet controls access (capability as primitive). They compose — a moonlet script constructs nanites task graphs; nanites spawns moonlet-backed executors. Neither subsumes the other.

**Alternatives rejected.**
- *One subsumes the other (e.g. express orchestration directly in moonlet/Lua)* — In moonlet control flow is implicit in the Lua script — can't inspect, pause, cache, or replay. Nanites makes work first-class data with typed edges, which Lua control flow cannot provide.

**Consequences.** The two repos have a fixed compositional relationship rather than overlapping responsibilities; moonlet decides what's allowed, nanites decides what work needs doing. Mined from: /home/me/git/rhizone/nanites/docs/design/decisions.md (127), /home/me/git/rhizone/nanites/docs/design/decisions.md (129).
