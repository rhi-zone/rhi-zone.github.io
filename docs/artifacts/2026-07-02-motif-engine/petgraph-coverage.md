# petgraph Ecosystem — Coverage + Gap Inventory

Scope question: a new crate positioned as "the capabilities petgraph is missing." The
danger to bound: that "the rest of petgraph" quietly means "re-implement rustworkx-core."
This inventory establishes what the *whole* petgraph-adjacent ecosystem already ships, so
the deliverable is the genuinely-absent surface.

Method: docs.rs module/function listings, crate READMEs, and targeted web search
(2026-07-02). Confidence tags: **[V]** verified from docs.rs/source, **[V~]** partial
(module listed, not every fn enumerated), **[I]** inferred (absence claims — a negative is
never fully provable; these reflect exhaustive search turning up nothing).

---

## 1. Per-crate coverage

### petgraph (core) — `petgraph::algo` **[V]**
Traversal: Bfs/Dfs/DfsPostOrder/Topo visitors, `toposort`, `all_simple_paths`,
`all_simple_paths_multi`. Shortest path: `dijkstra`, `bidirectional_dijkstra`,
`bellman_ford`, `find_negative_cycle`, `astar`, `k_shortest_path`, `floyd_warshall`,
`johnson`, `parallel_johnson`, `spfa`. MST: `min_spanning_tree` (Kruskal),
`min_spanning_tree_prim`. Steiner: `steiner_tree`. Connectivity: `connected_components`,
`has_path_connecting`, `kosaraju_scc`, `tarjan_scc` (+`TarjanScc`), `condensation`,
`bridges`, `articulation_points`, `dominators`, `is_cyclic_directed/undirected`,
`is_bipartite_undirected`. Flow/matching: `ford_fulkerson`, `dinics`, `greedy_matching`,
`maximum_matching`. Cliques: `maximal_cliques`. Coloring: `dsatur_coloring`. Centrality:
`page_rank`. DAG: `toposort`, `tred` (transitive reduction), `greedy_feedback_arc_set`.
**Isomorphism (notably strong here):** `is_isomorphic`, `is_isomorphic_matching`,
`is_isomorphic_subgraph`, `is_isomorphic_subgraph_matching`, `subgraph_isomorphisms_iter`.
Data structures: `Graph`, `StableGraph`, `GraphMap`, `MatrixGraph`, `Csr`, `UnionFind`.
**Missing from core:** DAG longest_path, most centralities, clustering coefficient,
community, motif/census, richer generators.

### rustworkx-core — the critical dedup target **[V]**
petgraph-based; the biggest single gap-filler. Modules and key fns:
- **dag_algo:** `longest_path`, `longest_path_length` (the canonical "petgraph lacks this"
  example — filled here), `layers`, `lexicographical_topological_sort`, `collect_runs`,
  `collect_bicolor_runs`.
- **centrality:** `betweenness_centrality`, `edge_betweenness_centrality`,
  `closeness_centrality`, `newman_weighted_closeness_centrality`, `eigenvector_centrality`,
  `katz_centrality`, `degree_centrality`, `group_betweenness/closeness/degree_centrality`.
- **connectivity:** `articulation_points`, `bridges`, `chain_decomposition`, `cycle_basis`,
  `find_cycle`, `johnson_simple_cycles` (+`SimpleCycleIter`), `core_number`, `isolates`,
  `stoer_wagner_min_cut`, `connected_components`, `number_connected_components`,
  `all_simple_paths_multiple_targets`, `longest_simple_path_multiple_targets`.
- **shortest_path:** `dijkstra`, `bellman_ford`, `astar`, `all_shortest_paths`,
  `single_source_all_shortest_paths`, `k_shortest_path`, `distance_matrix`,
  `negative_cycle_finder`.
- **coloring:** `greedy_node_color` (+strategy/preset variants), `greedy_edge_color`
  (+strategy), `misra_gries_edge_color`, `two_color`; separate **bipartite_coloring**.
