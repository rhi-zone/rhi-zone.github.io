# Frame 1 — The space of single-decision behavior changes, derived theory-down from program structure

**Method.** A program is a structure of decisions. We want the *axes* along which a
program can be changed *at all*, and for each, the single-decision behavior changes it
admits — edits that are one decision in thought but smear across the text. Behavior-
*changing* only; behavior-preserving refactorings are excluded (renaming, reformatting,
extract-function). The discriminator throughout: **one intent, one decision, in the head
— but the text projection scatters it across many character/line edits, often across
files.** That scatter is the whole point; an axis only earns a place if its decisions
genuinely smear.

I derive the axes by sweeping the structural strata of a program, roughly from "what is
computed over" outward to "how it is composed, run, and constrained." For each axis I give
(a) the kind of decision, (b) concrete decisions with real language features, (c) why it
smears, (d) confidence flags.

A program, structurally, is: **values** flowing through **bindings/names**, shaped by
**types** and **data layout**, transformed by **operations**, sequenced by **control
flow**, selected by **dispatch**, producing **effects** under an **error/partiality**
discipline, possibly **concurrently**, over **resources** with **lifetimes**, composed
into **modules/dependencies**, governed by **invariants/contracts**, evaluated under an
**order/strictness** regime, and observed through an **interface/protocol**. Those are the
strata. Each is an axis.

---

## A. Values & literals — the constant layer

**Decision kind:** change *what a fixed quantity is*, without changing the shape of the
program around it.

Single-decision changes:
- **Tune a magic constant / threshold.** `MAX_RETRIES = 3 → 5`; timeout `30s → 10s`;
  page size `20 → 50`. Often the *same* literal recurs in many places (the smear) because
  it was never lifted to one binding.
- **Change a unit/scale of a literal.** `sleep(5)` meaning seconds vs `sleep(5000)`
  meaning ms — a one-decision unit change that touches every call site.
- **Change a sentinel.** "missing" encoded as `-1` → `null` → `Optional`; this *bleeds*
  into the type axis (D) and the error axis (H). At the literal layer alone: `-1 → 0`,
  `"" → "N/A"`.
- **Flip a default value.** `verbose=false → true`; `timeout=None → 30`.
- **Change a regex / format string / glob.** One decision ("also accept `+` in emails"),
  one literal, but downstream validation, tests, and docs shift.
- **Change an enum's wire value while keeping the variant.** `RED = 0 → RED = "#f00"`.

**Why it smears:** the value is *replicated* (no single source of truth) or *implicitly
depended on* by callers who hardcoded the same number. The decision is atomic; the text
isn't.

---

## B. Operations & expressions — the semantics of a computation step

**Decision kind:** change *how a value is transformed*, holding inputs and outputs' types
fixed.

Single-decision changes:
- **Change rounding/truncation mode.** `floor → round → ceil → banker's rounding`. The
  canonical example. One word in thought; in code it may be `int(x)` here, `x // 1`
  there, `Math.trunc` elsewhere — same decision, three syntaxes, N sites.
- **Change an arithmetic/comparison operator.** `<` → `<=` (off-by-one boundary policy);
  `+` → `saturating_add` (overflow policy); `/` → integer-div.
- **Change associativity/precedence of an accumulation.** sum-then-divide vs
  divide-then-sum (numerical-stability decision); left-fold vs right-fold.
- **Change a string/collection operation's semantics.** case-sensitive →
  case-insensitive compare; `trim` policy; sort stability; dedup keep-first vs keep-last.
- **Change overflow/saturation/wrapping policy.** `wrapping_add` → `checked_add` (this
  also crosses into error axis H if it returns `Option`).
- **Change a hash/equality definition.** equality by identity → by value → by a subset of
  fields. Smears into every set/map/dedup that relied on the old notion.

**Why it smears:** the "same" operation is expressed with different surface syntax at
different sites, and equality/ordering decisions are *consumed implicitly* by collections
and conditionals far away.

---

## C. Names & bindings — the identity/wiring layer

