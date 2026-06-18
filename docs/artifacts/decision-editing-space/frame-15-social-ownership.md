# Frame 15 — Social / ownership / organizational smear

> Mandate: map the axis where a single logical decision smears not across *code* but across
> *people, teams, repos, and organizations*. Conway's law as smear-radius; ownership/authority
> over who may make a decision; cross-boundary contracts as a *social* (not just technical)
> frontier; coordination cost as smear; rationale-knowledge smear. Central questions: is "you
> don't control all the sites" a *different kind* of unlocalizability than "no representation
> localizes it"? Is the fix tooling or decoupling? Ground in real practice; flag uncertainty.

What I read first (so this attacks the real text): `frame-2-localizing-representations.md`
(its §7 "crosses a boundary no single tool spans — wire, language, *organization*" and §2
cross-boundary-contracts frontier), `frame-7-decision-entropy.md`'s "who supplies the bits"
framing as quoted in the dispatch, frame 4's "the decision often lives outside the code"
finding, frame 10's flag of social/ownership/Conway as an unmapped axis, plus this repo's own
`docs/decisions/ecosystem/` + `docs/decisions/repo-local/` ADR split and the
`tooling/*propagate*.sh` / `sync-skills.sh` propagators as a working specimen. Frames 5,6,8,9
I attack only at their dispatch-summary content and flag where I infer.

---

## 0. The thesis in one line

Every other frame asks *"what representation would let one editor change this decision in one
place?"* This frame asks a prior question the others assume away: **does a single editor have
the standing and the reach to change it at all?** Social smear is the gap between the decision's
logical extent and any one agent's **span of control** — the set of sites that agent is both
*able* (has write access) and *allowed* (has authority) to edit atomically. When the decision's
extent exceeds that span, the decision is unlocalizable for reasons that **no representation can
fix**, because the obstacle is not where the bits live but *who may touch them*.

I'll argue this is a **genuinely distinct unlocalizability** from frame 2's, defend that against
the obvious objection that it collapses into "just another boundary," then map the taxonomy and
the coping mechanisms, and land on the tooling-vs-decoupling question.

---

## 1. Social smear is a different *kind* of unlocalizability (the load-bearing claim)

Frame 2's frontier is **representational**: the decision is smeared because we lack a notation in
which it is positionally local; in principle a better representation closes the gap (and for some
classes — postures, semantic invariants — possibly no representation can, which is frame 2's own
"in principle" band). The defect lives in the *artifact*.

Social smear is **authority-structural**: the decision is smeared because the sites that realize
it sit under **different write-authorities**, and no notation grants you write access. Even with a
*perfect* representation — say, every cross-repo consumer's call expressed as one editable node —
you still cannot commit the edit to a repo you don't own without someone else's act. The defect
lives in the *org chart*, not the artifact.

The sharp test that separates them: **give the agent an oracle representation that localizes the
decision to a single editable node. Does the smear vanish?**

- Frame-2 (representational) smear: **yes.** That's the definition of having found the
  representation. The whole frontier is "we haven't found / can't have that node."
- Social smear: **no.** The node now exists and is perfectly local — and you *still can't apply
  it*, because applying it is N write-acts under N authorities (a merge into someone's `main`, an
  approval, a deploy you don't trigger). The localizing representation was *necessary but not
  sufficient*. What's missing is not information; it's **standing**.

So the two frontiers are orthogonal, and frame 2 quietly conflates them: its item 7 lists
"organization" alongside "wire" and "language" as boundaries-no-tool-spans, but a wire boundary
and an org boundary fail differently. A wire/language boundary is *spanned by building a tool*
(an IDL, a cross-language refactor engine) — pure representation. An org boundary is **not spanned
by any tool**, because the thing on the far side is a *will*, not a syntax. You can build the IDL;
you cannot build the consumer team's consent. That is the cut.

**Objection (frame 10 would press this): isn't "authority" just another representation gap — model
the ACL and you've localized it?** No, and the asymmetry is the proof. You can *read* the whole
org's code (frame 2's representation problem is symmetric: notation helps reader and writer alike).
You cannot *write* the whole org's code regardless of how well you can read or represent it. Social
smear breaks the read/write symmetry that every representational frame implicitly assumes.
Representation is about **knowing**; authority is about **acting**; a perfect map of a territory you
may not enter is still a wall. **This is the frame's central finding: social unlocalizability is the
write-side residue that survives after representation has done everything it can.**

