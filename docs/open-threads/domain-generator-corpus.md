# Domain generator corpus

**Project(s) touched:** all (claude-config layer); meta-investigation lives in github-io

**Status:** Open

**Surfaced in:** `docs/introspection/investigations/2026-05-20-whats-wrong/synthesis.md`, "Hypotheses no one tested but the data implies" (H-DOMAIN-GENERATOR-COMPRESSION); the May 13 "Counterweight: don't fake confidence" rule (`7521987c`) is held up as the working case

---

## The question

Would a **generator-corpus** (worked examples + counterexamples) outperform a
**rule-corpus** (CLAUDE.md prose) for the constraint classes that keep failing —
no-specialcase, no-bandaid, specialcasing-vs-generalization?

## Why this is a registry thread

Every repo's CLAUDE.md is downstream of the answer. If examples beat rules for
these classes, the propagation tooling and the shape of the ecosystem-common
region both change.

## What's still open

- No comparison of rule-corpus vs generator-corpus on the failing classes.
- The working case (`7521987c`, "don't fake confidence") is a single data point;
  bandaid-style rules are the failing cases.

## Working answer

None — hypothesis only.
