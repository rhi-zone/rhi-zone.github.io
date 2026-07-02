# SPINE-B — Pattern-Abstraction-First

Disposable design attempt for the conceptual spine of `petgraph-motifs` (placeholder), the
petgraph-native structural-mining crate. Organizing center: **the Pattern is the primitive.**
A named motif and a VF2 template are *the same kind of thing* — both are `Pattern`s exposing
`enumerate / count / score`. Census, graphlets, significance, and kernels are all expressed as
operations *over* patterns or *decorators around* pattern operations. This attempt commits to
that center without hedging toward a census-engine framing; §7 names honestly where the commitment
strains.

Calibration tags per load-bearing claim: **[V]** read/ran this session (cited); **[I]** inferred
from the certified briefs / VERIFIED facts (joint named); **[U]** needed but unconfirmed (gap).

---

## 1. The core `Pattern` abstraction

A `Pattern` is a *query object*: it knows its own shape and can answer three questions against a
host graph — *where are my instances* (enumerate), *how many* (count), *how surprising is that*
(score). The two constructors that must both satisfy it (certified rim + hard constraint):

- **Named motifs** — diamond (the seed), FFL, bi-fan, chain, directed-triad-13, triangle. Backed by
  a small data table, matched by a specialized or catalog routine.
- **VF2 templates** — an arbitrary user-supplied `&G` pattern graph, matched by delegating to
  petgraph's `subgraph_isomorphisms_iter` [V: petgraph-coverage.md:29]. We do NOT rebuild a matcher
  [I: hard constraint + grounding.md:249].

```rust
/// Induced = matched node set must reproduce pattern edges AND non-edges;
/// Non-induced (monomorphism) = pattern edges present, extra edges allowed.
/// (grounding.md:36-38 — load-bearing; the seed diamond is silently non-induced.)
#[derive(Clone, Copy, PartialEq, Eq)]
pub enum Match { Induced, NonInduced }

/// One located instance: the host NodeIds in canonical pattern-vertex order.
/// SmallVec keeps k-node tuples allocation-free for the catalog sizes (k<=5).
pub struct Instance(pub smallvec::SmallVec<[NodeIndex; 8]>);

/// The spine. Generic over ANY petgraph graph: Graph OR StableGraph, any
/// directedness Ty: EdgeType, any weights N/E. No forced conversions.
/// (hard constraint; petgraph-coverage.md:30.)
pub trait Pattern<G>
where
    G: IntoNodeIdentifiers + IntoNeighborsDirected + NodeIndexable + GetAdjacencyMatrix + GraphProp,
{
    /// Pattern order (node count). Lets a family bucket patterns by k.
    fn order(&self) -> usize;

    /// Lazily list every instance. The seed find_diamonds IS this for the diamond.
    fn enumerate<'g>(&self, g: &'g G, m: Match) -> Box<dyn Iterator<Item = Instance> + 'g>;

    /// Frequency. DEFAULT = count the enumerate() stream, but a Pattern MAY
    /// override with a closed form (e.g. triangle count via neighbor-set
    /// intersection) without materializing tuples. This override door is what
    /// keeps census-scale counting viable — see §7.
    fn count(&self, g: &G, m: Match) -> u64 {
        self.enumerate(g, m).count() as u64
    }

    /// Significance of the observed count. DEFAULT = raw count (no null model
    /// bound yet). A Significance decorator (§3) overrides this to a z-score.
    fn score(&self, g: &G, m: Match) -> f64 {
        self.count(g, m) as f64
    }
}
```

Design commitments made visible here:
- **enumerate is the ground truth; count and score are derived** — but each is an *overridable*
  method so a cheaper closed form (triangle set-intersection, an ensemble z-score) slots in without
  changing the caller. This is the pattern-first bet: one vocabulary, three sharpness levels.
- **`Match` is a per-call parameter, not a type** [I: grounding.md:264 keeps it a flag] — the same
  Pattern answers induced and non-induced. Fixing the seed's silent non-induced semantics is then a
  caller choice, not a hardcode.
- **`count`/`score` are pure functions of `(g, m)`** [I: grounding.md:296-297] — no global state, so
  an ensemble runner can call `count` over shuffled graphs (§3) with zero redesign.

Two concrete implementors:

