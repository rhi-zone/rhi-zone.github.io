# ADR-0188: Rendering and social surface are separate projects, not part of noncanon

- Status: Accepted
- Date: 2026-05-29

**Context.** A worldbuilding system naturally wants wiki views, graph views, social features, and conflict-resolution UIs. The design had to decide whether noncanon owns these or restricts itself to data and canon semantics.

**Decision.** noncanon handles only the data model and canon semantics; rendering (wiki/graph view), social features, wikis, and conflict-resolution UIs are deliberately excluded and live as separate projects.

**Alternatives rejected.**
- *Bundle rendering and social surface into noncanon* — Those are separate concerns; folding them in would make noncanon a platform again, contradicting the library/local-first framing.

**Consequences.** noncanon stays a library, not a platform. Rendering and social surfaces are deferred to separate projects (sits alongside hologram and aspect with a distinct primitive: canon acceptance). The scope boundary forecloses adding UI/social code to this repo. Mined from: /home/me/git/exoplace/noncanon/README.md (23), /home/me/git/exoplace/noncanon/CLAUDE.md (26).
