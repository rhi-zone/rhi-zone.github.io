# ADR-0081: Composition strictly dominates monolithic frameworks: every named thing is a primitive or a pattern, never a framework or base class

- Status: Accepted
- Date: 2026-05-29

**Context.** A stage library could be shaped as a framework that stages extend, or as a toolbox of independently composable pieces. This decision fixes the shape for every primitive and pattern added.

**Decision.** Every named thing in the library is either an architecturally distinct primitive OR a pattern (a callable composer of primitives) — never a framework, base class, or hidden monolith. Patterns are 90% wiring + 10% defaults with no private state and no new mechanics; if a pattern grows logic, that logic is a missing primitive to extract. The stage still extends StageBase, but its hooks delegate to small modules.

**Alternatives rejected.**
- *A monolithic framework / base-class hierarchy stages inherit from* — Removes the author's ability to choose abstraction level at the import statement (raw primitive for control vs pattern for ergonomics); hides mechanics in a monolith.
- *Letting a pattern accumulate its own logic/private state* — Logic in a pattern signals a missing primitive; it must be extracted first rather than living in the composer.

**Consequences.** Forecloses ever shipping a framework abstraction in this library. Any new capability must be classified as primitive, pattern, or recipe; patterns may not hold state or mechanics. Mined from: /home/me/git/pterror/chub-stage-factory/CLAUDE.md (15), /home/me/git/pterror/chub-stage-factory/CLAUDE.md (15).
