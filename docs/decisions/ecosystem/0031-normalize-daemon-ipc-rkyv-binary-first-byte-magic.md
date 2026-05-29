# ADR-0031: normalize daemon IPC: rkyv binary with first-byte magic protocol detection, LSP-style pull over JSON broadcast

- Status: Accepted
- Date: 2026-05-29

**Context.** normalize's warm-path performance was dominated by IPC: roughly 82ms of a ~90ms `rules run`. During an Apr 27-30 multi-day session reworking the daemon IPC, the team had to choose a daemon-client wire protocol that hit a sub-16ms (6-8ms IPC) target while staying backward-compatible, and simultaneously resolve the delivery model (pull vs broadcast).

**Decision.** Adopt an rkyv binary IPC protocol for the daemon (schema bumped 8->9 with BLOB storage and rkyv derives on Issue) with magic-byte dispatch on the first byte (0x01 = rkyv, else JSON). The no-filter case gets a zero-copy passthrough fast path; the filtered case takes a slow path of rkyv-deser + filter + re-serialize. JSON is retained as fallback. Delivery resolves in favor of LSP-style pull over broadcast. Target: 82ms IPC down to 6-8ms.

**Alternatives rejected.**
- *Broadcast delivery (blanket broadcast of data, or one-message-per-file)* — LSP-style pull vs broadcast was debated and resolved in favor of pull; broadcasting where a single socket handles the case was rejected ('why are you broadcasting when a single socket handles this?'). User rejected copying orders of magnitude more data ('just copy 3 orders of magnitude more data because we're lazy') and per-file messaging ('one message per file sounds like orders of magnitude more latency').
- *Keep JSON-only IPC* — JSON IPC was the ~82ms bottleneck and could not meet the sub-16ms warm-path target; rkyv binary + magic-byte detection hit the 6-8ms target while keeping JSON as fallback.

**Consequences.** Daemon IPC is binary-first with JSON fallback selected by first-byte magic; pull is the delivery model and the daemon-client wire contract going forward. Schema version bumped 8->9 with BLOB storage and rkyv derives on Issue; clients must detect protocol by first byte. Performance target achieved: warm `rules run` dropped from ~90ms to 13-16ms, IPC to the 6-8ms range. This decision recurs across two independent introspection sources (the Apr 26-May 09 synthesis and the Apr 30 daily log), confirming it as a durable, deliberate outcome rather than a passing note. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-26-2026-05-09.md (27), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-26-2026-05-09.md (27), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-04-30.md (39), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-04-30.md (46).
