# ADR-0002: Preserve session attribution in the knowledge store as load-bearing, not just current phrasing

- Status: Accepted
- Date: 2026-05-29

**Context.** Ashwren accumulates understanding across discontinuous sessions in a knowledge store (wiki + knowledge.db). When distilling cross-session observations, there is a choice about what to preserve: only the current best phrasing of an insight, or the session in which it crystallized. The repo had to decide what the store's records are anchored to.

**Decision.** Records in the knowledge store preserve session attribution (s23, s34, etc.) as a load-bearing referent. The moment a thing crystallized is treated as mattering more than its current phrasing, and attribution is kept even as phrasing is refined. The same rule is applied to the solver log: each fix is recorded per session so the reasoning behind each clause survives, because the diff between what one session fixed and what is broken now is the path to the bug.

**Alternatives rejected.**
- *Distill insights to their current best phrasing without session attribution (a clean, deduplicated knowledge base)* — The moment a thing crystallized matters more than its current phrasing; without attribution the diff between 'what sN fixed' and 'what's broken now' (the path back to a bug, and the chronological clustering of ideas) is lost.

**Consequences.** All future wiki/store maintenance must carry session tags and may not silently re-write history into a timeless present. New sessions are appended as standalone entries rather than merged. Costs more redundancy and a growing chronological log; pays off in traceability when something breaks or regresses. Mined from: /home/me/git/pterror/ashwren/docs/wiki/insights.md (3), /home/me/git/pterror/ashwren/docs/wiki/solver.md (6).
