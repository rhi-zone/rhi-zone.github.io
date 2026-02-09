# Motif

**Structural exploration of mathematics across fields and representations.**

::: info Status: Sketch ○
Initial scaffolding. No implementation yet.
:::

Motif treats mathematics as a graph of structural relationships rather than a tree of fields. It extracts invariants from existing math, detects recurring structural patterns (motifs) across domains, and enables cross-field translation by normalizing to shared intermediate representations.

## Key ideas

- **Math as graph** — Fields are clusters in a structure graph, not branches of a tree. Boundaries are historical artifacts, not structural necessities.
- **Layered IRs** — No single "true" representation. Multiple IR layers (surface DSL → structural IR → semantic core), like a compiler pipeline for mathematics.
- **Cross-field translation** — Remove artificial restrictions between disciplines. Tools transfer even when formulas don't.
- **Structural motifs** — Recurring patterns (symmetry, duality, optimization, composition) are the high-degree hubs in the math graph.
- **Pruned search** — The interesting manifold in idea-space is measure-zero. Discovery is navigation, not enumeration.

## Architecture

```
human math DSLs (notation, conventions, field-specific idioms)
  → structural IR (invariants, transformations, relationships)
    → semantic core (interchangeable minimal foundations)
```

Each layer preserves meaning while exposing different structure. Translation happens above the core. The core ensures coherence.

## Links

- [GitHub](https://github.com/rhi-zone/motif)