- **transitivity:** `graph_transitivity`, `digraph_transitivity` (GLOBAL transitivity only).
- **planar:** `is_planar`. **line_graph.** **steiner_tree.** **max_weight_matching.**
  **token_swapper** (Qiskit-specific). **geometry**, **graph_ext**, **distancemap**,
  **dictmap**, **utils**.
- **generators (~24, rich):** cycle, path, star, complete, grid, hexagonal_lattice
  (+weighted), heavy_hex, heavy_square, petersen, barbell, lollipop, binomial_tree,
  full_rary_tree, dorogovtsev_goltsev_mendes, karate_club, barabasi_albert, gnm/gnp random,
  random_regular, random_geometric, random_bipartite, **sbm_random_graph** (stochastic block
  model), hyperbolic_random.
- **Absent from core:** isomorphism/VF2 (lives in the Python-facing `rustworkx` crate, *not*
  exported by `-core`), graph edit distance, community detection, motif/census,
  clustering coefficient (per-node), link prediction, Watts-Strogatz/configuration-model
  generators. **[V~]**

### graphalgs **[V]**
- **metrics:** `radius`, `diameter`, `center`, `periphery`, `eccentricity`, `girth`
  (+weighted variants) — best-in-ecosystem for distance-summary metrics.
- **shortest_path:** floyd_warshall, spfa, johnson, APD/Seidel-family **[V~]**.
- **connect:** `articulation_points`, `find_bridges`, `connected_components`,
  `has_path_connecting`, `scc` (kosaraju/tarjan/condensation).
- **mst.** **tournament** (tournament-graph algos). **elementary_circuits.**
- **generate:** `complement`, `random_(weighted_)(di|un)graph`.
- **spec:** `count_spanning_trees`, `laplacian_matrix`, `prufer_code`/`prufer_decode`,
  `is_degree_sequence_graphlike`.
- **adj_matrix** (nalgebra-backed), **traits**.

### daggy **[V]**
DAG data-structure wrapper over `petgraph::Graph` (`Dag`, `StableDag`, `Walker`). Adds
cycle-safe edge insertion and **transitive reduction**; not a general algorithm library.

### pathfinding **[V]**
Standalone (closure/trait-based, *not* petgraph data structures). astar, bfs, dfs, dijkstra,
fringe, idastar, iddfs, bidirectional, brent/floyd cycle detection, `edmonds_karp`
(max-flow), `yen` (k-shortest), topological_sort, strongly_connected_components,
connected_components, `kruskal`, `prim`, Bron-Kerbosch `cliques`, `kuhn_munkres` (Hungarian
weighted bipartite matching), `Grid`/`Matrix` helpers.

### petgraph-gen **[V]**
`complete_graph`, `empty_graph`, `star_graph`, `random_gnm_graph`, `random_gnp_graph`,
`barabasi_albert_graph`. Strict subset of rustworkx-core generators.

### Adjacent / peripheral **[V~]**
- **fdg / fdg-sim** — Fruchterman-Reingold force-directed **layout**, N-dim, converts any
  `petgraph::Graph`. → **layout is covered.**
- **Community detection** lives only in *standalone, non-petgraph* graph libs: `graphrs`
  (Louvain+Leiden), `leiden-rs` (own CSR; optional petgraph adapter), `fast-louvain`,
  `single-clustering`. No first-class petgraph-ecosystem community module.
- **memoesu** — memoized parallel ESU subgraph enumeration, but a standalone **CLI binary**
  (bioinformatics), not a petgraph-integrated library crate.
- **vf2** (OwenTrokeBillard) — standalone VF2 subgraph isomorphism crate.

---

## 1b. Cohesion / depend-ability of each satellite (crates.io / lib.rs, 2026-07-02) **[V~]**

A capability only fills a gap for a petgraph user if it lives somewhere they'd sanely
*depend on*: petgraph-native types (no conversion), petgraph-idiomatic API, and discoverable
relative to petgraph itself. Reference point: **petgraph = ~30M downloads/mo, ~12,000
reverse-deps (1,409 direct), #29 Data Structures.**

