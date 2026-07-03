# Design-failure evidence corpus — pipeline scaffolding

Design-only scaffolding for an evidence-mining pipeline. Output supports a planned essay:
evidence-grounded boundaries of what LLM coding agents can and cannot design, mined from
this ecosystem's introspection logs, postmortems, and ADRs. No mining has run yet; no
scripts exist yet. Companion docs: [schema.md](schema.md) (event record + mapping table +
index schemas — the only file miners see), [hypotheses.md](hypotheses.md)
(pre-registered hypothesis register — orchestration-side only, context-fenced).

## Containment rule (read first, with the privacy rule)

Mining agents (pre-filter support, skim, extraction, induction) receive **ONLY
[schema.md](schema.md) and their assigned chunk** — nothing else. This README and
hypotheses.md are both **orchestration-side documents**: they are read by the
orchestrator, the post-hoc matching stage, and the human arbiter, and never enter a
miner's context. schema.md is kept theory-neutral for exactly this reason.

## Methodology note — pre-registration + blind extraction

The hypotheses are pre-registered (committed before any mining) and extraction is blind
(miners record neutral descriptive events, never hypothesis matches). Why: three
same-session demonstrations showed that a frame present in a reader's context gets found
in the data — a reader primed with a theory reliably "discovers" that theory in whatever
it reads. Blinding the miners and matching only post-hoc, on a verified ledger, is what
makes support or refutation evidential rather than confirmation harvesting. Divergence
between what the data induces bottom-up and what was pre-registered is a first-class
result, not a failure of the run.

## Privacy rule

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

- **Stage 0 — deterministic pre-filter + random-sample arm.** ripgrep over the corpus
  with a broadened, theory-neutral marker list: decision, design, rename, revert,
  postmortem, fail, success, ship, complete, cost markers, plus session ids and project
  names. Shrinks the model-read set; no model involvement. PLUS a **random-sample arm**:
  a stratified random sample of unmarked docs is always included, to estimate base rates
  — the denominator for any clustering claim.
- **Stage 1 — cheap-model skim/classify.** A cheap model skims stage-0 survivors and
  classifies them (relevant / irrelevant) — no theory-flavored labels.
- **Stage 2 — BLIND extraction.** Extraction agents run over small chunks and emit
  neutral structured EVENT records ONLY (per [schema.md](schema.md)): descriptive events
  with a neutral `event_type` vocabulary. Agents receive the event schema and their
  chunk, never the hypotheses (see containment rule) — no conclusions, no synthesis, no
  editorializing in the record.
- **Stage 3 — refuter-pass verification.** Every record is verified against its source:
  the quote exists verbatim; the surrounding context is not distorted by the excerpting.
  **Nothing unverified flows downstream.**
- **Stage 4 — deterministic aggregation.** Counts, timelines, per-project inventories —
  computed in code over verified records, not by a model.
- **Stage 5 — bottom-up pattern induction.** Induction agents see the verified ledger
  ONLY (no sight of hypotheses.md) and cluster recurring patterns into an **induced
  taxonomy** of what the record actually shows.
- **Stage 6 — post-hoc hypothesis matching.** Orchestration-side: the verified ledger
  plus hypotheses.md, producing the mapping table ([schema.md](schema.md)) — every
  mapping auditable against its quoted record.
- **Stage 7 — comparison and certification.** The induced taxonomy is compared against
  the pre-registered hypothesis register, arbitrated and certified by the user.
  Divergence between induced and pre-registered structure is a first-class result.
  Synthesis/essay drafts may only make claims that cite verified record IDs; conclusions
  are certified by the user, not by the pipeline.

### Cross-cutting design

- **Index-once / query-many.** The first pass emits a compact structured index (see index
  schema in [schema.md](schema.md)); every later pass seeks into the index, never
  re-scans the corpus.
- **Append-only JSONL ledger, keyed by source content hash.** Re-runs are incremental and
  convergent: unchanged sources are skipped by hash; changed sources produce new entries;
  nothing is rewritten in place.
- **Effort tiering.** Cheap model for stage-1 skim; strong model only for stage-2
  extraction, stage-3 cited-record verification, and stages 5–6 induction/matching.

## Cost design

Cost is controlled structurally, not by hoping runs stay small:

- Stage 0 is free (ripgrep) and eliminates the bulk of the corpus before any model reads;
  the random-sample arm adds a small fixed-size increment, not a corpus scan.
- Stage 1 uses the cheapest viable model on the reduced set; only its survivors reach the
  strong model.
- Strong-model spend is confined to stages 2–3 (small chunks, only where stage 1 flagged
  relevance) and stages 5–6 (ledger-sized inputs, far smaller than the corpus).
- Index-once/query-many means corpus-scale reads happen once; the hash-keyed ledger means
  re-runs pay only for deltas.
- Stage 4 and stage 7 are deterministic code / user judgment, not model spend.
- Transcript access is targeted seeks only — the most expensive source class is never
  scanned.
