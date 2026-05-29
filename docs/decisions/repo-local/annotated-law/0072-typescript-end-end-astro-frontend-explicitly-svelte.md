# ADR-0072: TypeScript end-to-end with Astro frontend; explicitly not Svelte

- Status: Accepted
- Date: 2026-05-29

**Context.** The stack spans ingestion, IR storage, an LLM summary pipeline, and a content-heavy multi-view frontend. The project had to choose a language strategy and a frontend framework among the common content-site options.

**Decision.** TypeScript end-to-end as the single language for ingestion, IR, LLM pipeline, and frontend; Astro for the content-heavy four-view frontend, with SolidJS for interactive islands when interactivity is actually needed, and explicitly NOT Svelte. Runtime is bun, typecheck via tsgo, lint via oxlint.

**Alternatives rejected.**
- *Svelte for the frontend / interactive islands* — Explicitly rejected ('Explicitly NOT Svelte'); SolidJS is the chosen islands framework instead, layered under Astro for the content-heavy views.

**Consequences.** The whole codebase is one language (lower context-switch cost across ingestion/pipeline/frontend); the frontend is Astro-first with SolidJS islands. The repo scaffolding (flake provides bun, Astro config, TS-only src tree) already commits to this and forecloses adding a Svelte island. Mined from: /home/me/.claude/plans/snuggly-wobbling-melody.md (91), /home/me/.claude/plans/snuggly-wobbling-melody.md (90), /home/me/git/pteraworld/annotated-law/CLAUDE.md (9).
