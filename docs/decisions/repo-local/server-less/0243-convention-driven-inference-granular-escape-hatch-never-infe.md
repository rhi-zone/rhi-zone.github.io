# ADR-0243: Convention-driven inference with a granular escape hatch, never inference when it would surprise

- Status: Accepted
- Date: 2026-05-29

**Context.** Server-less must decide HTTP verbs/paths/parameter locations and CLI argument styles from method signatures. The library could require explicit configuration everywhere, or infer aggressively, or something in between.

**Decision.** Infer from names and types using a small set of well-known conventions; if a convention would surprise a reasonable developer reading the signature, require explicit config instead; and always provide a granular per-item escape hatch (#[route], #[param], #[cli]) so a single wrong result can be overridden without abandoning the derive.

**Alternatives rejected.**
- *Aggressive/total inference with no surprise guardrail* — Conventions that produce output not matching domain expectations (e.g. an ambiguous verb prefix) are rejected by the guiding test 'would a developer reading the function signature immediately understand the generated behavior?' If no, require explicit config rather than infer.
- *Abandoning the whole derive to fix one route (coarse escape hatch)* — The escape hatch is deliberately granular: you override just that method rather than dropping #[http]; dropping to manual Tower code is the nuclear option, not the per-route fix.

**Consequences.** Every inference rule (verb prefixes, _id->path, bool->flag, Vec->append) carries a matching override attribute. Unrecognized method prefixes fall back to POST with a deliberately odd plural path to prompt the user to add an override. The conservative _id suffix rule (not substring 'id') is locked in to avoid false positives. Mined from: /home/me/git/rhizone/server-less/docs/design/inference-vs-configuration.md (9-10), /home/me/git/rhizone/server-less/docs/design/inference-vs-configuration.md (202), /home/me/git/rhizone/server-less/docs/design/inference-vs-configuration.md (268).