| Crate | What it really is | Graph types | Adoption (dl/mo · rev-deps) | Cohesion verdict |
|---|---|---|---|---|
| **rustworkx-core** | Pure-Rust backend of IBM/Qiskit's Python `rustworkx`; re-exports petgraph, promises "stable rust API for downstream crates" | **petgraph-native** (operates on petgraph `Graph`) | ~64k · **5** | petgraph-native & technically depend-able, but **obscure relative to petgraph (~500× fewer dl, 5 rev-deps)** and positioned/versioned around Qiskit's needs (e.g. `token_swapper`). Depend-able but low-discoverability; not a general "petgraph extensions" brand. |
| **graphalgs** | Explicit "extra algorithms on petgraph" grab-bag | **petgraph-native** | ~555 · **1** | petgraph-native and idiomatic but **near-invisible** (1 rev-dep). Effectively undiscoverable. |
| **pathfinding** | Popular generic pathfinding lib | **own closure/trait API** (NOT petgraph types) | ~155k · **85** | Well-adopted & maintained, but **foreign to petgraph** — using it means abandoning petgraph's graph types / writing successor closures. Not a cohesive petgraph extension. |
| **daggy** | DAG data-structure wrapper | petgraph-native (wraps `Graph`) | ~411k · **232** | Cohesive & popular, but scope = DAG container + transitive reduction only. |
| **petgraph-gen** | Generator helpers | petgraph-native | (niche) · **5** | Cohesive but tiny scope; strict subset of rustworkx-core generators. |
| **fdg / fdg-sim** | Force-directed layout | consumes petgraph `Graph` | (niche) | Cohesive for layout. |
| **graphrs / leiden-rs / fast-louvain / single-clustering** | Community detection | **own graph types** (CSR); leiden-rs has optional petgraph adapter | (niche) | **Foreign** — conversion required; not a petgraph-native community capability. |
| **memoesu** | ESU subgraph enumeration | **standalone CLI binary**, not a library | (research tool) | Not depend-able as a library at all. |

**Key consequence:** the ecosystem's most complete algorithm satellite (rustworkx-core) is
petgraph-native yet *obscure and Qiskit-coupled*, and the other petgraph-native satellites
(graphalgs, petgraph-gen) are nearly invisible. So "does a capability exist?" and "does a
petgraph user have a cohesive, discoverable place to get it?" diverge — which motivates the
two-tier gap split below. **Discipline:** obscurity is a *discoverability* problem, not a
correctness one; for stable well-defined algorithms already living in a petgraph-native
depend-able crate (e.g. centralities, DAG longest_path in rustworkx-core), re-implementing
is **NIH**, not gap-filling. Tier B is reserved for capabilities whose only homes are
*foreign* (non-petgraph types) or *non-library* (CLI) — where a petgraph-native version
removes real friction.

---

## 1c. Interop friction — do the satellites actually compose? **[V]**

petgraph version each satellite currently requires (crates.io Cargo.toml, 2026-07-02;
current petgraph is 0.8):

| Satellite (latest) | petgraph req | Graph types |
|---|---|---|
| rustworkx-core 0.18.0 | **^0.8** | petgraph |
| daggy 0.9.0 | **^0.8** | petgraph |
| petgraph-gen 0.2.0 | **^0.7** | petgraph |
| graphalgs 0.2.0 | **^0.6.5** | petgraph (+nalgebra 0.33) |
| pathfinding 4.15.0 | *none* | own closure/matrix API |

**This is real friction, not dependency-count aesthetics.** petgraph is pre-1.0, so 0.6 /
0.7 / 0.8 are **semver-incompatible majors** — Cargo links all three simultaneously and the
`petgraph::graph::Graph<N,E>` type from each major is a **distinct, non-interchangeable
type**. Consequences:
- The petgraph-native satellites are **scattered across three incompatible petgraph majors**.
  A graph you build for rustworkx-core (0.8) **cannot be passed to graphalgs (0.6) or
  petgraph-gen (0.7)** without rebuilding it under that crate's petgraph version. There is no
  smooth "petgraph + graphalgs + rustworkx-core + petgraph-gen" toolbox today.
