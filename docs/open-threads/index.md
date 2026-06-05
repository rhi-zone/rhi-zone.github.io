# Open Threads

A registry of **open work that is not expected to land soon** — large or long
arcs, paused or abandoned sessions, parked design questions, anything left open
without a clear path to imminent completion.

**The discriminator is liveness, not scope.** A thread belongs here if it is
*still genuinely open and parked for the foreseeable future*, regardless of
whether it touches one repo or many. A single-repo arc someone walked away from
mid-flight belongs here just as much as a cross-project convention question.

**File here:**
- Large or long-running arcs that won't complete soon.
- Paused or abandoned sessions — real work someone left mid-flight.
- Parked questions: a design or convention decision left open, with no owner
  driving it to a near-term answer.

**File in the project's `TODO.md` instead** when the item is *actively owned*
inside one repo and being driven toward completion there. Live, progressing
backlog is TODO work, not an open thread — even if it's large. The registry is
for what's parked, not for everything that's unfinished.

When a thread resolves, move it to [closed.md](./closed) with a one-line reason
rather than deleting it, so the archive stays auditable.

---

## Threads

### Cross-cutting design questions

These are parked convention/architecture questions whose answer would propagate
across repos. None has an owner driving it to a near-term decision.

- [harness-orchestrator-fit](./harness-orchestrator-fit) — Does the Claude Code harness assume an orchestrator-class top-level model? Affects model defaults in every repo's CLAUDE.md. Untested.
- [domain-generator-corpus](./domain-generator-corpus) — Would a generator-corpus (worked examples + counterexamples) outperform a rule-corpus (CLAUDE.md) for the failing constraint classes?
- [design-decisions-convention](./design-decisions-convention) — What's the standard filename + pointer pattern for prior design decisions, and where's the ephemeral/load-bearing cutoff? Partial, inconsistent adoption across repos.
- [context-md-adoption](./context-md-adoption) — Should `CONTEXT.md` be a mandatory ecosystem-wide artifact or stay opt-in? Partial adoption, no decision recorded.
- [out-of-scope-stance](./out-of-scope-stance) — Should the ecosystem CLAUDE.md forbid "out of scope" as a deferral pattern, and how does that square with legitimate project-boundary discipline?
- [claude-md-saturation-curve](./claude-md-saturation-curve) — Is CLAUDE.md churn saturating (converging on the implicit-constraint set) or still mining? Measurable but unmeasured.
- [compaction-loss-rate](./compaction-loss-rate) — What's the actual rate at which compaction silently strips load-bearing prior agreements? Measurement-blocked.
- [specs-as-software](./specs-as-software) — Is `@spec:` / `@protocol:` a software-taxonomy-only namespace, or a shared ecosystem concept concord/paraphase/rescribe can reference?

### Substrate & scope questions

- [worldbuilding-namespace](./worldbuilding-namespace) — How should the `worldbuilding` lens namespace be structured in software-taxonomy, and how should that convention propagate if paragarden universes export into the corpus?
- [lua-on-mobile](./lua-on-mobile) — Is a mobile (Android / Termux) target for crescent/moonlet in scope? JIT is disallowed on Android; interpreter fallback works but the in-scope decision is unresolved.
- [Deterministic simulation testing](/deterministic-simulation-testing) — What does an open, instrumentation-optional testing substrate look like across levels (in-process, wasm, emulator, hypervisor)? Unresolved: the oracle problem, the managed-runtime frontier, whether exploration and reproduction are better as separate tools.

### Paused arcs

- [existence-persistent-awareness](./existence-persistent-awareness) — The `fluffy-rolling-meadow` "Persistent Awareness Display" plan (time/money degradation HUD) was written, presented for sign-off, and never approved or discarded. Plan file untouched since 2026-04-10; not tracked in existence's `TODO.md`.
