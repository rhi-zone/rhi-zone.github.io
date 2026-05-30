# ADR-0046: Dusklight actions are serializable data plus a transport function, not closures

- Status: Accepted
- Date: 2026-05-29

**Context.** Dusklight's first architecture session had to choose how actions are represented to make them transportable across protocol/transport layers.

**Decision.** Dusklight models actions as data plus a transport function (serializable), explicitly not as closures, with scriptable actions expressed as S-expressions-as-data and transports/protocols kept as separate layers.

**Alternatives rejected.**
- *Represent actions as closures* — Closures are not serializable; modeling actions as data + transport function keeps them serializable and transportable across the separated transport and protocol layers.

**Consequences.** Dusklight actions can be serialized and sent across transports; scripting uses S-expressions as data structures; transports and protocols remain decoupled layers; closure-based action handlers are foreclosed. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar5-mar9.md (94).
