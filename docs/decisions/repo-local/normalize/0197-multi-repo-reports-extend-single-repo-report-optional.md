# ADR-0197: Multi-repo reports extend the single-repo report with an optional repos field rather than a separate wrapper type

- Status: Accepted
- Date: 2026-05-29

**Context.** normalize analyze hotspots/ownership/coupling gained a --repos DIR mode to run across all git repos under a directory, forcing a decision on the return-type shape. Four options were considered.

**Decision.** Extend the existing single-repo report struct with an optional repos: Option<Vec<RepoResult>> field alongside its existing top-level fields. The top-level fields are always present and always mean the same thing; --repos merely adds a .repos field with per-repo breakdowns.

**Alternatives rejected.**
- *Always wrap in MultiRepoReport<T>* — Consistent outer shape but forces single-repo callers to unwrap an array, breaking --jq .files; and MultiRepoReport<T> semantically means 'here are N repos', a different concept from 'a report that optionally aggregates multiple repos'.
- *Untagged union (Single(T) | Multi(MultiRepoReport<T>))* — One command but callers must handle two shapes, breaking the stable top-level shape (--jq .files no longer works identically).
- *Separate commands (hotspots-multi)* — Clean types but duplicates the command surface.

**Consequences.** --jq .files works identically with or without --repos; callers never conditionally unwrap. Establishes the invariant that a report's top-level fields are stable and additive flags add sibling fields. Mined from: /home/me/git/rhizone/normalize/docs/architecture-decisions.md (393), /home/me/git/rhizone/normalize/docs/architecture-decisions.md (408).
