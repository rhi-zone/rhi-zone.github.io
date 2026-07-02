# SPINE-A (census-engine-first)

**Status: one disposable design attempt, held open for adversarial attack. Not a conclusion.**
Framing assigned: the unifying primitive is a subgraph-CENSUS engine over petgraph; motifs,
graphlets, triangles, clustering, kernels, and significance are VIEWS or CONSUMERS of one
counting/enumeration substrate. Built bottom-up from the counting core. Hard constraint:
depend only on `petgraph` + `rand`; own every small algorithm; operate on petgraph's own
`Graph`/`StableGraph`, generic over directedness and weights.

Calibration tags on load-bearing claims: **[VERIFIED]** (read/checked this run, cited),
**[INFERRED]** (reasoned from VERIFIED facts / the record; joint named), **[UNCONFIRMED]**
(needed but not established — a gap, not support).

---

## 1. The core abstraction — the census engine's shape

The substrate is a single function shape: *given a graph and a description of what to look
for, yield instances (node tuples) or fold them into per-class frequencies.* Two pure,
side-effect-free entry points over one enumeration core:

```rust
/// One matched occurrence. `nodes` is the matched node set in CANONICAL order
/// (not discovery order) so dedup, orbit attribution, and cross-graph class identity
/// are all definable downstream. `class` names the isomorphism class it fell into.
pub struct Instance<Ix> {
    pub nodes: SmallVec<[Ix; 8]>,
    pub class: ClassId,
}

#[derive(Clone, Copy)]
pub enum Induced { Induced, NonInduced }   // §H of grounding.md: explicit, never hardcoded

/// A census: per-class counts + a canonical representative per class.
pub struct Census { counts: HashMap<ClassId, u64>, rep: HashMap<ClassId, PatternGraph> }

/// WHAT to find. Both named motifs and arbitrary templates are the `Template` arm;
/// full-catalog census and graphlets are the `AllClasses` arm.
pub enum Selector<'p, G> {
    Template { pattern: &'p G, induced: Induced,
               node_match: NodeMatch, edge_match: EdgeMatch },
    AllClasses { order: usize, induced: Induced },
}

/// THE TWO PURE ENTRY POINTS. Everything in the rim is a caller of these.
pub fn enumerate<'g, G>(g: &'g G, sel: &Selector<G>)
    -> impl Iterator<Item = Instance<G::NodeId>> + 'g
where G: GraphBase + /* Data + IntoNeighborsDirected + NodeCount + EdgeType */;

pub fn count<G>(g: &G, sel: &Selector<G>) -> Census;   // default: fold over enumerate
```

Three axes, deliberately factored:

- **enumerate-instances vs count-frequency** are *the same computation observed at two
  granularities*. `count` is DEFINED as `enumerate(...).fold(bin_by_class)`; a specialized
  counter may later override it, but the default guarantees they never diverge. [INFERRED —
  rests on canonical `Instance.nodes` making dedup total.]
- **induced vs non-induced** is a `Selector` parameter, never a hardcode — directly fixing
  the seed's silent non-induced semantics flagged in grounding.md §3/H. [VERIFIED against
  grounding.md lines 37-38, 261-264.]
- **generic over directedness/weights** falls out of bounding on petgraph's own traits
  (`EdgeType`, `Data`) — no forced conversions. [VERIFIED: petgraph is generic over
  `EdgeType`; petgraph-coverage.md line 232 area / grounding.md axis C.]

Internally, ONE enumeration core with two pluggable strategies behind the `Selector` arms:

```rust
trait EnumStrategy<G> {
    fn run<'g>(&self, g: &'g G) -> Box<dyn Iterator<Item = Instance<G::NodeId>> + 'g>;
}
// Template arm  -> VF2Strategy: delegates to petgraph::algo::subgraph_isomorphisms_iter
// AllClasses arm-> EsuStrategy: own ESU walk (connected k-subsets) + canonical-label classify
```

## 2. How every named thing reduces to the census core

| Consumer | Reduction | Which arm |
|---|---|---|
| Seed `find_diamonds` | `enumerate(g, &catalog::diamond(NonInduced))`; canonical `Instance.nodes` supplies the `i<j` dedup for free | Template/VF2 |
| FFL, bi-fan, directed triangle | `catalog::ffl()` etc. — each is a `&PatternGraph` constructor + induced default | Template/VF2 |
| Arbitrary user template | user hands their own `&G`; we call `subgraph_isomorphisms_iter`, we do NOT rebuild a matcher | Template/VF2 |
| Triad-13 / dyad census | `count(g, &AllClasses{ order: 3, induced: Induced })` | AllClasses/ESU |
| Triangle count/enumeration | the connected-3-class subset of the order-3 census (or `catalog::triangle()`) | either |
| Graphlets / orbits (GDV/GDD) | `AllClasses{ order: 2..=5 }`; per-node orbit attribution is a post-pass over `Instance.nodes` using each class's automorphism-orbit table | AllClasses/ESU |
| Local & avg clustering coeff | `clustering(v) = tri_through(v) / C(deg v,2)`, and `tri_through(v)` is exactly v's k=3 orbit count — a census VIEW, not a separate algorithm | AllClasses/ESU |

