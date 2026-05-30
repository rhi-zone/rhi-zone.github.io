# ADR-0028: Normalize: discoverability (fewest tool calls) as the organizing purpose

- Status: Accepted
- Date: 2026-05-29

**Context.** Normalize had completed its polish cycle and positioned itself at the boundary between 'tool for exploration' and 'infrastructure for code intelligence.' The Mar 25 session had to decide what the tool is fundamentally for.

**Decision.** Reframe normalize's purpose around a 'discoverability pillar': minimize the number of tool calls an agent needs to answer a query — i.e. assemble the context needed in the fewest steps — transitioning from structural analysis (view, rank, rules) to contextual query assembly.

**Alternatives rejected.**
- *Keep normalize framed as a code-structure exploration tool ('show me the code structure')* — Reframed as the wrong question for an agent consumer; the goal is 'assemble the context I need in the fewest steps,' which optimizes for agent token/step efficiency rather than human structural browsing.

**Consequences.** Drives concrete work (refs subcommand, snapshot regression investigation, CallEntry access field population) and questions about whether SUMMARY.md serves agents vs humans, recursive CLAUDE.md rules, glob-based filename matching. If achieved, reduces tool calls for every agent across the ecosystem. Reincarnate remains blocked on normalize shipping ratchet lints for cyclomatic complexity. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-20-2026-03-27.md (45), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-20-2026-03-27.md (47).
