# ADR-0075: Stay on JS Yjs as CRDT source of truth; defer Yrs/Loro

- Status: Accepted
- Date: 2026-05-29

**Context.** Y.js is the source of truth for all graph state and sets the performance floor for sync and materialization. Faster CRDT libraries exist (Yrs, Loro), and there were documented Yjs concerns (Y.Map write bloat, monotonic tombstone growth). A migration decision was needed.

**Decision.** Keep JS Yjs. Current stance: Yjs performance is acceptable. The real per-frame bottleneck was affordance evaluation (now resolved via an edge index), and sync overhead happens off the critical path. Revisit only if document sizes grow large or materialization becomes a bottleneck.

**Alternatives rejected.**
- *Loro (Rust + WASM)* — 'Different API and wire protocol — requires rewriting CardGraph, persistence, and sync layers' — rewrite cost not justified while Yjs is acceptable
- *Yrs (Rust port of Yjs)* — Protocol-compatible but 'Speeds up server-side work only' — does not address client materialization, limited benefit
- *V2 encoding (encodeStateAsUpdateV2)* — Better for large docs but 'worse for small incremental updates' and 'All clients must agree on encoding version'

**Consequences.** CardGraph, persistence, and sync stay on JS Yjs; no Rust CRDT dependency. Performance work is directed at app-level hot paths (affordance evaluation) rather than swapping the CRDT. Decision is explicitly revisitable on document-size growth. Mined from: /home/me/git/exoplace/aspect/docs/design/performance.md (92), /home/me/git/exoplace/aspect/docs/design/performance.md (94).
