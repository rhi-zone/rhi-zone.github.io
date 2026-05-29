# ADR-0035: Plan-mode handoff to fresh context as the default strategy for long-running sessions

- Status: Accepted
- Date: 2026-05-29

**Context.** Sustained multi-project work routinely hit context limits. The longest-lived sessions re-read their entire accumulated conversation history on every continuation turn, paying a heavy cache_read tax: 799 continuation turns drove 22% of total cache reads, one session hit the context limit 49 times, and continuations plus handoff plan turns together drove 36% of all cache reads.

**Decision.** Adopt the plan-mode handoff pattern as the standard context strategy for long work: a session generates a plan and hands off immediately to a fresh context (often interrupted on turn 0) rather than continuing to accumulate conversation history toward the context limit. Developers proactively checkpoint/interrupt before context limits hit rather than waiting for overflow. One cache_create to start fresh is treated as far cheaper than accumulating 50K+ tokens of cache_read on every subsequent turn near the limit.

**Alternatives rejected.**
- *Continue a single long session via context continuations until it organically overflows the context window* — Each continuation turn near the limit re-reads the entire accumulated conversation, and this tax compounds. As stated: 'one cache_create to start fresh is far cheaper than accumulating 50K+ tokens of cache_read on every subsequent turn in a session approaching its context limit.' Long sessions are more token-efficient per turn, but they hit context limits, making clean handoffs the better long-run strategy. Usage of the handoff pattern exploded as it matured.

**Consequences.** Handoff usage grew from 66 (Jan) to 288 (Feb) as the pattern matured. Sessions end with handoff summaries and begin from continuation summaries; ~19% of sessions are interrupted on turn 0 by design, becoming normal rather than overhead. Codified later as the orchestrator/handoff discipline. Open: whether this scales and whether architectural control is maintained as the codebase grows. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar2.md (245), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar2.md (251), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar4.md (288), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar4.md (33).
