# ADR-0162: Crescent typechecker v5: dual independent interpreters as correctness mechanism, with structurally-forced spec interleave

- Status: Accepted
- Date: 2026-05-29

**Context.** Crescent's typechecker was reframed from a linting/audit pass into a formal operational-semantics "v5 substrate" with proof artifacts. Before features build on it, a correctness-enforcement mechanism had to be chosen. The substrate is implemented by re-encoding three normative specs (Spec A: simple-sub bounds; Spec B: match types + TPack; Spec C: TLiteral + TRecord). A sequencing question (TODO Thread 5's fork) asked whether the specs could be encoded fully independently in spec order. Phase 0 (CLAUDE.md guardrails) and Phase 1 (three normative specs) were already committed.

**Decision.** Crescent's typechecker v5 implements its normative specs against TWO independent interpreters (`lib/type/static-v5/op_sem.lua` and `op_sem_alt.lua`); correctness is enforced by independent-encoding parity — building the thing twice and checking they agree — before anything builds on it (echoing the design-it-twice / redundancy-as-rigor pattern). The implementation sequence cannot be fully independent: it is forced to interleave as TPack substrate (B.1) -> Spec C (TLiteral/TRecord) -> match_pattern completion (B.2), because Spec B's match_pattern forward-references Spec C's TLiteral.

**Alternatives rejected.**
- *A single interpreter / ordinary direct validation of the typechecker* — Insufficient rigor for a substrate everything else builds on; soundness hardened into "validated against an independent re-encoding of its own spec" — redundancy-as-rigor
- *Encode the specs in independent/spec order ("Option (b)")* — "Option (b) is structurally impossible" — Spec B's match_pattern forward-references Spec C's TLiteral, creating a genuine interleave dependency that no independent ordering can satisfy

**Consequences.** All v5 spec work (Spec A/B/C) must be implemented and cross-validated against both interpreters; Phase 2 implementation must follow the TPack -> Spec C -> match_pattern(B.2) interleave. This raises per-feature implementation cost in exchange for provable soundness. Payoff: once the substrate exists, ad-hoc pcall/coroutine/pairs/ipairs handlers can be deleted. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-05-10-2026-05-29.md (52), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-05-10-2026-05-29.md (55), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-05-29.md (14), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-05-29.md (19), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-05-28.md (13).
