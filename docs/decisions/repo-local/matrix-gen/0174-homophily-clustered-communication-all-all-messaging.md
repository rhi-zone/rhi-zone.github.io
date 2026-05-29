# ADR-0174: Homophily-clustered communication, not all-to-all messaging

- Status: Accepted
- Date: 2026-05-29

**Context.** Agents must communicate, but naive all-to-all messaging scales quadratically with agent count and ignores real social structure.

**Decision.** Group agents by profile-embedding similarity via constrained K-means; LLM-powered modulators route relevant messages within clusters and gate communication across clusters.

**Alternatives rejected.**
- *All-to-all messaging between agents* — It suffers a quadratic blow-up and ignores the sociological observation that similar people cluster; homophily-guided clustering avoids the blow-up.

**Consequences.** Communication is mediated by clusters + modulators (constrained K-means over embeddings). Message volume scales sub-quadratically; cross-cluster contact is gated semantically rather than open. Mined from: /home/me/git/pterror/matrix-gen/docs/introduction.md (11).
