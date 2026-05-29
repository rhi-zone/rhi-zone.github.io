# ADR-0043: Handoff plans require freshness checks, not just correctness checks

- Status: Accepted
- Date: 2026-05-29

**Context.** By Mar 12 the handoff-chain relay was invisible ambient infrastructure. On Mar 15 the reincarnate session discovered handoff plans had been copy-pasted across ~30 sessions without revision, accumulating stale commands that were trusted uncritically because they "came from a plan," amplifying errors across dozens of sessions.

**Decision.** Handoff/relay plan documents must be subjected to freshness checks (does this plan still describe reality, has the codebase changed, are these commands still necessary), not just correctness checks. The relay system is held to the same audit discipline as code.

**Alternatives rejected.**
- *Trust handoff plan artifacts uncritically and keep abandon/replace relays as-is* — The relay works so well its artifacts are trusted uncritically, which let stale commands accumulate across ~30 sessions and amplify errors; abandoning relays was rejected because they are the primary scaling mechanism, so freshness checks were added instead.

**Consequences.** The relay system gains a self-correction obligation; plans are no longer authoritative by default. Adds a maintenance burden to an already-dense workflow but prevents error amplification across session chains. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar10-mar16.md (125), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar10-mar16.md (169).
