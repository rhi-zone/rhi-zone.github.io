# ADR-0026: Collapsed the normalize kg CLI from 11 verbs to 3 primitives (read/write/walk)

- Status: Accepted
- Date: 2026-05-29

**Context.** The normalize knowledge-graph (kg) CLI had grown to 11 verbs with overlapping, asymmetric, and redundant semantics. A refactor session/plan reframed the CLI's primitive vocabulary around three irreducible operations.

**Decision.** Collapse the kg CLI's 11 verbs into 3 primitive operations — read, write, walk — treated as irreducible operations, with jq embedding for composition. This is an asymmetry-elimination refactor: jq covers the composition the extra verbs provided. Overrideable excludes follow the same config discipline as existing settings.

**Alternatives rejected.**
- *Retain the existing 11-verb kg CLI surface* — The 11 verbs carried redundant, asymmetric semantics; the 3-primitive design collapses those asymmetries into irreducible operations, with jq covering the composition the extra verbs provided ("3 primitives collapse asymmetries").

**Consequences.** kg consumers now build on read/write/walk plus jq composition rather than a wide 11-verb surface; this constrains how new kg operations are added — compose, don't add verbs. Code was refactored and pushed the same day. A daemon CPU regression surfaced during implementation and was patched (not solved) via config-driven overrideable excludes; file-watching scalability remains a possible future concern. This decision recurs across two independent introspection sources — the May 21 daily log (capturing the refactor plan and implementation) and the 2026-05-10..05-29 synthesis (recording it as a single long session) — corroborating both the design and its same-day execution. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-05-21.md (9), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-05-21.md (12), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-05-21.md (27), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-05-10-2026-05-29.md (67).
