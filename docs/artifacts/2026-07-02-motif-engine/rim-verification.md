# Adversarial Verification — Five "Absent from Rust" Claims

Adversarial re-check of five capabilities the coverage survey
([petgraph-coverage.md](petgraph-coverage.md)) marked as GAPS by inference `[I]`. Mandate:
assume a depend-able Rust impl EXISTS and hunt for it; concede "absent" only when a genuine
search comes up empty. Method: crates.io / lib.rs / docs.rs / GitHub / web (2026-07-02).
Confidence: **[V]** verified from source/docs, **[V~]** partial, **[I]** inference.

Depend-ability bar (from the survey): a capability fills a gap only if a petgraph user can
`cargo add` it — i.e. it lives in a **published crates.io crate**, ideally petgraph-native.
Code that exists only in a GitHub one-off or a **PyPI package with a private Rust backend**
is *effectively absent* for a Rust dependency.

---

## The recurring near-miss: `franken_networkx`

A single project shadows three of the five claims and must be handled carefully.
**`Dicklesworthstone/franken_networkx`** is a clean-room Rust reimplementation of NetworkX
with a heavily-engineered CI/conformance story. Its source implements
`degree_assortativity_coefficient`, `rich_club_coefficient`, `common_neighbors`,
`jaccard_coefficient`, `adamic_adar_index`, `preferential_attachment`,
`resource_allocation_index`, `watts_strogatz_graph`, `random_regular_graph`, over its own
`Graph/DiGraph/MultiGraph` types (IndexMap adjacency, NOT petgraph).

**Decisive limitation:** it is distributed as a **PyPI package (`franken-networkx`)** — a
Python drop-in with a GIL-releasing Rust backend. There is **no evidence of a published
crates.io crate**; the Rust internals are not exposed as a cargo dependency, and the graph
types are non-petgraph. So it does **not** clear the depend-ability bar for a Rust/petgraph
developer. It is the strongest single threat to the "no Rust home" thesis and should be
tracked — if it (or a sibling) ever publishes its internals as a crate, claims 2/3/4 partly
collapse — but today it is *effectively absent* for our purposes.

---

## Claim-by-claim

### 1. Graphlet / orbit counting (GDD, orbit counts, ORCA-equivalent)
**Verdict: CONFIRMED-ABSENT [V~].** No depend-able Rust implementation found. The obvious
lead **`orca-rs`** (crates.io) is a **name collision** — it is Optimal Reciprocal Collision
Avoidance (multi-agent navigation, modules `obstacle`/`participant`, last release 2022),
**not** Pržulj orbit counting. The real ORCA (Hočevar/Demšar) is C++/R (CRAN `orca`) with no
Rust port. `franken_networkx` does not implement graphlets. `graphembed` does not. No GDV/GDD
crate exists. Genuine empty search. **Survives as a gap.**

### 2. Link-prediction indices (Jaccard, Adamic-Adar, RA, pref-attach, common-neighbors)
**Verdict: CONFIRMED-ABSENT as a depend-able crate [V~]** (capability exists only in
non-cargo-depend-able homes). All five indices exist in `franken_networkx` source — but
that is the PyPI/non-petgraph package above, not a crate. `graphembed` (petgraph-native,
~490 dl/mo, v0.0.8) uses **Adamic-Adar and Jaccard only as internal ingredients** of its
embedding pipelines (ATP/NodeSketch), not as exposed standalone scoring functions. No crate
offers the link-prediction score family as a depend-able petgraph-native API. **Survives as
a gap**, with the caveat that the code demonstrably exists (franken_networkx) — this is a
packaging/home gap, not an algorithmic-novelty gap.

### 3. Assortativity / rich-club
**Verdict: CONFIRMED-ABSENT as a depend-able crate [V~].** `degree_assortativity_coefficient`
and `rich_club_coefficient` exist **only** in `franken_networkx` (PyPI, non-petgraph). No
petgraph-native or crates.io Rust crate provides them. The generic `correlation` crate can
compute a Pearson coefficient but is not graph-aware (you'd hand-roll the degree-pair
extraction — i.e. you'd be implementing assortativity yourself). **Survives as a gap**, same
"code exists but not cargo-depend-able" caveat as claim 2.

### 4. Null-model generators (Watts-Strogatz, configuration model, double-edge-swap, LFR)
**Verdict: CONFIRMED-ABSENT [V].** Strongest verification of the five. **rustworkx-core's full
generator list was enumerated** (24 generators: barabasi_albert, gnm/gnp, random_regular,
sbm, hyperbolic, grid, etc.) — it contains **no Watts-Strogatz, no configuration model, no
double-edge-swap, no LFR**. `petgraph-gen` is a strict subset. `franken_networkx` has
`watts_strogatz_graph` + `random_regular_graph` only (PyPI/non-petgraph, and still lacks
configuration model / double-edge-swap / LFR). No depend-able Rust home for the
degree-preserving-randomization / small-world / LFR null-model family. **Survives as a gap.**

### 5. Graph kernels (WL subtree, graphlet, shortest-path)
**Verdict: PARTIAL [V] — the WL primitive is REFUTED; SP/graphlet kernels CONFIRMED-ABSENT.**
**`wl_isomorphism`** (crates.io, ~875 dl/mo, v0.1.1 Jan 2025) is **genuinely depend-able and
petgraph-native**: it computes 1-WL and 2-WL neighbourhood hashes per node per iteration,
explicitly "for tasks like feature extraction for graph kernels." That is the **core engine
of the WL subtree kernel** — what remains is only assembling hashes into a kernel matrix.
So the survey's blanket `[I]` "graph kernels absent everywhere" is **too strong for WL**: the
hard part already has a petgraph-native home. However, no crate produces WL **kernel
matrices**, and **no shortest-path kernel and no graphlet kernel** exist in Rust
(`svegapons/graph_kernels` is Python, not a crate). **Thins but does not close.**

---

## Bottom line

**Gaps surviving this adversarial pass: 4 confirmed-absent + 1 partial (of 5).** None of the
five was fully refuted; claim 5 (graph kernels) is materially thinned — the WL kernel's core
primitive is depend-able petgraph-native today (`wl_isomorphism`), so that piece is NIH, not a
gap.

**The "structural / network-science mining subfield has no Rust home" thesis HOLDS, but thins
at two seams that the survey's `[I]` tags missed:** (a) `wl_isomorphism` gives the WL kernel a
real petgraph-native foothold; (b) `franken_networkx` proves link-prediction indices,
assortativity, rich-club, and WS generation are already *written in Rust* — they are absent
from the *cargo-depend-able / petgraph-native* ecosystem, not from Rust source per se. The
gaps are real but three of them (2, 3, part of 4) are **packaging/cohesion gaps** (code exists,
wrong home) rather than **algorithmic-void gaps** (1 graphlets, LFR/config-model, SP+graphlet
kernels). `franken_networkx` is the live threat to watch: a crates.io publication of its
internals would collapse claims 2/3 and dent 4.