**Decision kind:** change *what a name refers to* or *where a value comes from*, changing
behavior (not a pure rename, which is refactor-only).

Single-decision changes:
- **Rebind a name to a different source.** `config.host` now read from env var instead of
  file; `now()` injected instead of called directly. One decision ("source X from Y").
- **Change scope/lifetime of a binding to change sharing.** module-level singleton →
  per-request instance (a sharing/aliasing decision with real behavior change — state no
  longer shared). Crosses into resource axis (K) and concurrency (I).
- **Shadow / un-shadow.** introduce a local that overrides an outer binding for part of a
  scope — changes which value flows downstream.
- **Change `const` vs mutable / `let` vs `var`** in a way that *enables* a later mutation
  decision. Often the enabling half of a two-part decision.
- **Change capture semantics of a closure.** capture-by-value → capture-by-reference
  (`[=]` vs `[&]` in C++; `move` in Rust). One decision; behavior (staleness, aliasing)
  changes everywhere the closure runs.

**Why it smears:** "where does this value come from" is a single intent, but dependency
injection / sourcing touches construction sites, signatures, and wiring across files.

**Flag:** the boundary between this axis and pure refactor is sharp — rename is refactor;
*re-sourcing* is behavior. Keep only the behavior-changing half here.

---

## D. Types — the classification layer

**Decision kind:** change *the set a value is drawn from*, or *what is statically
guaranteed about it*.

Single-decision changes:
- **Widen/narrow a type.** `i32 → i64`; `float → decimal` (precision decision); `string →
  enum` (restrict the domain).
- **Make a field/parameter optional or required.** `name: string` → `name?: string`. One
  decision; ripples to every constructor, every read site (now must null-check), every
  serializer. A textbook smear.
- **Add a variant to a sum type.** add `Pending` to `Status = Active | Closed`. One
  decision; in an exhaustive-match language (Rust/Swift/OCaml/TS-with-never) the compiler
  forces edits at *every* match site — the smear is mechanically visible.
- **Remove a variant.** symmetric; dead-arm cleanup everywhere.
- **Generalize/specialize via generics.** `List<Int> → List<T>` (if it changes accepted
  inputs, it's behavior; pure generalization with no new instantiation is refactor —
  **flag: this one straddles the line**).
- **Add/remove/strengthen a type-class / trait / interface bound.** require `Ord` where
  only `Eq` was needed; require `Send` (crosses into concurrency I).
- **Change nominal vs structural identity, or introduce a newtype.** `type UserId = string`
  → `newtype UserId(string)` to forbid mixing with `OrderId`. One decision; every site
  that passed a bare string must now wrap/unwrap.

**Why it smears:** types are *checked at every use site*, so a single type decision
propagates to all of them — and the compiler turns the smear into a worklist. This is the
axis where "decision vs line" is most legible because the toolchain already enumerates the
fan-out.

---

## E. Data shape / representation — the layout layer

**Decision kind:** change *how data is structured or encoded*, holding the information
content roughly fixed. Distinct from D: types classify; shape arranges.

Single-decision changes:
- **Change a value's representation/encoding.** dollars → cents (int); naive-local →
  UTC-instant; `Date` → epoch-millis; degrees → radians; RGB → HSV. One decision; every
  producer and consumer must convert. **The flagship smear** — the original example set.
- **Restructure a record.** flatten nested → flat (`addr.city` → `address_city`); split
  one field into two (`fullName` → `first,last`); merge two into one. Touches schema,
  every accessor, serialization, migrations.
- **Change a collection type for semantic reasons.** `List` → `Set` (dedup + lose order);
  `Array` → `Map` keyed by id (lookup semantics change); `Vec` → `RingBuffer` (eviction
  policy). Behavior changes, not just perf.
- **Change identity representation.** sequential int id → UUID → ULID. One decision;
  ripples to db schema, key generation, foreign keys, URLs, logs.
- **Normalize ↔ denormalize.** store derived value vs recompute; embed vs reference. A
  consistency-vs-cost decision spanning writes and reads.
