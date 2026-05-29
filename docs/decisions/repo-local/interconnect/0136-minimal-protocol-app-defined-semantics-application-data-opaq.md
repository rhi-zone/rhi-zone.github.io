# ADR-0136: Minimal protocol, app-defined semantics: application data is opaque bytes

- Status: Accepted
- Date: 2026-05-29

**Context.** A game, a social network, and a forum have different addressing, data, and subscription needs. The protocol must decide how much semantic structure to impose versus leaving to applications.

**Decision.** The protocol defines structure (message framing, identity format, content-addressed substrate verification), not semantics. Intent/Snapshot/Passport contents, server addresses, content references, and subscription meaning are application-defined and opaque to the protocol.

**Alternatives rejected.**
- *Encode subscription/intent/snapshot semantics and addressing schemes into the protocol* — A game's 'I'm in this room' differs from social's 'I follow this account' and a forum's 'I'm watching this thread'; the protocol shouldn't encode assumptions, and it should fit into existing systems rather than impose new addressing/data schemes.

**Consequences.** Applications bring their own Intent/Snapshot/Passport types and addressing; the protocol provides only handoff machinery and verification. Subscription is therefore necessarily app-level. Forecloses any protocol-level subscription or schema standard. Mined from: /home/me/git/rhizone/interconnect/docs/design-decisions.md (140), /home/me/git/rhizone/interconnect/docs/design-decisions.md (170).