(Uncertainty I'll flag honestly: in the limit, *consent is information you don't have* — you could
model "will team B approve?" as a probability and the decision as not-yet-localized-because-bits-
missing, folding this back into frame 7's "who supplies the bits." I think that's a category slip:
frame 7 is about the *entropy* of which decision, here the decision is fully determined and known;
what's missing is the *right to enact it*, which is deontic, not epistemic. But I hold this with
medium confidence — the deontic/epistemic boundary is exactly where I'd expect a critic to push.)

---

## 2. Taxonomy of social smear (five distinct mechanisms)

These are *not* a severity ladder; they're different axes that compose. Each is "one logical
decision, smeared socially," and each smears via a different organizational structure.

### 2a. Conway smear — module boundaries mirror team boundaries

Conway's law (Conway 1968; corroborated empirically by Nagappan/Murphy et al. on Windows defect
data, and the "mirroring hypothesis" literature, MacCormack/Baldwin/Rusnak): a system's structure
mirrors the communication structure of the org that built it. The decision-editing consequence:
**a decision smeared across modules that mirror team boundaries has a smear radius measured as an
org-chart traversal, not a call-graph traversal.** "Change the auth token format" touching the
gateway team's code, the session team's code, and the mobile team's code is *one decision* whose
edit unit is **a coordination across three teams** — three backlogs, three review queues, three
release trains. The call graph might be three functions; the *editing* graph is three orgs.

The deep point: Conway smear is the case where the technical boundary and the social boundary
**coincide**, so it looks like a pure frame-2 cross-module problem — but the cost is dominated by
the social layer. A monorepo with an atomic refactor tool removes the *technical* boundary (one
commit touches all three modules) and reveals that the *social* boundary is still there: you still
need three teams' sign-off, you just no longer need three merges. (See §4 — this is why monorepos
help *less* than their advocates claim and *differently* than expected.)

### 2b. Ownership/authority smear — who is *allowed* to decide

Orthogonal to who can *reach* the code: who has the *standing* to make the call. Decisions stratify:

- **Sole-authority**: one owner can decide unilaterally (a service team's internal data layout).
  Smear radius = 1 person. Cheapest to edit.
- **Consensus-required**: the decision needs N parties to *agree*, not just permit (an API contract,
  a shared schema, a cross-team SLA). The decision isn't *made* until the last holdout agrees; the
  editing unit includes the *negotiation*, which has no representation at all.
- **External-authority**: the decision belongs to a party outside the org entirely — a standards
  body (HTTP semantics, an OAuth spec), a platform vendor (Apple's review rules), a regulator
  (GDPR). You can't edit it; you can only *conform* or *fork*. This is frame 4's "the decision lives
  outside the code" in its strongest form: it lives outside the *company*.

Authority smear connects to frame 7's "who supplies the bits": frame 7 asks *where the entropy that
selects the decision comes from*; this frame asks *who is licensed to write the selected decision
down*. They're dual — supply vs. sanction — and a decision can be high-entropy/low-authority (a
junior dev makes a hard novel call alone) or low-entropy/high-authority (an obvious change that
nonetheless needs the VP and legal). The two-by-two is real and the costly cell is high-authority
regardless of entropy: **bureaucratic cost is set by the authority structure, not the difficulty.**

### 2c. Reach smear — you don't control all the sites (the write-access frontier)

The purest form, and the one §1 is about. A decision realized partly in code you own and partly in
code you don't: a public API change that requires every external consumer to update, a wire-format
change between two independently-deployed services owned by different teams. You **cannot atomically
edit** the consumer side. This is frame 2's "cross-boundary contracts — biggest frontier" *recast as
a property of the org, not the notation*: the boundary is impassable not because no IDL spans it but
because the far side has its own `main` branch, its own deploy cadence, and its own priorities. The
canonical industrial coping mechanism — **versioning + deprecation windows** — is precisely an
admission that the atomic edit is *impossible*, replaced by a *temporally smeared* edit (frame 8
overlap): old and new contracts coexist for a deprecation period because you cannot synchronize the
writes.

### 2d. Coordination smear — the decision *is* the process

Some single decisions are realized almost entirely as **process artifacts before any code moves**:
an RFC/design-doc, sign-offs, a synchronized multi-team deploy plan, a feature-flag rollout
sequence. The "edit" to the program is one diff; the *decision* is the RFC + three approvals + a
staged rollout across two weeks. Here the smear is in **time and process**, and the code change is
the small visible tip. Decision-granular tooling that operates on *code* sees only the tip and is
blind to 90% of the decision's actual extent. (This is the strongest case that the bottleneck is
human, not representational — §5.)