- **Change wire/serialization format of a field.** snake_case ↔ camelCase keys; ISO string
  ↔ epoch; nullable-absent vs explicit-null.

**Why it smears:** representation is a *contract between every producer and every
consumer*; changing it on one side without the other is a bug, so the decision is
inherently many-site. This axis is the strongest argument for the whole "edit the
decision" thesis.

---

## F. Control flow — the sequencing/branching layer

**Decision kind:** change *which steps run, in what order, how many times, under what
condition*.

Single-decision changes:
- **Add/remove/reorder a guard.** add an early-return precondition; add a permission check
  before an action. One decision; but if the guarded logic is duplicated, the guard must
  be added in many places (the smear) — and the *reason* it smears is the absence of a
  single choke point.
- **Change a loop's bounds/direction/step.** inclusive↔exclusive end; iterate reversed;
  stride by 2. Boundary-policy decision (overlaps B).
- **Change branch *policy*.** "on conflict, last-write-wins" → "first-write-wins" → "merge"
  — one policy decision realized as scattered `if`/`else` edits.
- **Short-circuit vs evaluate-all.** `&&`/`||` vs `&`/`|`; `any()` early-exit vs collect.
  Behavior differs when sub-expressions have effects.
- **Add/remove a fast path.** memo/cache hit branch, special-case `n==0`. One decision; new
  branch + invariant that the path matches the slow path.
- **Restructure into/out of a state machine.** flag-soup → explicit states; a transition
  policy change ("can't go Closed→Active") is one decision over many transition sites.

**Why it smears:** policies (conflict, precedence, ordering) are realized as *distributed
conditionals*. The intent is one rule; the text is every place the rule is enforced.

---

## G. Dispatch & polymorphism — the selection layer

**Decision kind:** change *how the runtime chooses which implementation runs*.

Single-decision changes:
- **Static → dynamic dispatch or vice versa.** concrete type → interface/trait-object
  param (`fn(Logger)` → `fn(dyn Logger)`); template → virtual. Changes extensibility and
  behavior under subtyping.
- **Add an implementation/overload/instance.** new `impl Trait for NewType`; new method
  override. One decision; but call sites silently rebind to the new impl — *invisible*
  smear (no text edit at the call site, yet behavior changes — a smear into the *absence*
  of an edit).
- **Change the dispatch key.** route by type → route by a runtime tag/field; change a
  visitor's dispatch dimension. Touches the dispatcher and every handler.
- **Change resolution policy.** overload resolution preference; MRO / linearization order
  in multiple inheritance; trait coherence/specialization. **Flag:** these are
  language-specific and subtle (C++ overloads, Python MRO, Rust specialization-nightly).
- **Open vs closed dispatch.** sealed sum (closed, exhaustive) ↔ open trait/interface
  (extensible). This is the *dual* of D's "add a variant": adding a variant is cheap in
  closed dispatch but adding an *operation* is cheap in open dispatch — the
  expression-problem axis. One decision flips which dimension is cheap to extend.

**Why it smears:** dispatch is the indirection layer; a single decision about *how
selection happens* relocates behavior across the dispatcher + all participants, and can
change behavior with *no* visible call-site edit.

---

## H. Effects, partiality & error handling — the "can it fail / does it touch the world" layer

**Decision kind:** change *whether/how a computation can fail, and what it does to the
world*.

Single-decision changes:
- **Make a pure function fallible.** `T` → `Result<T,E>` / `Option<T>` / throws. One
  decision; every caller must now handle/propagate. Classic fan-out, often compiler-forced
  (Rust `?`, checked exceptions).
- **Change the error-handling *policy*.** log-and-continue → fail-fast → retry → fallback
  default → circuit-break. One decision over every failure site.
- **Change error granularity/representation.** single `Error` → typed error enum; add
  context/wrapping; opaque → structured. Crosses D and E.
- **Change retry/backoff policy.** add retries; linear → exponential backoff + jitter;
  change idempotency assumptions. One decision, many call sites if not centralized.
