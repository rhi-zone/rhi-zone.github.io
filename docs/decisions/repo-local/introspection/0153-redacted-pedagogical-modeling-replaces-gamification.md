# ADR-0153: redacted-project/private-recipient-a: pedagogical modeling replaces gamification

- Status: Accepted
- Date: 2026-05-29

**Context.** redacted-project (the private-recipient-a/parents teaching project) previously centered on a gamification layer (XP, streaks, attention mechanics) as its engagement/retention strategy. A strategic rework on Mar 23 forced a decision about the product's core thesis: whether engagement mechanics or learning outcomes are what LLM-augmented teaching actually delivers.

**Decision.** Strip the gamification layer (XP, streaks, attention mechanics) entirely and rebuild the product around individualized LLM-driven pedagogical feedback at scale as the core thesis — LLMs solving teaching's #1 problem. Keep lessons, classes (student grouping + analytics), and mock exams as the fixed structural foundation; treat everything else as flexible and reimagine it around pedagogical modeling of how students learn specific skills rather than engagement metrics.

**Alternatives rejected.**
- *Retain the gamification layer (XP, streaks, attention mechanics) as the engagement/retention mechanism and organizing model* — Identified as solving the wrong problem — gamification is a retention/attention mechanism, not a learning mechanism, and not the actual value of LLM-augmented teaching. The real differentiator is individualized pedagogical feedback at scale (LLMs solving teaching's #1 problem).

**Consequences.** A major architectural reset: the interaction model is reimagined around pedagogical feedback while lessons/classes/exams remain stable. A rewritten VISION.md captures open design questions that remain to be resolved (profile format free-form vs queryable, version tracking for silent amnesia, teacher query/tool-use architecture, NL vs dashboard interfaces). Forecloses the engagement-metric product direction; future work builds on pedagogical modeling. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-20-2026-03-27.md (77), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-20-2026-03-27.md (79), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-23.md (5), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-23.md (9), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-23.md (9).
