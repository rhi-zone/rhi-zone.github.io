# ADR-0095: Perform is the sole mutation boundary; all other Expr forms are pure

- Status: Accepted
- Date: 2026-05-29

**Context.** An evaluator that walks rule ASTs could allow mutations and side effects anywhere, or it could confine them. defocus needs deterministic replay and clear reasoning about handler behavior, which is easier if side effects are localized.

**Decision.** `["perform", tag, ...]` is the sole mutation boundary in Expr evaluation; it generates an Effect (SetState, Send, Reply, Schedule, Spawn, or Remove). All other Expr forms are pure — they compute values but produce no side effects. The handler returns effects; the runtime applies them.

**Alternatives rejected.**
- *Allow side effects/mutations from ordinary Expr forms (treat Perform as a regular function call)* — If any Expr could mutate, evaluation would be impure and harder to reason about and replay; confusing Perform with a regular function call leads to expecting mutations from pure Exprs. Confining effects to Perform keeps the rest of the language pure and replay-friendly.

**Consequences.** Effects are the only way objects change state or communicate, and they are applied by the runtime rather than during expression evaluation. This supports deterministic replay and clean separation between computation and mutation. Every effect kind must be enumerable and serializable. Mined from: /home/me/git/rhizone/defocus/CONTEXT.md (57-58), /home/me/git/rhizone/defocus/CONTEXT.md (63).
