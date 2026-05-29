# ADR-0114: NPCs are live-simulated at dynamic resolution (never zero); labels/archetypes/flavors are banned

- Status: Accepted
- Date: 2026-05-29

**Context.** Friends, coworkers, and family were driven by labels — flavors (sends_things, warm_quiet), archetypes (warm_caring, critical), and family_sketch tag arrays — that select prose from lookup tables. A labeled NPC behaves identically every day because the label never changes.

**Decision.** Replace labels with live state: continuous personality params (warmth, openness, stability), a drifting stress value, life facts (children with ages, parent_health, has_partner, employment_stable), active life events generated each sleep cycle via backgroundRng, and an evolving relationship (trust, contact_recency). Behavior emerges from current state. Resolution scales continuously with proximity/contact (high/medium/low/ephemeral) but the floor is never zero — every named person has a drifting stress, one event slot, and a relationship state.

**Alternatives rejected.**
- *Keep the label/archetype/flavor model (lookup-table prose dispatch)* — Labels skip simulation: a 'stressed_out' coworker is always stressed and a 'warm_quiet' friend is always warm, because nothing is actually happening in their life; this violates simulate-ground-truth, dynamic-resolution-never-zero, and fairness-to-all-characters. Labels are short-circuits, not low-resolution simulation.

**Consequences.** Coworkers (v33), friends (v34), and family (v34) migrated to live state; family_archetype, family_sketch tags, and flavor-keyed prose tables are removed/superseded; NT-target coupling must re-ground from category to parameters+state. NPC state is persisted in the run record and event generation must be deterministic for replay. Dynamic resolution scaling and ephemeral-stranger sim remain designed-but-unbuilt. Mined from: /home/me/git/paragarden/existence/docs/design/npc-simulation.md (16), /home/me/git/paragarden/existence/CLAUDE.md (107), /home/me/git/paragarden/existence/docs/design/npc-simulation.md (316).
