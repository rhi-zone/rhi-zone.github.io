# Grounding Brief — Generic Graph Motif-Detection Engine (`petgraph-motifs`, working name)

Adversarial grounding for a proposed Rust library seeded by a ~50-line `find_diamonds`
(strict 4-node diamond: one source, two intermediates, one sink, direct edges, canonical
`i<j` intermediate ordering, tuple-deduped output).

**Purpose of this brief:** gather genuine real-world use cases for graph motif detection,
then test which abstractions a "generic motif engine" can actually justify. The commissioning
constraint is verbatim: *"generic motif engine but we need to ground adversarially in genuine
usecases."* The bar is deliberately hostile to speculative generality.

**Confidence tags:** `[V]` verified against a cited primary/authoritative source this session;
`[V~]` verified in substance but a specific numeric/detail is from secondary summary, not the
primary read; `[I]` inferred from domain knowledge, not independently verified this session.
No citation below is invented; where I could not confirm a detail I say so.

---

## 0. Vocabulary (fixed so the audit is unambiguous)

Terms per Ribeiro, Paredes, Silva, Aparicio & Silva, *A Survey on Subgraph Counting: Concepts,
Algorithms, and Applications to Network Motifs and Graphlets*, ACM Computing Surveys 54(2),
2021 (arXiv:1910.13011). `[V]`

- **Enumeration** — list every instance (every node-tuple) of a pattern. This is what
  `find_diamonds` does.
- **Counting / census** — report frequency per pattern class, not the instances. A *census*
  is the counts of *all* isomorphism classes of a fixed size (e.g. the 13 three-node directed
  connected digraphs; the 16-class dyad/triad census of Holland–Leinhardt).
- **Significance** — compare observed counts against an ensemble of randomized graphs
  (degree-preserving nulls) and report z-scores / p-values. This is the *original* definition
  of a "network motif" (Milo 2002, below): a pattern is a *motif* only if over-represented vs.
  random. Enumeration/counting alone produces subgraphs, not motifs, in the strict sense.
- **Induced vs non-induced.** Induced = the matched node set must reproduce the pattern's edges
  *and* its non-edges. Non-induced (a.k.a. monomorphism / partial subgraph) = pattern edges
  must be present, extra edges among matched nodes are allowed. The strict diamond is
  *non-induced* on its face (it does not forbid a source→sink shortcut) — this is a load-bearing
  detail, see §3.
- **Exact vs approximate.** Exact = true counts. Approximate = sampling (RAND-ESU, path
  sampling) trading accuracy for scale.

---

## 1. Genuine use cases across domains

Summary matrix (per-domain detail follows). "Need" = the dominant operation that domain
actually performs, from the cited literature.

| Domain | Motifs that matter | Dir? | Size | Dominant need | Induced? | Exact? | Typical scale |
|---|---|---|---|---|---|---|---|
| Gene-regulatory / transcription | FFL, bi-fan, feedback loop, DOR, auto-reg | directed | 3–4 (occ. k) | **significance** (z-score vs null) | induced | exact + sampled | 10²–10⁴ nodes |
| Software dependency / call / module | diamond, chain, cycle, hub-spoke | directed | 3–4, **also path-based** | **enumeration** (locate instances) | often non-induced | exact | 10²–10⁶ nodes |
| Neuroscience / connectomics | 13 three-node digraphs, FFL, recurrent loops | directed | 3 (some 4) | **census + significance** (motif fingerprint) | induced | exact | 10²–10⁵ nodes |
| Social networks | dyad/triad census (16 classes), triangles | directed | 2–3 | **census** (+ significance) | induced | exact | 10³–10⁸ nodes |
| Ecology / food webs | tri-trophic chain, omnivory, apparent & exploitative competition | directed | 3 (some 4) | **census + significance** | induced | exact | 10¹–10³ nodes |
| Bioinformatics / PPI (graphlets) | 30 graphlets ≤5 nodes, 73 orbits (GDV) | **undirected** | 2–5 | **counting** (per-node orbit vectors) | induced | exact + approx | 10³–10⁵ nodes |