```rust
pub struct Named { kind: MotifKind }              // enum: Diamond, Ffl, BiFan, Chain, Triad(u8), Triangle
pub struct Template<'p, P> { pattern: &'p P }     // wraps a user &G, delegates to VF2

impl<G> Pattern<G> for Template<'_, G> /* bounds */ {
    fn enumerate<'g>(&self, g: &'g G, m: Match) -> Box<dyn Iterator<Item = Instance> + 'g> {
        // subgraph_isomorphisms_iter gives NON-induced mappings; for Induced we
        // wrap with a non-edge filter (one adjacency check per matched pair).
        // (grounding.md:237,264 — induced = one predicate.)
        Box::new(vf2_iter(self.pattern, g).filter(move |inst| m == Match::NonInduced
            || is_induced(self.pattern, g, inst)))
    }
}
```

The typed-match hook (node/edge color constraints, grounding.md:238) rides in as an optional
`NodeMatcher`/`EdgeMatcher` closure passed through to VF2's existing weight matching — no new
machinery.

---

## 2. Census and graphlets as operations over a Pattern family

Census is not a separate engine in this framing — it is **`count` mapped across a family of
patterns**. A `PatternFamily` enumerates the patterns of interest; the census is the vector of their
counts.

```rust
pub trait PatternFamily<G> {
    type Item: Pattern<G>;
    fn members(&self) -> Vec<Self::Item>;         // e.g. the 13 connected 3-node digraphs
}

pub fn census<F, G>(fam: &F, g: &G, m: Match) -> Vec<(F::Item, u64)>
where F: PatternFamily<G>, /* G bounds */ {
    fam.members().into_iter().map(|p| { let c = p.count(g, m); (p, c) }).collect()
}
```

- **Triad-13 / dyad census** (social, connectomics, ecology — grounding.md:53-55,118) = a
  `PatternFamily` whose members are the 13 (or 16) fixed classes. `census()` over it *is* the
  Holland-Leinhardt census.
- **Graphlets (≤5 nodes, 30 classes)** = a `PatternFamily` of the 30 connected induced graphlets,
  counted with `Match::Induced` [I: grounding.md:141,149 graphlets are induced].
- **Orbits / GDV (73 orbits, per-node)** = a variant trait `OrbitPattern` whose `enumerate` yields
  `(NodeIndex, orbit_id)` touches rather than whole instances; the per-node vector is an aggregation
  of that stream. Expressible as a Pattern refinement, **[U]** not proven to reuse the ORCA
  linear-system shortcut [grounding.md:143] — a naive per-orbit pass is correct but slower.
- **Triangle counting** = the k=3 `Named { Triangle }` Pattern with an overridden `count`
  (neighbor-set intersection) [I: petgraph-coverage.md:242 cost low]. Local/avg clustering coefficient
  is a thin aggregation over per-node triangle touches.

So gaps 1, 2, 3 of the coverage brief (census, graphlet/orbit, triangles) all land as
families/patterns over the one spine.

---

## 3. Significance as a decorator over `Pattern::count`

Significance is *constitutive* of "motif" in 4 of 6 domains [V: grounding.md:63,155] but is the most
expensive axis [V: grounding.md:236] and deferred for v1 implementation while its **hook** stays open
[I: grounding.md:258-259]. Pattern-first expresses it cleanly as a **decorator that wraps any
Pattern and overrides `score`**:

```rust
/// Degree-preserving / null-model shuffler. The rim's generator family
/// (config model, double-edge-swap, Watts-Strogatz, LFR) each implement this.
/// Only dependency beyond petgraph: `rand`. (hard constraint.)
pub trait NullModel<G> {
    fn sample(&self, g: &G, rng: &mut impl rand::Rng) -> G;
}

pub struct Significant<'a, P, Nm> { inner: P, null: &'a Nm, ensemble: usize }

impl<G, P: Pattern<G>, Nm: NullModel<G>> Pattern<G> for Significant<'_, P, Nm> {
    fn order(&self) -> usize { self.inner.order() }
    fn enumerate<'g>(&self, g: &'g G, m: Match) -> Box<dyn Iterator<Item = Instance> + 'g> {
        self.inner.enumerate(g, m)               // pass-through
    }
    fn count(&self, g: &G, m: Match) -> u64 { self.inner.count(g, m) }
    fn score(&self, g: &G, m: Match) -> f64 {
        let obs = self.inner.count(g, m) as f64;
        let mut rng = /* seeded for determinism */;
        let samples: Vec<f64> = (0..self.ensemble)
            .map(|_| self.inner.count(&self.null.sample(g, &mut rng), m) as f64).collect();
        let (mu, sigma) = mean_std(&samples);    // ~10 lines, owned (hard constraint)
        if sigma == 0.0 { 0.0 } else { (obs - mu) / sigma }   // z-score
    }
}
```