- Only **rustworkx-core + daggy** currently align (both ^0.8, both current) and compose
  cleanly with each other and with fresh petgraph. graphalgs and petgraph-gen are **stranded
  on older majors** — using them forces the whole graph pipeline down to 0.6/0.7.
- pathfinding composes with *nothing* by type — it's a separate world (closures), so any
  petgraph interop is user-written glue.

**Consolidation value (genuine, not NIH):** a single cohesive crate that (a) tracks *current*
petgraph and (b) provides the structural-mining surface petgraph-native, lets a user stay on
one petgraph major and get census/graphlets/link-prediction/clustering/etc. without importing
graphs across three incompatible type universes. That is friction a cohesive crate removes —
distinct from merely reducing the dep count. (Caveat: this argues for consolidating the
*genuinely-absent* surface onto current petgraph, **not** for re-implementing what
rustworkx-core already does well on ^0.8 — depending on rustworkx-core is friction-free since
it already tracks 0.8.)

---

## 2. Coverage matrix (category → who provides it)

| Category | petgraph | rustworkx-core | graphalgs | pathfinding | other | Gap? |
|---|---|---|---|---|---|---|
| Traversal (BFS/DFS/topo) | ✅ | ✅ | — | ✅ | | no |
| Shortest path (single/APSP/k) | ✅ strong | ✅ strong | ✅ | ✅ | | no |
| MST | ✅ | — | ✅ | ✅ | | no |
| SCC / connectivity | ✅ | ✅ | ✅ | ✅ | | no |
| Bridges / articulation | ✅ | ✅ | ✅ | — | | no |
| Cycle basis / simple cycles | — | ✅ | ✅(circuits) | ✅(detect) | | no |
| Min cut (Stoer-Wagner) | — | ✅ | — | — | | no |
| Max flow | ✅ | — | — | ✅ | | no |
| Matching (max / weighted) | ✅ | ✅ | — | ✅(KM) | | no |
| Centrality (betweenness/eigen/katz/closeness) | page_rank only | ✅ full | — | — | | no |
| Distance metrics (radius/diameter/girth) | — | — | ✅ best | — | | no |
| DAG longest path / layers | — | ✅ | — | — | | no |
| Transitive reduction | ✅(tred) | line_graph | — | — | daggy | no |
| Coloring (node/edge/bipartite) | dsatur | ✅ rich | — | — | | no |
| Cliques (maximal) | ✅ | — | — | ✅ | | no |
| Isomorphism / subgraph-iso (boolean+iter) | ✅ strong | — | — | — | vf2 | no |
| Planarity | — | ✅(is_planar) | — | — | | thin |
| Generators | — | ✅ ~24 | random+complement | — | petgraph-gen | mostly no |
| Layout | — | — | — | — | **fdg** | no |
| Tournament algos | — | — | ✅ | — | | no |
| Spanning-tree count / Laplacian / Prüfer | — | — | ✅(spec) | — | | no |
| **Global transitivity** | — | ✅ | — | — | | no |
| **Local/avg clustering coeff, triangle count** | — | — | — | — | — | **YES (partial)** |
| **Community detection (Louvain/Leiden/modularity/label-prop)** | — | — | — | — | non-petgraph libs | **YES (ecosystem gap)** |
| **Motif discovery / subgraph census (ESU)** | — | — | — | — | memoesu (CLI) | **YES (island)** |
| **Graphlet counting / orbit / GDD** | — | — | — | — | — | **YES** |
| **Link prediction (Jaccard/Adamic-Adar/RA/pref-attach)** | — | — | — | — | — | **YES** |
| **Assortativity / degree correlation / rich-club** | — | — | — | — | — | **YES** |
| **Graph kernels (WL / graphlet / shortest-path)** | — | — | — | — | — | **YES** |
| **Graph edit distance** | — | — | — | — | — | **YES (separable)** |
| **Node/graph embeddings (node2vec/spectral)** | — | — | — | — | — | **YES (separable)** |
| **Spectral clustering / Fiedler partition** | — | laplacian only | laplacian only | — | — | **YES (separable)** |
| **Watts-Strogatz / configuration model / LFR gens** | — | — | — | — | — | **YES** |