- **Add/remove an effect.** add logging/metrics/audit at an operation; add a transaction
  boundary; emit an event. Cross-cutting → smears badly (the AOP motivation).
- **Change effect *placement/scope*.** widen a transaction to cover two operations; move a
  lock; change a span boundary. One decision about *where the boundary is*.
- **Make an effect conditional / sampled.** always-log → sample 1%; feature-flag an effect.

**Why it smears:** effects and fallibility are **cross-cutting**; the decision is one
policy but its realization is sprinkled through every operation it governs. This is the
axis aspect-oriented programming exists to address, which is direct evidence the smear is
real and structural.

---

## I. Concurrency, async & scheduling — the "when does it run relative to other things" layer

**Decision kind:** change *the temporal/parallel relationship between computations*.

Single-decision changes:
- **Make a call async/awaitable.** sync `f()` → `await f()`. One decision; **function
  color propagates** up the entire call chain (every caller becomes async) — the canonical
  *viral* smear. Strongly compiler/runtime-enforced.
- **Change a concurrency primitive's policy.** mutex → RW-lock → lock-free; coarse → fine
  lock granularity; add/remove a lock. Behavior (deadlock, throughput, correctness)
  changes.
- **Change a sharing/ownership decision.** `Rc` → `Arc` (Rust, to cross threads); value →
  `Arc<Mutex<_>>`; thread-local → shared. One decision; types and call sites ripple.
- **Change ordering/memory-model guarantees.** `Relaxed` → `SeqCst` atomic ordering; add a
  fence. **Flag:** extremely subtle, language/hardware-specific.
- **Sequential → parallel / batched.** `map` → `par_map`; serial requests → `join_all`;
  one-by-one → batched. Changes failure semantics (partial failure) and ordering.
- **Change scheduling/backpressure policy.** unbounded → bounded queue; add rate-limit;
  fair vs priority scheduling; debounce/throttle.
- **Change cancellation/timeout discipline.** add a deadline; make cancellation
  cooperative vs forced.

**Why it smears:** async-coloring is the purest example of a one-decision change that the
*language itself* forces to propagate transitively. Lock/ownership decisions smear through
the type system (Rust) or through invisible-and-dangerous untyped assumptions (C).

---

## J. Module, dependency & boundary structure — the composition layer

**Decision kind:** change *how the program is partitioned and what depends on what*.
(Pure moves are refactor; **behavior-changing** boundary decisions belong here.)

Single-decision changes:
- **Swap a dependency / implementation behind a boundary.** in-memory store → Redis; one
  HTTP client lib → another; mock → real. One decision; behavior + wiring change.
- **Change a boundary's *contract* not just its impl.** make an internal call go over the
  network (in-process → RPC): adds latency, partial failure, serialization — drags in H,
  E, I all at once. One decision, enormous smear.
- **Change visibility to change the contract.** `pub`→`pub(crate)`; widen/narrow an API
  surface (this *changes* who can call → behavior at the ecosystem level).
- **Change a version/feature-flag of a dependency.** bump a lib major version (semantics
  shift); toggle a Cargo feature. One decision; behavior changes diffusely.
- **Invert a dependency.** pass a callback/handle in instead of importing (DI). Crosses C
  and G.

**Why it smears:** boundary decisions (esp. in-process↔network) *bundle* changes across
many other axes — they're "one decision" at the architecture level but maximal smear in
code. The most under-appreciated axis for tooling.

---

## K. Resource lifetime & ownership — the "who allocates/frees/holds" layer

**Decision kind:** change *the lifecycle of a held resource* (memory, fd, connection,
lock, GPU buffer).

Single-decision changes:
- **Change ownership/lifetime.** stack → heap; owned → borrowed (Rust `T` → `&T`); add an
  explicit lifetime; `unique_ptr` → `shared_ptr`. One decision; signatures + call sites
  ripple (compiler-forced in Rust/C++).
