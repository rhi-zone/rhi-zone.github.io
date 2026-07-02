# ADR-0290: Build a new petgraph-native structural / network-science mining library

- Status: Accepted (decided; not yet scaffolded)
- Date: 2026-07-02

**Context.** normalize carries a ~50-line `find_diamonds` motif detector. Asking whether it
should be extracted opened a wider question: what graph capability is *genuinely* absent from
the Rust ecosystem, versus already served. Working through the correction chain narrowed it
sharply. `find_longest_chains` stays in normalize as an admitted approximate domain heuristic
(not a general algorithm to extract); DAG-longest-path already exists in rustworkx-core; only
diamond/motif detection was the genuinely-absent asset — and that asset, examined, broadened
into an entire subfield. `find_diamonds` itself stays in normalize as its own copy; it is the
*seed* for the new library, not code to be lifted out. Evidence:
[grounding.md](../../artifacts/2026-07-02-motif-engine/grounding.md).

**The gap (what is actually absent).** The absent-from-Rust surface is the **structural /
network-science mining** subfield — graphlet/orbit statistics, null-model generators, motif
census, structure-aware kernels — *not* "the whole graph domain" and *not* the motif island
alone. The naive rest of the domain is already filled: rustworkx-core, graphalgs, and
petgraph itself cover traversal, shortest-path, flow, MST, centrality, coloring, DAG,
isomorphism, and planarity. The library **depends on** those; it does not rebuild them.
Coverage audit: [petgraph-coverage.md](../../artifacts/2026-07-02-motif-engine/petgraph-coverage.md).

**Decision.** Build a new, standalone, petgraph-native crate for this subfield (working
placeholder name `petgraph-motifs`; the identity is broader than "motifs", so the real name is
resolved at scaffold time). It is a new independent crate, **not** an extraction from
normalize.

