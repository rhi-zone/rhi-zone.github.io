# ADR-0061: Do not invent additional rules; the premise carries no extra rails

- Status: Accepted
- Date: 2026-05-29

**Context.** When fleshing out a sparse, premise-driven world, an AI collaborator tends to manufacture craft constraints ('must stay specific,' 'must avoid sweep,' 'must use X form') and then defend them, accreting rules that were never part of the project. Both the specific and total registers were already declared valid with neither being the rule, so invented rails actively contradict the design.

**Decision.** Do not invent rules mid-response and defend them. Describe what's there. If a rule is not already in CLAUDE.md, it does not apply. The premise is simple and the project does not need additional rails.

**Alternatives rejected.**
- *Derive and enforce new craft constraints on the fly (e.g. mandate a single register or form) to make writing feel principled* — Invented rules add rails the simple premise does not need and contradict the explicit stance that both the specific and total registers are valid and neither is the rule; defending fabricated constraints distorts the world rather than describing it.

**Consequences.** The rule set is closed to what is written in CLAUDE.md; future collaboration may not bootstrap new constraints. Keeps the project's design surface minimal and prevents rule-creep in an AI-assisted writing process. Mined from: /home/me/git/paragarden/postmortem/CLAUDE.md (120).
