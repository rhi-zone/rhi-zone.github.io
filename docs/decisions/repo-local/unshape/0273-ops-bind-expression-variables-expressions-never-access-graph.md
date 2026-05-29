# ADR-0273: Ops bind expression variables; expressions never access graph EvalContext

- Status: Accepted
- Date: 2026-05-29

**Context.** Expressions need values like position, normal, uv, time, resolution to evaluate. There is a choice between letting expressions reach into the graph EvalContext directly versus having ops explicitly supply the variables.

**Decision.** Expressions do not access EvalContext directly. Instead, ops bind variables into an ExprContext when invoking an expression (e.g. a mesh vertex op binds position/normal/uv/time; a texture op binds uv/time/resolution). Well-known variable IDs are defined per domain.

**Alternatives rejected.**
- *Expressions read the graph EvalContext directly* — Creates implicit coupling between expressions and graph context, prevents the same expression type from working across different contexts, and obscures what variables exist where

**Consequences.** No implicit coupling between expressions and graph context; ops explicitly control the exposed variable set; the same expression type is reusable across mesh/texture/audio domains; available variables per domain are documented. Each op must explicitly declare its bindings. Mined from: /home/me/git/rhizone/unshape/docs/design/expression-language.md (498), /home/me/git/rhizone/unshape/docs/design/expression-language.md (526).