**Delegation, not reinvention** [VERIFIED: petgraph ships `subgraph_isomorphisms_iter`,
petgraph-coverage.md lines 28-29; grounding.md lines 185-188]: the Template arm is a thin
adapter over petgraph VF2 (with its native node/edge weight matching for the typed-match
hook, grounding.md axis I). The only genuinely new engine we own is the ESU `AllClasses`
walk + canonical labelling — which is precisely the Tier-A hard gap
(petgraph-coverage.md §3, "Motif discovery / subgraph census … only memoesu (CLI)").

**The framing's strongest win:** triangles + clustering coefficient + graphlets/GDD are not
three modules — they are three *readouts of the order-3..5 census with per-node orbit
attribution*. Census-first collapses them into one code path. [INFERRED from the ORCA/GDV
definitions in grounding.md §1f, lines 138-149.]

## 3. How significance composes (null model + ensemble + census reuse)

Because `count` is a *pure function of the graph*, an ensemble runner just calls it N times
over randomized graphs — no redesign, exactly the "free half of G" the record reserved
(grounding.md lines 251-259).

```rust
pub trait NullModel<G> {
    /// One randomized sample. Degree-preserving nulls take `g`; parametric gens ignore it.
    fn sample<R: Rng>(&self, g: &G, rng: &mut R) -> G;
}
// impls (own each; rand only): DoubleEdgeSwap, ConfigurationModel, WattsStrogatz, Lfr

pub fn significance<G, N: NullModel<G>>(
    g: &G, sel: &Selector<G>, null: &N, ensemble: usize, rng: &mut impl Rng,
) -> HashMap<ClassId, f64> {                    // per-class z-scores
    let obs = count(g, sel);
    let samples: Vec<Census> =
        (0..ensemble).map(|_| count(&null.sample(g, rng), sel)).collect();
    z_scores(&obs, &samples)                     // (obs - mean) / std, own ~15-line stat
}
```