### 2e. Knowledge / rationale smear — the *why* is unlocalized

The decision's outcome is in the code; its **rationale** is in someone's head, a Slack thread, a
closed ticket, a hallway conversation, or nowhere. This is why decisions *rot*: the *what* is
localized (the code is right there) but the *why* is smeared across people and ephemeral channels,
so a later editor can't tell a load-bearing constraint from an accident and either preserves cruft
or breaks an invariant they couldn't see. **Knowledge smear is the temporal dual of the others:**
2a–2d are about editing the decision *now* across people; 2e is about the decision being
*re-editable later* at all. A decision whose rationale lives only in a departed engineer's memory
is, for editing purposes, **append-only** — you can pile new code on it but can't safely revise it,
because the constraint set that would tell you what's safe is gone. ADRs (§4) are the direct attack
on this cell, and notably the *only* social-smear mechanism that a pure documentation discipline
fully addresses.

---

## 3. The composition: smear radius is a product, not a sum

The five mechanisms compose multiplicatively. A worst-case decision — change a cross-org wire
contract (2c) between services that mirror team boundaries (2a), requiring consensus among external
consumers (2b), executed via an RFC and staged deploy (2d), where the original rationale is lost
(2e) — has an editing cost that is the *product* of org traversals, negotiation rounds, deprecation
windows, and archaeology. This is why "simple" decisions ("just rename this field") routinely cost
quarters: the field is one token in frame 2's representation and a five-mechanism social smear here.

