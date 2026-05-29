# ADR-0073: Interaction model is structure-driven affordances, not language commands or fixed menus

- Status: Accepted
- Date: 2026-05-29

**Context.** There are three established paradigms for world interaction: MOO-style language commands (incantation), GUI fixed menus (selection), and structure-driven. Each trades off discoverability against flexibility.

**Decision.** Aspect interaction is structure-driven: the graph neighborhood plus world pack derive the available affordances, rendered as actionable UI. Affordances are always visible, contextual, and adaptive — 'if you can do it, you can see it.' The world tells you what you can do (declarative) rather than you telling the world what to do (imperative).

**Alternatives rejected.**
- *Language-driven (MOO command parser)* — 'Discoverability is poor: you read docs, ask other players, or guess'; requires learning verb syntax
- *Menu-driven (GUI fixed panels)* — 'Discoverability is high but flexibility is low: you can only do what the designers built buttons for'

**Consequences.** The UI surface must derive options from action preconditions evaluated against the current neighborhood; affordances cannot be hardcoded panels or typed commands. Adding graph state automatically changes available actions. Forecloses a typed-command parser as the primary interface. Mined from: /home/me/git/exoplace/aspect/docs/design/affordances.md (9), /home/me/git/exoplace/aspect/docs/design/affordances.md (13), /home/me/git/exoplace/aspect/docs/design/affordances.md (17).
