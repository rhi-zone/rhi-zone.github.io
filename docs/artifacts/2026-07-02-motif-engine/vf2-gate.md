# VF2 induced-filter gate — motif-engine template-match arm

Adversarial prototype of residual risk #4 from `spine-adjudication.md`: does the
petgraph-delegating template-match arm behave correctly, and is the induced/non-induced
distinction handled right? Mandate: break, not bless.

Toolchain: `nix run nixpkgs#cargo` (cargo 1.94.0). Real crate `vf2gate` built against
**petgraph 0.8.3** (fetched from crates.io). Code + full run at
`…/scratchpad/vf2gate/`. **57/57 assertions PASS** under the corrected model below.

## Verdict: gate CLOSES for INDUCED — but the SPINE'S POLARITY IS INVERTED (a real break)

The gate closes on its literal question (induced template matching over petgraph is
correct, generic over directedness, with working predicates). But it **breaks the spine's
stated model**, and the correction is load-bearing:

> spine-adjudication.md §3 / risk #4: *"`subgraph_isomorphisms_iter` yields monomorphisms
> (non-induced) [V: signature/comment read]; the induced wrapper (non-edge filter) is
> structurally sound … non-induced = VF2's native output, induced = one non-edge filter."*

**This is backwards.** petgraph 0.8.3 `subgraph_isomorphisms_iter` returns
**NODE-INDUCED subgraph isomorphisms, NOT monomorphisms.** Confirmed three independent ways:

1. **Docstring** (`petgraph-0.8.3/src/algo/isomorphism.rs:882-885`), verbatim: *"'subgraph'
   always means a 'node-induced subgraph'. Edge-induced subgraph isomorphisms are not
   directly supported. For subgraphs which are not induced, the term 'monomorphism' is
   preferred over 'isomorphism'."*
2. **Source** (`isomorphism.rs:383`, `is_feasible`): evaluates `r_succ!(0)` **and**
   `r_succ!(1)`. `r_succ!(1)` walks the *host* node's mapped neighbours and `return false`s
   unless the *pattern* has the corresponding edge — i.e. it **rejects extra host edges**.
   That is exactly the induced (no-extra-edge) constraint, per-direction for directed graphs.
   `match_subgraph=true` only relaxes the node/edge *count* gate, not this adjacency check.
3. **Empirical** (this harness): P3-in-triangle returns `Some(iter)` yielding **0** matches
   (the induced answer), not 6 (the monomorphism answer).

### Why the inversion matters (not cosmetic)

The spine's plan — "petgraph gives non-induced, we add a non-edge filter for induced" — is
**unimplementable as written and points the wrong way**:

- **Induced is FREE and native** — no wrapper needed. `Induced` mode = call petgraph, done.
- **NON-induced (monomorphism) is the hard arm and CANNOT be recovered by filtering
  petgraph's output.** The induced match set is a strict *subset* of the monomorphism set
  (adding edges can only remove matches); a post-filter can only shrink, never recover the
  matches petgraph already discarded. In every adversarial case below the monomorphism count
  is strictly larger than the induced count petgraph returns (6 vs 0, 24 vs 0, …).
- So if the library must support non-induced template matching (the seed's silent-non-induced
  bug in grounding.md §H was a *non-induced* expectation), the `Induced::No` arm of the
  Template selector **needs its own enumerator** (own VF2/monomorphism pass, or an
  edge-subset relaxation), NOT petgraph's function. petgraph covers only `Induced::Yes`.

This does **not** sink the parallel-arm shape — VF2 stays a thin delegating sibling — but it
relocates the work: the induced arm is trivial, the non-induced arm is the one carrying cost.

## API surface (verified from source)

```rust
subgraph_isomorphisms_iter(g0 /*PATTERN*/, g1 /*HOST*/, node_match, edge_match)
  -> Option<impl Iterator<Item = Vec<usize>> + 'a>
// Vec indexed by PATTERN node index; value = HOST node index.
// None only when pattern.node_count > host.node_count or pattern.edge_count > host.edge_count.
// node_match: FnMut(&G0::NodeWeight, &G1::NodeWeight) -> bool   (pattern, host)
// edge_match: FnMut(&G0::EdgeWeight, &G1::EdgeWeight) -> bool
```

Generic-over-directedness and typed-match hooks both work: the harness runs the *same*
generic `pg_matches<Ty: EdgeType>` over `Graph<_,_,Directed>` and `Graph<_,_,Undirected>`,
and drives the closures with `char`/`i32` weights.

