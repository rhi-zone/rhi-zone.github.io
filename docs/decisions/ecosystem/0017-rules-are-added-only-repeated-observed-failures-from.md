# ADR-0017: Rules are added only on repeated observed failures, not from one-off corrections

- Status: Accepted
- Date: 2026-05-29

**Context.** The CLAUDE.md ruleset evolves over time. A governance choice was needed about what justifies adding a new behavioral rule: any user correction, or only demonstrated recurring failure modes.

**Decision.** User corrections are treated as conversation, not material for new rules. Rules are added only when a failure mode is observed repeatedly.

**Alternatives rejected.**
- *Encode every user correction as a new standing rule* — Would bloat the ruleset with one-off, possibly transient guidance; rules are reserved for repeatedly-observed failure modes to stay durable and signal-bearing.

**Consequences.** The ruleset stays lean; single corrections do not become rules. Raises the bar for what enters CLAUDE.md, governing how the AI-collaboration ruleset itself grows. Mined from: /home/me/git/rhizone/github-io/CLAUDE.md (144).
