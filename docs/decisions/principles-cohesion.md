# Principle-Set Cohesion Analysis

Analysis behind the Ecosystem Design Principles encoded in CLAUDE.md's ecosystem-common region. Dated 2026-05-30. **P11 (open-models vs typed-API) and the X1 load-time-contract discriminator remain open** — see §3 and §1 below.

---

# Cohesion memo: the 8 Ecosystem Design Principles

Critical assessment of whether the 8 principles just added to CLAUDE.md form a
canonizable philosophy. Sources read in full: `throughlines.md` (T1–T15, X1–X6,
§3 candidates, §4 caveats), the new CLAUDE.md `## Ecosystem Design Principles`
block, and the 12 cited ADRs (X1: 0034, 0207, 0007, 0033, 0012; X3: 0238, 0090,
0093, 0124, 0192, 0272, 0284). ADR-0151 confirmed retired/merged into 0033.

---

## 1. The X1 discriminator (hand-roll vs defer)

**Candidate rule:** *Hand-roll only where self-containment / air-gap legibility is
a declared product value of the substrate (crescent, portals-the-tool). Defer to a
maintained library everywhere else.*

**Verdict: the rule is REAL but the candidate as phrased is half-wrong on portals,
and it is being SHARPENED here, not merely read off the corpus.**

Testing against the ADRs:

- **0034 (defer side):** Clean fit. Hand-rolled Pratt parser and HTML entity
  decoder were torn out for oxc_parser / html-escape because bespoke code could not
  reach standards parity affordably. This is reincarnate — a project with *no*
  declared self-containment value. Discriminator classifies it correctly: defer.
- **0007 + 0012 + 0033 (hand-roll side):** Clean fit. Crescent writes JSON parsing
  from scratch, refuses vendored lunajson, refuses even Nix-`buildInputs` FFI —
  *because* "own your dependencies end-to-end / air-gapped bare clone is supported"
  is the stated product value (0012 names it explicitly: "make the computer small /
  knowable end-to-end"). Discriminator classifies correctly: hand-roll.
- **0207 (portals) — the counterexample that breaks the clean phrasing.** Portals
  is cited in the candidate as a hand-roll exemplar. It is the opposite. 0207
  *defers* to serde/clap/url/regex and only hand-rolls "primitives and contested
  domains." Portals' product value is *portability* ("when in doubt, leave it out",
  T5/0210), and portability led it to *defer on solved domains*, not hand-roll them.
  So "self-containment as a product value ⇒ hand-roll" does NOT hold for portals;
  portals self-contains by *narrowing scope and deferring*, the inverse mechanism
  from crescent. Throughlines §X1 already mis-bundles portals onto crescent's side
  of the seam ("crescent and portals have declared self-containment a first-class
  product value, so hand-rolling is the point there") — that sentence is wrong about
  portals and should not be inherited.

**The discriminator that actually holds across all five** is narrower and is about
the *loadability/legibility of the dependency*, not "self-containment" generically:

> Defer to a maintained library by default. Hand-roll only when the dependency
> would violate a substrate's load-time contract — i.e. it cannot be loaded,
> owned, and read end-to-end in the substrate's supported configuration (air-gapped
> bare clone, runtime-loadable, no build step). The trigger is "this dep can't live
> inside our supported runtime," not "we value owning things."

Under that phrasing: crescent hand-rolls JSON because a vendored/FFI dep breaks
"git clone and it runs air-gapped" (0007/0012/0033 all turn on loadability, not on
an abstract preference). Reincarnate defers because oxc_parser loads fine and
correctness-at-scale dominates (0034). Portals defers on solved domains *and*
hand-rolls primitives by the *same* test — wrapping serde adds friction with no
loadability gain, so don't; primitives have no consensus crate to load, so own them.
This unifies all five ADRs; the "declared product value" phrasing only unifies four
and mis-files portals.

