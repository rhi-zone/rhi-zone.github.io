# ADR-0023: CLAUDE.md triggers vs invocable skills: split by always-on need

- Status: Accepted
- Date: 2026-05-29

**Context.** Recurring patterns (audit loops, handoff steps, parallel-audit workflows) were accumulating. The question arose whether to encode them as always-on CLAUDE.md guidance or as on-demand skill commands. The /polish workflow forced the decision.

**Decision.** Workflows the user explicitly invokes (audit loops like /polish) become skill commands, NOT permanent CLAUDE.md sections; CLAUDE.md is reserved for behavior that must trigger on natural language (e.g. 'let's handoff' must be recognized in-context). Skills are user-invoked and kept out of permanent session context to avoid cold-context cost.

**Alternatives rejected.**
- *Put the /polish audit loop (and similar workflows) into CLAUDE.md* — CLAUDE.md is always-on context; putting on-demand workflows there carries cold-context cost on every session and dilutes the always-on instructions. Reserve it for things that must trigger on natural language.

**Consequences.** New recurring workflows are evaluated for a trigger test: if they must fire on a natural-language phrase, they go in CLAUDE.md; otherwise they become a user-invoked skill. /polish was written and committed as a skill. Subsequent CLAUDE.md sections (commit convention, handoff) were kept because they double as immediate-trigger recognition. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-07.md (29), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-07.md (41).