- **Change acquisition/release discipline.** manual open/close → RAII / `with` / `defer` /
  `using`; pool vs per-use; eager vs lazy acquisition.
- **Change resource scope/pooling.** per-call connection → connection pool → single shared
  connection. Behavior (limits, contention, leaks) changes.
- **Change caching/eviction policy as a lifetime decision.** cache forever → TTL → LRU →
  no-cache. One policy decision; placement scattered.
- **Change copy vs move vs share.** deep-copy → shallow → COW → reference. Aliasing
  behavior changes everywhere the value flows.

**Why it smears:** lifetime is a property of a value *as it flows*, so a single
ownership decision propagates along the entire flow path — again compiler-enumerated in
Rust/C++, invisible-and-perilous in GC'd or manual-memory languages.

---

## L. Invariants, contracts & validation — the "what must be true" layer

**Decision kind:** change *the constraints the program asserts or assumes*.

Single-decision changes:
- **Add/remove/strengthen a precondition or postcondition.** "qty must be > 0" added to a
  function; tighten an `assert`/`require`. One decision; enforcement may need to appear at
  many entry points if there's no single gateway.
- **Add/remove a validation rule.** "email must be unique"; "sum of allocations == 100%".
  Crosses F (the check) and H (what happens on violation).
- **Change an invariant's *enforcement point*.** validate-on-write vs validate-on-read vs
  validate-at-boundary (parse-don't-validate). Moving the boundary is one decision, many
  edits.
- **Change a default/total-function policy.** total (handle all inputs) → partial (panic on
  bad) → defaulting (clamp). Overlaps H and B.
- **Change a consistency model.** strong → eventual; transactional → best-effort. Huge
  smear; bundles H, I, J.

**Why it smears:** an invariant is a *global* property; without a single enforcement
choke point (a smart constructor, a parse boundary), it must be asserted at every site
that could violate it. The decision is "this must always hold"; the text is every place
it's checked.

---

## M. Evaluation order, strictness & timing — the "when is it computed" layer

**Decision kind:** change *when/whether a value is computed*, holding what-is-computed
fixed.

Single-decision changes:
- **Eager → lazy / lazy → eager.** compute now → thunk/`lazy`/generator; Haskell strictness
  annotations (`!`); `Iterator` vs materialized `Vec`. Behavior changes if there are
  effects or non-termination.
- **Memoize / un-memoize.** add caching of a pure computation. Behavior changes iff inputs
  to "pure" aren't actually pure (the bug surface).
- **Eager vs deferred effect (the IO monad / promise distinction).** running an effect at
  definition time vs at run time; cold vs hot observable.
- **Change evaluation count.** compute-once-and-share vs recompute-per-use (CSE as a
  *semantic* decision when the computation has effects/cost). Overlaps C (sharing) and K.
- **Streaming vs batch.** process-as-you-go vs load-all-then-process. Changes memory
  profile and failure/partial-output semantics.

**Why it smears:** strictness/timing is a property of how a value threads through the
program; flipping it can require introducing thunks/awaits/generators along the whole
path. **Flag:** the boundary with I (async) blurs — async is timing across *tasks*; this is
timing within one logical flow.

---

## N. Interface, protocol & versioning — the "how it's observed/talked to" layer

**Decision kind:** change *the external contract* — what callers/peers see, in space
(API shape) and time (versions).

Single-decision changes:
- **Change a function/endpoint signature.** add/remove/reorder a parameter; positional →
  named/keyword; change return shape. One decision; every caller edits.
- **Change a protocol/format.** REST → graphQL field; add a required request field;
  change status-code semantics; protobuf field add/deprecate (wire-compat decision).
- **Change defaulting/optionality at the boundary.** make a query param optional with a
  default; change pagination defaults.
- **Change a versioning/compat policy.** additive-only → breaking; introduce a `/v2`;
  change a feature-detection scheme. One decision governing how *all* future changes
  propagate.
- **Change observability contract.** log format/level, metric names, trace attributes that
  *other systems parse* — changing them is a contract break even though it "looks like"
  internal logging (overlaps H but the smear is external/cross-repo).

**Why it smears:** the contract is shared with parties *outside the file/repo*, so the
smear extends past the codebase — into clients, dashboards, other services. The decision
is one; the blast radius is unbounded by the local module.

---

## Cross-cutting structure of the taxonomy

Three observations that make this MECE-ish rather than a flat list:

1. **Layered stack.** A→B→...→N roughly ascends: *what is computed* (A,B), *over what,
   shaped how* (C,D,E), *sequenced/selected how* (F,G), *with what world-interaction and
   failure* (H), *with what timing/parallelism* (I,M), *over what resources* (K),
   *composed how* (J), *constrained by what* (L), *observed how* (N). Most real edits live
   on one axis; the high-smear ones (in-process→RPC; strong→eventual consistency) are
   *bundles* that cross many — and that bundling is itself a recognizable category.

2. **The smear has three mechanisms, and they predict tooling difficulty:**
   - *Replication smear* (A, some F, L): same decision copied to N sites because no single
     source of truth. Tooling answer: lift to one binding/choke point.
   - *Contract smear* (D, E, H, K, N): decision propagates because every use site is
     bound by a shared contract (type, representation, signature, lifetime). The compiler
     can *enumerate* this when the contract is typed — which is exactly why typed
     languages make these edits feel like a worklist rather than a search.
   - *Cross-cutting smear* (H effects, I async, parts of L/M): one policy sprinkled through
     unrelated code by structural necessity (aspect-oriented territory; viral async
     coloring). Hardest to localize; the strongest case for a decision-level edit unit.

3. **Many "single decisions" are actually small DAGs of decisions on different axes.**
   "Store money as cents" = E (representation) + B (arithmetic now integer) + N (wire
   format) + L (invariant: never sub-cent). The *intent* is one node; faithful editing
   means editing that node and letting the projection regenerate the scattered text. This
   directly supports the thread's thesis.

---

## Axes I expect the other frames (bottom-up-from-anecdotes, or tooling/diff-driven) to MISS or under-weight

- **G's open-vs-closed dispatch / expression-problem flip** — the *dual* nature (adding a
  variant vs adding an operation) is a structural insight that anecdote-mining rarely
  surfaces, because each side looks like an ordinary "add a case" edit.