The general statement: **a decision's true editing unit is `code-extent × social-extent`, and the
frames before this one only measured the first factor.** Text smears one decision across many
*edits* (the reasoning thread's thesis); the org smears one decision across many *editors*, and the
second smear is the one no editor representation touches.

---

## 4. How real orgs cope — and what each mechanism *actually* attacks

The industrial toolkit maps cleanly onto the taxonomy, and the mapping is diagnostic — each tool
attacks a *specific* cell, and confusing which cell a tool attacks is a common, expensive error.

| Coping mechanism | Cell attacked | What it actually does |
|---|---|---|
| **Monorepo + atomic cross-module commit** (Google, Meta) | 2a/2c *technical* layer only | Collapses N merges into 1 commit. Removes the **reach** barrier *within the org* (you *can* edit all sites). Does **not** remove the **authority** barrier — you still need the owning teams' review (CODEOWNERS). It converts reach-smear into authority-smear. |
| **API/semantic versioning + deprecation windows** | 2c | *Decouples* so you **don't need** atomicity. Trades a synchronous cross-org edit for an asynchronous temporal one (frame 8). The opposite philosophy to the monorepo. |
| **ADRs / design docs** (Nygard) | 2e, partly 2b | Localizes the *rationale* and the *authority context* (who decided, in what context, superseded by what) into a versioned, diffable artifact. This repo's `docs/decisions/`. |
| **RFC process / design review** | 2d, 2b | Makes the *consensus* and *coordination* explicit and (somewhat) auditable, at the cost of making the smear *visible as latency*. |
| **CODEOWNERS / required reviewers** | 2b | Encodes *authority* as a checkable artifact — but encoding ≠ removing; it makes the wall legible, not lower. |
| **Conway-aligned team design / "inverse Conway maneuver"** (Team Topologies, Skelton/Pais) | 2a, preventatively | Re-draws *team* boundaries so the decisions you expect to make often fall *inside* one team — shrinking future smear radius by org design rather than code design. |

The two **philosophically opposed** strategies are worth stating sharply, because they answer the
title question (tooling vs. decoupling) in opposite directions:

- **Monorepo / atomic-edit camp**: make the org *able* to edit everything at once — *enable*
  atomicity with tooling. Bets that coordination is cheaper than versioning's long-tail
  compatibility cost. Scales to org boundaries; **stops dead at company boundaries** (you cannot put
  your external consumers in your monorepo).
- **Versioning / decoupling camp**: make atomicity *unnecessary* — design contracts so each side
  edits independently. Bets that decoupling cost is cheaper than perpetual coordination. **This is
  the only strategy that works across company boundaries**, which is why all *public* APIs use it
  and is strong evidence that beyond the org boundary, **decoupling, not tooling, is the answer.**

---

## 5. Is the fix tooling or human coordination? (the title question)

Split by where the boundary sits — this is the frame's practical payload:

- **Within a team (intra-authority):** tooling wins outright. The decision is sole-authority (2b
  trivial) and reach-complete (you own all sites), so the only smear is representational — and that's
  frames 1–9's territory. Decision-granular tooling helps here exactly as much as it helps anywhere.
- **Across teams, same org (inter-authority, intra-company):** **mixed, and this is the interesting
  middle.** Tooling (monorepo atomic edits, cross-repo refactor bots) removes the *reach* smear and
  is genuinely valuable — but it **converts reach-smear into authority-smear**, and the residual
  authority/coordination cost (2b/2d) is *human* and tooling only makes it *legible* (CODEOWNERS,
  RFC trackers), not *cheap*. Best tooling here is **coordination-reducing**: ADRs that localize
  rationale (2e) and "inverse Conway" team design that shrinks future smear radius. So: tooling for
  reach, org-design for authority.
- **Across orgs/companies (extra-company):** **decoupling, not tooling, full stop.** You cannot
  build a tool that edits code you don't control or manufactures another party's consent. The *only*
  moves are decouple (version + deprecate so the far side edits asynchronously) or conform/fork (for
  external-authority decisions). Every public-API versioning scheme is the industry conceding this.

So the honest answer is **scale-dependent and it's the title's false dichotomy that's wrong**:
tooling fixes *reach* (and only within ownership); *decoupling* fixes *cross-authority* by removing
the need for atomicity; *org design + ADRs* fix *authority and rationale* by reshaping who-decides
and recording why. **The social frontier is real and tooling does not cross it — it pushes the wall
back to the company boundary and stops.** Beyond that boundary, unlocalizability is permanent and
the discipline is to *design decisions so they never need to be edited atomically across it.*
This is the same lesson frame 2 reached for postures ("possibly not localizable in principle"),
arrived at from the social side: some decisions are unlocalizable not because we lack a notation but
because **localizing them would require an authority no one has.**

---

## 6. This ecosystem as a live specimen

The rhi ecosystem is an unusually clean instance because it is **one person's org** — authority
smear (2b) is near-zero (the operator can decide unilaterally across all repos), which isolates the
*other* mechanisms for inspection:

- **Reach smear is real and is engineered against by tooling.** 57 recipient repos
  (`tooling/skill-recipients.txt`) means a single decision — "all repos get skill X" — is smeared
  across 57 write-targets. The ecosystem's answer is squarely the **tooling / enable-atomicity**
  camp: `sync-skills.sh` and `propagate-*.sh` are a *propagator* that makes a one-author edit fan
  out to N repos — a poor-man's monorepo atomic-edit built *on top of* a polyrepo. Crucially it
  **respects the authority/state boundary it can't cross**: it skips *dirty* receivers and writes a
  TODO.md line instead (per CLAUDE.md), which is the social-smear pattern in miniature — *you cannot
  atomically edit a site that is mid-change*, so you defer and leave a note. That deferral is a
  micro-version of a deprecation window.
- **The polyrepo-with-propagator design is a deliberate position in §4's debate.** It refuses the
  monorepo (the hard constraint "no path dependencies in Cargo.toml — they couple repos and break
  independent publishing" is *decoupling-camp* doctrine) yet recovers atomic-edit ergonomics for the
  *control surface* via propagation. So the ecosystem runs **decoupling for code/publishing,
  tooling-enabled-atomicity for the harness/rules**. That's a sophisticated split: it pays the
  decoupling tax exactly where cross-company reuse matters (published crates) and pays the
  coordination-tooling cost exactly where one author wants uniform policy (skills, CLAUDE.md).
- **ADRs attack 2e head-on.** `docs/decisions/ecosystem/` vs `docs/decisions/repo-local/` is
  literally an *authority-scoped* rationale store — the split mirrors §2b's sole-authority vs
  shared-authority distinction encoded as directory structure. And CLAUDE.md's own rule "Corrections
  from the user are conversation, not material for new rules; rules are added when a failure mode is
  observed repeatedly" is a *consensus/authority gate on rule-decisions* — an explicit policy about
  *who/what is allowed to mint a durable decision*, i.e. authority smear managed by convention.
- **The org→disk→domain mapping table is a Conway artifact in the open.** rhi-zone/exo-place/
  para-garden/pterror with a stated discriminator ("whose purpose the substrate serves") is the
  *inverse Conway maneuver* applied to a solo operator: pre-drawing boundaries so future "where does
  this decision live" calls fall inside one clear domain — shrinking *future* social smear radius by
  design, even with no other humans, because the boundaries also partition *attention* and *the
  agent's* write scope.

The specimen confirms §5: where the operator has full authority, the ecosystem reaches for
**tooling** (propagators) to kill reach smear; where it touches the outside world (published
crates, crates.io naming), it reaches for **decoupling** (no path deps, independent publishing). The
one place it can't tool its way past — a *dirty* receiver — it handles exactly as cross-org practice
does: defer + note, never force the atomic write. The ecosystem has, without naming it, implemented
this frame's conclusion.

---

## 7. Frontier / open questions (flagged, not padded)

1. **Can ADR-style rationale-localization be made *mechanical* (link decision→nodes→rationale) so
   2e stops depending on human discipline?** Frame 2's "claim→node citation" idea points here; the
   social obstacle is that *recording why* is unrewarded labor, so even perfect tooling may not get
   used. Bottleneck likely human, not representational. (Medium confidence.)
2. **Is there a representation that makes *authority* a first-class, checkable property of a
   decision-edit** (this node's edit requires consent of {A,B}), turning 2b from invisible latency
   into a typed precondition? CODEOWNERS is a crude version. Doesn't *remove* the wall but could
   make the editing tool *refuse to pretend* an edit is local when it isn't — arguably the most
   useful thing decision-granular tooling could do at the social boundary: **be honest about its own
   span of control.**
3. **The deontic/epistemic boundary (§1 uncertainty).** Whether "consent I don't have yet" is best
   modeled as missing *authority* (this frame) or missing *information* (frame 7) is genuinely
   unsettled and is the seam where this frame and frame 7 should be reconciled, not duplicated.
