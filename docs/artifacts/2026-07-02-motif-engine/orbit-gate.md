# Per-node orbit attribution gate (GDV / GDD) — undirected k≤5

Adversarial stress of spine-adjudication.md §4 (orbit layer, flagged in k4k5-gate.md
"What is covered vs. what is a further gate"): from the census pass
(`Instance.nodes` in canonical order + `ClassId`), can we correctly attribute **each
node in each subgraph instance to its automorphism ORBIT** within that graphlet, and
accumulate a correct **73-entry Graphlet Degree Vector (GDV)** per node? Mandate: try
to BREAK it, not bless it.

**Verdict: GATE CLOSES for orbit attribution at k≤5 undirected, all 73 orbits.** The
census-based per-node GDV equals an independent brute-force per-node oracle
**node-for-node** on paths, cycles, stars, K4, K5, K6, and 12 fuzzed random G(n,p)
graphs across seeds/densities — zero mismatches. It is additionally consistent with the
independently-computed class census (`Σ_v GDV[v][o] = class_count · orbit_size` for all
73 orbits), stable under node-relabelling / `StableGraph`, and matches hand-verified
GDVs (K3, C5, K5). Attribution overhead on top of the class-census pass is **~1.01×
(negligible)** — confirming the k4k5 gate's "cheap and addable" flag. Scale is
**not** in scope here: the dominant cost is the ESU + canonical-labelling pass itself,
which is the separate deferred scalable-k=5 gate; orbit attribution adds essentially
nothing to it.

## Build (real, not reasoned around)

Throwaway crate `orbitgate` in the session scratchpad, **petgraph 0.8.3** (fetched from
crates.io) + rand 0.8, own algorithms; toolchain `nix run nixpkgs#cargo` (cargo 1.94).
Compiled clean, ran to completion. Reuses the k4k5-gate primitives (`adjacency<G>`
generic boundary, Wernicke-2006 ESU, brute canonical labelling) and adds the orbit
layer.

### How attribution works (the mechanism under test)

1. **Registry (built once).** For each connected class k=2..5 (the 30 graphlets),
   compute the automorphism group (perms preserving the induced adjacency) and reduce
   to a node-orbit partition by union-find — the exact machinery that reproduced 73 in
   k4k5-gate.md. Assign a global orbit id per (class, local-orbit) in a stable order.
   Result: **73 global orbits, per-k breakdown 1 / 3 / 11 / 58 — reproduced from
   scratch, matching Pržulj/ORCA.**
2. **Attribution per instance.** `canonical_arg` returns not just the `ClassId` (min
   upper-triangle bitmask over k! perms) but the arg-perm — a witnessing isomorphism
   from the instance to the canonical representative. Canonical slot `c` is filled by
   instance node `sub[arg[c]]`; that node's orbit is `registry[class].slot_orbit[c]`.
   **Key correctness fact:** the arg-perm is not unique (it varies by an automorphism of
   the canonical graph), but orbit id is automorphism-invariant, so any minimizing perm
   yields the same orbit — attribution is well-defined regardless of which perm the
   canonicalizer happens to pick, and regardless of `Instance.nodes` ordering.
3. **Accumulate.** One ESU pass over connected k-subsets (k=2..5); for each instance,
   increment `GDV[node][orbit]` for all k members.

## Results

### [ADVERSARIAL CORE] spine GDV == independent brute-force oracle — ALL PASS

The oracle does **not** share the enumeration path: for each node v it enumerates every
size-(k) subset containing v by **combinations over all other nodes** (C(n-1,k-1)), then
filters to connected, canonicalizes, and tallies v's orbit — a completely different
walk from ESU's connected-subset expansion. Equality therefore tests both that ESU
enumerates each connected k-subset **exactly once** (no dup / no miss across all k
members) and that attribution is order-independent.

```
P6, P8 paths .............. OK        C5, C7, C10 cycles ........ OK
star K1,5, K1,7 ........... OK        K4, K5, K6 ................ OK
G(n,p) fuzz: 12 graphs, n=9..13, p=0.25..0.46, seeds 0..11 ... ALL OK
==> oracle cross-check: ALL PASS   (every node × 73 orbits identical)
```

Any single mismatch would have printed the node, orbit, and the offending
(k, class, orbit-size) to localize the break. None occurred.

### [class-census tie] GDV consistent with the independent class census — PASS

