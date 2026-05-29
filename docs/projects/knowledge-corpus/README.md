# Knowledge Corpus — Design Docs

> **INTERIM HOME** — This is a `pterror`-account project (not rhi-zone). These design
> docs live here as an interim durable home; relocate to the corpus repo on
> `github:pterror` once it is named and created. **Project name: TBD.**

**Status:** Concept/design stage. See [ADR-0001](../../decisions/0001-knowledge-corpus-foundations.md) for the settled decisions and the open questions.

---

## Project summary

A unified omnimedia knowledge corpus: richly interlinked, richly annotated structured knowledge, with the explicit ambition to be the best of its kind. The corpus itself is the product — not a learning-path engine, not a prose wiki, not a bare triple store. It bridges the two camps nobody currently bridges: structured-knowledge players (Wikidata, Wolfram) that are not pedagogical, and pedagogical-content players (Khan Academy, Crash Course) that are not structured or queryable.

Key design choices: **document-native, no-blessed-metadata format** (entity-per-file JSON, RDF-star semantics, open key/value bag); **domains as lenses** over one shared entity set (software, finance, law, medical all coexist with zero schema changes); **projection via Dusklight** (rhi-zone substrate, configurable data-driven views, Marinada query language); and **corpus-is-the-product** (per-domain "readers" are Dusklight view configurations, not separate codebases). All LLM use is construction-time and amortized; query/render logic is deterministic.

---

## Design docs in this directory

| File | Contents |
|---|---|
| [design-overview.md](./design-overview.md) | Master plan / design spine — context, prior art map, reuse verdict, architecture, settled decisions, open questions |
| [format-spec.md](./format-spec.md) | Final substrate/format specification — the implementable contract for the document-native no-blessed-metadata JSON format and its RDF-star export mapping |
| [annotation-schema.md](./annotation-schema.md) | Annotation/topic-ontology layer — omnimedia explainers, claim→node citation with construction-time verification, `@topic:*` ontology; pressure-tested against the actual validator source |
| [dusklight-binding.md](./dusklight-binding.md) | Projection layer — Dusklight corpus binding and the four config-driven gap closures required to make "domain reader = config/data" actually work |
| [format-options.md](./format-options.md) | Format options and rationale that led to the spec — retained as the reasoning trail; superseded by `format-spec.md` |

Foundational decisions: [ADR-0001](../../decisions/0001-knowledge-corpus-foundations.md)
