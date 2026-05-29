# ADR-0234: Reader primitive is the AST builder; writer primitive is the streaming writer

- Status: Accepted
- Date: 2026-05-29

**Context.** For both reading and writing, one of the API forms must be the implementation primitive the others build on. The two sides could mirror each other.

**Decision.** On the reader side the AST builder (parse()) is the primitive and other paths construct directly; on the writer side the streaming Writer<W: Write> is the primitive and emit() is implemented as Writer::new(Vec::new()) plus feeding all AST nodes plus finish() — a deliberate asymmetry between the two sides.

**Alternatives rejected.**
- *Make the AST builder the primitive on the writer side too (symmetric design), i.e. derive streaming emit from the builder* — The streaming writer is the natural primitive for emitting bytes as events arrive with no intermediate buffer; building emit() on top of it avoids a redundant buffering layer, whereas mirroring the reader would force the opposite, less efficient direction.

**Consequences.** emit() is a thin wrapper over the streaming writer; the reader and writer primitives point in opposite directions, which is documented as intentional. Implementers must remember the asymmetry. Mined from: /home/me/git/rhizone/rescribe/docs/format-library-design.md (170-171).