For every one of the 73 orbits, `Σ_v GDV[v][orbit] == class_count(class) · orbit_size`
on a random G(14, 0.35) graph, where `class_count` is the aggregate class census
computed by a **separate** ESU fold (the spine's own readout, no orbit machinery). This
ties the per-node layer back to the already-validated aggregate census: each class-C
instance contributes exactly `orbit_size` node-attributions to each of C's orbits. All
73 consistent. This guards against a systematic attribution bug that the oracle (which
shares the attribution function) could not catch.

### [stability] GDV is a relabelling-invariant per-node signature — PASS

Same logical graph built as `Graph` and as `StableGraph` with **reversed** node-insertion
order. Per-node GDV identical up to the node relabelling — the GDV of a node depends only
on its structural role, not its `NodeIndex`.

### [external ground truth] hand-verified GDVs — PASS

| graph | node | verified values |
|---|---|---|
| K3 (triangle) | any | edge-orbit = 2, triangle-orbit = 1 |
| C5 (5-cycle) | any (vertex-transitive → all identical) | edge = 2, P3-center = 1, P3-end = 2 |
| K5 | any (vertex-transitive → all identical) | edge = 4, triangle = C(4,2)=6, K4 = C(4,3)=4, K5 = 1 |

All assertions hold. **Note on ORCA numbering (honest scope):** I did **not** verify
against a fetched copy of the published ORCA/Pržulj 73-orbit table. The global ids here
are an internal, stable numbering (assigned by k then canonical-bitmask order). It
coincidentally matches ORCA on o0 (edge) and o3 (triangle) but *not* in general — e.g.
this numbering puts P3-center at o1 and P3-end at o2, whereas ORCA's convention is the
reverse. Aligning to ORCA's exact ids is a mechanical fixed permutation (a lookup table),
**not** a correctness question — orbit *identity and attribution* are what this gate
proves, via the oracle + class-census tie + hand values, not the id labels. If a shipped
API must emit ORCA-numbered vectors, add the permutation table and gate it against ORCA's
published GDV for one reference graph.

### [cost] orbit attribution overhead — ~1.01× (negligible)

| n | p | edges | subs(k2..5) | class-only | full-GDV | overhead |
|---|---|---|---|---|---|---|
| 60 | 0.15 | 254 | 179,066 | 1.5 s | 1.5 s | 1.01× |
| 80 | 0.12 | 394 | 476,167 | 4.1 s | 4.1 s | 1.01× |
| 100 | 0.10 | 515 | 788,289 | 7.0 s | 7.0 s | 1.01× |

Confirms k4k5-gate.md's flag: orbit attribution is **cheap and addable**. The
`canonical` pass already computes the min-perm; taking the arg-perm and doing k
increments per instance is free relative to the k! canonicalization. The wall-clock is
dominated by ESU + per-subset canonical labelling — i.e. **the same cost as the class
census**, which is the *separate deferred scalable-k=5 perf gate* (k4k5-gate §6: naive
per-subset canonicalization is untenable at biological scale; needs ORCA orbit-equation
counting / g-trie). This gate does not touch that; it proves attribution is correct and
free *given* the census pass.

## What is covered vs. what remains

- **Per-node orbit attribution → 73-entry GDV (undirected k≤5):** CLOSED. Correct
  (oracle node-for-node), consistent with class census, stable, hand-verified.
- **GDD (graphlet degree distribution):** trivially follows — GDD[orbit] is the
  distribution of `GDV[·][orbit]` over nodes; nothing new to gate once per-node GDV is
  correct.
- **Scalable k=5 at biological scale:** OUT of scope (separate deferred gate). Naive
  canonicalization cost is inherited from the census pass, unchanged by attribution.
- **Directed orbits:** OUT of scope by design (deferred).
- **ORCA-exact orbit ids:** a mechanical permutation-to-published-table, not built here;
  internal numbering is stable and sufficient for the kernel/GDD rim.

## Meaning for the GDD / graphlet-kernel rim

The graphlet-kernel rim's per-node arm (graphlet degree signatures, GDV/GDD-based node
descriptors, GDD-agreement graph similarity) rests on exactly this attribution layer.
It is now proven correct and effectively **free** on top of the census pass the spine
already centers on — `Instance.nodes` in canonical order (spine §1) is the *only* thing
the layer needs from the substrate, and it is sufficient (the arg-perm is recomputed at
attribution time, not stored). The rim is therefore **unblocked for GDV/GDD and per-node
graphlet signatures at k≤5 undirected**, with the single remaining dependency being the
already-named scalable-k=5 counter (ORCA/g-trie) for biological-scale graphs. Nothing
here forecloses or reshapes the spine; it confirms the orbit layer is a thin, correct,
cheap consumer of the census pass.

## Test code

`src/main.rs` in the scratchpad `orbitgate` crate: `build_registry` (automorphism →
union-find orbit partition → 73 global ids), `canonical_arg` (ClassId + witnessing
arg-perm), `gdv_spine` (single ESU pass, attribute all k members), `gdv_oracle`
(independent per-node combination enumeration), the class-census tie, stability
(Graph vs reversed-order StableGraph), hand-verified GDV asserts, and the cost harness.
Built with `nix run nixpkgs#cargo -- run --release`.
