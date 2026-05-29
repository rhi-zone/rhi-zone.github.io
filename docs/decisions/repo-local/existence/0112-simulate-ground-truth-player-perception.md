# ADR-0112: Simulate ground truth, not player perception

- Status: Accepted
- Date: 2026-05-29

**Context.** A simulation could track what the character has observed/knows as a layer, or it could track the underlying reality and derive perception. The former is the intuitive route for a narrative game.

**Decision.** The simulation models what is actually happening in the world. The character's perception is derived from that and is the reader's job, not a stored simulation layer. The game does NOT track 'what the character has observed' as a layer; it tracks what's real. A fact (a coworker's child being sick) exists in the simulation regardless of whether the character knows.

**Alternatives rejected.**
- *Track the character's perceptions/knowledge as a simulation layer* — Modeling perception as state conflates what's real with what's known; the design instead keeps reality canonical and treats noticing/inferring/misunderstanding as downstream prose output, so the world stays honest independent of the viewpoint.

**Consequences.** Every NPC and system stores ground-truth state; the prose layer filters it through attention and relationship. No 'observed-by-character' bookkeeping is permitted as state. This pairs with the NPC dynamic-resolution model where the sim 'knows why' even when the player doesn't. Mined from: /home/me/git/paragarden/existence/CLAUDE.md (105), /home/me/git/paragarden/existence/docs/design/npc-simulation.md (34).
