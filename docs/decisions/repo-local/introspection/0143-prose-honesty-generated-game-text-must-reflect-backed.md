# ADR-0143: Prose honesty: generated game text must reflect backed game state

- Status: Accepted
- Date: 2026-05-29

**Context.** The existence game's ambient/phone text was describing states the simulation could not back up (fake phone messages, phantom inbox, reused ambient events). The recurring choice was whether to keep patching these with bandaids (cap-and-reuse of events, fabricated artifacts) or to resolve them at the architectural level by forbidding any prose the systems can't justify.

**Decision.** Adopt 'prose honesty' as a first-class, encoded design principle: game text must reflect actual game state, and the engine must not generate artifacts (messages, events, descriptions) that no backing system can substantiate. Captured in CLAUDE.md/DESIGN.md rather than left as ad-hoc fixes.

**Alternatives rejected.**
- *Bandaid fixes: cap-and-reuse ambient events, fabricate phone/inbox artifacts to fill prose* — Called out as 'fundamentally wrong' / 'never acceptable' design; produces text the simulation cannot back up and degrades gameplay (e.g. idle scrollback).

**Consequences.** Every prose-generating subsystem now owes a backing system; new content cannot be hand-faked. Constrains the sensory-prose compositor, phone system, and ambient/event design that followed. Encoded as a durable principle in the game's CLAUDE.md/DESIGN.md. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-02-12.md (14), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-02-13.md (25-26).