---

## 3. Genuine gap list — two tiers

**Tier A = hard gap:** absent everywhere, OR present only in a non-library form (CLI) — no
depend-able implementation exists at all.
**Tier B = effectively-absent gap:** the capability exists but *only* in a home a petgraph
user can't cohesively depend on — foreign graph types (conversion tax) or a non-library
tool. A petgraph-native version adds real friction-removal value, NOT mere NIH.
**Explicitly NOT gaps (NIH watch):** capabilities that already live in a petgraph-native,
depend-able crate — even an obscure one. Re-implementing these is duplication, not reach:
centralities, DAG `longest_path`/layers, coloring, planarity, min-cut, cycle_basis,
simple-cycle enumeration, generators (all rustworkx-core, petgraph-native); distance metrics,
Laplacian/Prüfer/spanning-tree-count (graphalgs, petgraph-native). The right answer for these
is *depend on the satellite*, not rebuild it. (Their obscurity is a discoverability problem a
new crate does not fix by copying them.)

### Tier A — hard gaps

Each: what it is · domain · rough cost.

**Structural-mining cluster (cohesive):**
1. **Motif discovery / subgraph census** [V~] — enumerate/count all size-k connected
   induced subgraphs (ESU / g-trie), with random null models for significance profiles.
   Domain: network science, systems biology, social nets. Cost: **high** (the reason-to-exist
   engine; enumeration + iso-canonicalization).
2. **Graphlet counting / orbit counting / GDD** [I] — per-node graphlet degree vectors,
   graphlet degree distribution. Domain: bioinformatics, graph ML features. Cost: **moderate**
   (specialized combinatorial counting; ORCA-style shortcuts). Natural extension of (1).
3. **Local & average clustering coefficient, triangle counting/enumeration** [V~] — only
   *global* transitivity exists (rustworkx-core). Domain: universal network analysis. Cost:
   **low**.
4. **Link prediction scores** [I] — common-neighbors, Jaccard, Adamic-Adar, resource
   allocation, preferential-attachment, Katz index. Domain: recommenders, knowledge graphs.
   Cost: **low** (mostly neighborhood set ops).
5. **Assortativity / degree correlation / rich-club coefficient** [I] — Domain: network
   science summary stats. Cost: **low**.
6. **Null-model / randomization generators** [I] — Watts-Strogatz small-world,
   configuration model, double-edge-swap degree-preserving randomization, LFR benchmark.
   Domain: motif significance, benchmarking (directly feeds (1)). Cost: **low–moderate**.
7. **Graph kernels** [I] — Weisfeiler-Lehman, graphlet kernel (consumes census), shortest-
   path kernel. Domain: graph classification / ML. Cost: WL **low**, full kernel matrices
   **moderate**.
**Non-cohesive / separable Tier-A gaps (do not belong to the structural-mining identity):**
8. **Graph edit distance** [I] — approximate/exact GED. Domain: pattern recognition. Cost:
   **moderate–high**. Compatible but separable.
9. **Node/graph embeddings** (node2vec, DeepWalk, spectral) [I] — pulls in linalg/ML deps.
   Cost: **high**, heavy maintenance.
10. **Spectral clustering / Fiedler vector / spectral partitioning** [I] — Laplacian matrix
    exists (graphalgs) but no eigen-based algorithms. Cost: **moderate** (needs eigensolver dep).
11. **Temporal / dynamic graph algorithms** [I] — out of the static-structure family.

