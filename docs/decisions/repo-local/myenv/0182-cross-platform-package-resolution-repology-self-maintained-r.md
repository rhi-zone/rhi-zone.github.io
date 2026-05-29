# ADR-0182: Cross-platform package resolution via Repology, not a self-maintained registry

- Status: Accepted
- Date: 2026-05-29

**Context.** myenv needs to resolve tool names to package names across many package ecosystems (apt, pacman, nix, brew, etc.). The team had to decide whether to build their own package-name registry or reuse an existing service.

**Decision.** Use Repology's existing infrastructure (300+ tracked repos, JSON API) to resolve tool names to per-ecosystem package names, with local caching (24h TTL) and rate limiting. Tool names in myenv.toml must match Repology project names.

**Alternatives rejected.**
- *Build and maintain our own package-name registry* — Repology already provides comprehensive (300+ repos), community-maintained, battle-tested, API-accessible coverage; the spec explicitly chooses 'Instead of building and maintaining our own registry, we leverage Repology's existing infrastructure'.

**Consequences.** myenv inherits Repology's coverage and update cadence but also its naming quirks (project-name mismatches like fd vs fd-find), requiring a `myenv tools lookup` workflow. Network dependency on repology.org with 1 req/sec bulk limit and 24h cache. Mined from: /home/me/git/rhizone/myenv/docs/tool-registry-spec.md (11), /home/me/git/rhizone/myenv/docs/tool-registry-spec.md (7).
