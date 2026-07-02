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
  unified into the census enum (that unification was rejected as cosmetic).
- The pattern-first alternative was **refuted** at the census-scaling joint: per-`Pattern`
  census is O(classes × scan); only one ESU pass bucketed by canonical label scales. `Pattern`
  survives, demoted to consumer-facing vocabulary.
- Neighborhood statistics (link-prediction / assortativity / rich-club) sit **outside** the
  census as a sibling module — both independent design framings converged on this.
- Kernels: only the graphlet kernel reduces to census vectors; WL and shortest-path kernels are
  siblings.
- Induced vs non-induced is a **threaded parameter** (this fixes the seed's silent
  non-induced semantics).

**Gates.** Empirical, via real builds (nix cargo) against petgraph 0.8.3 —
[k4k5-gate.md](../../artifacts/2026-07-02-motif-engine/k4k5-gate.md):

- **CLOSED:** the generic spine compiles and runs over all graph-type × directedness × weight
  combinations; k=3 census plus k=4/k=5 graphlet *class* labelling is stable
  (insertion-order-invariant) and correct (class counts 2 / 6 / 21; the 73 orbits reproduced
  from scratch).
- **OPEN (live, not resolved):** per-node **orbit** attribution (GDV/GDD — cheap/addable,
  distinct from class labelling); **scalable k=5** (naive canonicalization is untenable at
  biological scale — needs ORCA orbit-equations or a g-trie); lazy `impl Iterator` versus the
  adjacency-borrow lifetime; VF2 induced-filter untested; directed k≥4 deferred.

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
