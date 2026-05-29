# ADR-0239: rescribe operates strictly at the document IR layer

- Status: Accepted
- Date: 2026-05-29

**Context.** A document tool could grow to cover adjacent capabilities: layout-preserving PDF manipulation, image/video processing, spreadsheet computation, full execution of document programming languages. A scope boundary was needed.

**Decision.** An operation is in scope only if it can be expressed as parse to IR, transform IR, emit; anything requiring work below the IR layer (PDF binary manipulation, media processing, formula evaluation, Typst/LaTeX execution) is explicitly out of scope and belongs in a different tool.

**Alternatives rejected.**
- *Extend rescribe to layout-preserving PDF manipulation, media processing, and spreadsheet/document-language execution* — Those operate below the IR layer (on binary structure or via a language runtime); pulling them in would dissolve the clean parse-transform-emit boundary and turn rescribe into a different kind of tool.

**Consequences.** Sets a durable boundary: XLSX cells are extracted as data with formulas unevaluated, Typst/LaTeX capture static authored content only. Such needs are routed to other tools rather than absorbed. Mined from: /home/me/git/rhizone/rescribe/docs/introduction.md (93-95).
