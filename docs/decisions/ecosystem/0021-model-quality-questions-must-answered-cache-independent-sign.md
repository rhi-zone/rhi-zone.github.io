# ADR-0021: Model-quality questions must be answered with cache-independent signals, not aggregate cost/token metrics

- Status: Accepted
- Date: 2026-05-29

**Context.** The investigation needed to test whether Claude's performance was degrading (H-MODEL-REGRESSION) over a 60-day corpus. Measuring cache efficiency showed it sat at effectively 100.0% across all sub-windows (a ~10,000:1 cache_read-to-input ratio even on first turns), meaning aggregate token-volume and cost metrics are structurally insensitive to model quality changes. A method had to be chosen for what evidence counts as admissible when judging model quality.

**Decision.** Establish as a standing epistemic constraint that any 'is the model getting better or worse?' question must be answered using cache-independent quality proxies — tool-error baselines, user-affect/correction deltas, and turn-to-resolution metrics — and explicitly NOT aggregate cost or token-volume/cache trends. The investigation's Phase A/B methodology was bound by this: H-MODEL-REGRESSION was killed not by token stats but by cache-independent signals (model-switch direction, user-affect grep).

**Alternatives rejected.**
- *Use aggregate token-volume and cost trend analysis to detect model regression/improvement over time* — At 100.0% cache efficiency the cost and token counters are dominated by model-independent cache_read; quality changes produce no observable signal. Absence of metric change is not evidence of model stability — and the masking is symmetric, hiding improvements too.

**Consequences.** Future ecosystem-quality investigations are constrained to cache-independent signals; cost/token dashboards are disqualified as quality evidence. What remains open: none of the cache-independent proxies (tool-error rates, user-affect counts, turn-to-resolution) has yet been baselined as a timeseries against a counterfactual, so the ecosystem still lacks a usable quality trend line. Mined from: /home/me/git/rhizone/github-io/docs/introspection/investigations/2026-05-20-whats-wrong/registry/H-CACHE-MASKS-DEGRADATION.md (119), /home/me/git/rhizone/github-io/docs/introspection/investigations/2026-05-20-whats-wrong/registry/H-CACHE-MASKS-DEGRADATION.md (35), /home/me/git/rhizone/github-io/docs/introspection/investigations/2026-05-20-whats-wrong/registry/H-CACHE-MASKS-DEGRADATION.md (119).
