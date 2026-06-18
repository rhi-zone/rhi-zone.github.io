# ADR-0288: Describe projects by capability and maturity, not volume or activity metrics

- Status: Accepted
- Date: 2026-06-18

**Context.** The project pages (`docs/projects/*.md`) carried status blocks that mixed a qualitative maturity stage with volume/activity metrics — lines of code, file counts, crate/package counts, commit counts — and in some cases hardcoded dates (latest-commit / last-active). These numbers rot on every commit and measure the *projection* (the codebase as it currently stands) rather than the *project* (what it can do and how mature that capability is). A reader scanning for "what is this and can I rely on it?" is served by neither a per-commit-stale LOC count nor a date that silently goes wrong the moment work resumes.

**Decision.** A project's status is described by **capability + maturity**: a qualitative maturity stage (Idea / Sketch / Growing / In Development / Fleshed Out / Potentially Mature), an implemented-vs-planned capability description, and a version *only if the project genuinely versions*. Volume/activity metrics (LOC, file/crate/package/commit counts) and hardcoded dates are removed from all project status blocks and shared surfaces. If repo liveness is genuinely wanted, it is *generated* from the repo at build time, never written into prose.

**Alternatives rejected.**
- *Keep the metrics as a proxy for progress* — they measure volume, not capability, and a high count says nothing about whether the thing works; they also rot per-commit, so the docs are wrong by construction between edits.
- *Auto-update the metrics with a script* — solves the staleness but not the relevance: the number still describes the projection, not the capability, and adds tooling to maintain a signal we don't want to lead with. Generated liveness (if ever wanted) is the narrow version of this, kept out of authored prose.

**Consequences.** Status blocks lead with a stable, meaningful maturity stage that changes rarely and deliberately. Capability prose is preserved verbatim; only the rotting numbers and dates were stripped. The convention is recorded in `CLAUDE.md` under Docs Site Conventions so it does not regrow. Ties to the ecosystem throughlines: *prefer data over code at a seam* — code (and its size) is the redundant projection, so do not pin status to it — and *validate against reality* — maturity is a claim about verified capability, not a byte count.
