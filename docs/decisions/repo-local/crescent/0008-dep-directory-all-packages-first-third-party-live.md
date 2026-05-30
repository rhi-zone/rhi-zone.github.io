# ADR-0008: No dep/ directory: all packages (first- and third-party) live under lib/, no path rewriting ever

- Status: Accepted
- Date: 2026-05-29

**Context.** The package manager needed a directory and require-resolution model. An earlier model (reflected in README and ecosystem-design) had a separate dep/ directory for installed dependencies. The pkg-design needed to settle where installed packages land and how versioning resolves.

**Decision.** Everything lives under lib/; there is no separate dep/ directory. First-party and third-party code are both just directories under lib/ resolved by require via package.path. lib/ is not configurable — 'the convention is the design.' Multiple major versions coexist as versioned subdirectories (lib/foo/v1, lib/foo/v2) resolved by plain ?/init.lua path patterns. The package manager hardlinks/copies files into place but never rewrites require paths — authors write the versioned require path themselves at development time.

**Alternatives rejected.**
- *Separate dep/ directory for installed third-party packages, distinct from first-party lib/* — The distinction between first-party and third-party code is irrelevant to the runtime — both are just directories under lib/ that require resolves. A separate dep/ adds a meaningless boundary.
- *Package manager rewrites require paths on install to handle versioning* — Rejected explicitly ('No path rewriting, ever'). The version subdirectory is part of the author-written require path, not an install artifact; rewriting would couple install mechanics to source.

**Consequences.** Installer is a file-copy/hardlink into lib/ with no path mutation; version coexistence relies on author-written versioned require paths and an optional author-shipped redirect at lib/<name>/init.lua. Note this supersedes the older dep/-based description still present in ecosystem-design.md and README. Mined from: /home/me/git/rhizone/crescent/docs/pkg-design.md (16), /home/me/git/rhizone/crescent/docs/pkg-design.md (47).

**Note (review cross-reference).** Reconciled with ADR-0007 (stdlib zero-dep, dep/ stopgaps) as end-state-vs-transitional, not a contradiction: ADR-0007 endorses the existing dep/ directory only as a transitional stopgap slated for removal; this ADR specifies the end-state layout in which dep/ does not exist and all packages live under lib/. The two describe the same trajectory at different points in time.