This is where "subgraph" becomes "motif" in Milo's strict sense (grounding.md lines 30-33).
Deferred as *implementation* but foreclosed by *nothing*: the hook is the pure `count`
signature, already present in v1. [VERIFIED against grounding.md lines 256-259.] The
null-model family is a confirmed Tier-A gap [VERIFIED: rim-verification.md claim 4,
CONFIRMED-ABSENT — no WS/config-model/double-edge-swap/LFR in rustworkx-core's 24 gens].

## 4. How kernels consume census output

A kernel is a `Features -> GramMatrix` pipeline. Census is ONE feature source:

```rust
pub trait Features<G> { fn embed(&self, g: &G) -> Vec<f64>; }

struct GraphletKernel { order: usize }   // TRUE census consumer: embed = count(...).to_vec()
struct WlKernel       { iters: usize }   // sibling: own WL neighborhood-hash histogram
struct ShortestPathKernel;               // sibling: consumes petgraph SP length distribution

pub fn gram_matrix<G>(fs: &dyn Features<G>, gs: &[G]) -> Vec<Vec<f64>>;  // pairwise dot/normalize
```

Honest scope of the "consumer" claim: **only the graphlet kernel truly reduces to census.**
WL is iterative neighborhood hashing and SP is a distance distribution — neither enumerates
subgraph instances, so both are *siblings feeding a shared Gram assembler*, not census
views. [VERIFIED: rim-verification.md claim 5 — WL primitive is petgraph-native-present
(`wl_isomorphism`); SP/graphlet kernels CONFIRMED-ABSENT. Hard constraint says own the small
WL hash rather than depend.] Presenting all kernels as "census consumers" would overclaim;
the graphlet kernel is the only clean reduction.

## 5. Where the framing does NOT hold — link-prediction / assortativity / rich-club

These sit **OUTSIDE the census spine, as a sibling `neighborhood` module.** Stated plainly
because the framing must be committed to honestly, not stretched:

- Link-prediction indices (common-neighbors, Jaccard, Adamic-Adar, resource-allocation,
  preferential-attachment) are set operations on the neighbor sets of a node *pair*. They
  enumerate no subgraph instance and produce no per-class frequency. Not census.
- Degree assortativity is a Pearson correlation over edge degree-pairs; rich-club is a
  degree-thresholded edge-density ratio. Both are degree/edge scans. Not census.

They share the *graph substrate* and the *neighborhood primitive*, but not the *counting
substrate*. Forcing them under a census engine would be the pattern-catalog-style stretch
the framing is meant to avoid. They live in `neighborhood::` beside `census::`, both under
the crate roof. [VERIFIED they are confirmed-absent Tier-A gaps: rim-verification.md claims
2-3.] This is the honest boundary of census-first: it is the center of the structural-mining
cluster, not the whole of it (matches petgraph-coverage.md §4 — census is the *anchor of a
cluster*, and neighborhood stats are "the same neighborhood-structure primitives," a sibling
lineage, line 288).

## 6. v1 API surface + proof it does not foreclose the rim

```rust
pub mod census {
    pub struct Instance<Ix>; pub struct Census; pub enum Induced; pub enum Selector<'p,G>;
    pub fn enumerate<'g,G>(g:&'g G, sel:&Selector<G>) -> impl Iterator<Item=Instance<..>>+'g;
    pub fn count<G>(g:&G, sel:&Selector<G>) -> Census;
}
pub mod catalog {   // named motifs -> Selector::Template constructors
    pub fn diamond(i: Induced) -> OwnedSelector;   // seed, NonInduced default per grounding
    pub fn ffl() -> OwnedSelector;  pub fn bi_fan() -> OwnedSelector;
    pub fn triangle() -> OwnedSelector;
}
```

v1 ships: `census::{enumerate,count}` (both arms — VF2 delegation + ESU), the `Induced`
flag, the typed-match hook via petgraph weight matching, and the named `catalog`. The seed
becomes `enumerate(g, &catalog::diamond(NonInduced))`.

**Non-foreclosure proof (each rim item is additive, zero v1-signature change):**
- Significance → wraps `count` in an ensemble; `count` already pure. No change.
- GDD/orbits → post-pass over `Instance.nodes` (already canonical) + a static orbit table.
- Kernels → `Features::embed` calls `count`; new trait, no change to census.
- Null models → new `NullModel` impls; `rand` already the one allowed randomization dep.
- Neighborhood stats → sibling module; never touched census.

The two things v1 MUST get right or the rim IS foreclosed [INFERRED, load-bearing]:
(1) `Instance` carries the full node tuple in **canonical order**, not a bool/count — else
orbit attribution and cross-graph class identity are impossible to add later;
(2) `count` is defined as a fold over `enumerate` and `induced` is a parameter — else
significance/graphlets fork the code path. Both are cheap in v1 and irreversible if skipped.

---

## Self-critique (adversarial, against SPINE-A itself)

**Weakest joint — the "one engine" claim is a union wearing a trenchcoat.** There are two
irreducibly different algorithms: target-driven VF2 (Template arm) and enumerate-all ESU
(AllClasses arm). They share the `Instance` output *type* and almost no *code*. Census-first
presents `Selector` as one substrate, but an attacker rightly says it is an enum over two
unrelated engines, and the unification is cosmetic. The genuinely-new work (ESU + canonical
labelling) serves the biology/graphlet rim; the seed's actual need (enumerate diamond
instances, software domain) is served entirely by the VF2 arm — which **petgraph already
ships** [VERIFIED, petgraph-coverage.md l.28-29]. So census-first risks the exact inversion
grounding.md §5.1 warns against: it makes significance/graphlets (biology) the center and
the software seed a degenerate special case, walking away from the one use case that
motivated the library.

**What must be true that I did NOT verify:** that a *cheap, deterministic, graph-independent*
canonical-labelling scheme exists so `ClassId` is stable across the null ensemble (§3's
z-scores are meaningless if `ClassId` is discovery-order-assigned). [UNCONFIRMED.] Also
UNCONFIRMED: that `count`-as-fold-over-`enumerate` is performant enough versus a specialized
counter at social-network scale (grounding.md notes census beats enumeration precisely
because you *cannot* materialize all instances at 10^8 edges, lines 122-125) — the default
that guarantees consistency may be the default that cannot scale.

**Strongest alternative I did not take:** pattern-catalog-first (SPINE-B territory) — make
the named-motif catalog + VF2 delegation the center, and treat census/ESU as one advanced
consumer. That aligns with the seed and with "the missing thing is an ergonomic named-motif
enumerator" (grounding.md §4, l.306-308), and avoids building ESU in v1 at all. I did not
take it because the assignment fixed census-first; but it is the honest rival and it is
*better aligned with the seed*.

**Single cheapest evidence to confirm-or-kill SPINE-A:** prototype the ESU `AllClasses` arm's
canonical labelling on order-3 (the triad-13) and check that `ClassId` is stable and matches
the known Holland-Leinhardt 16/13-class taxonomy across two different node orderings of the
same graph. If canonical labelling is stable and cheap there, the census core holds and the
rim (orbits, significance) is reachable; if it is not cheap/stable, the "one counting
substrate" collapses to "VF2 the record already has," and pattern-catalog-first wins.
