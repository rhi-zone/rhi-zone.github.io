# ADR-0069: Event-driven freshness over blind poll-and-diff (deferred to Phase 4)

- Status: Accepted
- Date: 2026-05-29

**Context.** Laws change, and stale summaries are a correctness/trust hazard. Keeping the corpus current can be done by periodically polling sources and diffing, or by subscribing to legislative-tracker and court feeds and reacting to change events.

**Decision.** Freshness will be event-driven: subscribe to legislative-tracker / court feeds per jurisdiction and, on change, re-ingest affected nodes, diff, enqueue affected summaries for re-review, and surface a 'law changed, summary updating' status — rather than polling-and-diffing blindly. This infrastructure is explicitly deferred until Phase 4; snapshot-based is fine until breadth (Phase 3) justifies it.

**Alternatives rejected.**
- *Poll-and-diff the sources on a schedule* — Characterized as polling 'blindly'; the chosen model reacts to actual change events from trackers/feeds, avoiding wasteful blind polling and giving precise per-node re-ingestion triggers.

**Consequences.** The directional freshness model is fixed, but the implementation is parked behind Phase 4; until then snapshot-based ingestion is acceptable. Re-ingestion must be node-granular and must feed the summary re-generation queue when activated. Mined from: /home/me/.claude/plans/snuggly-wobbling-melody.md (15), /home/me/.claude/plans/snuggly-wobbling-melody.md (81).
