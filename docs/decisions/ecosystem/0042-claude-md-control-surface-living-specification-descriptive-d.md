# ADR-0042: CLAUDE.md is a control surface / living specification, not descriptive documentation

- Status: Accepted
- Date: 2026-05-29

**Context.** The Mar 15 reincarnate session spent 60+ turns on tooling friction; the breakthrough was recognizing CLAUDE.md described an ideal workflow rather than reality. Across every project that hit a quality wall this week, the corrective was to update CLAUDE.md with invariants, not just to fix code.

**Decision.** Treat CLAUDE.md as a control surface that specifies what each project actually is and its invariants, and as the mechanism for fixing problems — adding rules that prevent friction rather than describe ideals. New sections were added on handling user disagreement (trust pushback as a signal).

**Alternatives rejected.**
- *Treat CLAUDE.md as behavioral guidance / documentation describing the ideal workflow* — Documentation describing ideals rather than actuals was the source of accumulated friction (stale commands trusted because they were written down); rules must prevent friction, not describe ideals.

**Consequences.** Every quality reckoning now produces updated CLAUDE.md invariants alongside code fixes; the document evolves into a specification language for each project. Compresses the cycle time between reckonings. Ongoing maintenance burden to keep specs matched to reality. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar10-mar16.md (45), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar10-mar16.md (45), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar10-mar16.md (43).
