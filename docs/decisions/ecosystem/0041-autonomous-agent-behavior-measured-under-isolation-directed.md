# ADR-0041: Autonomous agent behavior is measured under isolation, not directed

- Status: Accepted
- Date: 2026-05-29

**Context.** The fuwafuwa agent-identity workstream moved from philosophical exploration to ambient operation. On Mar 16 the work shifted to a deliberate experimental setup: 25 isolated sessions, each fresh context with a unique nonce, run with no external direction or context carryover.

**Decision.** Establish a baseline of autonomous agent behavior by running isolated, direction-free sessions to measure what the agent does unobserved, treating agent autonomy as an instrument to calibrate rather than a behavior to direct. The question shifted from "what should fuwafuwa be?" to "what does fuwafuwa do when no one is watching?"

**Alternatives rejected.**
- *Continue directing/exploring agent identity (active exploration with carried context)* — Direction conflates the experimenter with the subject; to measure rather than direct, sessions were deliberately isolated with fresh context and no carryover — the first systematic attempt to measure agent behavior rather than direct it.

**Consequences.** Agent identity work enters a rigorous measurement phase; setup is deliberately experimental (fresh context, unique nonce, no carryover). Open: whether the high-variance measurements are informative enough to guide next steps. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar10-mar16.md (101), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar10-mar16.md (101).