## Adversarial results (petgraph raw = induced; brute-force oracle for both)

Each case cross-checks petgraph against a petgraph-independent brute-force enumerator over
all injective pattern→host maps, and hand-computed induced **and** non-induced counts.

| case | induced (petgraph = hand = brute) | non-induced / monomorphism (hand = brute) |
|------|-----------------------------------|--------------------------------------------|
| **P3 in triangle** | **0** | **6** (3 centres × 2 orient) |
| **P4 in C4** | **0** | 8 (drop each of 4 edges × 2) |
| **P4 in K4** | **0** | 24 (every bijection is a path) |
| **C4 in K4** (chord non-edge) | **0** | 24 |
| **diamond in K4** (missing-edge matters) | **0** | 24 |
| P3 in P4 (tree, ind=mono) | 4 | 4 |
| C4 in C4 | 8 (dihedral) | 8 |
| triangle in K4 | 24 = 4 triples × |S₃| | 24 |
| diamond in diamond | 4 = |Aut| | 4 |
| **dir 2-path in dir path** | 1 | 1 |
| **dir 2-path in reciprocal host** (0↔1,1↔2) | **0** (recip = extra edge) | 2 |
| **dir 2-path in partial-recip** (extra 2→1) | **0** | 1 |
| mutual dyad in mutual triangle | 6 | 6 |

The five bold-zero rows are the whole point: induced ≠ non-induced, and petgraph returns the
induced value. The directed reciprocal/partial cases confirm per-direction presence *and*
absence are handled correctly (a reciprocal back-edge counts as an "extra edge" that kills
the induced match, exactly as the induced definition requires).

My independent `is_induced` predicate applied on top of petgraph's output is a **no-op**
(every returned match is already induced) — corroborating that petgraph's native semantics is
induced, and that the predicate is correct should the library ever want to double-check.

## Predicates (typed/colored match) — WORK

Labelled `Graph<char,i32>`: pattern edge `A—B` weight 7 against a host with three edges
(A–B/7 match, A–B/9 colour-ok-weight-wrong, A–A/7 colour-wrong).

- no predicate: 6 raw matches (all edges, both orientations)
- colour `node_match` only: **2** (the two A–B edges, each one orientation fixed by colour)
- colour + weight `edge_match`: **1** (only A–B/7)

Predicates strictly filter, in both node and edge dimensions. Confirmed.

## Automorphism de-duplication — straightforward

petgraph yields **one mapping per pattern automorphism** (VF2 enumerates labelled
embeddings). E.g. triangle-in-K4 = 24 raw mappings = 4 distinct node-sets × |Aut(K₃)|=6;
P4-in-K4 = 24 = 12 labelled paths × 2. De-dup to distinct host **node-sets** is a one-liner
(`BTreeSet<BTreeSet<usize>>`, done in the harness) and is exact when the semantics wants
"distinct occurrences." Caveat: node-set dedup is only correct when a node-set admits a
*single* pattern placement; if a pattern can embed on the same node-set in structurally
distinct ways (e.g. path endpoints), dedup to node-sets over-collapses — dedup to
**edge-sets** (or canonical orbit) is the safe general key. For the census substrate this is
moot (it canonically labels); it matters only for the Template arm's "count distinct
instances" readout, and the library must pick node-set vs edge-set dedup deliberately.

## Residual risk

1. **Non-induced arm has no petgraph home.** The single biggest carry-forward. If
   `Induced::No` is a supported Template mode, it needs its own monomorphism enumerator;
   petgraph cannot provide it and filtering cannot recover it. Re-scope risk #4: induced =
   done, non-induced = new implementation work. (Confirm whether the seed/consumers actually
   need non-induced template matching, or only induced — census already owns induced counting.)
2. **Dedup key (node-set vs edge-set)** must be chosen per the instance semantics; node-set
   dedup silently over-collapses patterns with multiple embeddings on one vertex set.
3. **`None` vs empty:** petgraph returns `None` (not an empty iterator) when the pattern is
   larger than the host in node/edge count — the wrapper must treat `None` as "zero matches,"
   which the harness does. (An unrelated `CHANGELOG` note flags an infinite-iterator bug for
   *empty* isomorphisms in some version — worth a glance if empty patterns are ever passed.)
4. Not exercised: `StableGraph` template inputs and non-`()` typed hosts at scale — trait
   bounds (`NodeCompactIndexable + DataMap + GetAdjacencyMatrix + GraphProp + IntoEdgesDirected`)
   are satisfied by both `Graph` and `StableGraph`, so expected fine, but unverified here.
