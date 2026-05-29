# ADR-0133: Algorithm-agnostic identity: scheme:payload, verification is deployment-specific

- Status: Accepted
- Date: 2026-05-29

**Context.** Every federated protocol invents an identity scheme (email user@domain, Matrix @user:server, ActivityPub WebFinger, DIDs). Picking wrong is expensive and migrating is painful. Interconnect must avoid locking in one scheme.

**Decision.** Identity is a string of the form algorithm:payload. The protocol passes identity around; verification is deployment-specific. Schemes (ed25519, dilithium, url, local) coexist, letting deployments start with local:/url: and migrate to cryptographic or post-quantum identity later without protocol changes.

**Alternatives rejected.**
- *Commit to a single fixed identity scheme (e.g. keys-only, or DNS-based like Matrix)* — Picking wrong is expensive and migrating is painful; different deployments have different trust requirements, and a fixed scheme blocks post-quantum migration.

**Consequences.** Deployments choose trust model (cryptographic, delegated, or local) without protocol changes; migration to post-quantum is a deployment change, not a protocol break. Open questions remain: key rotation/recovery, human-readable names, and key discovery. Mined from: /home/me/git/rhizone/interconnect/docs/design-decisions.md (40), /home/me/git/rhizone/interconnect/docs/why-interconnect.md (43).
