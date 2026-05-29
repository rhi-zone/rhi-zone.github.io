# ADR-0068: Citation rigor replaces human-review governance as the trust mechanism

- Status: Accepted
- Date: 2026-05-29

**Context.** A legal-summary product needs a trust model. The two available models are reviewer governance (a human review team approves summaries, ToS;DR/Wikipedia style) versus verifiable per-claim citations to primary sources. A review-team flywheel implies governance overhead and gatekeeping; the project has no review team and wants automation quality to be the focus.

**Decision.** Trust in annotated-law comes from verifiable primary-source citations, not reviewer governance: every claim in a generated summary must trace to a specific IR node, a verification pass checks the cited source actually supports the claim, and there is no mandatory human-review gate (community edits/disputes are a deferred later layer).

**Alternatives rejected.**
- *Mandatory human-review gate / reviewer-governance flywheel (ToS;DR / Wikipedia model) as the trust layer* — Trust is instead placed in citation rigor — 'a reader can always verify any sentence against primary source' — which replaces formal human review; a review-team flywheel is explicitly something the project does not have to worry about, removing governance as a dependency.

**Consequences.** Every summary sentence must be citation-tagged to IR node(s) and run through a verification pass before display; no reviewer sign-off blocks publication. Open: the verification pass design (separate LLM call vs rules-based check) and how community dispute/edit governance layers on later. Mined from: /home/me/.claude/plans/snuggly-wobbling-melody.md (88), /home/me/.claude/plans/snuggly-wobbling-melody.md (23), /home/me/.claude/plans/snuggly-wobbling-melody.md (54).
