# ADR-0066: Iris core requires no external infrastructure; complexity is opt-in

- Status: Accepted
- Date: 2026-05-29

**Context.** Iris analyzes agent session logs to author insight content. The design had to decide whether retrieval/clustering infrastructure (embeddings, vector DBs) is part of the baseline or an optional add-on, given that for small session counts the LLM context window already suffices.

**Decision.** Core Iris works without embeddings, vector DBs, or external services beyond the LLM: the pipeline is a stateless read -> format -> single LLM call -> markdown. Embeddings/clustering/RAG/temporal modules are opt-in extensions added only when a real limitation is hit, each independent and toggleable.

**Alternatives rejected.**
- *Make embeddings / vector storage / RAG retrieval part of the baseline architecture* — Raises the barrier to entry and adds infrastructure complexity; for small session counts the context window is sufficient, so complexity should be opt-in, not required. 'Start simple, add complexity only when we hit real limitations.'

**Consequences.** Basic Iris works out of the box with only an LLM. Embeddings remain possible later (e.g. via moonlet-embed) as an optional enhancement, not a precondition. Extension points (history, split, cluster, temporal) exist but are off-by-default; whether any should default on is an open question. Mined from: /home/me/git/rhizone/zone/docs/design/iris.md (112), /home/me/git/rhizone/zone/docs/design/iris.md (117), /home/me/git/rhizone/zone/docs/design/iris.md (63), /home/me/git/rhizone/zone/docs/design/iris.md (71).
