# Frame 4 — Empirical, bottom-up: what edits actually happen

Grounding the "program is a structure of decisions; text smears one decision across
many edits; the right unit of editing is the decision" frame from **what real diffs,
commits, and PRs actually consist of** — not from the top-down structure of programs.

Method: I sampled real history in this ecosystem (normalize, marinada, et al.) plus
draw on general industry diff/PR experience. Where a claim rests on general experience
rather than a sampled diff I flag it. The point of the empirical frame is to catch
edit-kinds the structural / mechanism frames don't surface because they only appear
when you look at *who actually changed what, and why, across a real codebase's life*.

## Two grounding examples (real diffs from this repo's neighbors)

1. **Dependency bump** (`marinada@71f0abc`, "use @rhi-zone/rainbow@0.2.0-alpha.1"):
   one decision — *upgrade rainbow* — touched **three files in three different
   representational substrates**: `package.json` (the human-authored intent, "I want
   0.2.0-alpha.1"), `bun.lock` (machine-generated resolved graph, 4 lines), `src/index.ts`
   (the breaking-change adaptation: restore the reactive exports the new version moved).
   The "decision" lives in *one* of those edits (the version string); the rest are
   *consequences* — one machine-derivable, one semantic-adaptation.

2. **House-style migration** (`normalize@2f9c4545`, "wave 2 batch D"): one decision —
   *conform 6 subcommands to the new output house-style* — smeared across **8 files,
   ~600 changed lines**, including a CHANGELOG entry and a SUMMARY line. This is a
   maximal-smear case: the decision is a single predicate ("output must match house
   style"), the text is hundreds of edits, and there is *no* localizing representation
   today — it's done as repeated waves/batches precisely because it can't be expressed once.

These two anchor the taxonomy: the recurring axis is not "how big" but **how far the
text representation sits from where the decision lives**, and **how many distinct
substrates one decision crosses**.

## The taxonomy of real edit-kinds

For each: (D) is it one decision in thought? (S) smear severity in text. (L) does a
localizing representation exist or is it conceivable?

### A. Point fixes — decision and text nearly coincide

- **Off-by-one / boundary fix** (`<=`→`<`, `i+1`→`i`). D: one decision. S: ~nil, one
  token. L: already local; the edit *is* the decision. These are the cases the
  "text smears decisions" thesis handles *worst as motivation* — here text is fine.
- **Wrong operator / inverted condition** (`&&`→`||`, `!`drop). D: one. S: ~nil. L: local.
- **Null / edge-case guard added** (`if x is None: return`). D: one ("handle the empty
  case"). S: low — usually one block, but *sometimes* the same guard must be added at
  N call sites because the language/contract doesn't centralize it → see C. L: local
  when centralizable; smears when the guard is a per-caller obligation.
- **Constant / config bump** (timeout 30→60, retries 3→5). D: one. S: ~nil if the
  constant is named once; **non-trivial if the value is duplicated** (the classic
  "magic number in 4 places"). L: local iff DRY; the smear is a *symptom of missing
  representation*, not inherent to the decision.

Takeaway for the thesis: point fixes are the **counterexamples** that bound the claim.
For a large fraction of real bug-fix commits, decision≈edit already. The thesis earns
its keep on the *non*-point kinds below.

### B. Fan-out from a single definitional change — the core smear

- **API / signature change + call-site fan-out** (add a param, rename, change return
  type). D: **one decision** ("the contract is now this"). S: **high and unbounded** —
  N call sites, often across files/packages. L: *partially* exists — IDE rename,
  "change signature" refactors, codemods. This is the kind the decision-unit thesis is
  most clearly *right* about and where tooling has *already partially won*: a rename is
  one decision and good tools already make it one gesture. The residue is the cases
  the refactor engine *can't* prove safe (dynamic dispatch, reflection, string-keyed
  calls, cross-language/IPC boundaries).
- **Data-model / schema change** (add column, change type, split a field). D: one
  decision conceptually. S: **very high** — the change crosses *substrates*: ORM model,
  migration up/down, serializers, validators, fixtures, possibly the API DTO and the
  frontend type. L: weak. Migrations exist but are themselves a *separate authored
  artifact* expressing the same decision a second time. The decision "field foo is now
  optional" is re-stated in: the schema, the migration, the validation, and every
  consumer's null-handling. No single representation owns it.
- **DI / wiring changes** (register a service, swap an implementation, thread a
  dependency through constructors). D: one ("component X now depends on Y"). S: medium
  to high — "constructor threading" makes you touch every layer between the provider
  and the consumer even though only the endpoints carry the decision. L: partial — DI
  containers *are* an attempt to localize this into config; the smear reappears in
  manual-wiring codebases.

### C. Cross-cutting predicate edits — one decision, no locus at all

These are the cases where **the decision is a predicate over the whole codebase** and
text has *no* place to put it once.

- **House-style / formatting / output-format conformance** (the normalize example).
  D: one predicate. S: maximal. L: none today unless the property is mechanizable by a
  formatter; when it's semantic ("spell out abbreviations in headers") it's a human
  judgment applied N times.
- **Security fix = "add a check everywhere this pattern occurs"** (authz check before
  every mutation, escape every interpolation, validate every external input). D: one
  ("this class of access must be guarded"). S: high, and **dangerous because partial
  application is a vulnerability** — missing one site is the bug. L: weak; the right
  representation is often *architectural* (a choke point / middleware) and the edit's
  real content is "move this from N sites to one site," which is a different decision.
- **i18n / copy / string extraction** (wrap user-facing strings in `t(...)`). D: one
  policy. S: high. L: lint rules approximate it; the actual edit is per-string judgment.

### D. Edits whose "one decision" lives *outside the code* — what top-down frames miss

This is the empirically-distinctive payload of this frame. The structural and
mechanism frames look at the program and ask "what's the smallest semantic unit." They
will systematically **miss the kinds where the decision's identity is defined by an
artifact the program doesn't contain**:

- **External-contract-driven changes.** A third-party API changes its response shape,
  a payment provider deprecates an endpoint, an OS raises a permission requirement.
  The "one decision" is *theirs*, not yours; your diff is the *forced adaptation*. It
  spans your client code + your types + your error handling + your tests + often a
  feature flag to roll it out. Top-down frames see an unmotivated multi-file change
  with no internal decision node, because the decision node is in *someone else's*
  system. The localizing representation would be "a typed binding to the external
  contract, regenerated" — i.e. the decision lives in *their* spec, and the honest unit
  is "re-pin to contract version N."
- **Dependency upgrade + breaking-change fan-out.** (The marinada example.) The
  decision "upgrade to X" is one line in `package.json`; the *fan-out* is dictated by
  the dependency's CHANGELOG, not by your program's structure. The lockfile edit is
  machine-derived (should never be a "decision" at all — it's a *projection*, and the
  fact that it shows up in diffs at all is a representational accident). The adaptation
  edits are forced by *their* decisions. Three substrates, one nominal decision, and
  the bulk of the text is consequence rather than intent.
- **Changes that are "one decision" only relative to a spec / ticket / RFC.** "Implement
  ticket PROJ-1234." Internally this may be a feature flag + a schema column + an API
  field + a UI control + a copy string + a migration + a test. There is no single
  *code* node that is the decision; the decision is the ticket, and the code is its
  *shadow cast across every layer*. The structural frame, asked "is this one decision,"
  will say "no, it's six" — and be wrong about the human reality, where it's one
  intent. This is the strongest empirical case that **the decision unit is sometimes
  supra-code**: it can only be localized by binding the diff to the external spec.
- **Simultaneous code + config + schema + docs changes.** Real PRs routinely touch all
  four for one feature: the code, the feature-flag default, the migration, and the
  README/changelog. A purely code-structural decision model has no node spanning
  code+config+schema+docs because they're in *different languages and files*. Yet a
  reviewer reads them as one decision. The smear here is *across representational
  systems*, which is invisible to any frame that stays inside the program's AST.
- **Feature flag lifecycle.** A flag is *introduced* (one decision, but the edit adds a
  branch at the consumption point *and* a registration *and* often a config default),
  then later *flipped* (one trivial edit — decision≈edit), then *removed* (one decision
  "the flag is permanent," but the edit must delete the dead branch at every site — a
  fan-out / dead-code-deletion smear). The same conceptual entity produces a low-smear
  edit at flip time and a high-smear edit at birth and death. Top-down frames tend to
  model "the feature," missing that the *flag's own lifecycle* generates three
  structurally different edit-kinds.
- **Revert / rollback.** "Undo decision D." Empirically common, conceptually one
  decision, and git *does* localize it (`git revert <sha>`) — a rare case where the
  representation already binds the edit to the decision (the commit) perfectly. Worth
  noting because it's the existence proof that decision-granular editing is *possible*
  when the decision was captured as a unit at creation time.
- **Performance changes** (swap algorithm, add a cache, batch a loop). D: one ("make
  this path faster"). S: medium — but distinctive in that the diff often *adds a whole
  parallel structure* (a cache layer, a memo table, an index) whose every line is in
  service of one decision, plus invalidation logic scattered at every mutation site.
  The invalidation fan-out is the smear; cache *introduction* is the decision.
- **Compat / version shim.** "Support old and new behavior during transition." One
  decision, but it *deliberately* creates a branch (a smear by design) that a later
  decision ("drop old") must remove. Pairs with the migration-fence principle: the
  shim is the honest mark that a migration isn't finished.

### E. Edits that aren't decisions at all (and pollute the signal)

Empirically the largest category by *line count* in many repos, and a trap for any
decision-unit model:

- **Machine-generated artifacts in diffs**: lockfiles, generated clients, snapshots,
  compiled assets, formatter output. These appear in version history as edits but carry
  *zero* decision content — they're projections of a decision made elsewhere. A
  decision-granular editor should treat these as *derived*, never as units. (This
  ecosystem's own "library-first; projection-from-one-definition" and "data over code"
  principles are exactly the prescription: the lockfile shouldn't be a diff you reason
  about, it's a build output.)
- **Mechanical propagation / sync**: this very repo's history is dominated by
  "sync ecosystem region across 37 repos" commits — *one* decision (edit the canonical
  CLAUDE.md) replicated mechanically to N repos. This is the **purest real-world
  smear**: one authored decision, N identical commits across N repositories, and the
  ecosystem already built a *localizing representation for it* (`sync-skills.sh`,
  `propagate-harness.sh` — author once in github-io, fan out by tool). It's a working
  proof that when the smear is recognized, the fix is a propagator that makes the
  decision editable in one place. The top-down frames will miss this because the smear
  is *across repositories*, not within one program.

## Synthesis — what the empirical view contributes

1. **Smear severity is bimodal, not continuous.** A large fraction of bug-fix edits are
   point fixes where decision≈edit (smear ~0). The rest are fan-out/cross-cutting where
   smear is high-to-unbounded. There's relatively little in between. The thesis should
   not claim *all* editing smears decisions — it should target the fan-out and
   cross-cutting classes, and explicitly concede point fixes as the boundary.

2. **The decision frequently lives outside the code.** Tickets, external API contracts,
   dependency CHANGELOGs, style guides, security policies. The honest "unit of editing"
   for these is a *binding to the external artifact* (re-pin to contract vN, conform to
   style guide rule R), and the code diff is its projection. Any decision-editor that
   only models intra-program structure cannot represent these decisions at all — it can
   only see their shadows. **This is the class the top-down frames most reliably miss.**

3. **One conceptual entity emits different edit-kinds over its lifecycle.** Feature
   flags (birth=fan-out, flip=point, death=dead-code-removal); shims (creation=branch,
   removal=fan-out); caches (intro=structure-add, use=invalidation-fan-out). A static
   "what is a decision" taxonomy misses this; you have to watch the *temporal* history.

4. **The smear crosses representational substrates, not just files.** schema↔migration↔
   serializer↔validator↔DTO↔frontend-type; package.json↔lockfile↔adaptation-code;
   code↔config↔docs. The hardest smears aren't "many lines in one language" — they're
   "the same decision restated in five different languages," which no AST-level frame
   can localize.

5. **Derived artifacts must be excluded from the decision model.** Lockfiles, generated
   clients, snapshots, formatter output, and mechanical cross-repo propagation are the
   *highest line-count* changes in real history and carry *no* decision. Treating them
   as edits is the main way an empirical signal gets polluted. The ecosystem's own
   projection-from-one-definition / propagator tooling is the existence proof that the
   right move is to make them *derived*, not edited.

6. **Where decisions were captured as units at birth, decision-granular editing already
   works.** `git revert <sha>`, IDE rename, codemods, DI config, feature-flag flips,
   and this repo's propagators all show that the smear is *contingent on the
   representation*, not fundamental. The lesson isn't "editing is doomed to smear" —
   it's "smear is what you get when the decision was never given a home; give it one and
   the edit collapses to the decision."
