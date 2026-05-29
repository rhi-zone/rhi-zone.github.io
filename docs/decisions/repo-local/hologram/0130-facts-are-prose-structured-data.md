# ADR-0130: Facts are prose, not structured data

- Status: Accepted
- Date: 2026-05-29

**Context.** Entity facts feed an LLM. They could be stored as structured key/value syntax (parseable, machine-friendly) or as freeform natural-language prose.

**Decision.** Facts are freeform natural-language prose rather than structured syntax. (Facts matching a `key: value` pattern are still parsed into `self` for expressions, but the canonical fact form is prose.)

**Alternatives rejected.**
- *Structured syntax (e.g. body:ears: type=fox, color=orange)* — adds parsing overhead; forces the model to parse format AND understand meaning, whereas prose lets it focus on meaning

**Consequences.** Authors write facts the way a human would describe them; the LLM reads them naturally. The system avoids a parsing/format layer for fact content. Style flexibility (discrete facts vs prose paragraphs) is explicitly supported downstream. Mined from: /home/me/git/exoplace/hologram/docs/philosophy.md (27), /home/me/git/exoplace/hologram/docs/philosophy.md (39).
