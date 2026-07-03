# Pilot ledger report — 2026-07-03

Rebuilt deterministically from the stopped workflow's per-agent transcripts
(`~/.claude/projects/.../subagents/workflows/wf_d6369c02-8c3/`) after the writer stage was
halted for cost. See `events.jsonl` for the full record set and
[schema.md](../schema.md) for field definitions.

## Per-doc table

| doc path | candidate | verified | rejected | unverified |
|---|---:|---:|---:|---:|
| docs/introspection/log/synthesis-jan28-mar2.md | 47 | 47 | 0 | 0 |
| docs/introspection/log/daily/2026-06-11.md | 31 | 30 | 1 | 0 |
| docs/introspection/investigations/2026-05-20-whats-wrong/registry/H-MOMENTUM-LOSS.md | 18 | 17 | 1 | 0 |
| docs/introspection/log/friction-analysis-2026-03-29.md | 32 | 32 | 0 | 0 |
| docs/introspection/log/synthesis-mar10-mar16.md | 38 | 38 | 0 | 0 |
| docs/introspection/investigations/2026-05-20-whats-wrong/registry/H-DECOMPOSITION-FAILURE.md | 20 | 20 | 0 | 0 |
| docs/introspection/investigations/2026-05-20-whats-wrong/registry/H-DESIGN-CEILING.md | 19 | 19 | 0 | 0 |
| docs/introspection/log/synthesis-jan28-mar4.md | 54 | 53 | 1 | 0 |
| docs/introspection/log/synthesis-2026-05-10-2026-05-29.md | 37 | 36 | 1 | 0 |
| docs/introspection/log/sequence-analysis-2026-03-29.md | 25 | 24 | 1 | 0 |
| docs/introspection/log/synthesis-2026-04-01-2026-04-20.md | 35 | 35 | 0 | 0 |
| docs/introspection/log/synthesis-2026-05-30-2026-06-23.md | 69 | 69 | 0 | 0 |
| **Total** | **425** | **420** | **5** | **0** |

## Totals

- Candidate records: 425
- Verified: 420 (98.8%)
- Rejected: 5 (1.2%)
- Unverified: 0

12 documents were reached by the extraction stage before it was stopped; every one of
those 12 also has a completed verification pass, so this pilot ledger has no
`unverified` records. (The join logic still supports the `unverified` fallback —
`"workflow stopped before verification"` — for any future doc that reaches extraction
without a matching verification pass; this run simply didn't produce one.)

## Caveats

- **Single-repo corpus.** This pilot draws only from github-io's own
  `docs/introspection/` tree — weekly/daily logs, synthesis docs, and one investigation's
  hypothesis registry. It is not yet a cross-ecosystem sample.
- **Extraction tier: strong-tier session-inherit, deliberate reference arm.** Extraction
  ran at the calling session's own model tier (`"model": "session-inherit"`) rather than a
  cheaper stage-1-style skim model — a deliberate choice to establish a strong-tier
  reference arm before any cheaper-tier comparison is attempted.
- **Verification: single-vote, low-effort.** Each record received exactly one adversarial
  verification pass, not multi-vote consensus. Verifier notes were taken at face value;
  no second-order audit of the verifiers themselves has run.
- **Writer stage stopped for cost.** The workflow's downstream writer/synthesis stage was
  halted before running. This ledger was rebuilt deterministically from the extraction and
  verification agents' own transcripts (structured `StructuredOutput` tool calls), joined
  by exact quote-set matching per document — no model re-transcription or re-summarization
  was used to produce it.
