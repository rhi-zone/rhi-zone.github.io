# k=4 / k=5 residual gate — ESU + canonical labelling (undirected)

Adversarial stress of the census spine's load-bearing residual (spine-adjudication.md §4
risk 2): does `enumerate-connected-k-subsets → canonical-label → fold` stay **stable** and
**correct** at k=4 and k=5? k=3 was already proven. Mandate: try to break it.

**Verdict: GATE CLOSES for class labelling at k=4 AND k=5 (undirected).** Stable, correct
class counts, exact on every hand-computed graph. Per-node **orbit attribution** (needed for
GDD/GDV) is a *further, uncovered* gate — class labelling alone does not attribute orbits,
though the orbit machinery is cheap and was verified to reproduce the canonical 73. Naive
per-subset canonical labelling is fine at k=4 and modest k=5, but blows up at k=5 on larger
graphs — a smarter scheme (ORCA orbit-equations / g-trie) is needed at biological scale.

## Build (real, not reasoned around)

Throwaway crate `k4k5` in the session scratchpad, **petgraph 0.8.3** (fetched from
crates.io) + rand 0.8, own algorithms. Toolchain `nix run nixpkgs#cargo` (cargo 1.94).
Compiled clean, ran to completion. ESU = Wernicke 2006 (each connected k-subset enumerated
exactly once). Canonical `ClassId` = min over all k! vertex permutations of the packed
upper-triangle adjacency bitmask of the induced subgraph (24 perms at k=4, 120 at k=5).
Genericity lives at an adjacency-extraction boundary (`adjacency<G>` over
`IntoNodeIdentifiers + IntoNeighbors + NodeIndexable + NodeCount + Copy`), exercised against
both `Graph` and `StableGraph` (undirected).

## Results

### [1] Ground-truth class counts — exhaustive, independent of ESU
Enumerated ALL 2^C(k,2) labelled graphs on k nodes, kept connected, canonicalized, counted
distinct classes. Result: **k=2→1, k=3→2, k=4→6, k=5→21** — exactly the established
connected-graphlet taxonomy (Pržulj's 30 graphlets = 1+2+6+21). Canonical labelling neither
merges nor splits classes.

### [2] Orbit count — 73 VERIFIED (not assumed)
For every connected class, computed the automorphism group (adjacency-preserving perms) and
reduced to node orbits by union-find. Sum over k=2..5: **1 + 3 + 11 + 58 = 73**, matching
Pržulj/ORCA (orbit ids 0–72). The claimed number checks out against an independent
computation, not a citation.

### [3] Stability fuzz — PASS
n=16 random dense graph (p=0.5). 40 random permuted node-insertion orders × {`Graph`,
`StableGraph`} at each of k=4 and k=5. Per-class census (keyed by `ClassId`) **identical
every time**: k=4 = 6 classes / 1130 subs; k=5 = 21 classes / 3294 subs. Isomorphic subsets
receive the same `ClassId` regardless of internal `NodeIndex` assignment. No divergence.

### [4] Correctness on dense random graphs — PASS
G(n,0.5) for n ∈ {20,24,28}: census exhibits **exactly** the ground-truth class set at both
k=4 (6/6) and k=5 (21/21) — missing=0, extra=0, set-equal in all cases.

### [5] Validation on known small graphs — all match hand computation
| graph | k | census | check |
|---|---|---|---|
| P5 | 4 | 2× P4 | remove either end → 2 connected 4-paths ✓ |
| P5 | 5 | 1× P5 | ✓ |
| C5 | 4 | 5× P4 | drop any 1 of 5 vertices → path ✓ |
| C5 | 5 | 1× C5 | ✓ |
| star K1,4 | 4 | 4× claw K1,3 | C(4,3) leaf choices ✓ |
| star K1,4 | 5 | 1× K1,4 | ✓ |
| K4 | 4 | 1× K4 | ✓ |
| K5 | 4 | 5× K4 | C(5,4) ✓ |
| K5 | 5 | 1× K5 | ✓ |

(Note: K_n induced k-subsets are all K_k — a single class — so K5/K6 are *not* dense enough
to exhibit all classes; that role is filled by the random dense graphs in [4].)

### [6] Cost — naive per-subset canonical labelling
| n | p | edges | k | #subs | time |
|---|---|---|---|---|---|
| 30 | 0.3 | 128 | 4 | 5,583 | 8 ms |
| 30 | 0.3 | 128 | 5 | 33,143 | 309 ms |
| 50 | 0.2 | 245 | 5 | 165,245 | 1.4 s |
| 100 | 0.1 | 502 | 4 | 54,113 | 90 ms |
| 100 | 0.1 | 502 | 5 | 662,648 | 5.8 s |

k=4 is comfortable everywhere tested. k=5 cost is dominated by connected-subset count ×
120 permutations/subset and grows fast: ~660k subsets → ~6 s. On a real biological network
(thousands of nodes, sparse), k=5 subset counts run to 10^7–10^9 and naive canonicalization
is untenable. This is expected and matches the literature's motivation for ORCA
(orbit-equation counting — no per-subset canonical form) and g-trie symmetry-breaking.

## What is covered vs. what is a further gate

- **Class labelling (per-subgraph `ClassId`):** CLOSED at k=3 (prior), **k=4, k=5** (here).
  Stable, correct, exact. This is the census-substrate readout the spine centers on.
- **Per-node ORBIT attribution (GDV/GDD):** NOT covered by class labelling. Census yields
  "this subset is class C"; orbits require, per instance, mapping each *node* to its orbit
  within C's automorphism partition. The machinery is cheap (orbit partition per class,
  computed here → 73) and the spine keeps `Instance.nodes` in canonical order, so it is
  *addable* — but it is a **distinct implementation layer and a further prototype gate**,
  not something the k=4/k=5 class result delivers for free.
- **Directed k=4/k=5:** OUT of scope by design — directed motif taxonomy explodes; v1 +
  biology rim lead with undirected graphlets + directed-triads-at-k=3 (proven). Deferred.
- **Cost at scale:** naive canonicalization is a k=5-at-scale gate. Acceptable for k=4 and
  small/medium k=5; needs ORCA/g-trie before locking a scalable k=5 counter.

## Meaning for the graphlet rim

The graphlet-census rim (graphlet kernel, graphlet-degree signatures, orbit-based GDD) rests
on exactly this pass. The **class-census half is now proven correct and stable up to k=5** —
the taxonomy (30 graphlets) and the orbit number (73) both reproduced from scratch. The rim
is therefore *unblocked for graphlet class census and graphlet-kernel feature vectors* at
k≤5 undirected. GDV/GDD (per-node orbit vectors) needs the orbit-attribution layer built and
gated separately, and a scalable k=5 counter (ORCA-style) is required before the rim claims
biological-scale graphs. Nothing here forecloses the spine shape; it confirms it and sharpens
two residuals into named next gates.

## Test code

`src/main.rs` in the scratchpad `k4k5` crate: `adjacency<G>` (generic boundary), `esu` +
`extend` (Wernicke ESU), `perms`/`canonical`/`mask_of` (brute canonical form), `census<G>`
(ESU→label→fold), `all_connected_classes` (exhaustive ground truth), `orbit_count`
(automorphism→union-find orbits), permuted-order builders for `Graph` and `StableGraph`, and
the six test sections above. Built with `nix run nixpkgs#cargo -- build --release`.
