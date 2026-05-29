# ADR-0125: One-directional variable unification between $if and templates

- Status: Accepted
- Date: 2026-05-29

**Context.** Both $if expressions and Nunjucks templates consume variables, and it would be natural to share one variable namespace bidirectionally. But $if conditions are evaluated per-fact before the full template context exists.

**Decision.** Variable unification is one-directional: templates receive everything from ExprContext, but template-only variables (entities, others, memories, history, char, user) are NOT available in $if.

**Alternatives rejected.**
- *Bidirectional unification (give $if access to template-only variables too)* — $if conditions are evaluated per-fact before the full template context is assembled; exposing template-only variables to $if would require assembling the full context first, creating a circular dependency

**Consequences.** ExprContext is the shared base; template rendering adds template-only variables on top; fact macros are a separate string-replacement mechanism. Adding a variable to both means editing createBaseContext(); template-only additions live in template.ts. Mined from: /home/me/git/exoplace/hologram/docs/design/decisions.md (23), /home/me/git/exoplace/hologram/docs/design/decisions.md (29).
