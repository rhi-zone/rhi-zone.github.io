# ADR-0158: Crescent metadata is a flat key-value primitive, not a hierarchy

- Status: Accepted
- Date: 2026-05-29

**Context.** When designing how cards and entries carry metadata (tags, folders, classification), Crescent faced a choice between structured hierarchies and a flat model.

**Decision.** Metadata is an arbitrary flat key-value primitive per card/entry, with tags as one use case among many. No folders, no tag taxonomies, no hierarchies.

**Alternatives rejected.**
- *Hierarchical metadata: folders and tag taxonomies* — Rejected in favor of a flat key-value primitive; hierarchies were deemed unnecessary structure with tags expressible as just one key-value use case

**Consequences.** All organizational features (tags, classification, filtering) must be built on flat key-value pairs; no nesting available. Likely resolves the earlier unresolved metadata gap. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-01-2026-04-20.md (121).
