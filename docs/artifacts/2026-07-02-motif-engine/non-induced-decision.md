# NON-INDUCED SCOPE DECISION — attempt (held open for ratification)

**Attempt: v1 is induced-native everywhere; non-induced is a bounded post-processing of
the induced census for CONNECTED CATALOG patterns (counts *and* named instances), and is
NOT built as a general enumerator; the only genuine monomorphism-enumerator need —
non-induced matching of an ARBITRARY template — has no grounding beneficiary and is
deferred behind an additive method, never an erroring toggle.**

This is a disposable recommendation advancing from the certified spine/gates, not a
verdict. Reject it whole and the spine (induced census substrate + parallel VF2 arm +
`Induced` threaded as a parameter) is untouched.

Calibration: **[V]** observed/derived this run; **[I]** reasoned from certified facts;
**[U]** needed but unverified.

---

## Arm 1 — Census / named-motif arm: the derivability verdict

**Claim under test (from the tasking):** non-induced count of pattern P =
Σ over induced classes C ⊇ P of `count[C] × (embeddings of P in C)`, with the per-(P,C)
embedding numbers a fixed constant table for k≤5 — so non-induced motif counts need NO
separate enumerator, only a post-pass over the induced census.

**Verdict: CORRECT for connected P, with two sharpenings that make it stronger than the
counts-only claim.** [V for the identity; [I] for the table-build cost]

1. **The identity holds.** A non-induced (monomorphism) embedding of a k-node pattern P
   maps P's k vertices onto k host vertices whose *induced* subgraph is some class C whose
   edge-set ⊇ P's (extra host edges allowed = non-induced). Grouping non-induced embeddings
   by the induced class of their image gives exactly
   `mono(P in G) = Σ_{C ⊇ P, |C|=k} indCount(C in G) · s(P,C)`,
   where `s(P,C)` = number of edge-preserving bijections V(P)→V(C) (spanning monomorphisms).
   `s(P,C)` depends only on (P,C), not on G — a fixed table. Divide by |Aut(P)| for
   *distinct-occurrence* counts vs. labelled-embedding counts; still a constant table.
   **Hand-check against an independent source:** P=P3, C-classes at k=3 are {P3, K3};
   `s(P3,P3)=2`, `s(P3,K3)=6`. For G=K3: indCount = {P3:0, K3:1} ⇒ mono = 0·2+1·6 = **6**,
   matching vf2-gate.md's brute-forced "P3 in triangle = 6". [V]

2. **Connectivity closes cleanly with ESU.** ESU/census enumerates only *connected*
   induced k-subsets. For a connected P, every C ⊇ P (edge-superset) is also connected, so
   every class the sum ranges over is already in the connected census. The reduction
   therefore composes with the exact pass the k4k5/orbit gates certified — no
   disconnected-class gap. [V — structural, from edge-superset preserving connectivity]

3. **Instances, not just counts, are derivable for NAMED patterns.** The tasking asked only
   about counts; the stronger fact is that during the single ESU pass, each induced instance
   of a class C ⊇ P can emit its `s(P,C)` spanning embeddings as *non-induced instances* of
   P (bounded constant fan-out per instance; disjoint vertex-sets across classes ⇒ no
   cross-class double count). So the seed's original non-induced `find_diamonds` behaviour
   (a diamond with an extra source→sink edge still counts) is recoverable as a post-pass,
   **without** a monomorphism search. [I — mechanism is the same arg-perm expansion the
   orbit gate already runs; not separately built this session]

4. **The table build is cheap and reuses verified machinery.** `s(P,C)` for all connected
   class pairs at k≤5 (≤21 classes at k=5, ≤120 perms each) is the same brute
   automorphism/embedding enumeration that reproduced the 73 orbits in orbit-gate.md, run
   once at registry-build time. [I]

**So for Arm 1, non-induced (counts and named-pattern instances) is NOT new enumeration
work — it is a small fixed table + a bounded post-pass over the certified induced census.**

Scope boundary (honest): the reduction needs the *complete* connected census at that k
(the substrate provides it, k≤5 verified) and applies to *connected catalog* patterns. A
*disconnected* pattern would range over disconnected classes ESU does not enumerate — out
of scope, and no catalog motif is disconnected. [I]

---

## Arm 2 — Template-match arm (arbitrary user query graph via VF2)

Certified (vf2-gate.md): petgraph `subgraph_isomorphisms_iter` returns **node-induced**
matches natively; induced ⊂ monomorphism; a post-filter can only *shrink*, never recover
the monomorphisms petgraph discarded. So:

- **`Induced::Yes` for an arbitrary template is FREE/native** — delegate, done. [V, certified]
- **`Induced::No` (monomorphism) for an arbitrary template is genuinely new work** — an
  unbounded pattern has no precomputable `s(P,C)` table (the k-bounded catalog trick does
  not apply), the census substrate does not enumerate at an arbitrary template's size, and
  petgraph will not do it. It needs our own monomorphism/VF2-relaxation enumerator. [V/I]

**Does any grounding use case demand non-induced ARBITRARY-template matching? No.** [I —
survey of grounding.md]

- Every biology/science domain (regulatory, connectomics, social, ecology, PPI/graphlets)
  is **induced** by definition (grounding §1a–1f, §3-H). No non-induced demand at all.
- The **software/seed** domain is the only non-induced consumer — but its patterns are the
  *named catalog* small motifs (diamond, chain, cycle, hub-spoke), served by Arm-1
  expansion (§Arm-1.3), **not** arbitrary templates. Its genuinely-uncovered fuller need is
  *path/reachability-based* (unbounded paths), which no subgraph-motif engine addresses and
  is out of scope regardless (grounding §5.1).
- The "match any user template" capability is treated by grounding §2b as *largely already
  shipped* by VF2 — and VF2 ships **induced**. No cited consumer asks for the non-induced
  variant of it.

**Conclusion: the monomorphism-over-arbitrary-template enumerator has zero concrete
beneficiary today; under the cost/compat gate it is not free and lacks a beneficiary, so it
is not built now.**

---

## Recommendation

### What v1 commits to
- **Induced-native everywhere** as the primitive (the certified ESU→canonical-label→fold
  pass; VF2 delegation for induced templates).
- **Non-induced counts AND non-induced named-motif instances** for the census/named-catalog
  arm, implemented as the fixed `s(P,C)` table + bounded post-pass over the induced census
  (§Arm-1). This is a *real, implemented* `Induced::No` for that arm — it does not error.
  Concrete v1 beneficiary: the seed's non-induced diamond enumeration (no regression vs. the
  original `find_diamonds`).
- **NOT** a general monomorphism enumerator.

### API exposure (the honesty issue)
A public `Induced::No` that errors is worse than not exposing it, and the two arms differ in
what they can honour — so **do not share one runtime `Induced::No` across an arm that cannot
implement it.**

- **Census / named-catalog API:** expose the full `Induced { Yes, No }` parameter — both
  variants are implemented (No via the reduction/expansion). Honest, no landmine.
- **Template API (arbitrary graph):** expose **induced matching only** — an inherently
  induced entry point (no toggle that can be set to a value it can't honour). Non-induced
  arbitrary-template matching is reserved as a *future additive method*
  (`match_monomorphism`/`Induced::No` overload introduced when built) — additive is
  non-breaking, so nothing is foreclosed and nothing ships that errors.
- If a single unified `Induced` enum is wanted for ergonomics, gate the illegal combination
  in the **type system** (template constructor accepts an induced-only marker; won't
  compile) rather than accept-then-error at runtime. [I — typestate is the honesty-preserving
  option; a runtime error is the anti-pattern to avoid]

This keeps the spine's "induced/non-induced threaded as a parameter" (don't-foreclose)
intact where it is real, and refuses to advertise a parameter value one arm can't deliver.

### What is deferred, gated on which beneficiary
- **Non-induced ARBITRARY-template (monomorphism) enumerator:** DEFERRED. Gate: a concrete
  consumer needing non-induced matching of a pattern that is (a) not in the catalog **and**
  (b) needs actual instances, not counts. None exists in grounding.md today. Reserve via an
  additive method; ship no erroring toggle.
- **Disconnected-pattern non-induced counts:** out of scope (ESU is connected-only; no
  catalog motif is disconnected).

---

## Self-critique (adversarial)

- **Weakest joint:** the `s(P,C)` embedding-count table and the per-instance expansion are
  asserted correct-and-cheap by analogy to the certified orbit machinery, but were **not
  built or run this session** — only the k=3 P3-in-K3 case was hand-checked [V]. If the
  table's automorphism-normalization (labelled embeddings vs distinct occurrences, and the
  node-set-vs-edge-set dedup caveat from vf2-gate.md §"Automorphism de-dup") is gotten wrong,
  non-induced *counts/instances* would be off by an integer factor while looking plausible.
  This is the one thing to prototype before locking. [U]
