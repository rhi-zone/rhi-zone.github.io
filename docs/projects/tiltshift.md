# tiltshift

**Iterative structure extraction from opaque binary data.**

::: info Status: Growing ◔
28 commits, 21 Rust files. Signal detection pipeline with chi-square uniformity, alignment map, TLV sequence, padding run, and ngram frequency detectors. Core architecture in place, expanding signal coverage.
:::

tiltshift progressively uncovers the structure of binary formats through signal analysis. each pass informs the next, converging on a structural model of whatever you feed it — without needing to know what the format is in advance.

## Key features

- **Signal extraction** — chunk boundaries, magic bytes, length-prefixed fields, encoding patterns, alignment, byte frequency, ngram analysis
- **Iterative refinement** — partial structure feeds back into analysis, narrowing unknowns with each pass
- **Multi-file correlation** — diff structural models across samples to separate data fields from structural fields
- **Known format corpus** — feed known formats (PNG, ZIP, ELF) to build a reference library; use it to identify fragments in unknown data
- **Agent-friendly output** — rich diagnostic output with confidence scores and reasoning, not just parse success/failure

## Use cases

- Reverse engineering unknown or undocumented binary formats
- Anomaly detection — feed a known format, find what doesn't fit
- Building format corpora for use by paraphase and reincarnate
- Validating that a file matches an expected structural schema

## Related projects

- [Paraphase](/projects/paraphase) - format conversion route planner (needs format understanding as input)
- [Reincarnate](/projects/reincarnate) - legacy lifting (opaque binary formats are a primary blocker)
- [Rescribe](/projects/rescribe) - document conversion (tiltshift handles unknown document formats)

## Links

- [GitHub](https://github.com/rhi-zone/tiltshift)
