# ADR-0138: Transport-agnostic core: one protocol semantics, multiple transport bindings

- Status: Accepted
- Date: 2026-05-29

**Context.** The protocol serves both real-time use cases (games) wanting persistent streams and async use cases (social) wanting per-request HTTP. It must decide whether to define separate protocols or one with transport bindings.

**Decision.** The protocol defines message semantics (Manifest, Intent, Snapshot, Transfer); transport bindings (Stream/WebSocket, Request/HTTP) define delivery. Start unified; split into separate protocols only if the bindings diverge significantly.

**Alternatives rejected.**
- *Define separate protocols per transport from the start* — One conceptual protocol gives optimized delivery for different use cases without duplication; splitting prematurely loses the shared semantics, so split only if bindings diverge significantly.

**Consequences.** Manifest/Intent/Snapshot/Transfer are defined once and bound to both WebSocket and HTTP. Leaves open a future split if bindings diverge, but the default is one unified protocol. Mined from: /home/me/git/rhizone/interconnect/docs/design-decisions.md (79), /home/me/git/rhizone/interconnect/docs/design-decisions.md (96).
