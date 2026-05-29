# ADR-0263: Entry points are supplied by context, not found by scanning every offset

- Status: Accepted
- Date: 2026-05-29

**Context.** Bytecode discovery needs a starting offset to begin decoding. The naive approach is to try decoding from every offset to find where a valid instruction stream begins. This is expensive and conflates entry-point detection with grammar discovery.

**Decision.** The discovery signal receives candidate entry points from the hypothesis engine (typically a preceding MagicBytes signal — ELF .text offset, WASM code section, .pyc bytecode start), plus offset 0 and user-annotated boundaries. It does not scan every offset for entry points.

**Alternatives rejected.**
- *Scan every offset for valid entry points* — Explicitly rejected: "It does not scan every offset for entry points." Entry-point discovery is the hypothesis engine's job, keeping the discovery signal focused and avoiding O(n) brute-force decode attempts.

**Consequences.** Separates concerns: MagicBytes/hypothesis layer feeds entry points; the bytecode signal consumes them. The discovery signal depends on upstream context rather than being self-sufficient about where to start. Mined from: /home/me/git/rhizone/tiltshift/DESIGN.md (151), /home/me/git/rhizone/tiltshift/DESIGN.md (151).
