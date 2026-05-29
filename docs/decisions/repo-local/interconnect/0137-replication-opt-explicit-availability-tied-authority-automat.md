# ADR-0137: Replication is opt-in and explicit; availability is tied to authority (no automatic replication)

- Status: Accepted
- Date: 2026-05-29

**Context.** Once single-authority is chosen, the protocol must decide two coupled questions: what happens when the authoritative server is unreachable, and whether replication is built-in behavior or an application choice. Matrix-style replication would keep content available across authority loss but reintroduces the attack surface single-authority was meant to remove. Separately, different applications have conflicting replication needs (a game wants zero replication for authoritative simulation; a social profile wants CDN caching; a community wants designated mirrors), so the protocol must not impose one replication model on all of them.

**Decision.** Replication is opt-in, never automatic or emergent. If the authoritative server is down, content is inaccessible (ghost mode: substrate visible, simulation paused); content availability deliberately depends on server availability, the same model as traditional websites. Matrix-style replication of mutable state is rejected. Servers MAY optionally replicate content (read replicas, substrate caching, forwarding, explicit mirrors), but replication is never required or automatic. Mirrors are designated explicitly, not emergent. The application chooses the pattern.

**Alternatives rejected.**
- *Matrix-style replication so content survives authority loss* — Creates state-resolution attacks, history rewriting, split-brain merge chaos, and 'delete doesn't mean delete'; Project Hydra patches make the algorithm more complex, not simpler, and the multi-untrusted-server attack surface is inherent.
- *Automatic/required replication baked into the protocol* — Different applications have different needs (a game server wants zero replication, a social profile wants CDN caching); baking one in would impose costs others don't want, and emergent mirrors recreate the multi-copy problems single-authority avoids.

**Consequences.** When the authority is unreachable you get ghost mode (stale/paused), not corrupted state. Accepted tradeoff: availability == server availability. The protocol supports all four replication patterns but mandates none; applications opt in, and mirrors must be explicit. This keeps the default coherent with single-authority semantics and makes opt-in replication a separate, deliberate choice rather than a default. Mined from: /home/me/git/rhizone/interconnect/docs/design-decisions.md (7), /home/me/git/rhizone/interconnect/docs/design-decisions.md (19), /home/me/git/rhizone/interconnect/docs/design-decisions.md (23), /home/me/git/rhizone/interconnect/docs/design-decisions.md (29).
