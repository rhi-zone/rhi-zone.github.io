# ADR-0082: One repo per Chub stage (factory pattern), not a monorepo or generic template

- Status: Accepted
- Date: 2026-05-29

**Context.** Each Chub stage is a small, self-contained artifact with its own design notes, test data, and deploy credentials. The question was how to host the lifecycle of many such stages.

**Decision.** Scaffold a deliberately single-use repo per stage: one repo holds one stage's DESIGN.md (the actual design), its commits (the actual implementation), and its deploy config. The factory clones a fresh workspace per stage rather than accumulating stages in one place.

**Alternatives rejected.**
- *A monorepo of stages* — Would couple the stages' lifecycles.
- *A generic reusable template* — Would lose the design context (the per-stage DESIGN.md as authoritative spec).

**Consequences.** Every stage gets an isolated history; DESIGN.md is authoritative per artifact. Implies repo proliferation (one per stage) and that ecosystem-common rules must be propagated into each. Mined from: /home/me/git/pterror/chub-stage-factory/CLAUDE.md (57), /home/me/git/pterror/chub-stage-factory/CLAUDE.md (57).
