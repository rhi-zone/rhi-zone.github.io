# ADR-0047: Gate version bumps on audit resolution, not feature completion

- Status: Accepted
- Date: 2026-05-29

**Context.** Projects reaching a publish threshold needed a rule for when a version bump is warranted.

**Decision.** A version bump follows resolution of all audit findings (consistency, gaps, adversarial run by parallel subagents), not merely completion of the planned feature list; build to a threshold, audit with multiple parallel agents, resolve findings, then advance version.

**Alternatives rejected.**
- *Publish/bump version once the feature list is complete* — Feature completion alone does not establish quality; the version bump followed resolution of all audit findings, not just completion of the feature list.

**Consequences.** Publishing is gated behind multi-agent audit resolution; CRITICAL/HIGH findings must be cleared before advancing version; this is now standard operating procedure rather than an occasional step. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar5-mar9.md (33), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar5-mar9.md (68).
