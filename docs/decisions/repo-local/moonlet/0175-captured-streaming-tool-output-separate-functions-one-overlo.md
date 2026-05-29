# ADR-0175: Captured vs streaming tool output via separate functions, not one overloaded call

- Status: Accepted
- Date: 2026-05-29

**Context.** Tool/test execution needs both synchronous captured output and incremental streaming output; needed to decide whether one function serves both.

**Decision.** Provide distinct functions: a captured synchronous run (tools.test.run) and a streaming variant returning a handle (tools.test.start), rather than overloading a single function.

**Alternatives rejected.**
- *A single overloaded function that returns either a result or a handle depending on options* — Overloading makes return types ambiguous; separate functions have clear, unambiguous signatures.

**Consequences.** The sync/streaming split is fixed across the tool API; the streaming path is the Handle-based async design; signatures stay statically clear. Mined from: /home/me/git/rhizone/moonlet/docs/design/moss-integrations.md (190), /home/me/git/rhizone/moonlet/docs/design/moss-integrations.md (206).
