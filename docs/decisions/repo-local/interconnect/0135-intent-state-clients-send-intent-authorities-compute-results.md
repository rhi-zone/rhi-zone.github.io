# ADR-0135: Intent over state: clients send intent, authorities compute results

- Status: Accepted
- Date: 2026-05-29

**Context.** Any room where clients can cheat must decide whether to trust client-declared state. Trusting client state enables history-rewrite and state-injection attacks; this is the security foundation of the protocol.

**Decision.** Clients send intent ('I want to do X'); servers compute results ('You are now Y'). Clients declaring their own state, sending deltas to merge, or being trusted with client-provided data are explicitly not supported. The authority is the source of truth.

**Alternatives rejected.**
- *Let clients declare/merge their own state (client-authoritative or delta-merge)* — Clients can lie, be buggy, or be malicious; trusting client state permits history-rewrite and state-injection attacks, so the server must be the source of truth.

**Consequences.** Eliminates entire attack classes (history rewrite, state injection) by construction. Application-defined intents in, authoritative snapshots out. Does not prevent social abuse/bots, but removes state injection. Underpins the security model. Mined from: /home/me/git/rhizone/interconnect/docs/design-decisions.md (174), /home/me/git/rhizone/interconnect/docs/security.md (11).