The decorator **reuses `inner.count` unchanged** — over the observed graph once and over each null
sample. z-score/p-value stats are ~20 lines we own [I: hard constraint "copy textbook is
implementation"]. This is the pattern-first payoff: significance needed *no* new counting code, only
a wrapper and a `NullModel` family. The null-model generators (gap 6, coverage.md:322) are the exact
`NullModel` implementors, and are also useful standalone.

---

## 4. Kernels over patterns / pattern-counts

- **Graphlet kernel** = the dot product of two graphs' graphlet census vectors (§2). It *literally
  consumes census output* [V: petgraph-coverage.md:285] — `graphlet_kernel(g1,g2) =
  census(GraphletFamily, g1) · census(GraphletFamily, g2)` (normalized). Pure reuse; no new engine.
- **Shortest-path kernel** = a census over a *path-length pattern family* (bucket node-pairs by SP
  distance, compare histograms). It fits the family/count shape but leans on petgraph's `dijkstra`
  /`floyd_warshall`, not on subgraph matching — so it is a Pattern only by analogy (the "pattern" is
  a distance bucket, not a subgraph). **[U]** honest strain: SP kernel rides the *census vector*
  abstraction but not the *subgraph Pattern* abstraction.
- **Weisfeiler-Lehman** — the WL neighborhood-hash primitive is already depend-able and
  petgraph-native in `wl_isomorphism` [V: rim-verification.md:74-81], so the *hash engine* is NIH,
  not ours to build. What we add is assembling per-iteration hash multisets into a **WL feature
  vector**, then a kernel matrix — again a census-vector-shaped operation (count of each WL label).
  WL fits the *count-vector* half of the spine, not the *subgraph Pattern* half.

Net: kernels hang off the **pattern-count vector**, which is the census output. Two of three
(graphlet, WL-feature) are genuine reuse; SP is a looser fit.

---

## 5. Link-prediction / assortativity / rich-club — honest placement

**These do NOT fit the Pattern spine. They are a sibling module.** Stating it plainly rather than
forcing the framing:

- Link-prediction indices (Jaccard, Adamic-Adar, resource-allocation, preferential-attachment, Katz)
  score a **node *pair*'s likelihood of an edge** from neighborhood set overlap [I:
  petgraph-coverage.md:243]. There is no subgraph template being matched, no instance to enumerate,
  no isomorphism class to count. Wrapping "common neighbors of (u,v)" as a `Pattern` would be a
  category error — the output is a per-pair score, not a frequency of a shape.
- Assortativity / degree-correlation / rich-club are **global scalar summaries over the degree
  sequence** [I: petgraph-coverage.md:247] — a Pearson correlation of edge-endpoint degrees, a
  density ratio among high-degree nodes. No pattern, no enumeration.

They share the crate's *substrate* (local neighborhood structure over a static petgraph graph —
coverage.md:288) but not its *primitive*. So SPINE-B places them in a sibling `neighborhood` module
of small owned functions, cohabiting the crate for the cohesion/interop reason (one current-petgraph
home — coverage.md:162) but **outside** the Pattern trait. This is the framing admitting its own
boundary rather than over-reaching. (Under a census-engine framing they'd be equally outside — this
is not a defect unique to pattern-first, but pattern-first makes the mismatch sharpest because the
primitive is so specifically "a shape you match.")

---

## 6. v1 API surface (motif + census) and non-foreclosure

v1 ships exactly the certified slice — named-motif enumeration + census — as the concrete face of the
spine:

```rust
// --- v1 public surface ---
pub enum MotifKind { Diamond, Ffl, BiFan, Chain, DirectedTriangle, Triad(u8), Triangle }
pub struct Named { pub kind: MotifKind }
impl<G> Pattern<G> for Named { /* enumerate/count, seeded by find_diamonds for Diamond */ }

pub struct Template<'p, G> { pub pattern: &'p G }           // VF2 delegation
impl<G> Pattern<G> for Template<'_, G> { /* §1 */ }

pub trait PatternFamily<G> { /* §2 */ }
pub struct ConnectedKNode { pub k: usize, pub directed: bool }   // triad-13, graphlet-30
pub fn census<F,G>(fam: &F, g: &G, m: Match) -> Vec<(F::Item,u64)>;

// convenience mirrors of the seed:
pub fn find_diamonds<G>(g: &G) -> impl Iterator<Item = Instance> { Named{kind:Diamond}.enumerate(g, NonInduced) }
```