- **What would have to be true that I did not verify:** that a full `s(P,C)` table for all
  connected pairs at k=4 and k=5 reproduces published non-induced↔induced conversion numbers
  (I verified only k=3, one pair). And that ESU's connected census is genuinely *complete* at
  the k used (certified at k≤5, but the reduction is only as correct as that completeness).
- **Strongest alternative I did not take:** ship v1 **induced-only** everywhere (drop even
  the Arm-1 non-induced post-pass), exposing no `Induced::No` at all, and defer *all*
  non-induced to a beneficiary. Rejected because the seed itself is non-induced on its face
  (grounding §1b, §3-H) — induced-only would silently regress the one motivating in-house use
  case, and the fix is cheap (a table + expansion), so the cost/compat gate favours building
  it. But if the seed is willing to accept induced diamonds, the induced-only cut is simpler
  and strictly honest, and I would switch to it.
- **Single cheapest evidence to confirm-or-kill:** build the `s(P,C)` table at k≤5 in the
  existing orbit-gate crate and check, for 2–3 (P,C) pairs, that
  `Σ_C indCount(C)·s(P,C)` equals a brute-force monomorphism count on one random G(n,p) —
  reusing the orbit gate's independent-oracle pattern. That single test closes the [U] joint
  and either ratifies the Arm-1 "no enumerator needed" claim or kills it.

---

## Derivability confirm-build (k=4 AND k=5, adversarial) — [V, this run]

The [U] joint above was prototyped and stress-tested against an independent brute-force
oracle. **Verdict: the identity HOLDS at k=3, k=4, AND k=5** (not just the hand-checked
k=3). This closes the one open joint the self-critique flagged. The k=4/k=5 "by analogy"
reasoning is now verified, not analogized.

**What was built** (self-contained crate, `rand` only, `nix run nixpkgs#cargo`; reused the
orbit/k4k5 gate machinery — `perms`, `class_to_adj`, `all_connected_classes`, canonical
labelling):

1. **Fixed `s(P,C)` table** for all connected classes at k=3,4,5. `s(P,C)` = number of
   edge-preserving **bijections** V(P)→V(C) (spanning: use all k vertices; injective; every
   P-edge maps to a C-edge; extra C-edges allowed = non-induced). Table sizes: k=3 → 2×2,
   k=4 → 6×6, k=5 → 21×21 (matching the known 2/6/21 connected-graphlet counts).
2. **Independent brute-force oracle:** true labelled monomorphism count of P in G by
   backtracking over all injective vertex maps preserving P's edges (a different code path
   from both the census enumerator and the perm-based `s` builder — genuinely independent).
3. **Fuzzed assertion** `Σ_C indCount(C)·s(P,C) == mono_oracle(P in G)` with **P ranging
   over EVERY connected class at each k** (so path/cycle/star/near-clique/diamond and all
   others are covered, not a hand-picked subset — 29 patterns total) across 45 host graphs:
   structured (paths, cycles C4–C8, stars, K4–K7) + 24 random G(n,p) over n∈7..12,
   p∈0.20..0.52, seeds 0..23.

**Result: 1105 / 1105 (P, graph) assertions matched exactly. Zero mismatches at any k.**
The k=3 hand-check reproduced independently: `s(P3,P3)=2`, `s(P3,K3)=6`.

**Normalization caveat (the thing to get right):** the table and the oracle both count
**LABELLED embeddings** — every injective/bijective vertex map, with **no division by
|Aut(P)|**. Because no automorphism factor is introduced on either side, the identity is an
exact integer equality with a *plain-count* table (no fudge factor). To report
*distinct-occurrence* counts instead, divide **both** sides by `|Aut(P)| = s(P,P)` (a
diagonal entry of the very same table) — that is a post-hoc scalar and does not touch the
identity. Pick one convention and apply the `s(P,P)` divisor consistently; the byte-exact
match confirms nothing else is needed.

**Cost:** full `s(P,C)` table build for k=3,4,5 = **~5 ms, one-time** (registry-build time).
Confirms the claim that `Induced::No` for the census/named-catalog arm is cheap
post-processing over the induced census — **no separate monomorphism enumerator is
needed for connected catalog patterns**. Arm-1's recommendation stands, now verified at
k=4 and k=5.

(Verification crate: `scratchpad/.../deriv/` — ephemeral; not part of the tracked tree.)
