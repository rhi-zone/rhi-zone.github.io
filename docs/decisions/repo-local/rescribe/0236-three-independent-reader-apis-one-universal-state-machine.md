# ADR-0236: Three independent reader APIs, not one universal state-machine primitive

- Status: Accepted
- Date: 2026-05-29

**Context.** Each standalone format crate must serve materialised-tree consumers, in-memory streaming consumers, and arbitrarily-large chunked-input consumers. The tempting design is one StateMachine::advance() that the other APIs derive from.

**Decision.** Expose three independent reader APIs — parse() (recursive descent to owned AST), events() (parser-IS-iterator over &[u8] yielding Event<'a> with Cow text), and StreamingParser<H: Handler> (chunked callback model) — sharing only plain state-transition functions, not a common runtime primitive.

**Alternatives rejected.**
- *A single StateMachine::advance() -> Event<'_> that everything derives from* — advance() borrowing from self's source buffer is a lending iterator the standard Iterator trait cannot express; the borrow situation differs between a caller-owned slice and an internal owned buffer, so the three cases are genuinely distinct, not stylistic variants.

**Consequences.** Every format crate implements all three APIs against shared parse_block/parse_inline/parse_escape functions with no trait objects, so the compiler inlines each path. The completion checklist and feature flags codify all three. More implementation surface per format than a single derived API would need. Mined from: /home/me/git/rhizone/rescribe/docs/format-library-design.md (48-49), /home/me/git/rhizone/rescribe/docs/format-library-design.md (59).