### 1a. Systems biology — gene-regulatory & transcription networks (the origin)

This is where "network motif" was coined. Milo, Shen-Orr, Itzkovitz, Kashtan, Chklovskii &
Alon, *Network motifs: simple building blocks of complex networks*, **Science 298(5594):824–827,
2002** (PubMed 12399590). `[V]` A network motif is defined as a pattern occurring at numbers
*significantly higher than in randomized networks* — significance is constitutive, not optional.
`[V]` The **feed-forward loop (FFL)** and **bi-fan** are the canonical over-represented patterns
in transcriptional regulation; **feedback loops**, **bi-parallel**, and **dense overlapping
regulons (DOR)** also appear (the latter two named in Shen-Orr, Milo, Mangan & Alon, *Nature
Genetics* 31:64–68, 2002, and Alon, *Nature Reviews Genetics* 8:450–461, 2007). `[V~]` (FFL/bi-fan
verified in cited sources this session; DOR/bi-parallel from Alon's body of work `[I]`.)

- Motifs: FFL (3-node), bi-fan (4-node), feedback/auto-regulation, DOR.
- Directed. Sizes 3–4 dominate; the tooling (below) goes to 8.
- **Need: significance** — z-score against a degree-preserving random ensemble is the whole
  point. Enumeration is a means, not the deliverable.
- **Induced** subgraphs (FANMOD, mfinder both count vertex-induced). `[V]`
- Exact for small graphs; **sampled** (RAND-ESU) for larger/larger-k. `[V]`
- Scale: transcription networks are small (E. coli ~400 operons); the algorithms were built
  for 10²–10⁴ nodes. `[I]`

### 1b. Software dependency / call / module graphs (the `normalize` origin case)

The seed. Diamonds and chains in module/import/call graphs signal architectural facts (a diamond
= two independent paths reconverging; a long chain = a fragile dependency spine; a cycle = a
circular-dependency smell). A search of the SE literature confirms motif/anti-pattern detection
on software dependency graphs is a named practice (cyclic dependencies, long dependency chains,
hub-and-spoke, and *diamond* patterns are all explicitly called out). `[V~]`

**Critical nuance that separates this domain from all the others:** dependency-graph motifs are
frequently defined over **indirect paths**, not only directly adjacent vertices — "the motifs
used in dependency graph analysis are more complex than those in bioinformatics in that they
do not only consider local sets of vertices directly connected by edges, but also sets of
vertices indirectly connected by paths." `[V~]` The strict diamond seed is the *direct-edge*
special case; the domain's fuller need is reachability/path-based.

- Motifs: diamond, chain, cycle, hub-spoke. Directed.
- Sizes 3–4 for the direct case; **path-based (unbounded)** for the general case.
- **Need: enumeration** — you want the *actual offending module tuples* to act on, not a
  frequency. Significance-vs-random is largely meaningless here (a codebase is not a sample
  from a random-graph ensemble). This domain is the odd one out: it wants what `find_diamonds`
  already does, and does **not** want the statistical machinery the biology domains center on.
- Often **non-induced** (a diamond with an extra source→sink edge is still a diamond for most
  refactoring purposes) — though "induced" may be wanted to distinguish pure diamonds.
- Exact. Scale: 10²–10⁶ (monorepo import graphs can be large). `[I]`

### 1c. Neuroscience / connectomics

Sporns & Kötter, *Motifs in brain networks*, PLoS Biology 2(11):e369, 2004, established
classifying networks by their **motif frequency profile**; the **13 connected three-node
directed subgraphs** are the standard vocabulary. `[V~]` In the *C. elegans* connectome, the
**feed-forward motif is the most prevalent unidirectional three-node motif**; three- and
four-node motifs are found over-represented. `[V~]` Directed. Size 3 dominant, some 4.

- **Need: census + significance** — the deliverable is the 13-class fingerprint and its z-scores,
  used to compare brains/regions. Both counting *and* significance are first-class.
- Induced. Exact (graphs are small: C. elegans ~300 neurons; larger connectomes 10⁴–10⁵). `[I]`

### 1d. Social networks

The **dyad census** (3 classes) and **triad census** (16 classes, Holland & Leinhardt 1970s)
are foundational SNA. igraph and NetworkX both ship `triad_census`/`triadic_census` as
first-class primitives. `[V]` Directed (the 16 classes are a directed-triad taxonomy). Size 2–3.

- **Need: census** (the 16-vector), often followed by significance vs. a random baseline.
- Induced. Exact, but scale can be huge (10⁶–10⁸ edges), which is exactly where *census*
  (counting) beats *enumeration* — you cannot enumerate all triangles of a billion-edge graph
  but you can count classes. `[I]`

### 1e. Ecology / food webs

Stouffer & Bascompte, *Understanding food-web persistence from local to global scales*, Ecology
Letters 13:154–161, 2010. `[V]` Of the 13 three-species subgraphs, **four** — **tri-trophic
chain, omnivory, apparent competition, exploitative competition** — make up **~95%** of all
three-species motifs in empirical food webs, and their over-representation is linked to dynamical
stability. `[V~]` Directed (trophic direction). Size 3 (some 4-species work exists).

- **Need: census + significance** — which of the 13 are over/under-represented, tied to a
  stability hypothesis. Small graphs (10¹–10³ species) → exact. `[I]`

### 1f. Bioinformatics / PPI — graphlets (a distinct lineage worth separating)

Pržulj's **graphlets**: all connected induced subgraphs up to 5 nodes (**30 graphlets**,
**73 automorphism orbits**); the per-node **graphlet degree vector (GDV)** is the signature.
**ORCA** (Hočevar & Demšar, *Bioinformatics* 30(4):559, 2014) counts orbits by solving a linear
system over smaller graphlets rather than brute enumeration. `[V]` Applied to PPI networks:
graphlet-based node similarity predicts protein function and cancer genes (Milenković & Pržulj
2008). `[V~]`

