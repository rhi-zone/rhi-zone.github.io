# Lazy iterator vs adjacency-borrow lifetime — census-spine core signature gate

Adversarial stress of spine-adjudication.md §4 **risk 1** (the single biggest residual):
can the census core be a **lazy, borrowing** `enumerate(g, &Selector) -> impl
Iterator<Item = Instance> + '_` — yielding connected-k-subset instances *without*
materializing all instances into a `Vec` — against real petgraph 0.8.x, generic over
`Graph`/`StableGraph` × directedness × weights? And regardless of public shape, does
`count` **stream** (memory ∝ #classes / graph size, not #instances)? Mandate: break the
lazy design, not bless it.

**Verdict: BOTH gates CLOSE, with a sharpened recommendation.** A lazy borrowing
`impl Iterator + 'g` holding `&G` **compiles, runs, and is correct** on real petgraph
0.8.3 across every required flavour. `count` **streams** — measured 44–249 KiB peak live
bytes vs up to 458 MiB for the equivalent `collect`, a **4590×** difference, and peak
tracks graph size (V+E) not instance count. The recommended core primitive is a
**lazy explicit-stack `Iterator` that owns an O(V+E) adjacency snapshot**, with `count` a
streaming fold over it and `collect` a `.collect()`. The pure-borrowing `+ '_` shape is
proven *possible* but is the wrong default (reasons below).

## Build (real, not reasoned around)

Throwaway crate `lazyiter` in the session scratchpad, **petgraph 0.8.3** (fetched from
crates.io) + rand 0.8, own algorithms. Toolchain `nix run nixpkgs#cargo` (cargo 1.94).
Compiled clean, ran to completion. A **tracking global allocator** (current + peak live
bytes, `compare_exchange` peak watermark) makes the streaming claim *measured*, not
argued. Three enumerator variants were built and **cross-checked against each other**:

- **A — `EsuBorrow<G>`:** lazy explicit-stack `Iterator` that stores `g: G` (= `&Graph`)
  and calls petgraph neighbor iterators *live* inside `next()`. Exposed through the gate's
  literal target signature `fn enumerate<'g, G>(g, k) -> impl Iterator<Item=Instance> + 'g`.
- **B — `EsuOwned`:** lazy explicit-stack `Iterator` that owns an O(V+E) adjacency
  snapshot; borrows `G` only in the constructor, so its lifetime is decoupled from the graph.
- **C — `for_each_instance`:** internal iteration (recursive visitor callback). `count`
  folds it; `collect` pushes into a `Vec`.

ESU = Wernicke 2006. Canonical `ClassId` = min over k! perms of the induced upper-triangle
bitmask (same labelling verified stable/correct in k4k5-gate.md).

## Results

### [1] Does the borrowing `impl Iterator + '_` compile and produce correct output? **YES.**
It compiled with `g: G` (= `&Graph`) held in the struct across `next()` calls. Census
computed by driving the borrowing iterator matched the internal-iteration census (variant
C, independently correct) **exactly** for k=3,4,5, over `Graph<(),()>`, `StableGraph`,
`Graph<char,f64>` (weighted), all four agreeing:

```
k=3  A(Graph)==A(Stable)==A(weighted)==B(owned)==C(internal): true   classes=2  subs=290
k=4  ... true   classes=6   subs=1130
k=5  ... true   classes=21  subs=3294
```

Genericity over directedness confirmed: the borrowing iterator also compiles and runs over
`Graph<(),(),Directed>` (out-neighbors, k=3). Hand-checks via the borrowing iterator: P5
k=4 → 2×P4, P5 k=5 → 1×P5. (An initial off-by-one in A/B — computing the exclusive
neighborhood against the subset *after* adding `w` instead of before — was caught precisely
*because* the [1] cross-check against the trivially-correct recursive variant C returned
`false`; fixed, all variants now agree. Lesson: the recursive internal form is the correct
oracle; the explicit-stack form is trickier and must be tested against it.)

**Lifetime finding.** petgraph's neighbor-iterator lifetimes compose fine with holding
`&G` in the iterator struct across `next()` — multiple concurrent *immutable* borrows of
`&'g G` are legal, so nothing forces giving up the borrow. The stack frames *do* hold owned
`Vec<usize>` extension sets, but **that is algorithmic, not a lifetime failure**: ESU's
extension set is a *computed union* of exclusive neighborhoods, not any single node's raw
neighbor list, so there is no petgraph iterator to store — the set is inherently a computed
owned value in every correct implementation.

### [2] Laziness is real
`enumerate(&g, 4).take(5)` on a 120-node graph with a quarter-million instances allocated
**~1 KiB** over baseline — the live state is the explicit stack (depth ≤ k), never the
instance set. Early-exit / `.take` / composition work as expected.

### [3] Does `count` stream? **YES — measured.** peak live bytes: `count` vs `collect`
Tracking allocator, peak reset between phases; both paths asserted to see the same
instance count:

```
n=150 p=0.10 k=4  instances=  250572  count_peak=101 KiB  collect_peak= 14044 KiB  ratio= 138x
n=150 p=0.14 k=4  instances=  704781  count_peak=134 KiB  collect_peak= 53340 KiB  ratio= 397x
n=110 p=0.12 k=5  instances= 2174104  count_peak= 77 KiB  collect_peak=229423 KiB  ratio=2958x
n=130 p=0.12 k=5  instances= 4320707  count_peak= 99 KiB  collect_peak=458815 KiB  ratio=4590x
```

`count` peak stays double-digit-to-low-hundreds KiB while instances span 2.5×10⁵–4.3×10⁶;
`collect` peak grows linearly to **448 MiB**. `count` builds **no `Instance`** — the fold
receives `&[usize]`, computes the canonical label, and drops it.

### [4] Does `count` peak scale with instances? **NO — it tracks graph size.**
```
n= 80 k=4  instances=  64208  count_peak= 44 KiB
n=140 k=4  instances= 586946  count_peak=125 KiB
n=200 k=4  instances=2506505  count_peak=249 KiB
```
Instances grew **39×**; `count` peak grew **5.6×** — and that residual growth is the O(V+E)
adjacency snapshot + walk stack scaling with `n`, *not* the instance count. Streaming
confirmed: `count` memory is O(V + E + k·max_ext + #classes), never O(instances).

## The three options, weighed

| | (a) lazy borrowing `impl Iterator + '_` (A) | (b) internal iteration primitive (C) | (c) lazy `Iterator` owning O(V+E) snapshot (B) |
|---|---|---|---|
| Lazy pull / early-exit / `.take` / zip | ✅ | ❌ (control inverted — cannot yield an external iterator without re-adding a stack) | ✅ |
| `count` streams | ✅ (fold it) | ✅ (fold it) | ✅ (fold it) |
| Lifetime coupling to graph | **tied** (`+ 'g`) — can't outlive/store past the borrow | none | **none** (owns snapshot) |
| Extra memory vs the graph | none (best at 10⁸ edges *iff* O(1) probes exist) | one O(V+E) snapshot | one O(V+E) snapshot |
| Adjacency probe cost in the hot loop | O(deg) re-scan per probe **unless** an O(1) matrix exists | O(1) via snapshot | O(1) via snapshot |
| Ease of writing correctly | tricky (explicit stack; had the off-by-one) | easiest (recursion) | tricky (explicit stack) |

Critical petgraph detail that decides borrow-vs-snapshot: the only way a *borrowing*
iterator gets O(1) `is_adjacent` is `GetAdjacencyMatrix`, whose `Graph` impl materializes
an **n² `FixedBitSet`** — O(V²), catastrophic for large sparse graphs. So a borrowing
iterator at 10⁸ *sparse* edges must fall back to O(deg) neighbor re-scans per probe (variant
A's actual behaviour) — slower, and it still allocates transient sets. The O(V+E) adjacency
snapshot is the *right-sized* structure: same order as the graph itself (what FANMOD /
gtrieScanner build anyway), gives O(1) probes, and is **not** O(V²) and **not** O(instances).

## Recommended core signature

**The primitive is a lazy explicit-stack ESU `Iterator` that owns an O(V+E) adjacency
snapshot (option c). Everything else is a thin wrapper.**

```rust
// primitive: lazy, real Iterator, lifetime NOT tied to g (owns its snapshot)
fn enumerate<G>(g: G, sel: &Selector) -> EsuIter          // EsuIter: Iterator<Item = Instance>
// streaming fold over the primitive — builds no Instance; peak ∝ graph size
fn count<G>(g: G, sel: &Selector) -> Census
// motif-listing convenience — O(instances) by construction, and honestly named as such
fn collect<G>(g: G, sel: &Selector) -> Vec<Instance>      // = enumerate(g, sel).collect()
```

Why this and not the gate's literal `+ '_` borrowing shape:
1. **External `Iterator` over internal iteration (a/c over b):** `count` and `collect` are
   both trivially derivable from an external iterator (`fold`, `.collect()`), *and* the
   external form uniquely gives early-exit motif search, `.take`, streaming-to-disk, and
   zipping two censuses. Internal iteration cannot yield those without re-introducing the
   explicit stack. So the external `Iterator` is strictly more expressive — make it primary.
2. **Owning snapshot over borrowing (c over a):** the borrowing shape *works* (proven), but
   to avoid the O(V+E) snapshot it must either use the O(V²) adjacency matrix (infeasible at
   scale) or pay O(deg) re-scans per probe (slower) — and it couples the iterator's lifetime
   to the graph borrow for **no memory win** (the snapshot is the same order as the graph and
   buys O(1) probes). Decoupled lifetime is a real ergonomic gain (store it, return it,
   thread it) at negligible cost.
3. **Correctness discipline:** implement the explicit-stack primitive, but keep the
   recursive internal form as a **test oracle** — the [1] cross-check is exactly what caught
   the off-by-one. This is cheap and non-negotiable given how easy the stack version is to
   get subtly wrong.

`count` should be a *distinct* fold (not `enumerate(..).map(label).fold(..)` allocating an
`Instance` each step): it takes `&[usize]`, labels, and increments — the non-materializing
counter the spine's risk 1 demanded. Verified to allocate no `Instance` (§3).

## Residual risk

- **Not benchmarked:** the borrowing variant's throughput vs the snapshot variant (A rebuilds
  transient `HashSet`s per probe — correct but wasteful); the recommendation rests on
  complexity reasoning + the O(V²)-matrix petgraph fact, not a head-to-head timing. If a
  future need forbids *any* duplicate adjacency at 10⁸ edges, revisit A with a bespoke O(1)
  sparse probe — but that is a niche, not the default.
- **`Instance.nodes` type:** prototype uses `Vec<usize>` (index space); the shipped type
  should carry `G::NodeId` in canonical order (orbit attribution / cross-graph identity, per
  spine §1). Storing `G::NodeId: Copy` is mechanical and does not change any finding here.
- **Snapshot cost is a real 1× graph duplicate** — acceptable and standard, but it *is*
  memory the borrowing shape avoids; noted so the tradeoff isn't laundered.
- Directed-union connectivity and induced/non-induced remain as already-scoped concerns
  (settled at k=3; undirected k4/k5 in k4k5-gate.md); unchanged by this gate.

## Test code

`src/main.rs` in the scratchpad `lazyiter` crate: tracking `GlobalAlloc` (peak live bytes),
`EsuBorrow<G>` (variant A + `enumerate` returning `impl Iterator + 'g`), `EsuOwned`
(variant B), `for_each_instance` + `count` + `collect` (variant C), canonical labelling,
and the five test/measurement sections above. Built with
`nix run nixpkgs#cargo -- run --release`.
