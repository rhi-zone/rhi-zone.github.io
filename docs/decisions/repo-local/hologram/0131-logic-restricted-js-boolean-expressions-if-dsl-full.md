# ADR-0131: Logic via restricted JS boolean expressions ($if), not a DSL or full scripting

- Status: Accepted
- Date: 2026-05-29

**Context.** Hologram needs conditional logic in entity facts (response control, conditional traits) but facts are otherwise freeform prose. A mechanism was needed to express conditions without inventing a language, embedding an unsafe interpreter, or pushing logic into the LLM.

**Decision.** Conditions are expressed as restricted JavaScript boolean expressions introduced by `$if`, compiled once and cached, with safe globals (random, roll, has_fact, time, message context). No loops or assignment are permitted; expressions are boolean-only.

**Alternatives rejected.**
- *LLM as logic layer (describe intent, LLM executes)* — indirection causes hallucination when deterministic logic is available
- *Custom DSL for conditions* — another language to learn and maintain
- *Full scripting (Lua/JS sandbox)* — sandbox security is hard; complexity and risk
- *Structured data / enums for condition types* — opaque, doesn't nest, hard to fit in facts

**Consequences.** All conditional behavior in facts is gated through one evaluated expression language; new condition combinations emerge without code changes via && || !. Future content can mention `$if` syntax safely because directives are only recognized at line start. Adding a context variable means extending ExprContext. Mined from: /home/me/git/exoplace/hologram/docs/philosophy.md (250), /home/me/git/exoplace/hologram/docs/philosophy.md (214).
