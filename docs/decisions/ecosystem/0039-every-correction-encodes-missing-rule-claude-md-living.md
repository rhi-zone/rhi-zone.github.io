# ADR-0039: Every correction encodes a missing rule (CLAUDE.md as living constitution)

- Status: Accepted
- Date: 2026-05-29

**Context.** Agents repeatedly violated implicit expectations (using `any`, inventing numbers, not committing). Fixing individual outputs did not prevent recurrence, and frustration markers clustered around repeated failure modes.

**Decision.** Treat every correction as evidence of a missing behavioral rule: when the agent gets something wrong, do not merely fix the output — encode the violated principle as a CLAUDE.md rule and apply it everywhere. This was itself codified as the meta-rule 'every correction means a rule is missing'.

**Alternatives rejected.**
- *Correct the agent's output case-by-case without encoding the underlying principle* — Per-instance correction does not prevent recurrence; the structural response (identify missing rule, encode it, move on) is what reduced frustration-signal frequency over time.

**Consequences.** CLAUDE.md files are accumulating behavioral constraints; violation-to-rule-encoding latency compressed from days to minutes. Establishes governance for a one-person org delegating implementation to agents. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar4.md (78), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar4.md (104).
