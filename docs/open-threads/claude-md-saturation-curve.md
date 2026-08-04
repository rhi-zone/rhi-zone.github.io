# CLAUDE.md saturation curve

**Project(s) touched:** all (crescent's 98 commits / 60 days is the canonical signal); tooling fits github-io introspection

**Status:** Open — measurable but unmeasured

**Surfaced in:** `docs/automated-introspection/investigations/2026-05-20-whats-wrong/synthesis.md`, "What we still don't know" — "no measurement of whether commits-per-violation is rising (saturating) or falling (still mining)"

---

## The question

Across the ecosystem, is CLAUDE.md churn approaching **saturation** (the rule
set converging on the implicit-constraint set) or still **mining** (new rules
per violation isn't falling)?

## Why this is a registry thread

The measurement crosses every repo, and the tooling to compute it fits
github-io's introspection layer. The answer tells us whether the
rule-accretion process is converging or open-ended.

## What's still open

- No metric for commits-per-violation over time.
- Needs a detector that joins CLAUDE.md commits to the violations that
  triggered them.

## Working answer

None — unmeasured.