### Tier B — effectively-absent (exists only in a foreign / non-cohesive home)

| Capability | Where it lives today | Why effectively absent | Cohesion value vs NIH |
|---|---|---|---|
| **Community detection** (Louvain, Leiden, label-prop, Girvan-Newman, modularity) [V~] | graphrs / leiden-rs / fast-louvain / single-clustering — **own CSR graph types** (leiden-rs has an *optional* petgraph adapter); memoesu unrelated | A petgraph user must convert to a foreign type; no petgraph-native community module exists | **Genuine cohesion value** for petgraph-native modularity + label-propagation (cheap, no foreign dep). Full Louvain/Leiden borders NIH of graphrs — but graphrs isn't petgraph-native, so a native impl still removes the conversion tax. Honest: partial value, sized down. |
| **Weighted bipartite assignment (Hungarian / Kuhn-Munkres)** [V] | pathfinding `kuhn_munkres` — **foreign closure/matrix API** | Not petgraph-typed; petgraph's own `maximum_matching` is *unweighted* | **Mild** value (petgraph-native weighted assignment). pathfinding is well-adopted and usable; only a convenience/idiom gain. Borderline — include only if trivially cheap. |
| **k-shortest simple paths (Yen)** [V] | pathfinding `yen` (foreign API); petgraph/rustworkx-core have `k_shortest_path` (Eppstein-style, *may revisit nodes*) | Petgraph-native *simple*-path Yen is absent in petgraph types | **Mild**; niche. Not core identity. |

Tier-B honest bottom line: only **community-detection primitives** carry real cohesion value
(the alternatives are genuinely foreign-typed); the matching/Yen items are convenience-grade
and mostly redundant with depend-able crates — include only if near-zero cost.

---

## 4. Coherence judgment

The genuine gaps do **not** scatter into a dozen unrelated crates, nor collapse to a single
lonely function. Gaps 1–7 form **one coherent "structural / network-science mining" family**,
bound by a shared substrate: they all consume *local neighborhood structure and small-subgraph
statistics* over a static graph. Motif census (1) is the **anchor**, not an outlier — its
immediate neighbors are load-bearing:
- graphlet counting/GDD (2) *is* motif census re-expressed per-node/orbit;
- the graphlet kernel (7) directly consumes census output;
- motif significance requires the null-model generators (6);
- triangle counting (3) is the k=3 special case of census;
- link prediction (4) and assortativity (5) are the same neighborhood-structure primitives.

So the motif/catalog-enumeration+census island is the **center of a cluster**, not a
standalone. It drags in a coherent orbit (enumeration engine + canonical labeling + null-model
generators + GDD + kernel + the cheap neighborhood stats).

Community detection (Tier B) is *adjacent* (partition-quality driven, shares the graph
substrate) but is arguably its own project with its own large API and existing (foreign-typed)
competitors; best treated as optional/separable. Tier-A gaps 8–11 are genuinely unrelated to
the structural-mining identity and each carries heavy deps — separate crates or out of scope.

**Cohesion + interop reinforce the cluster.** Beyond capability-absence, the coherence case
is strengthened by two facts from §1b/§1c: (1) the ecosystem has **no discoverable
petgraph-native home** for structural mining — the closest satellite (rustworkx-core) is
obscure and Qiskit-coupled, and it doesn't cover this surface anyway; and (2) the
petgraph-native satellites are **scattered across incompatible petgraph majors (0.6/0.7/0.8)**,
so even the *existing* pieces don't compose into a toolbox. A crate that lands the
structural-mining cluster on *current* petgraph is therefore not just "a bag of missing
functions" — it's the first cohesive, discoverable, version-current home for this family.

---

## 5. Gate applied per gap (verbatim gate: in-scope iff (a) COMPATIBLE with genuine use
cases / doesn't foreclose a real future need, AND (b) doesn't COST disproportionately —
API surface, impl complexity, perf, maintenance. Keep compatible-and-cheap; cut only what
costs without buying compat; no proven beneficiary required for zero-cost inclusion.)

