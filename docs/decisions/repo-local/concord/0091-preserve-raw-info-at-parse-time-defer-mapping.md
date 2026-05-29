# ADR-0091: Preserve raw info at parse time; defer mapping decisions to target generators

- Status: Accepted
- Date: 2026-05-29

**Context.** When parsing an API spec into the IR, the parser could either normalize/map information into target-friendly forms eagerly, or capture everything verbatim and leave mapping to generators.

**Decision.** Don't lose information during parsing. The parser preserves raw info and lets target generators decide how to map it.

**Alternatives rejected.**
- *Normalize/lower information during parsing into a target-oriented form* — Eager normalization loses information that some target generator might need; preserving raw info keeps the IR a faithful superset and pushes mapping policy to the generator that has the target context.

**Consequences.** The IR stays source-faithful and generators carry the burden of mapping; this enables multiple divergent target languages from one parse. It also means the IR can contain target-irrelevant detail that each generator must filter. Mined from: /home/me/git/rhizone/concord/docs/design/ir.md (7).
