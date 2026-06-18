# Frame 2 — Localizing Representations

*Mechanism-up enumeration of the single-decision behavior-change space, organized by
the representation/mechanism that turns a class of decision into a one-unit edit.*

## The frame, stated precisely

A program encodes a structure of **decisions**. A *single-decision behavior change* is
an intended change to exactly one decision that alters observable behavior (excluding
behavior-preserving refactors — those are a different axis). The pathology of text is
that one decision is **smeared**: changing it requires N coordinated character/line edits
across the file set, and the burden of finding-and-coordinating all N falls on the human.

The thesis of this frame: for each class of decision, there exists *a* representation in
which that decision is **localized** — collapses to a single edit — and the machine
**propagates the shrapnel** (mechanically derives and applies the other N−1 edits the
decision determines). Different decisions are localized by different representations; no
single representation localizes all of them (cross-cutting concerns smear even in the
AST). So the space is best charted *by mechanism*: each mechanism is a lens that makes one
band of the decision-spectrum into single-unit edits.

Two orthogonal properties distinguish the mechanisms, and they matter for the frontier:

- **Localization** — does the decision live in one place? (define-once)
- **Propagation** — when you edit that one place, does the machine *derive* the dependent
  changes, or merely *route you to* them?

The strongest mechanisms do both (you edit one site, the compiler/runtime/codegen
produces the rest). Weaker ones only localize *authoring* but propagate by **failing
loudly** — they don't write the shrapnel, they enumerate it as a worklist. That second
mode (exhaustiveness errors as a to-do list) is itself a major design technique and worth
naming as distinct from full propagation.

---

## 1. DRY / abstraction — the baseline localizer

**Decision class.** "This value / this algorithm / this policy is *the same* everywhere it
appears." A magic number (tax rate, retry count, buffer size), a duplicated computation,
a repeated control pattern.

**How it localizes.** Name the thing once (constant, function, method, module). The
decision now has a single definition site; every use is a *reference*, not a copy.

**How it propagates.** Edit the definition; references see the new value automatically — at
compile time (inlined constant) or at runtime (function call). The propagation is the
language's name-resolution mechanism; it is *complete and automatic* for everything
downstream of the name. This is the cleanest possible case: localization and propagation
are both total.

**Concrete.** A `const TAX_RATE` in any language; a shared `validate_email()` instead of
inlined regex; React lifting a `useCallback` to one place; CSS custom properties
(`--brand-color`) as a single-edit site for a color that paints 200 elements; ecosystem
`normalize-core` as the *one* normalization definition every surface calls.

**Limits.**
- DRY localizes *sameness*, and only sameness you've already factored. Two things that
  *happen* to be equal today but are conceptually independent (the "incidental
  duplication" trap) get falsely coupled — now one decision smears *into another decision*
  because you DRY'd across a seam that should have stayed separate. Sandi Metz's "duplication
  is far cheaper than the wrong abstraction" is exactly this failure.
- It cannot localize a decision that is *structurally* spread — control flow that must
  thread a value through ten stack frames, an error case that every caller must handle.
  Naming doesn't help there; you need the type system or effects (below).
- The factoring itself is a decision you must make *in advance*. DRY localizes future
  edits only for decisions you predicted. Unanticipated change still smears.

---

## 2. The static type system — propagation by exhaustive failure

**Decision class.** "The shape of this data changed" — add a variant/case, add a required
field, change a field's type, make a value non-optional, split one type into two.

**How it localizes.** The change is *one edit to the type definition* (add the enum case,
add the struct field). The decision lives at the type.

**How it propagates — and this is the key move.** A sound, exhaustive type system converts
the edit into a **complete worklist of every site the decision touches**, surfaced as
compile errors. Add a case to a Rust `enum` and every non-`_` `match` becomes a
non-exhaustive-match error: the compiler hands you the exact set of N−1 shrapnel sites.
You don't *find* them; the type checker *enumerates* them. This is propagation-by-failure:
the machine doesn't write the new arms (it can't know the behavior), but it guarantees you
will not *miss* one. Localization of authoring + mechanical enumeration of shrapnel.

The strength is proportional to **soundness + exhaustiveness + absence of escape hatches**:

