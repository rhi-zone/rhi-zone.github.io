# ADR-0140: Aspect multiplayer uses Y.js CRDTs instead of in-memory graph + snapshots

- Status: Accepted
- Date: 2026-05-29

**Context.** Aspect needed real-time multiplayer. Its prior model was an in-memory CardGraph with snapshot persistence, which does not support concurrent real-time editing.

**Decision.** Pivot aspect's state model to Y.js CRDTs for real-time multiplayer, replacing the in-memory CardGraph plus snapshot persistence. Presence/awareness is also built on Y.js.

**Alternatives rejected.**
- *Keep in-memory CardGraph with snapshot persistence* — Snapshot persistence cannot support real-time multiplayer concurrency; the log frames Y.js as a major architectural pivot away from snapshots to CRDTs.

**Consequences.** Aspect's persistence and editing model is now CRDT-based; export/import, presence, and entity modeling are built atop Y.js. The snapshot persistence path is abandoned. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-01-29.md (71), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-01-29.md (17).
