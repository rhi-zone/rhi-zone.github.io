# Spine Adjudication — motif-engine conceptual spine

Adversarial adjudication of SPINE-A (census-engine-first) vs SPINE-B (pattern-abstraction-first)
for the petgraph-native structural-mining crate. Mandate: break, not bless. Locked constraints
(petgraph + rand only, generic over Graph/StableGraph × directedness × weights, VF2 for arbitrary
templates, v1 = motif discovery + subgraph census, must not foreclose the rim or the neighborhood
sibling) are taken as given, not relitigated.

Calibration: **[V]** verified by the build run this session (cited); **[I]** inferred from the
certified briefs / build; **[U]** needed but unverified — a must-prototype gate.

---

## 1. Attack log

### 1.1 SPINE-A core claim
**Claim:** the unifying primitive is one subgraph-**census substrate** over petgraph; motifs,
graphlets, triangles, clustering, kernels, significance are views/consumers of one
enumeration+counting core. `Selector::{Template, AllClasses}` are two arms of *one engine*.

**Strongest attack (A's own "union wearing a trenchcoat", pressed hard):** the two arms are
irreducibly different algorithms — target-driven VF2 (Template) and enumerate-all ESU
(AllClasses). They share the `Instance` *output type* and almost no *code*. Worse, the seed's
actual need (enumerate diamond instances, software domain) is served **entirely** by the VF2 arm,
which petgraph **already ships** (`subgraph_isomorphisms_iter` [V: petgraph-coverage.md:29]). So
"one census engine" risks the grounding.md §5.1 inversion: it centers the biology-serving
ESU/canonical-labelling engine and makes the motivating software seed a degenerate special case
served by code that already exists.

**Verdict: BREAKS as stated, SURVIVES corrected.** The build refutes the *unification* but
vindicates the *center*. The census substrate that actually compiled and ran (§2) is the
ESU-walk + canonical-label + fold pipeline — it is **self-contained and touches no VF2 code**. So
`Selector` as "one enum over two engines" is cosmetic (A's self-critique is correct). But the
substrate itself is real, is the Tier-A reason-to-exist (only memoesu, a CLI, exists
[V: petgraph-coverage.md:201]), and is exactly what the library must add. The "seed is the
outlier" attack does **not** sink census-primacy, because grounding.md §5.1 *itself* certifies the
seed as the outlier and coverage.md certifies the census layer — not a matcher — as the missing
value. So: census-substrate center **stands**; A's one-engine `Selector` unification is
**rejected** and replaced (§3).

### 1.2 SPINE-B core claim
**Claim:** the **Pattern** is the primitive. A named motif and a VF2 template are the same thing
(both expose enumerate/count/score); census is `count` mapped across a `PatternFamily`;
significance is a decorator; kernels are functions over pattern-count vectors.

**Strongest attack:** a size-k census computed as independent per-Pattern `count`s is
O(classes × graph-scan) — it re-scans the graph once per class. The efficient and *only scalable*
census (FANMOD RAND-ESU, gtrieScanner g-trie) is **one** pass: enumerate every connected k-subset
once, canonically label it, increment a bucket — O(one scan). B's proposed mitigation (overridable
`count`) cannot express a family-level combined pass at all; it needs a
`PatternFamily::census_combined` escape hatch that **bypasses the per-Pattern spine** — i.e. the
census-substrate reasserting itself inside pattern-first. This bites exactly where census exists to
serve (social 10⁶–10⁸ edges, where you cannot enumerate but can count [V: grounding.md:122-125]).

**Verdict: BREAKS at its load-bearing joint.** The build makes the attack concrete (§2): the
working census does **one** ESU walk and canonically labels each subset into a bucket; there is no
"for each of 13 patterns, scan" anywhere. B's own §7 concedes it: "for the census operation, the
Pattern is the wrong-grained primitive; the family/pass is." That is not a diplomatic split — it is
B's core claim refuted by the primitive that actually runs. B's Pattern object **survives only** as
the *consumer surface* for single-motif enumerate/score (§1.3), demoted from "the primitive."

### 1.3 The convergence both proposals reached — attacked directly
Both self-identified that census wants to be primary (A by assignment; B by conceding the
census-engine spine is stronger, §7). **Is that convergence right, or are both wrong?**

Attack: maybe *neither* counting nor pattern is primitive — maybe **enumeration of instances** is,
since the seed (the only real in-house beneficiary) wants instance tuples, not frequencies, and the
strict-diamond need is even path/reachability-based [V: grounding.md:91-99], which no subgraph
census covers.

**Result: the convergence is right, with a sharp correction.** "Census substrate" is the right
center *only if* "census" names the **enumerate-k-subsets → canonical-label → fold** pipeline (one
pass, with the per-instance stream available as a lazy view), **not** "counting instead of
enumerating." The build shows counting is literally a fold over the enumeration stream keyed by
canonical label — enumeration and counting are the same pass at two granularities [V]. The seed's
instance-enumeration need is that same pass with the fold removed (yield the tuples), OR the VF2
arm for a single named template. So the primitive is the *enumeration+canonical-labelling pass*;
"census" and "instance list" are its two readouts. Both proposals were right that this pass is
central and wrong to fuse it with VF2 (A) or to invert it under per-Pattern count (B).

---

## 2. Empirical kill-test — RESULT

Toolchain reached via `nix run nixpkgs#cargo` (cargo 1.94.0 / rustc 1.94.1). Throwaway crate
`motif_probe` built against **petgraph 0.8.3** (real, fetched from crates.io). VF2 signature read
from source (`subgraph_isomorphisms_iter`, `src/algo/isomorphism.rs:959`). Both joints **RAN** —
not [U].

### Joint 1 — does a generic census skeleton compile over all graph flavours? **[V] YES.**
One generic `enumerate<G>(g, &AllClasses) -> Vec<Instance<G::NodeId>>` + `count` as a fold over it
compiled and ran against, from a **single** set of trait bounds:

```
G: IntoNodeIdentifiers + IntoNeighborsDirected + NodeIndexable
 + GetAdjacencyMatrix + GraphProp + NodeCount + Copy,   G::NodeId: Eq + Hash + Copy
```

- `Graph<char,(),Directed>` — OK
- `Graph<char,(),Undirected>` — OK (same code path; directedness falls out of `IntoNeighborsDirected`/`GetAdjacencyMatrix`)
- `StableGraph<char,(),Directed>` — OK
- `Graph<char,f64,Directed>` (arbitrary non-`()` weight) — OK

No per-type specialization, no forced conversions. Directed connectivity uses the union of
Incoming+Outgoing neighbors; induced classification uses `is_adjacent` over the exact k-subset.

### Joint 2 — is order-3 canonical-labelling `ClassId` stable & cheap across re-orderings? **[V] YES.**
`ClassId` = min over all 6 position-permutations of the 6-bit directed-adjacency mask of the induced
triple (a canonical form). Built the **same** logical graph (triangle a→b→c→a plus d→a) under node
insertion order `[a,b,c,d]` and permuted order `[d,c,b,a]`:

```
directed Graph   order1 census == order2 census : true   [(6,1),(10,1),(25,1)]
StableGraph      order1 census == order2 census : true   [(6,1),(10,1),(25,1)]
directed Graph<f64> census                       :        [(6,1),(10,1),(25,1)]  (weight-agnostic)
undirected Graph census                          :        [(23,2),(63,1)]  = 2 paths + 1 triangle
```

Isomorphic 3-node subgraphs receive the **same** `ClassId` regardless of discovery/insertion order.
The directed graph yields 3 connected triples in 3 distinct classes (cyclic-triple, path, in-star);
the undirected yields the expected path/triangle split. Canonical labelling is order-stable and, at
k=3, cheap (6-perm brute canonical form per subset). **The "one counting substrate" holds; it does
NOT collapse to "VF2 the record already has."**

Net: **both must-prototype gates cleared for k=3.** The census-substrate center is not speculative —
it compiled, ran, and produced order-invariant class ids over every required graph flavour.

---

## 3. The adjudicated spine

**Winning organizing center: the CENSUS SUBSTRATE — corrected to its true shape:
`enumerate-connected-k-subsets → canonical-label → fold`.** It wins because (a) it is the Tier-A
reason-to-exist (no depend-able library home; only a CLI [V]), (b) B's rival "Pattern is the
primitive" **breaks** on census scaling by its own §7 admission and by the one-pass build evidence,
and (c) it is what actually compiled and produced stable ids. It is **not** A verbatim: A's
"one engine, two `Selector` arms" unification is rejected.

**Two layers, not one enum:**

1. **Substrate (the primitive).** `census(g, k, Induced) -> Census` and its lazy sibling
   `enumerate(g, k, Induced) -> impl Iterator<Item = Instance>`. Internals: ESU walk over connected
   k-subsets → canonical labelling → fold into per-`ClassId` counts. `Instance.nodes` carries the
   full tuple in canonical order (never a bool/count) so orbit attribution and cross-graph class
   identity remain addable [I: A §6]. `count`/`census` is the fold; `enumerate` is the same pass
   with the fold removed. This is the self-contained engine the build verified.

2. **Consumer vocabulary (retained from B, under attack).** A `Pattern` object — `Named` catalog
   (diamond/FFL/bi-fan/chain/triad/triangle) + `Template` — exposing enumerate/count/score. This
   **survives the "does per-Pattern buy anything?" attack for single motifs only**: for one named
   motif there is no combined-pass advantage, so a query object is the right ergonomics for the seed
   (`find_diamonds` = `Named{Diamond}.enumerate`) and the natural carrier for the `Significant`
   decorator. It is **demoted**: a *family* census is NOT `map count over members` — it projects out
   of the substrate's single pass by canonical label. B's `census = Σ count` is rejected.

**Template-match arm ↔ census substrate — how they relate.** *Parallel producers of a shared
`Instance`/`Census` vocabulary, NOT nested.* VF2 (`Template`) is **target-driven** (you hold a
pattern, locate it) and delegates to petgraph's shipped `subgraph_isomorphisms_iter` — never
rebuilt [V: bounds read from source]. The census substrate is **source-driven** (enumerate all,
classify). They meet only at the `Instance` type. This is the precise correction to A: the template
arm is a thin sibling, not a strategy inside the census enum. Neither is "on top of" the other; the
seed uses the VF2 arm or a `Named` enumerate, the census domains use the substrate.

**Neighborhood sibling (link-pred / assortativity / rich-club).** **Outside both**, in a sibling
`neighborhood::` module. Both proposals converged here and the attack finds no reason to move it:
these enumerate no subgraph instance and produce no per-class frequency (set ops on neighbor pairs;
degree-sequence scalars). They share the graph substrate and the neighborhood primitive, not the
counting substrate. Confirmed-absent Tier-A gaps [V: rim-verification claims 2-3]. Placement
unrefuted.

**Kernels.** Hang off the census-vector output *only where they genuinely reduce*: the **graphlet
kernel** is a true census consumer (dot of two census vectors). **WL** is a sibling — its hash
engine is already petgraph-native (`wl_isomorphism`) [V: rim-verification claim 5], so we assemble a
feature vector, not enumerate subgraphs. **Shortest-path** kernel is a sibling over a distance
distribution. So kernels sit at a shared Gram assembler fed by census vectors *and* sibling feature
sources; presenting all kernels as census consumers would overclaim (both proposals were honest
here).

**Significance.** An ensemble over the pure `census`/`count`: `significance = z_scores(count(g),
[count(null.sample(g)) for _ in ensemble])`. The hook is the pure counting signature already in v1;
the `NullModel` family (config model, double-edge-swap, WS, LFR — confirmed-absent Tier-A gap
[V: rim-verification claim 4]) and the ~15-line z-score stat are owned (rand only). Foreclosed by
nothing. Expressible as B's `Significant` decorator over the consumer `Pattern`, OR directly over
`census` — both reduce to "call the pure count over shuffled graphs."

**Induced / non-induced.** A **parameter** (`Induced` enum) threaded through both `enumerate`/
`census` and the `Template` arm — never hardcoded, fixing the seed's silent non-induced bug
[V: grounding.md §H]. In the substrate it *is* the classification semantics: the build's
`canonical_class3` labels on the induced adjacency of the exact k-subset — the verified induced
path. For the VF2 arm, non-induced = monomorphism (VF2's native output), induced = one non-edge
filter over each match [I: A §H / B §1].

---

## 4. Residual must-prototype-before-lock risks

1. **[U] Lazy `impl Iterator + 'g` vs the adjacency matrix borrow.** The build returned a `Vec`
   for expedience; it proved the trait bounds compose and canonical labelling is stable, but did
   **not** prove the *lazy* `enumerate(...) -> impl Iterator<Item=Instance> + 'g` (borrowing
   `adjacency_matrix()` for the walk's lifetime) compiles. This is the single biggest residual: at
   10⁸ edges you cannot materialize instances, so `count` must fold a lazy stream and skip building
   `Instance.nodes` when only counts are wanted. Prototype the lazy iterator + a
   non-materializing `count` override before locking the substrate signature.

2. **[U] Canonical labelling at k=4/k=5.** Verified only at k=3 (6 permutations). k=4 (24), k=5
   (120) brute canonical form is likely still cheap *per subset* but is unverified, as is its match
   to the graphlet-30 / orbit-73 taxonomy and to ORCA's linear-system shortcut. Whether brute
   canonical labelling is acceptable vs g-trie symmetry-breaking at catalog scale is open.

3. **[U] Canonical bitmask → named taxonomy.** `ClassId`s here are arbitrary canonical bitmasks,
   not the Holland-Leinhardt 16/13 names (030C, 021U, …) or graphlet ids. The mapping bitmask →
   named class must be built and checked against the published taxonomy; directed-connectivity
   choice (union of both directions) must be confirmed against the 13-class directed convention.

4. **[U] VF2 induced-filter correctness.** `subgraph_isomorphisms_iter` yields monomorphisms
   (non-induced) [V: signature/comment read]; the induced wrapper (non-edge filter) is structurally
   sound but the Template arm was **not exercised** in the build. Prototype one `Template` enumerate
   with an induced filter and check against a hand-computed case.

5. **[U] `count`-as-fold performance vs a specialized counter.** The consistency-guaranteeing
   default (fold over enumerate) may be the default that cannot scale; the override door
   (non-materializing counter) exists in the design but is unverified (see risk 1).

None of these foreclose the rim; each is a bounded prototype gate on the substrate's
*implementation*, not its *shape*. The shape — census substrate primary, VF2 a parallel arm,
Pattern the consumer vocabulary, neighborhood a sibling, significance an ensemble over pure count —
is the adjudicated lock.