**Observed-or-invented?** Partly observed (the loadability trigger is explicit in
0012/0033), partly invented-now (the *single seam statement* exists nowhere in the
corpus — throughlines §X1 says outright "this boundary is real but never stated as
such in one place"). So X1's discriminator is a *synthesis proposal*, not corpus
consensus, and the version currently implied by the candidate prompt is the weaker
of the two available phrasings.

---

## 2. The X3 discriminator (open bag vs strong types)

**Candidate rule:** *Open string-keyed at the data/IR/interchange layer that must
absorb unknown/unforeseen input; strongly typed at the executing/value/API layer.*

**Verdict: the rule cleanly classifies 5 of 7 ADRs, frays on 0192, and is barely
supported by 0284. It is the synthesis's proposed reconciliation, NOT observed
consensus — and the corpus itself admits it (§X3: "the corpus never names the
discriminator explicitly").**

Open side:

- **0238 (rescribe IR):** Textbook fit. Open `NodeKind(String)` + property bags
  precisely *because* the IR must absorb format-specific constructs unknown at
  library-build time. Seam = interchange/IR. Classifies cleanly: open.
- **0090 (concord annotations):** Clean fit. `kind: String`, generators
  ignore/warn on unknown. Seam = IR. Open. Correct.
- **0093 (concord unified IR):** Clean fit. HTTP/FFI as ordinary annotated types,
  "no special-cased layer," new sources without core changes. Seam = IR. Open.
- **0124 (hologram entity-everything):** Clean fit. Type emerges from facts; the
  data layer must absorb hybrids (sentient sword) unforeseeable at schema time.
  Seam = data model. Open. Correct.

Typed side:

- **0272 (unshape Value enum):** Clean fit, and it's the *sharpest* evidence
  because it self-discriminates: 0272 explicitly contrasts the *closed, finite*
  expression-primitive set (fixed enum) against *graph Value which wraps open-ended
  domain types like Mesh/Image* (which is `dyn`/open). The same repo draws the
  exact open-vs-closed line by "does this set absorb the unforeseen?" — i.e. the
  discriminator is *observed within one ADR*. Strong support.
- **0192 (normalize Reports) — FRAYS.** This is a *typed* exemplar, but its seam is
  **output/interchange**, not "execution." Reports are `Serialize + JsonSchema`
  structs whose whole job is to be *projected* to JSON/JSONL/jq/MCP/HTTP — i.e.
  they sit at the interchange seam where the X3 rule predicts *openness*, yet they
  are strongly typed. So "interchange ⇒ open" is falsified by 0192. The real reason
  normalize types its Reports is **library-first projection (P2/T3)**, not the X3
  seam: normalize *owns and defines* its output shape, so it can type it; rescribe's
  IR must *absorb foreign* shapes, so it can't. The operative variable is **"do I
  author this shape or must I absorb a foreign one?"**, not "data layer vs API
  layer." 0192 actually belongs to P2, and its appearance under X3 as the "typed
  API layer" exemplar is a miscategorization.
- **0284 (wick homogeneous expressions) — WEAK, as the review flagged. Confirmed.**
  0284 is about *intra-expression numeric-type homogeneity* (no mixing f32/f64 in
  one expression; convert at boundaries). That is a **uniformity/coercion** decision,
  not an open-vs-typed decision. It has essentially nothing to say about whether a
  model should be string-keyed-open or strongly-typed. Citing it under X3 inflates
  the typed side's support. Drop it from the evidence base for P11.

**Net:** the *correct* discriminator is not "data layer vs API layer." It is:

> Use an open string-keyed model where the structure must **absorb foreign /
> unforeseen constructs you do not author** (interchange IR, plugin annotations,
> emergent domain facts). Use strong types where you **own and close the set**
> (a finite primitive set; a Report shape you define; a value the runtime executes).
> The discriminator is *authorship + closedness of the set*, not the physical layer.

Under that phrasing all 7 reclassify cleanly (0192 → typed because normalize authors
the Report; 0284 → irrelevant to the axis). The CLAUDE.md wording ("Data / IR is
string-keyed ... persistence / interchange open, execution typed") encodes the
*wrong* variable and 0192 is a live counterexample to it sitting in the same corpus.

**Observed or proposed?** Proposed reconciliation. Only 0272 self-discriminates;
the rest are single-sided choices the synthesis aligned post hoc.

---

## 3. P11 verdict

**Recommendation: SPLIT into [principle + corrected discriminator], and fix the
discriminator variable — do not keep as-is.**

As written, P11's stated discriminator ("the seam is the discriminator:
persistence/interchange open, execution typed") is **falsified by ADR-0192 inside
its own citation set** (a typed struct living at the interchange seam) and rests
partly on ADR-0284, which is off-axis. The *principle* (open where you absorb the
unforeseen, typed where you close the set) is sound and 5-repo supported. The
*discriminator clause* is wrong.

Concretely:
- Keep the principle.
- Replace the discriminator with **authorship/closedness**: "Open string-keyed where
  the model must absorb constructs you don't author or can't foresee (IR, plugin
  annotations, emergent facts); strong types where you own and close the set (finite
  primitives, Reports you define, executed values)."
- Drop 0284 as supporting evidence; re-file 0192 under P2 (library-first), not P11.
- Demote the layer framing ("data layer vs API layer") to an *illustrative example*,
  not the rule, since it is the thing that breaks.

If a lighter touch is preferred: at minimum, demote the current discriminator
sentence to an open question, because shipping "persistence/interchange open" as a
rule will mislead anyone who looks at normalize and sees typed interchange.

---

## 4. The other 7 — mutual coherence

### The spine

These are **not** a flat checklist; six of the eight are facets of one commitment:

> **Every artifact is data you can serialize, replay, verify against something real,
> and diff — so behavior never hides in an opaque runtime object, an unaudited model
> call, or an unearned authority.** Determinism + inspectability as a single stance.

- P1 (data over code), P4 (LLM oracle / determinism), P5 (trust = verifiable
  evidence), P7 (validate against reality / tests-as-spec) are *direct* facets:
  serializable, replayable, checkable artifacts.
- P2 (library-first projection) is the same idea one level up: one authored
  definition, all surfaces derived from it (so surfaces are diffable/regenerable).
- P11 (open at absorb-seam, typed at owned-seam) is the *typing corollary* of P1:
  data you must absorb stays inspectable-open; data you own stays checkably-closed.

Two are **adjacent but not the same spine**:
- P3 (capability security) is a distinct commitment (least-authority, host-grants).
  It rhymes with the spine (allow-list = "dangerous surface absent by construction,"
  inspectable trust boundary) but is its own axis. Coherent, not redundant.
- P6 (retire don't deprecate; collapse to primitives) is an *aesthetic of minimal
  surface*. It supports inspectability (small knowable surface) but is logically
  independent — you could hold the spine and still carry back-compat. Coherent.

**No internal contradictions among the 7.** Overlap/redundancy worth flagging:

- **P1 vs P2** overlap heavily ("serializable data" and "one authored definition,
  projected surfaces" are the same instinct at two altitudes). Not a conflict, but a
  fresh reader may not see why they're two rules. Acceptable — they cut at different
  seams (in-the-large architecture vs in-the-small value representation).
- **P1 vs P11** partially overlap (both about data representation). P11 is the
  refinement that says *not all* data should be open — which is exactly the nuance
  that keeps P1 from over-applying. Keep both; they're complementary, not redundant.

Wording too loose to act on:
- **P5 "never bare references or governance."** "never ... governance" overreaches —
  the corpus replaces *review-as-trust-mechanism* with citation rigor (0068), it does
  not abolish governance. As written it reads as anti-process absolutism. Soften to
  "trust derives from checkable provenance, not from review authority alone."
- **P7 "tests are the spec."** Strong but corpus-true (0156, 0036, 0267); fine.
- **P6 "collapse asymmetries to primitives."** Actionable enough given the examples.

### Per-principle propagate-readiness

| P | Principle | Verdict | Edit if any |
|---|-----------|---------|-------------|
| P1 | Data over code at every seam | **ready** | — |
| P2 | Library-first / projection-from-one-definition | **ready** | (absorb 0192 here from P11) |
| P3 | Capability security | **ready** | — |
| P4 | LLM oracle at leaves / determinism invariant | **ready** | — |
| P5 | Trust = verifiable evidence | **needs-minor-edit** | drop "or governance" absolutism; "not from review authority alone" |
| P6 | Retire don't deprecate; collapse to primitives | **ready** | — |
| P7 | Validate against reality; tests are the spec | **ready** | — |
| P11 | Open data / typed API | **hold** | split principle from discriminator; fix variable to authorship/closedness; drop 0284; re-file 0192 |

---

## 5. Overall verdict

**Seven of the eight are propagate-ready (P5 with a one-clause softening). P11
should be held and reworked before canonizing — its discriminator is falsified by a
member of its own citation set (0192) and partly propped on an off-axis ADR (0284).**

The set is a genuine philosophy, not a checklist, because six principles share a
single spine:

> **Determinism + inspectability: every artifact is data you can serialize, replay,
> verify against reality, and diff — so behavior never hides in an opaque object, an
> unaudited model call, or an unearned authority.** Capability-security and
> retire-don't-deprecate are coherent satellites (least-authority; minimal surface).

Recommendation: **propagate P1–P7 now** (apply the P5 softening), and **hold P11**
pending the discriminator fix in §3. Both X1 and X3 discriminators in the synthesis
are *proposals*, not observed consensus; X1 is fine left as guidance prose in
throughlines but should not be phrased around "self-containment as product value"
(it misfiles portals). Neither X1 nor X3 is mature enough to ship as a hard
one-line rule without the corrected variable.