- **Undirected** (this is the one major domain that is undirected-first). Sizes 2–5.
- **Need: counting** — per-node orbit vectors, not instance lists, not global significance.
- Induced (graphlets are induced by definition). Exact + approximate for scale. `[V]`

**Cross-domain synthesis.** Directedness splits ~5:1 directed (biology-regulatory,
software, connectomics, social, ecology) vs. undirected (graphlets/PPI). The *dominant need*
splits three ways: **enumeration** (software — the seed), **census** (social, connectomics,
ecology), **significance** (regulatory biology, connectomics, ecology). Only software genuinely
does not want significance. Every biology/network-science domain treats *induced* + *significance*
as the default, which is precisely the machinery the seed lacks.

---

## 2. Tooling landscape

### 2a. Established motif tools (non-Rust)

| Tool | What it computes | Algorithm | Sizes | Notes |
|---|---|---|---|---|
| **mfinder** (Kashtan/Milo/Alon, ~2002–04) | census + **significance** | full enum + ensemble | 3–4(–6) | original motif tool `[I]` |
| **FANMOD** (Wernicke & Rasche, Bioinformatics 22(9):1152, 2006) | vertex-induced census + **z-score** significance | **RAND-ESU** (exact or sampled) | **3–8** | GUI; directed/undirected; the reference fast tool `[V]` |
| **gtrieScanner** (Ribeiro & Silva) | subgraph counting + significance | **g-trie** (prefix-tree of graphs + symmetry-breaking conditions) | small k | fastest exact for a *set* of query graphs `[V]` |
| **igraph** (`motifs`, `triad_census`, `dyad_census`) | induced census | RAND-ESU | dir 3–4, undir 3–6 | library primitive, many languages `[V]` |
| **NetworkX** (`triadic_census`, `triads`; VF2 iso/monomorphism) | triad census; pattern matching | — | 3 for census | **no general motif finder** — open feature request (#7218) `[V]` |
| **ORCA** | per-node graphlet **orbit counts** (GDV) | orbit linear-system | 4–5 | undirected graphlets `[V]` |

API-shape takeaway: the mature tools center on **census + significance over a fixed catalog of
sizes** (FANMOD/mfinder/igraph), OR **counting a user-supplied *set* of query graphs**
(gtrieScanner), OR **per-node orbit counting** (ORCA). *Instance enumeration as the deliverable*
— the software/`find_diamonds` need — is the least-served operation among the science tools,
because those domains want frequencies, not tuples.

### 2b. The Rust ecosystem gap (verified this session)

- **petgraph `algo::isomorphism`** exposes exactly: `is_isomorphic`, `is_isomorphic_matching`,
  `is_isomorphic_subgraph`, `is_isomorphic_subgraph_matching`, and
  **`subgraph_isomorphisms_iter`**. All take a **user-supplied pattern `g0`** and test/locate it
  in target `g1` via VF2 (with optional node/edge weight matching). **No function enumerates all
  k-node subgraph classes without a supplied pattern.** `[V]`
- The **`vf2` crate** (OwenTrokeBillard) does graph / subgraph / **induced**-subgraph isomorphism,
  directed or undirected, against a supplied query graph; iterator-based to avoid materializing
  all mappings. Also pattern-driven. `[V]`
- **rustworkx-core** (on top of petgraph) offers VF2 `is_isomorphic` / `is_subgraph_isomorphic`
  and many core algorithms, but **no dedicated motif/graphlet/census functions were found**. `[V~]`
  (Presence of the iso primitives verified; absence of motif functions is a not-found result,
  so `[V~]` not `[V]`.)

**The precise gap:** the Rust ecosystem has **pattern-matching** (given a query graph, find/verify
its occurrences via VF2) but has **no**: (i) all-classes **census** of a given size k, (ii)
**significance** machinery (randomized ensembles + z-scores), (iii) **graphlet/orbit** counting,
or (iv) a **named-motif catalog** with instance enumeration. `find_diamonds` is a hand-rolled
point solution for one cell of (iv). The honest gap is *not* "there is no subgraph matcher" —
there are three. It is "there is no motif *census/significance* layer, and no catalog with
ergonomic enumeration."

**Caveat against overstating:** because petgraph/`vf2`/rustworkx already provide VF2 pattern
matching, any "generic engine" whose value proposition is "match a user-supplied template" is
**largely already shipped**. A new library earns its keep only by adding the census/significance/
catalog layers that are actually missing — not by re-wrapping VF2.

---

## 3. Adversarial abstraction audit

**Revised gate (per coordinator correction, adopted).** For each candidate axis, decide on TWO
prongs, not a beneficiary count:

1. **Compatibility** — does *omitting* it foreclose a genuine use case / paint the first cut
   into a corner? (Foreclosure = bad.)
2. **Cost** — does *including* it add meaningful API surface, implementation complexity,
   performance penalty, or maintenance burden?

**KEEP** an axis if it is compatible-and-free: either it opens a door with no cost, or omitting
it would foreclose a real use case. **CUT** an axis only when it **costs without buying
compatibility** — i.e. it adds real burden *and* omitting it forecloses nothing that a later,
cheap extension couldn't add. Zero-cost door-opening is kept even with no beneficiary yet.

> Note: this is a weaker, more permissive gate than the "≥2 beneficiaries or speculative" rule
> originally commissioned. It was relayed by a coordinator, not the user; I flag that the two
> gates can disagree (§ end) and apply the relayed one as instructed while surfacing the tension.

| Axis | Omitting forecloses a real use case? | Including costs us? | Verdict |
|---|---|---|---|
| A. Named catalog (diamond, FFL, bi-fan, chain, triad-13) | — (it *is* the product) | low — small data table | **KEEP (core)** |
| B. Arbitrary user-supplied template | Yes for gtrie-style queries — but VF2 already ships it | **high** if we reimplement matching; **~free** if we delegate to petgraph VF2 | **KEEP as thin delegation, don't rebuild** |
| C. Directed vs undirected | Yes — graphlets/PPI are undirected-first, biology directed | low — petgraph is generic over `EdgeType` | **KEEP** |
| D. Size k as a parameter | Partially — catalog entries are fixed-k; general census needs k | **high** — general-k census/enum is the hard algorithm (RAND-ESU/g-trie) | **DEFER k>catalog; keep k fixed-per-motif for v1** |
| E. Enumeration | No — it's the seed's whole behavior | low | **KEEP (core)** |
| F. Counting / census | Yes — social/connectomics/ecology center on it | low-med — count without materializing tuples | **KEEP** (derivable from enumeration; cheap) |
| G. Significance (random ensemble + z-scores) | Yes — regulatory biology/connectomics/ecology *define* motif by it | **high** — needs null-model generator, RNG, ensemble runner, stats | **DEFER, but do not foreclose** (see below) |
| H. Induced vs non-induced toggle | Yes — sharp semantic split across domains, and the seed is silently non-induced | **low** — one predicate (check forbidden non-edges) | **KEEP as an explicit flag** |
| I. Node/edge type/color constraints | Yes — signed connectomes, typed dependency edges, colored biology | low-med — a match predicate; VF2 already supports weight matching | **KEEP as optional predicate hook** |
| J. Streaming / out-of-core / >RAM scaling | Only social (10⁸) needs it; all others fit RAM | **very high** — dominates architecture | **CUT for v1** (costs heavily; omission forecloses nothing an in-memory v1 needs) |
| K. Approximate sampling (RAND-ESU) | Only large-k / large-graph biology needs it | **high** — separate algorithm + error bounds | **CUT for v1** (exact suffices at catalog scale) |
| L. Graphlet orbit vectors (GDV/ORCA) | Yes for PPI, but that's a distinct algorithm lineage | **high** — ORCA is its own solver | **DEFER** (compatible seam, but a separate module later) |

Per-axis reasoning where it matters:

- **B (arbitrary templates).** The trap. A "generic motif engine" instinctively wants "user hands
  us any graph, we find it." But VF2 in petgraph/`vf2`/rustworkx **already does this**. Rebuilding
  it is pure cost buying nothing (it would foreclose nothing to *omit* our own reimplementation).
  KEEP the *capability* by delegating to petgraph's `subgraph_isomorphisms_iter`; do **not** write
  a matcher. This converts B from a high-cost axis into a free one.

- **G (significance).** This is the single most important boundary call. Significance is
  *constitutive* of "motif" in 4 of 6 domains (Milo's definition). Omitting it means v1 finds
  *subgraphs*, not *motifs* in the strict sense — a real limitation. **But** building it well
  (degree-preserving edge-swap null models, ensemble sizing, z-score/p-value stats, RNG
  determinism) is a large, opinionated subsystem. The cost/compat resolution: **defer the
  implementation but design the enumeration/count API so an ensemble runner can call it N times
  over shuffled graphs without redesign** (i.e. keep the graph an input parameter, keep counting
  pure and side-effect-free). That is a free compatibility guarantee; the expensive part waits
  for a beneficiary. Omitting the *hook* would foreclose; omitting the *implementation* does not.

- **H (induced flag).** Load-bearing and nearly free — and there's a latent bug-risk in the seed:
  the strict diamond as specified is **non-induced** (it does not forbid a source→sink edge), yet
  every biology/graphlet domain wants **induced**. If v1 hardcodes one interpretation silently,
  it will be wrong for half the audience. One boolean + one non-edge check buys both. KEEP.

- **D/K/G/J/L deferred-or-cut** are the axes where "generic" over-reaches: general-k census,
  sampling, ensembles, streaming, and orbit-counting are each a *distinct hard algorithm*
  (RAND-ESU, g-trie, ORCA, edge-swap nulls, external-memory). Pulling any of them into v1 pays
  full algorithmic cost for a catalog-sized product. None of their *omissions* foreclose a corner
  provided the core API stays (a) generic over `EdgeType`, (b) pure/graph-parameterized, and
  (c) built around an isomorphism-class notion that later general-k code can reuse.

**Where a *generic* engine over-abstracts and hurts:** the "user-supplied template + any k +
significance + streaming" maximal engine is four hard subsystems, three of which duplicate
existing crates (VF2) or existing tools (FANMOD/gtrieScanner/ORCA) that a Rust user can already
shell out to. Building that before a second in-house beneficiary exists is speculative generality
that competes with mature C tools on their turf while the actually-missing thing (an ergonomic
**named-catalog enumerator with an induced flag, typed-match hook, and a significance-ready pure
API**) goes unbuilt.

---

## 4. Recommendation — honest first-cut boundary

Ship a **named-motif catalog enumerator**, not a generic engine. Concretely, the load-bearing
core from §3 is:

1. **A small fixed catalog** of directed/undirected motifs with instance **enumeration**:
   diamond (the seed), chain, directed triangle / FFL, bi-fan, and the triad-13 set. (Axis A, E.)
2. **Generic over `EdgeType`** so directed and undirected are the same code path. (Axis C.)
3. **An explicit `induced` flag** per query — and fix the seed's silent non-induced semantics.
   (Axis H.)
4. **An optional match predicate** for node/edge type/color constraints, delegating to petgraph's
   existing weight-matching where a template is involved. (Axis I, B.)
5. **`count()` alongside `enumerate()`**, both **pure functions of the graph** — no global state —
   so an external ensemble runner can invoke them over shuffled graphs later. (Axis F, and the
   free half of G.)
6. **For arbitrary user templates, delegate to petgraph `subgraph_isomorphisms_iter`** rather than
   reimplement VF2. (Axis B.)

Explicitly **out of v1** (deferred, not foreclosed): significance ensembles + z-scores (G-impl),
general-k census (D), RAND-ESU sampling (K), graphlet orbits/ORCA (L), streaming/out-of-core (J).
Each is a distinct hard algorithm gated on a concrete beneficiary; the pure, `EdgeType`-generic,
isomorphism-class-based core keeps every one of them a non-breaking future addition.

**One-line framing:** the missing thing in Rust is not a subgraph matcher (three exist) — it is
an ergonomic *named-motif enumerator with an induced flag and a significance-ready pure API*.
Build that; borrow VF2; defer the ensembles.

---

## 5. Where the evidence contradicts the "generic engine is warranted" premise

Three genuine tensions, surfaced rather than smoothed:

1. **The seed domain is the outlier, not the template.** Software dependency graphs want
   *enumeration of instances* and do **not** want significance-vs-random (a codebase isn't a
   sample from a random ensemble); its fuller need is even **path/reachability-based**, which no
   subgraph-motif engine covers. Generalizing *from* `find_diamonds` toward the biology notion of
   "motif" walks away from the one use case that actually motivated the library.

2. **The generic "match any template" capability is already shipped** in petgraph, `vf2`, and
   rustworkx-core (VF2). A generic engine built around that axis is largely redundant; the value
   is in the *census/significance/catalog* layers, which are narrower and more opinionated than
   "generic" implies.

3. **"Motif" strictly requires significance** (Milo 2002), yet significance is the most expensive
   axis and is deferred — so the honest v1 detects **subgraphs / named patterns**, not "motifs"
   in the literature's sense. The product name (`petgraph-motifs`) overclaims relative to the
   defensible v1. This is a naming/scoping contradiction to resolve before shipping, not a
   feature to bolt on.

**Meta-note on the gate.** This audit was run under the coordinator-relayed cost/compatibility
gate (keep compatible-and-free generality even with zero beneficiaries), which is more permissive
than the user's original "≥2 genuine beneficiaries or speculative" instruction. Under the
*original* stricter gate, axes B, I, and the counting/census split would face a higher bar and
some (e.g. the typed-match hook I) might be marked speculative pending a second beneficiary. The
two gates converge on the same v1 core (catalog + enumerate + induced flag + pure API) and the
same deferrals (G/K/J/L); they diverge mainly on how eagerly to add the near-free optional hooks
(B/I/F). I applied the relayed gate as instructed and flag that the user may prefer the stricter
one for the optional hooks.