- Rust `enum` + `match` with no wildcard, OCaml/Haskell ADTs, Elm (famous for "if it
  compiles it works" precisely because of this) — near-total enumeration.
- TypeScript discriminated unions + `never`-assertion in the default branch — opt-in
  exhaustiveness; strong but you must wire the `assertNever`.
- Java `enum` + `switch` *without* sealed types — the `default:` swallows new cases
  silently; the worklist is *not* surfaced. Java 17 sealed classes + pattern switch
  finally closes this.

**Richer sub-cases (still the type system, more of it):**

- **`int → UUID` / `int → newtype`.** Changing an identifier's representation: one edit to
  the type alias, and every arithmetic/comparison site that no longer typechecks is
  surfaced. Newtypes (`struct UserId(u64)`) localize the decision "these two `u64`s are not
  interchangeable" — mixing `UserId` and `OrderId` becomes a type error rather than a
  silent bug.
- **Optionality (`T → Option<T>` / nullable→non-null).** Making a field optional forces
  every reader to handle absence; the compiler enumerates the readers. Kotlin/Swift
  nullability, Rust `Option`, TS `strictNullChecks`. The decision "this can now be missing"
  propagates as a worklist of unwrap sites.
- **Splitting a type.** `Order` → `DraftOrder | PlacedOrder`: every function that assumed
  the union must now declare which it takes; the type checker walks you through it.

**Limits.**
- Propagates *that* each site must change, never *how* — the behavioral content of each new
  match arm is yours to write. (This is correct: that content is genuinely new decision,
  not shrapnel.)
- Defeated by escape hatches: `_ =>`, `any`, `default:`, downcasts, reflection,
  serialization boundaries (the type system stops at the wire — a JSON payload that gained
  a field surfaces nothing).
- Dynamic languages (Python without full type coverage, Ruby, JS) get *none* of this;
  gradual typing gets it only on the typed fraction.
- The decision must be *expressible as a type change*. "Change the order in which two
  independent effects fire" is not a type-shaped decision; the type system is blind to it.

---

## 3. Richer types — pushing more decisions into the localizable band

This is the type system again, but the move is to *enrich the type* so that a decision
which was previously a smeared runtime convention becomes a single type-level edit.

**Decision class.** "This quantity has a *meaning* the bare representation hides" — units,
currencies, coordinate frames, time zones, sanitized-vs-raw, validated-vs-unvalidated,
provenance.

**How it localizes + propagates.**

- **Units of measure.** F# native units-of-measure (`float<m/s>`), the Rust `uom` crate,
  Haskell `dimensional`. The decision "this is meters, that is feet" is encoded in the type;
  a unit mismatch is a compile error, and *conversions become the only legal bridge*. The
  Mars Climate Orbiter (lb·s vs N·s) is the canonical demonstration of what *not* having
  this costs.
- **Money / cents / `Decimal`.** A `Money` newtype carrying currency localizes "never add
  USD to EUR" and "never use float for money" into the type; every arithmetic site is
  checked.
- **UTC vs local / `Instant` vs `LocalDateTime`.** Java `java.time`, Rust `chrono`/`jiff`
  distinguish the two at the type level so "is this timestamp zoned?" is answered by the
  type, not by a comment and a prayer.
- **Tainted / validated strings.** `Sanitized<String>` vs raw `String` (a newtype or
  branded type) localizes "this input has been validated" — every sink that requires
  sanitized input rejects raw input at compile time. Wyatt-protocol-style "parse, don't
  validate" (Alexis King) is the design idiom: push the decision into a type so the
  *unvalidated* state becomes unrepresentable past the boundary.

The richer-types move is essentially: **make the illegal state unrepresentable**, so the
decision "this combination is forbidden" is enforced once at the type and propagated as
type errors everywhere it would be violated.

**Limits.**
- Ergonomic cost: heavy newtype/phantom-type machinery is verbose; many ecosystems lack the
  type-system power (no dependent types, no first-class units) to express the constraint
  cleanly, so it degrades to runtime checks.
- Dependent/refinement-level facts ("this `Vec` is non-empty", "this index is in bounds")
  need Idris/Agda/Lean/F\*/Liquid Haskell — outside the mainstream; the decision is
  localizable *in principle* but the representation isn't available in the languages people
  ship.
- Still type-shaped only. Temporal, ordering, and resource-lifecycle decisions leak out
  (some recovered by linear/affine types — Rust's borrow checker localizes "who owns this /
  when is it freed" and propagates as borrow errors; a genuine extension of this band).

---

## 4. Effect systems & algebraic effects — localizing the cross-cutting *how*

**Decision class.** "*How* is this computation carried out" as opposed to *what* it
computes: is it async or sync, can it fail, does it do IO, does it log, is it
non-deterministic, can it be retried/cancelled/transacted. These decisions are notorious
smearers — making one function async forces `async`/`await` up the *entire* call chain
("function coloring", Bob Nystrom).

**How it localizes.** Move the *how* out of the call-site plumbing and into (a) a type-level
**effect annotation** on the computation and (b) a **handler** installed once at a chosen
boundary. The decision "this runs in IO / can fail / is async" becomes one effect tag; the
decision "how that effect is actually discharged" becomes one handler.

**How it propagates.**

- **Monadic effects (Haskell `IO`, `Either`, `STM`; Rust `Result`/`?`; do-notation).** The
  effect is in the type; `?` / `<-` thread it without manual plumbing. Changing a function
  to fallible localizes to its return type; the `?` operator propagates the early-return
  shrapnel mechanically. (Still suffers monad-transformer stacking pain — the composition
  doesn't localize cleanly.)
- **Algebraic effects + handlers (Koka, Eff, OCaml 5 effect handlers, the Unison ability
  system, React's "hooks/Suspense" as a de-facto effect system).** This is the strongest
  form: the *operation* is declared abstractly (`perform Log msg`), and a single `handle`
  installs the interpretation. The decision "logging now goes to a file / is suppressed in
  tests / is collected into a list" is **one handler swap** — the call sites that perform
  the effect are untouched. Async-vs-sync, real-IO-vs-mocked, deterministic-replay-vs-live:
  all become *handler selection*, localized at one boundary, propagated by the runtime's
  delimited-continuation machinery.

This directly realizes the ecosystem principle "the LLM is an oracle at the leaves, never
the control loop": an LLM call modeled as an *effect* lets you swap a live-model handler for
a seeded-replay handler, localizing the determinism decision to one handler install.

**Limits.**
- Mainstream availability is thin. OCaml 5 effects shipped 2022; Koka/Eff/Unison are
  research/niche; most production code simulates this with DI, monads, or manual
  threading — which re-smears.
- The *type* of the effect propagates; the *semantics* of a new handler is still authored.
- Effect *interaction order* (which handler wraps which) is a real decision that the
  mechanism makes *expressible* but does not make *single-unit* — reordering handlers can
  be subtle.
- Performance and debuggability of continuation-based handlers are still maturing.

---

## 5. AOP / aspect weaving — localizing the genuinely cross-cutting

**Decision class.** A concern that is *intrinsically* scattered across many unrelated units
and cannot be localized by naming or typing because it crosscuts the dominant
decomposition: logging, authorization checks, transactions, caching, metrics/tracing,
audit. "Log every public service method" touches every public service method.

**How it localizes.** Express the concern as **one aspect** = a *pointcut* (a query
selecting the join points: "all public methods in `com.foo.service.*`") + *advice* (the
behavior to run there). The decision "what crosscuts where" is now a single declarative
unit.

**How it propagates.** A weaver (compile-time, load-time, or runtime-proxy) injects the
advice at every matched join point automatically. *Adding a new service method
automatically inherits the aspect* — the propagation is to *future* code too, which DRY and
types cannot do. AspectJ (the canonical system), Spring AOP (proxy-based, the workhorse of
real Java backends — `@Transactional`, `@Cacheable`, `@PreAuthorize` are all advice),
PostSharp (.NET), Python decorators *as a poor-man's per-function aspect*, Go's lack of this
(felt as middleware boilerplate).

**Limits.**
- **Action at a distance** — the defining critique. Behavior appears at a site with no local
  textual evidence; you cannot read a method and know what runs around it. The decision is
  localized for the *author of the aspect* but *delocalized for the reader of the join
  point*. This is the precise dual of the type system (which makes the worklist *visible*);
  AOP makes it *invisible*. That trade is why AOP fell out of fashion outside the
  framework-blessed cases (`@Transactional`).
- Pointcuts are *queries over structure*; they're brittle to refactoring (rename a package,
  silently lose the advice — the "fragile pointcut" problem).
- Ordering of multiple aspects at one join point is underspecified/fiddly.
- Annotation-driven AOP (Spring) recovers locality (the `@Transactional` is *visible* at the
  method) at the cost of generality (you must annotate each site — back toward per-site
  edits). The trade between invisibility-but-general and visible-but-per-site is unresolved.

---

## 6. Macros / metaprogramming / codegen — localizing "generate this family of code"

**Decision class.** "Every X should also have a Y derived from it by a fixed rule" — derive
serialization from a struct, derive a builder/equality/hash, generate client stubs from an
API schema, generate parser from a grammar, generate boilerplate from a template. The
decision is *the rule*, and the shrapnel is the entire generated family.

**How it localizes + propagates.** Write the *rule* once; the generator emits the family and
re-emits it whenever the source changes. This is the most *general* propagation mechanism —
it can produce arbitrary derived code, not just type-checked worklists.

- **Hygienic macros (Lisp/Scheme/Racket, Rust `macro_rules!` + proc-macros, Elixir).**
  `#[derive(Serialize, Debug, Clone)]` in Rust is the exemplar: the decision "this struct is
  serializable" is *one attribute*; the proc-macro generates the impl and *regenerates it on
  every field change*. Adding a field propagates into the derived impl with zero extra edits
  — strictly better than the type-system case (which would only *flag* the missing handling).
- **Schema-first codegen.** Protobuf/gRPC (`.proto` → stubs in N languages), OpenAPI
  generators, GraphQL codegen, Thrift, Cap'n Proto. The decision "the wire contract has this
  field" is one edit to the `.proto`; regeneration propagates into every language client —
  *crossing the language and process boundary* that the type system cannot cross. This is the
  ecosystem's "library-first; projection-from-one-definition" principle as a build step: one
  typed definition, many generated surfaces (CLI/HTTP/MCP/WS), never hand-rolled per surface.
- **Compiler-as-codegen / lowering.** Rust `async fn` → state machine, C# `async/await` →
  continuation struct, Go generics monomorphization. The decision is written high-level; the
  compiler propagates the mechanical lowering.

**Limits.**
- **Debuggability and opacity** — you debug *generated* code you didn't write; stack traces
  and errors point into machinery. Macro errors are notoriously bad.
- **Staging / build complexity** — codegen adds a build step, a regeneration discipline, and
  a "is the generated output checked in or built?" decision. Stale generated code is a
  classic bug source.
- **The rule itself is hard to write and harder to change** — a proc-macro is a compiler; the
  decision *inside* the generator is now smeared in *its* representation. You've moved the
  locality, not eliminated the need for it.
- Macros operate on syntax/AST; they cannot see *semantics* or cross-module facts a type
  checker sees, so they localize *structural* generation, not *semantic* consistency.

---

## 7. Configuration / feature flags — localizing the runtime/deploy decision

**Decision class.** "Under condition C, behave differently" where the decision must be
changeable *without* recompiling/redeploying, or must vary per-environment, per-tenant,
per-user-cohort: enable a feature, tune a threshold, A/B split, kill-switch, per-tenant
policy.

**How it localizes.** Hoist the decision out of code into a **configuration value / flag**
read at runtime. The decision now lives in one config key (a file, a flag-service entry,
an env var), editable by non-engineers, at runtime, reversibly.

**How it propagates.** Every guarded site reads the same key; flipping the key changes all
of them at once, live. LaunchDarkly / OpenFeature / Unleash / Flagsmith, Statsig, plain
`.env` + 12-factor config, Chrome `chrome://flags`, Linux `Kconfig`. Kill-switches and
progressive rollouts are the headline value: one edit, instant fleet-wide effect, instant
rollback.

**Limits.**
- **Flag debt / combinatorial explosion** — N boolean flags = 2^N latent behaviors, most
  untested. The decision is localized but its *interactions* are not; flags are a notorious
  source of unreachable/contradictory states. (Knight Capital's $440M loss: a repurposed
  flag activated dead code on one of eight servers.)
- Flags are meant to be *temporary* (rollout scaffolding) but become permanent; stale flags
  re-smear the decision into dead branches nobody dares delete.
- The *guard sites* are manual — you still thread `if flag.enabled(...)` everywhere; that
  threading is per-site shrapnel the mechanism does *not* propagate (it's DRY-on-the-key,
  not weaving). Closer to AOP would auto-guard; flags don't.
- Config is untyped/stringly by default; a typo in a key is silent. Typed config (e.g.
  Rust `figment`, the ecosystem's preference for typed surfaces) recovers some of this.

---

## 8. Database schema + migrations — localizing the decision over *persistent state*

**Decision class.** "The shape/constraint/meaning of stored data changed" — add a column,
add a constraint, change a type, split a table, add an index, change a default. This is the
hardest band because the shrapnel includes **data already at rest** and **other processes
reading it concurrently**, not just code.

**How it localizes.** A **migration** is the single, ordered, versioned unit that *is* the
decision: "schema goes from version K to K+1, and here is the forward transform (and ideally
the reverse)." Flyway, Liquibase, Rails ActiveRecord migrations, Alembic, Prisma Migrate,
Diesel, sqlx, Ecto. The decision is one migration file; the migration *history* is the
log of all schema decisions, replayable to reconstruct any version.

**How it propagates.** The migration runner applies the transform to existing data and
advances the version marker; the ORM regenerates typed models from the new schema (Prisma,
Ecto), propagating the change into application types — at which point the *type system*
(mechanism 2) takes over and enumerates the code that must change. So this mechanism *hands
off* to the type system: schema decision → migration → regenerated types → compile errors as
worklist. The chain of two localizers covers data + code together.

**Limits.**
- **It must be online and backward-compatible during rollout.** A single-edit decision at
  the schema level *cannot* be a single deploy in a live system — you need expand/contract
  (add nullable column → backfill → start writing → start reading → drop old) precisely
  because old and new code run simultaneously. So the decision is localized in the *history*
  but *temporally smeared* across multiple deploys. This is the irreducible cost of mutable
  shared state.
- Migrations are typically *forward-biased*; clean reversibility is often a fiction (data
  loss isn't invertible). The "single decision" isn't truly bidirectional.
- Cross-cutting data invariants (referential integrity spanning services in a distributed
  system, no shared DB) have *no* schema to localize them — the decision smears across
  service boundaries with only conventions (sagas, outbox) to coordinate. This is on the
  frontier (below).

---

## 9. Adjacent localizers worth naming (not in the original anchor set)

- **Version control / VCS as decision history.** Git localizes "what changed and why" into a
  commit; `revert` propagates the inverse. Conventional commits + scoped messages (this
  ecosystem's discipline) make the *decision* legible in the log. But a commit is
  *text-diff* granular — it inherits the very smearing this whole frame is about. It
  localizes the *record* of a decision, not the *edit* of one.
- **Build-system / dependency declarations.** "Use version X of dep Y" is one edit to
  `Cargo.toml`/`package.json`; the resolver propagates the transitive graph. Localizes the
  *dependency* decision; the lockfile is the propagated shrapnel.
- **Capability / permission grants.** This ecosystem's `settings.local.json` allow-list:
  "grant this authority" is one entry; the harness propagates enforcement. Capability
  security generally (mechanism: pre-opened handles) localizes "who may do what" to the
  grant site — allow-list over deny-list is *localization of authority*.
- **Constraint solvers / declarative layout.** CSS flexbox/grid, Auto Layout, Prolog/Datalog,
  SQL itself, build dependency DAGs, spreadsheet formulas. You state the *constraint/relation*
  (one decision) and the solver propagates the consequences (the layout, the query plan, the
  recalc). Spreadsheets are the most widely deployed declarative propagation engine on Earth:
  edit one cell, the dependency graph recomputes the shrapnel. The decision class is
  "relationships between values"; the limit is that imperative/stateful decisions don't fit.
- **Term-rewriting / projectional editors.** JetBrains MPS, Lamdu, Hazel, Unison's
  content-addressed code: edit the *AST/semantic node* directly, never the text. This is the
  most literal realization of "edit the decision, not the characters" — Unison stores code by
  hash so a rename is a *metadata edit propagated everywhere* with zero diff, and dependency
  on a definition is by hash not name. Niche, but it is the existence proof that the
  text-smearing is contingent, not necessary.

---

## The frontier — decision classes with no good localizer today

These are the classes where, in mainstream practice, *no representation collapses the
decision to one unit*; the change still smears and the human still carries the
find-and-coordinate burden. This is where the frame predicts the most value and where it is
honest to say the tooling does not exist.

1. **Cross-cutting *behavioral/algorithmic* concerns that aren't structural.** AOP localizes
   concerns expressible as "run this advice at these join points." But a concern like "every
   monetary computation must round half-to-even and carry currency" or "every retryable
   operation must be idempotent" is *semantic*, not a join-point pattern. There is no
   pointcut for "all places that mutate money." The richer-types move (mechanism 3) catches
   *some* of this by construction, but only the part you encoded as a type; the open-ended
   semantic invariant has no localizer. **Open.**

2. **Protocol / contract decisions across an *untyped boundary*.** A decision that must hold
   on both sides of a wire (REST/JSON, message queues, event streams, two microservices, a
   browser and a server) has no shared type checker to enumerate the shrapnel. Codegen
   (mechanism 6) helps *when there is a single schema* (protobuf/OpenAPI); but for evolving
   event schemas, backward/forward-compatible message versioning, and consumer-driven
   contracts, the decision "the event gained a field / changed meaning" smears across
   independently-deployed services with only *runtime* contract tests (Pact) and schema
   registries (Confluent/Avro) as partial nets. No mechanism makes "evolve this distributed
   contract" a single propagated edit. **Frontier — arguably the biggest one in practice.**

3. **Temporal / ordering / concurrency decisions.** "These two effects must happen in this
   order", "this section is a critical region", "this operation must be cancellable",
   "happens-before between these events". Linear/affine types (Rust) localize *resource
   lifetime* and session types localize *protocol sequencing* — but session types are
   research-grade, and the general decision "change the interleaving/ordering policy" has no
   representation that makes it one edit. Effect handlers (mechanism 4) make *which* effects
   run localizable but not *in what temporal relation*. Concurrency decisions remain
   text-smeared across locks, channels, and async boundaries. **Open.**

4. **Performance / resource decisions.** "Make this O(n) instead of O(n²)", "cache this",
   "batch these calls", "move this off the hot path", "this must fit in 4KB". There is *no
   representation* in which an algorithmic-complexity decision is one unit — it is inherently
   a restructuring of the whole computation. Annotations (`#[inline]`, `@cache`) localize
   *trivial* resource decisions; the substantive ones (the choice of data structure, the
   memoization boundary) smear completely. (This is the deepest tie to the reasoning-thread:
   the *decision density per token* of a performance rewrite is terrible precisely because no
   representation localizes it.) **Open and probably hard-open.**

5. **Cross-language / polyglot consistency.** A decision that must hold identically in Rust,
   TypeScript, and SQL (the same validation rule on the server, the client, and a DB
   constraint) has no shared definition site unless you *generate all three from one source*
   — and most teams don't, so the rule is triplicated and drifts. Schema codegen and
   "projection-from-one-definition" are the *aspiration*; in practice the single source
   rarely spans the validation/business-logic layer, only the data shape. **Frontier;
   partially addressable, rarely addressed.**

6. **Naming / conceptual-structure decisions.** "This concept is actually two concepts" /
   "rename this domain term everywhere it appears in code, docs, UI strings, DB columns, and
   API fields." Unison localizes *code* renames perfectly (by-hash); IDE rename-refactor
   handles *one language's* symbols. But a *domain concept* lives across code + docs + UI +
   schema + external API + human conversation, and no representation spans all of those. The
   decision "we now call a Customer an Account" smears across every artifact. **Open.**

7. **Policy that spans code and the organization.** "Tighten this authorization rule",
   "change this rate limit", "this data is now PII and must be handled accordingly." The PII
   case is illustrative: the decision "this field is sensitive" *should* propagate into
   encryption-at-rest, redaction in logs, access controls, retention, and export filters —
   and there is no representation that makes it one edit. Data-flow/taint type systems and
   tools like data-classification + policy-as-code (OPA/Rego) are gesturing at it, but the
   propagation into all downstream handling is manual. **Frontier; active research
   (information-flow control, e.g. Jif/Jeeves) but not mainstream.**

8. **Decisions that *trade off* against each other (Pareto choices).** "Favor latency over
   throughput here", "favor consistency over availability for this data." These aren't
   single-site facts; they're *global postures* realized as a thousand small consistent
   choices. No representation localizes a posture. **Open — and possibly not localizable in
   principle**, because a posture is *by definition* the coherence of many decisions, not one.

### The shape of the frontier

The localizable band is, roughly: **decisions that are (a) structural, (b) expressible in a
representation a tool already checks/generates, and (c) contained within one
checkable/generatable boundary.** The frontier is everything that is **semantic rather than
structural** (invariant 1, 4), **crosses a boundary no single tool spans** (2, 5, 7 — wire,
language, organization), **is temporal/relational rather than positional** (3), or **is a
posture rather than a point** (8). Naming (6) is the odd one out — structurally simple,
mechanically localizable *within* code, but un-localized only because no single
representation spans all the *artifacts* a concept inhabits.

The throughline back to the reasoning thread: text has *uniform, terrible* decision-density
because it localizes *nothing* — every mechanism above is a partial escape that buys
single-unit editing for one band by adopting a representation in which that band is
positionally local. The frontier is exactly the set of decisions for which we have not yet
found — or cannot have — such a representation, and so are stuck paying text's price.
