# ADR-0102: Complex UIs composed from layout primitives, not monolithic renderer plugins

- Status: Accepted
- Date: 2026-05-29

**Context.** A universal UI client must produce complex interfaces (e.g. a chat UI). It could ship bespoke composite renderer plugins for each, or provide a small set of primitives and compose everything.

**Decision.** Define only layout primitives (HStack, VStack, ZStack, Grid, Spacer, ForEach, ...) and compose everything else. Layout is data — a JSON tree of nodes referencing renderers/sources, wired by Marinada expressions. A "chat UI" is a layout, not a bespoke plugin. CSS is an implementation detail the layout model does not expose; data scoping flows through composable optics with no read/write asymmetry.

**Alternatives rejected.**
- *Implement complex UIs as monolithic renderer plugins (a bespoke 'chat UI' plugin)* — Rejected — "define only primitives, compose everything else"; a chat UI is just a layout (message list + input + action trigger), no bespoke plugin required

**Consequences.** Layout is first-class data, not an afterthought. Each node carries an optional optic; children compose onto the parent's, reads and writes through the same optic. ForEach is a traversal giving each item a scoped lens. All layout properties are Marinada expressions with compiler-emitted reactive wiring. Mined from: /home/me/git/rhizone/dusklight/docs/architecture.md (112), /home/me/git/rhizone/dusklight/docs/architecture.md (131).