**Proof it does not foreclose the rim** — each north-star item has a named seam already shown above:
- graphlet/orbit/GDD → `PatternFamily` + `OrbitPattern` refinement (§2).
- null models (config, double-edge-swap, WS, LFR) → `NullModel` trait implementors (§3), also
  standalone generators.
- significance z-scores → `Significant` decorator (§3), reusing `count`, no core change.
- kernels (WL/SP/graphlet) → functions over census vectors (§4); WL hash via `wl_isomorphism` dep-or-own.
- triangles / clustering / link-prediction / assortativity / rich-club → §5 sibling `neighborhood`
  module (triangles also expressible as a Pattern override).
- Every method takes `(g, m)` purely and is generic over `EdgeType`/weights/`StableGraph` — the three
  compatibility invariants the briefs require for non-foreclosure [I: grounding.md:270-271].

Deferred-not-foreclosed (matches coverage.md:325-328): RAND-ESU sampling, general-k >catalog census,
full Louvain/Leiden, GED, embeddings, spectral, streaming.

---

## 7. Self-critique (adversarial, against SPINE-B)

**Weakest joint — census efficiency.** The framing's load-bearing weakness is exactly the one flagged
in the brief: **forcing census through a per-Pattern `count` throws away the single combined k-node
enumeration pass.** The efficient way to compute a size-k census (FANMOD's RAND-ESU, gtrieScanner's
g-trie — grounding.md:167-168) is to enumerate every connected k-node subgraph *once*, canonically
label each, and increment a bucket. SPINE-B's default `census()` instead calls `count` once *per
pattern class*, and each `count` (for Named without a closed form, or Template via VF2) re-scans the
graph — an O(classes × scan) blowup versus O(one scan). My mitigation (overridable `count`) does not
actually solve this: a *family-level* fast census cannot be expressed as independent per-Pattern
`count`s at all; it needs a `PatternFamily::census_combined(g)` escape hatch that bypasses the
per-Pattern spine and buckets by canonical label — which is the census-engine framing reasserting
itself *inside* pattern-first. So the honest read: **for the census operation, the Pattern is the
wrong-grained primitive; the family/pass is.** Pattern-first is natural for enumerate and for
significance-decoration, and awkward-to-inverted for scale census.

**What would have to be true that I did not verify:** (a) **[U]** that petgraph's trait bounds
(`GetAdjacencyMatrix`, `IntoNeighborsDirected`, `GraphProp`) actually compose to let one generic
`Pattern<G>` impl serve `Graph` and `StableGraph` and both directednesses without specialization — I
did not compile this; the bound set is plausible but unverified [petgraph-coverage.md:30 only lists
type names]. (b) **[U]** that `subgraph_isomorphisms_iter` yields non-induced (monomorphism)
mappings such that my induced-filter wrapper is correct — I asserted the direction but did not read
its semantics this session. (c) **[U]** that the ORCA orbit shortcut can live behind an
`OrbitPattern` without leaking its linear-system structure through the trait.

**Strongest alternative I did not take:** make the **PatternFamily + combined census pass** the
primitive (a census-engine spine), with individual Patterns as *projections* out of the shared pass.
That inverts SPINE-B and directly fixes the weak joint — census becomes native and individual counts
fall out of the buckets — at the cost of making single-motif enumeration and the significance
decorator less immediate. I did not take it because the assignment fixed pattern-first; but it is the
attack an adversary should press, and I judge it the stronger spine for the counting-centric domains
(social/connectomics/ecology — grounding.md:53-55).

**Single cheapest evidence to confirm-or-kill SPINE-B:** write the ~15-line generic `Pattern<G>` impl
for `Named{Triangle}` plus a two-member `PatternFamily`, and `cargo build` it against petgraph 0.8
over *both* `Graph` and `StableGraph`, directed and undirected. If the trait bounds compose and it
counts correctly, the spine's core claim (one generic Pattern over all petgraph types) stands; if it
needs per-type specialization or won't satisfy the bounds, the abstraction is refuted at its root
before any rim work.