| Gap | Compatible? | Cost | Verdict |
|---|---|---|---|
| 1 Motif census (ESU/g-trie) | yes (core identity) | high | **KEEP** — anchor; the reason to exist |
| 2 Graphlet/orbit/GDD | yes | moderate | **KEEP** — coheres, reuses census |
| 3 Clustering coeff / triangles | yes | low | **KEEP** — cheap, fills partial gap |
| 4 Link prediction scores | yes | low | **KEEP** — cheap, structural |
| 5 Assortativity / rich-club | yes | low | **KEEP** — cheap |
| 6 Null-model generators (WS/config/edge-swap/LFR) | yes (feeds motif signif.) | low–mod | **KEEP** — needed by (1), cheap |
| 7 Graph kernels | yes | WL low / matrices mod | **KEEP WL + graphlet kernel** (cheap, reuse census); defer heavy kernel machinery |
| 8 Community detection | yes | mod–high, big surface, existing non-petgraph libs | **PARTIAL** — keep cheap `modularity` + `label_propagation`; defer Louvain/Leiden to a separable crate |
| 9 Graph edit distance | yes | mod–high, separable | **CUT** (costs without buying the identity) |
| 10 Embeddings | yes | high, heavy ML deps, maintenance | **CUT** |
| 11 Spectral clustering | yes | mod, needs eigensolver dep | **CUT** (own crate if wanted) |
| 12 Temporal/dynamic | tangential | — | **CUT** (out of family) |

**In-scope core:** motif census + graphlet/orbit/GDD + clustering coeff/triangles + link
prediction + assortativity/rich-club + null-model generators + WL/graphlet kernels; plus
cheap community primitives (modularity, label propagation). Everything else is a separate
crate.

---

## 6. Verdict

"petgraph extension crate" has **real, non-redundant surface** — it does **not** collapse to
just the motif/census island once rustworkx-core is subtracted, and it is emphatically **not**
"re-implement rustworkx-core." rustworkx-core + graphalgs + petgraph already saturate
traversal, shortest-path, flow, MST, connectivity, centrality, coloring, DAG ops, distance
metrics, isomorphism (petgraph core), planarity, layout (fdg), and generators. The DANGER is
bounded: the naive "rest of petgraph" is largely *already filled*.

But subtracting all of that leaves a **coherent island with a rim**, not a bare point. The
motif/subgraph-census engine is the anchor (Tier A: only memoesu exists, a CLI, so there is
*no depend-able library* at all), and it is genuinely surrounded by cohesive, mostly-cheap
structural-mining capabilities (graphlet/orbit/GDD, clustering coefficient, triangle counting,
link prediction, assortativity, null-model generators, WL/graphlet kernels) that (a) are
absent everywhere and (b) share the census substrate.

The cohesion/interop dimension *raises* the verdict rather than lowering it. The question is
not merely "non-redundant surface after absolute subtraction" but "is there a coherent,
discoverable, petgraph-native, version-current home this surface lacks today" — and the answer
is yes on all four: the surface is coherent (one substrate), it is absent (Tier A) or only
foreign-typed (Tier B community detection), there is no discoverable petgraph-native home
(rustworkx-core is obscure + Qiskit-scoped and doesn't cover it), and the existing satellites
don't even compose (petgraph 0.6/0.7/0.8 type scatter).

Honest NIH boundary: the crate must **not** re-implement what rustworkx-core already does
petgraph-natively on current petgraph (centralities, DAG longest_path, coloring, min-cut,
generators) — depend on it. Its value is the genuinely-absent structural-mining cluster landed
on current petgraph, plus (sized-down) petgraph-native community primitives. The unrelated
heavy gaps (GED, embeddings, spectral, temporal) and full Louvain/Leiden stay out. Net: a real
project with a clear identity — "petgraph's structural / network-science mining layer" — anchored
by the motif/census island but decidedly larger than it.
