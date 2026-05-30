# ADR-0062: The graph is the primary reading surface; essays become a secondary format behind fragments

- Status: Accepted
- Date: 2026-05-29

**Context.** The site began essay-centric. As graph-native content (fragments) was developed, a choice arose about what the canonical reading experience should be: linear essay consumption or spatial graph exploration.

**Decision.** Make the graph the primary way to experience content as spatial exploration, with fragments (short, graph-native thoughts) as first-class nodes. Essays are demoted to a secondary, still-linkable format moved to their own '/prose/' entrypoint, freeing the default graph to be fragment-native.

**Alternatives rejected.**
- *Essays as the primary, linear reading format* — Linear consumption is rejected as the intended reading experience; essays re-explain ideas that should live as atomic linkable fragments, so the spatial graph supersedes them as the primary surface.

**Consequences.** Default graph entrypoint is fragment-native; essays live at /prose/ as a secondary format and could eventually be assembled dynamically from fragments based on view history. Open: continuing to write graph-shaped content and the eventual dynamic assembly of essays from fragments. Mined from: /home/me/git/pteraworld/TODO.md (24), /home/me/git/pteraworld/TODO.md (37), /home/me/git/pteraworld/TODO.md (38).
