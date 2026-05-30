# ADR-0007: Stdlib has zero external dependencies; vendored third-party packages are stopgaps to be removed

- Status: Accepted
- Date: 2026-05-29

**Context.** Crescent's value is 'own your dependencies' — every library copy-paste-ownable with no upstream to break you. But the repo currently has a dep/ directory with vendored third-party packages (lunajson, sha1) predating the package manager. A rule was needed on whether stdlib may depend on outside packages.

**Decision.** lib/ is self-contained: stdlib libraries must NOT depend on packages outside the repo. If a stdlib library needs functionality (e.g. JSON parsing), it gets a crescent-native implementation written from scratch to meet the bar, not a vendored third-party dependency. Currently vendored packages (dep/lunajson, dep/sha1) are explicitly stopgaps that will be replaced with native implementations or removed as the stdlib matures. Third-party predecessors belong in the registry (via cr add), not in lib/.

**Alternatives rejected.**
- *Keep depending on existing vendored third-party Lua packages (lunajson, sha1, etc.) inside the stdlib* — Their interfaces may not be consistent with crescent's conventions; a reference stdlib must be written from scratch to meet the quality/convention bar. Vendored deps are stopgaps predating the package manager.

**Consequences.** Every stdlib capability must eventually have a native, convention-compliant implementation; dep/ contents are transitional and slated for removal. Forecloses pulling in outside Lua libraries to fill stdlib gaps. Mined from: /home/me/git/rhizone/crescent/docs/ecosystem-design.md (127-131).

**Note (review cross-reference).** Reconciled with ADR-0008 (no dep/ directory) as transitional-vs-end-state, not a contradiction: this ADR treats the existing dep/ contents (lunajson, sha1) as transitional stopgaps to be removed; ADR-0008 specifies the end-state package-manager layout in which no dep/ directory exists and all packages live under lib/. The stopgaps 0007 slates for removal are exactly what 0008's end-state eliminates.
