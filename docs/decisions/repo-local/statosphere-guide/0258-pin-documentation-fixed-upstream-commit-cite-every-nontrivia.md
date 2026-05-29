# ADR-0258: Pin documentation to a fixed upstream commit and cite every nontrivial claim with a permalink

- Status: Accepted
- Date: 2026-05-29

**Context.** Statosphere is a third-party tool whose upstream README is only two lines; the substantive user-facing documentation is buried inside public/chub_meta.yaml's creator_notes, and the codebase is the only authoritative source for behavior. A guide that describes a moving, under-documented codebase risks silently drifting out of sync as upstream changes, leaving claims unverifiable.

**Decision.** The guide is pinned to a single upstream commit (e67cd9ffaf1ee63e7b5c7bce11462516f547f5f7), and every nontrivial claim must cite a source permalink at that pinned commit. This makes the codebase legible and every assertion independently checkable against a frozen reference point.

**Alternatives rejected.**
- *Document against upstream HEAD / latest without pinning, citing the live repo* — Upstream is an under-documented moving target (two-line README, real docs hidden in chub_meta.yaml); citing a moving HEAD would let claims silently drift out of sync and become unverifiable, defeating the goal of making the codebase legible.
- *Write a prose guide without per-claim source citations* — As a third-party guide not produced or endorsed by the upstream maintainers, unsourced claims carry no authority; tying each claim to a permalink at the pinned commit is what makes the guide trustworthy and auditable.

**Consequences.** All current and future doc pages must anchor nontrivial claims to permalinks at the pinned commit. Updating to a newer upstream version is a deliberate, repo-wide re-pinning effort (commit hash appears in README.md and CLAUDE.md), not an incremental drift. Verification of any claim is reduced to following its permalink. Mined from: /home/me/git/pterror/statosphere-guide/CLAUDE.md (13), /home/me/git/pterror/statosphere-guide/CLAUDE.md (15), /home/me/git/pterror/statosphere-guide/README.md (11).