- **G's invisible smear** — adding an `impl`/override changes behavior at call sites with
  *no text edit there*. A diff-driven frame literally cannot see it (there's no diff at the
  affected site), so it will be systematically blind to it.
- **M (evaluation order/strictness/memoization/streaming)** — rarely appears in
  example-driven lists because it has no characteristic syntax; it's a property of *when*,
  not *what*. Eager↔lazy and memoize↔recompute are real one-decision behavior changes that
  hide.
- **K (resource lifetime/ownership)** as distinct from types — anecdote lists fold this
  into "types," but ownership is its own axis (move/borrow/share, RAII, pooling) with its
  own smear path along value flow.
- **J's in-process→network as a single architectural decision** — it reads as "a big
  refactor," not "one decision," so it gets excluded; but it's exactly a single decision
  whose smear crosses H+I+E+N at once, and is the highest-value target for decision-level
  tooling.
- **N's observability-as-contract** — log/metric format changes look internal but are
  external contracts; easy to miss as a behavior-changing axis.

## Honesty flags / soft spots

- **D-generics, C-rename, J-moves** straddle the refactor/behavior line; I kept only the
  behavior-changing halves but the boundary is genuinely fuzzy and judgment-dependent.
- **G resolution policy** (overload/MRO/specialization) and **I memory-ordering** are real
  but so language-specific and subtle that my examples are illustrative, not exhaustive —
  flagged rather than confabulated.
- **MECE is approximate.** Effects (H), invariants (L), and timing (M) genuinely overlap;
  policy changes (conflict/retry/consistency) recur on multiple axes by nature. I treated
  the *primary structural locus* as the home axis and noted the crossings rather than
  forcing disjointness.
