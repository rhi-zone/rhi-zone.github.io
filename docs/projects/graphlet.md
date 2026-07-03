# Graphlet

**Petgraph-native graphlet analysis and small-subgraph structural mining.**

::: info Status: Growing ◔
A verified, tested, polished core exists; the broader feature set is planned. Implemented today: enumerate and count connected induced subgraphs (census) up to 5 nodes on undirected simple graphs, canonical class labelling, per-node graphlet degree vectors and their distribution across all 73 orbits (GDV/GDD), named-motif detection (diamonds, both induced and non-induced), and induced arbitrary-template matching via petgraph's VF2. Generic over petgraph `Graph` and `StableGraph`. Planned (per ADR-0290): significance testing / z-scores, null-model generators, graph kernels, neighborhood statistics (link-prediction, assortativity, rich-club), scalable k=5, and directed graphs at k≥4.
:::

Graphlet works directly on petgraph's graph types to enumerate, count, and classify the small connected subgraphs (graphlets) that appear in a network, and to describe each node by the orbits it participates in.

## Key features

- **Subgraph census** — Enumerate and count connected induced subgraphs up to 5 nodes on undirected simple graphs.
- **Canonical labelling** — Assign each subgraph to its canonical isomorphism class.
- **Graphlet degree vectors** — Per-node GDV and graph-wide GDD across all 73 orbits.
- **Named-motif detection** — Detect named motifs such as diamonds, both induced and non-induced.
- **Template matching** — Induced matching of arbitrary templates via petgraph's VF2.
- **Petgraph-native** — Generic over petgraph `Graph` and `StableGraph`.

## Planned

Per ADR-0290, the following are designed but not yet implemented: significance testing / z-scores, null-model generators, graph kernels, neighborhood statistics (link-prediction, assortativity, rich-club), scalable k=5, and directed graphs at k≥4.

## Links

- [GitHub](https://github.com/rhi-zone/graphlet)
- [Documentation](https://rhi.zone/graphlet/)
