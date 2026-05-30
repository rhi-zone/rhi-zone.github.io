# ADR-0101: In-world documents only: no omniscient narrator

- Status: Accepted
- Date: 2026-05-29

**Context.** Divergence is a worldbuilding site where every node must read as something that exists. A choice was needed for how content is voiced: an authorial/explanatory voice describing the world, or artifacts produced by people inside the world.

**Decision.** Every document is written as if it exists inside the world (messages, pages, notes, posts) with a specific in-world narrator who determines register; there is no omniscient narrator and no document explains the world from outside.

**Alternatives rejected.**
- *Omniscient/authorial narrator that explains how the world works (civics-lesson framing, system diagrams)* — Utopia zooms out and loses the person; if a document is explaining how the world works from outside, it's wrong — the intimate scale is load-bearing and is the texture legacy can't have

**Consequences.** All future content must be attributable to an in-world author with a determinate register; documents that drift into explaining the world are rejected. Open: many existing nodes (bakery, building) still need a narrator assigned. Mined from: /home/me/git/paragarden/divergence/CLAUDE.md (104), /home/me/git/paragarden/divergence/CLAUDE.md (108), /home/me/git/paragarden/divergence/CLAUDE.md (179).

**Note (review cross-reference).** Sibling decision: ADR-0167 (legacy) records the same in-world-documents / no-omniscient-narrator constraint, decided independently for the legacy repo from its own CLAUDE.md (and adds the character-card-as-artifact workflow). Both are retained as parallel per-repo records (each ADR is scoped to and sourced from its own repo); they are not merged.
