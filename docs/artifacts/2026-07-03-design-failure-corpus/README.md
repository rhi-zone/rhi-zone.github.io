# Design-failure evidence corpus — pipeline scaffolding

Design-only scaffolding for an evidence-mining pipeline. Output supports a planned essay:
evidence-grounded boundaries of what LLM coding agents can and cannot design, mined from
this ecosystem's introspection logs, postmortems, and ADRs. No mining has run yet; no
scripts exist yet. Companion docs: [schema.md](schema.md) (record + index schemas),
[hypotheses.md](hypotheses.md) (falsifiability-first hypothesis register).

## Privacy rule (read first)

Evidence records quoting **raw session transcripts** are **quarantined machine-local**
until checked against the private-names denylist (`.git/info/private-names`). Only records
sourced from **already-public docs** may be committed to this directory. No exceptions:
a quarantined record enters the committed ledger only after passing the denylist check.

## Corpus policy: distilled docs are the map

The corpus of record is the distilled layer — `docs/introspection/` (weekly/daily logs,
syntheses), postmortems, ADRs, open-threads registries, across ecosystem repos. These are
the MAP, and they are **lossy by construction**: distilled from individual days, they
compress and drop detail. Consequently:

- Load-bearing quotes are fetched by **targeted seeks into raw session transcripts at
  marked spots only** — a distilled doc names an event, the seek retrieves the verbatim
  ground truth for that event.
- **Full transcript scans never happen.** The distilled layer decides where to look; raw
  transcripts are random-access ground truth, never a scan target.

## Pipeline design (settled)

- **Stage 0 — deterministic pre-filter.** ripgrep over the corpus for failure/decision
  markers: `revert`, `postmortem`, `fail`, `oscillat`, `override`, `"did not converge"`,
  session ids, project names. Shrinks the model-read set; no model involvement.
- **Stage 1 — cheap-model skim/classify.** A cheap model skims stage-0 survivors and
  classifies them (relevant / irrelevant / which hypotheses plausibly touched).
- **Stage 2 — extraction.** Extraction agents run over small chunks and emit structured
  evidence records ONLY (per [schema.md](schema.md)) — no conclusions, no synthesis, no
  editorializing in the record.
- **Stage 3 — refuter-pass verification.** Every record is verified against its source:
  the quote exists verbatim; the surrounding context is not distorted by the excerpting.
  **Nothing unverified flows downstream.**
- **Stage 4 — deterministic aggregation.** Counts, timelines, per-project inventories —
  computed in code over verified records, not by a model.
- **Stage 5 — synthesis.** Drafts may only make claims that cite verified record IDs.
  The user is the final arbiter: conclusions are certified by the user, not by the
  pipeline.

### Cross-cutting design

- **Index-once / query-many.** The first pass emits a compact structured index (see index
  schema in [schema.md](schema.md)); every later pass seeks into the index, never
  re-scans the corpus.
- **Append-only JSONL ledger, keyed by source content hash.** Re-runs are incremental and
  convergent: unchanged sources are skipped by hash; changed sources produce new entries;
  nothing is rewritten in place.
- **Effort tiering.** Cheap model for stage-1 skim; strong model only for stage-2
  extraction and stage-3 cited-record verification.

## Cost design

Cost is controlled structurally, not by hoping runs stay small:

- Stage 0 is free (ripgrep) and eliminates the bulk of the corpus before any model reads.
- Stage 1 uses the cheapest viable model on the reduced set; only its survivors reach the
  strong model.
- Strong-model spend is confined to stages 2–3, over small chunks, and only where stage 1
  flagged relevance.
- Index-once/query-many means corpus-scale reads happen once; the hash-keyed ledger means
  re-runs pay only for deltas.
- Stages 4 and (partially) 5 are deterministic code / user judgment, not model spend.
- Transcript access is targeted seeks only — the most expensive source class is never
  scanned.
