# ADR-0145: Frontend/backend-specific compiler passes isolated, not baked into the shared backend

- Status: Accepted
- Date: 2026-05-29

**Context.** Reincarnate's TypeScript backend contained hardcoded Flash-specific logic (flash_system_module, emit.rs rewrites), and the GML AND/OR heuristics had been placed in the general structurize pass. This raised the question of whether the shared backend should special-case individual source languages at all.

**Decision.** The backend must treat source-language specifics (Flash, GML) as configuration, not as first-class shared logic: isolate Flash rewrites into their own backend modules, move GML-specific passes (e.g. AND/OR heuristics) into a GML-specific layer, and add an extra_passes mechanism letting each frontend and backend inject its own passes.

**Alternatives rejected.**
- *Keep language-specific rewrites/heuristics baked globally into the shared AST/structurize/backend* — Makes the backend treat one language as a first-class citizen, which doesn't scale across engines; the global GML AND/OR heuristic was flagged as belonging in a GML-specific layer, and global Flash rewrites were the architecture screaming under growth.

**Consequences.** Each source language's quirks live in its own injected passes; the shared compiler core stays language-agnostic, and new engines plug in via extra_passes rather than editing shared code. Sets the structural contract for how per-language behavior is added going forward. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-02-21.md (33), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-02-10.md (20).
