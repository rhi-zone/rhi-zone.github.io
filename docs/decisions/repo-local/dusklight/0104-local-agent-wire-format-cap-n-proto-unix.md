# ADR-0104: Local agent wire format is Cap'n Proto over Unix socket

- Status: Accepted
- Date: 2026-05-29

**Context.** Some sources cannot run in-browser (SQLite, filesystem, processes) and must reach a local agent. The wire format between Dusklight and the agent needs to carry the object-capability model that the rest of the system relies on.

**Decision.** The local agent protocol is Cap'n Proto over a Unix socket. It was chosen specifically because Cap'n Proto has first-class capability support built into the protocol, so the ocap model maps directly onto the wire format rather than being bolted on. The protocol is open; any conforming agent works.

**Alternatives rejected.**
- *A wire format without native capability support (capabilities layered on top)* — Rejected — with such formats the ocap model would be bolted on; Cap'n Proto's first-class capability support lets the model map directly onto the wire

**Consequences.** Rust agent and native clients get full zero-copy; TS clients forgo zero-copy but keep schema and capability semantics. dusklight-agent is the reference implementation but the open protocol allows alternatives. Mined from: /home/me/git/rhizone/dusklight/docs/architecture.md (206).