**Why a new crate and not NIH.** There is no discoverable petgraph-native home for this
subfield. rustworkx-core is obscure (~64k downloads/mo against petgraph's ~30M) and
Qiskit-coupled. The petgraph-adjacent satellites scatter across **incompatible petgraph
majors** — rustworkx-core/daggy on `^0.8`, petgraph-gen on `^0.7`, graphalgs on `^0.6.5` — so
they cannot even co-resolve in one dependency tree. And `franken_networkx` demonstrates that
the algorithms *do* get written, but only as a PyPI NetworkX port over non-petgraph types.
A cohesive petgraph-native home is the missing thing.

- **LIVE THREAT (not resolved):** if `franken_networkx`'s internals are ever published as a
  real crates.io crate over petgraph types, the cohesion case for the re-homed neighborhood
  statistics (link-prediction, assortativity, rich-club) weakens. The *true algorithmic voids*
  (below) are unaffected by this threat.

**Design constraint (locked).** Minimal-dependency and self-contained: depend **only** on
`petgraph` (including its VF2 `subgraph_isomorphisms_iter`) and `rand`. **Own** every
small/well-understood algorithm — copying a 20-line formula is implementation, not NIH. The
"depend, don't rebuild" rule applies only to *large/complex maintained* algorithms. Rationale:
trust-chain / audit-surface minimization — wrapping foreign glue relabels the transitive trust
chain, it does not shrink it. (Consistent with ADR-0016: no path deps; crates publish
independently.)

**Scope map** (from adversarial rim verification —
[rim-verification.md](../../artifacts/2026-07-02-motif-engine/rim-verification.md)):

- **TRUE algorithmic voids (build):** graphlet/orbit counting (GDD); configuration-model,
  double-edge-swap, Watts-Strogatz, and LFR null-model generators; shortest-path and graphlet
  kernels.
- **Cohesion re-homing (small — own them):** link-prediction indices, degree assortativity,
  rich-club, local/average clustering + triangle counting.
- **NIH-corrected (do NOT build):** the Weisfeiler-Lehman hash core — use/observe
  `wl_isomorphism` — plus everything rustworkx-core / graphalgs already ship.

**Adjudicated spine** (decided by adversarial rounds plus a real build —
[spine-adjudication.md](../../artifacts/2026-07-02-motif-engine/spine-adjudication.md), from
[proposal A](../../artifacts/2026-07-02-motif-engine/spine-proposal-A.md) and
[proposal B](../../artifacts/2026-07-02-motif-engine/spine-proposal-B.md)):

- The organizing center is the **census substrate**: the pipeline
  `enumerate-connected-k-subsets → canonical-label → fold`, with instance-enumeration and
  counting as two readouts of one pass.
- Generic over petgraph's `Graph`/`StableGraph` × directedness × weights from a **single
  trait-bound set** (compiled against petgraph 0.8.3).
- Template-matching is a thin **parallel arm** delegating to petgraph VF2 — deliberately **not**
  unified into the census enum (that unification was rejected as cosmetic). petgraph's
  `subgraph_isomorphisms_iter` returns **node-INDUCED** subgraph isomorphisms natively (verified —
  [vf2-gate.md](../../artifacts/2026-07-02-motif-engine/vf2-gate.md)), so the **induced** arm is
  *free* (call petgraph, no filter) and suits the graphlet/biology rim. **This corrects an earlier
  [V]-tagged claim** in the adjudication that VF2 yields monomorphisms with induced obtained by a
  non-edge filter — that is inverted three ways (docstring verbatim "'subgraph' always means a
  'node-induced subgraph'"; source `is_feasible` rejects extra host edges; empirically
  P3-in-triangle yields 0 induced, not 6), a reminder that even verified tags can be wrong and that
  the adversarial oracle is what caught it. Non-induced (monomorphism) matching **cannot** be
  recovered by filtering petgraph's output (induced ⊂ monomorphism — a post-filter only shrinks)
  and would need its **own** enumerator = new work with no petgraph home. Automorphism-dedup for the
  arm's "distinct instances" readout: edge-set / orbit keying is the safe default; node-set keying
  over-collapses when one vertex set admits multiple embeddings.
- The pattern-first alternative was **refuted** at the census-scaling joint: per-`Pattern`
  census is O(classes × scan); only one ESU pass bucketed by canonical label scales. `Pattern`
  survives, demoted to consumer-facing vocabulary.
- Neighborhood statistics (link-prediction / assortativity / rich-club) sit **outside** the
  census as a sibling module — both independent design framings converged on this.
- Kernels: only the graphlet kernel reduces to census vectors; WL and shortest-path kernels are
  siblings.
- Induced vs non-induced is a **threaded parameter** (this fixes the seed's silent
  non-induced semantics). Note the asymmetry established above: the induced value is petgraph-native
  and free; the non-induced arm is new implementation work, gated on a consumer actually needing it.

**Gates.** Empirical, via real builds (nix cargo) against petgraph 0.8.3 —
[k4k5-gate.md](../../artifacts/2026-07-02-motif-engine/k4k5-gate.md),
[lazy-iter-gate.md](../../artifacts/2026-07-02-motif-engine/lazy-iter-gate.md),
[orbit-gate.md](../../artifacts/2026-07-02-motif-engine/orbit-gate.md),
[vf2-gate.md](../../artifacts/2026-07-02-motif-engine/vf2-gate.md):

- **CLOSED:** the generic spine compiles and runs over all graph-type × directedness × weight
  combinations; k=3 census plus k=4/k=5 graphlet *class* labelling is stable
  (insertion-order-invariant) and correct (class counts 2 / 6 / 21; the 73 orbits reproduced
  from scratch).
- **CLOSED — lazy-iterator core signature:** the core primitive is a lazy explicit-stack
  `Iterator` yielding `Instance` that **owns an O(V+E) adjacency snapshot** (not the pure-borrowing
  shape — petgraph's only O(1) borrowing probe is its O(V²) adjacency matrix, infeasible at scale).
  `count` is a streaming fold — measured peak 44–249 KiB vs `collect`'s 448 MiB (up to 4590× less);
  `collect` = `.collect()`. `Instance` should carry `G::NodeId`, not `usize`. The recursive form is
  kept as a permanent test oracle.
- **CLOSED — per-node orbit attribution (GDV/GDD):** correct across all 73 orbits at k≤5
  undirected — attribution via the arg-perm witnessing the instance→canonical isomorphism, orbit
  looked up in the union-find automorphism registry (automorphism-invariant, so order-independent).
  Verified vs an independent combination-based brute-force oracle (zero mismatches on
  paths/cycles/stars/K4-6 + 12 fuzzed random) and `Σ_v GDV = count · orbit_size`; cost ~1.01×
  (effectively free). Follow-on (not correctness): internal orbit ids are stable but not ORCA's
  published permutation — a mechanical lookup.
- **CLOSED — VF2 induced arm (with a correction):** induced template matching over petgraph is
  correct and native — see the polarity correction in the spine section above.
- **OPEN (live, not resolved):** **scalable k=5** (naive canonicalization is untenable at
  biological scale — needs ORCA orbit-equations or a g-trie); the **non-induced (monomorphism)
  template arm** (new work, gated on confirming a consumer needs it — the graphlet rim wants
  induced; only the normalize `find_diamonds` seed had non-induced semantics, and that copy stays
  in normalize); throughput benchmark of owning-snapshot vs borrowing; ORCA-permutation alignment
  (mechanical); directed k≥4 deferred by design.

**V1 slice.** Motif discovery + subgraph census: k=3 plus k=4 named motifs (diamond seed, FFL,
bi-fan), seeded by `find_diamonds`.

**Alternatives rejected.**
- *Extract `find_diamonds` from normalize into a shared crate* — the seed is ~50 lines and stays
  home; the value is the surrounding subfield, not the snippet. Extraction would also couple
  normalize to a nascent crate against ADR-0016.
- *Wrap/glue existing satellites (rustworkx-core, graphalgs, petgraph-gen) into one facade* —
  they sit on incompatible petgraph majors and cannot co-resolve; a facade inherits every
  transitive trust surface without shrinking it, violating the minimal-dependency constraint.
- *Pattern-first architecture (census driven per-`Pattern`)* — refuted on scaling: O(classes ×
  scan) versus one label-bucketed ESU pass.
- *Unify template-matching into the census enum* — rejected as cosmetic; the VF2 arm stays
  parallel.
- *Build a Weisfeiler-Lehman hash core* — NIH; `wl_isomorphism` already exists, so observe/use it.

**Consequences.** Org placement is **rhi-zone** (`~/git/rhizone/`) — a substrate for
developer/technical purposes. The crate is **decided but not yet scaffolded**; this ADR plus
the artifacts under `docs/artifacts/2026-07-02-motif-engine/` (linked throughout above)
are the record, and it is deliberately **not** registered in the project tables
(`docs/about.md`, `README.md`, `docs/projects/index.md`, `.vitepress/config.ts`) until it
exists. Open at scaffold: the final crate name — note that a `petgraph-` prefix is petgraph's
ecosystem-plugin idiom, **not** a forbidden self-prefix under the no-prefix crate-naming
convention (ADR-0018 targets gratuitous self-namespacing); still verify name availability on
crates.io at scaffold. The `franken_networkx` publication threat and the open gates above remain
**live**, tracked in `TODO.md`.
