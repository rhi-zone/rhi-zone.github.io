# ADR-0157: CCv2 compatibility: dual-write coexistence, not migration

- Status: Accepted
- Date: 2026-05-29

**Context.** Crescent's first real app is a SillyTavern-compatible card runtime. A decision was forced on how Crescent relates to the existing CCv2 (SillyTavern character card) format: adopt-and-migrate to a native format, or coexist.

**Decision.** Cards carry SillyTavern fields (in PNG `tEXt` chunks with JSON) and Crescent extensions in the same metadata simultaneously; import/export round-trips both. CCv2 compatibility is treated as a transport layer rather than a schema, with no "our format vs their format" split.

**Alternatives rejected.**
- *Define a native Crescent format and migrate cards into it (treat CCv2 as a schema to convert from)* — Rejected to preserve coexistence: the same card can carry SillyTavern fields and Crescent extensions at once, avoiding an "our format" vs "their format" fork that would break interop

**Consequences.** The same card file remains valid in both ecosystems; round-trip import/export must preserve foreign fields. Forecloses ever introducing a migration-only native format. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-01-2026-04-20.md (117), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-01-2026-04-20.md (16).
