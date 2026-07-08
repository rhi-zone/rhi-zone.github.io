# Graphlet

**Petgraph-native graphlet analysis and small-subgraph structural mining.**

::: info Status: Fleshed Out ◐
The full rim from ADR-0290 is implemented and heavily verified: subgraph census with canonical labelling up to 5 nodes, per-node graphlet degree vectors and distribution across all 73 orbits with a fast ORCA-style counter (verified exact, roughly 100x faster at k=5 than the naive counter), a named + registerable motif catalog with arbitrary-pattern counting, both induced and non-induced (monomorphism) template matching, null-model generators (configuration model, double-edge-swap, Watts-Strogatz, and a documented-partial LFR), significance testing (z-scores, empirical p-values, significance profiles), neighborhood statistics (link prediction, clustering, assortativity, rich-club), graph kernels (Weisfeiler-Lehman, shortest-path, graphlet), and directed graphlets/orbits through k=5 plus the 16-type directed triad census. Depends only on petgraph and rand. Not yet published to crates.io or used outside the ecosystem.
:::

Graphlet works directly on petgraph's graph types to enumerate, count, and classify the small connected subgraphs (graphlets) that appear in a network, describe each node by the orbits it participates in, test structural significance against null models, and compare graphs via structure-aware kernels.

## Key features

- **Subgraph census** — Enumerate and count connected induced subgraphs up to 5 nodes, with canonical isomorphism-class labelling.
- **Graphlet degree vectors** — Per-node GDV and graph-wide GDD across all 73 orbits, via a fast ORCA-style counter verified exact against the naive counter.
- **Motif catalog** — Named and user-registerable motifs, plus arbitrary-pattern counting.
- **Template matching** — Both induced and non-induced (monomorphism) matching of arbitrary templates via petgraph's VF2.
- **Null models** — Configuration model, double-edge-swap rewiring, Watts-Strogatz, and a documented-partial LFR generator.
- **Significance testing** — Z-scores, empirical p-values, and significance profiles against null-model ensembles.
- **Neighborhood statistics** — Link prediction, clustering, assortativity, rich-club.
- **Graph kernels** — Weisfeiler-Lehman, shortest-path, and graphlet kernels.
- **Directed graphlets** — Directed graphlets and orbits through k=5, plus the 16-type directed triad census.
- **Petgraph-native** — Generic over petgraph `Graph` and `StableGraph`; depends only on petgraph and rand.

## Verification

Backed by 110 tests and three independent adversarial re-audits, which found the counting core sound and confirmed the ORCA-style counter clean-room versus the GPL reference implementation.

## Remaining scope

Genuinely open: LFR is a documented partial implementation; exact k=5 enumeration and directed k=5 are computationally slow; graphlets are bounded to k<=5. Not yet published to crates.io.

## Links

- [GitHub](https://github.com/rhi-zone/graphlet)
- [Documentation](https://rhi.zone/graphlet/)
