# Schemas — evidence records and corpus index

Both are JSONL: one object per line, append-only. See [README.md](README.md) for ledger
semantics (hash-keyed, incremental/convergent) and the privacy rule on transcript-sourced
records.

## Evidence record

One record = one verbatim quote bearing on one or more hypotheses. Records carry
evidence only — never conclusions.

| field | type | meaning |
|---|---|---|
| `id` | string | unique record id (stable across re-runs) |
| `hypothesis_ids` | list of string | hypotheses this record bears on (e.g. `["H2", "H4"]`) |
| `stance` | enum | `supports` \| `refutes` \| `complicates` |
| `quote` | string | verbatim quote from the source — no paraphrase, no ellipsis-splicing that changes meaning |
| `source` | object | `{ "path": string, "lines": [start, end] }` |
| `session_id` | string or null | session id, if the source names one |
| `date` | string | ISO date of the underlying event (not of extraction) |
| `project` | string | project the evidence concerns |
| `extraction` | object | `{ "model": string, "agent_id": string }` |
| `verification` | object | `{ "status": "unverified" \| "verified" \| "rejected", "verifier_note": string }` |
| `notes` | string | extractor context notes — descriptive only, no conclusions |

Lifecycle: records are born `unverified` (stage 2), and become `verified` or `rejected`
in stage 3. Only `verified` records are visible to stages 4–5.

## Index entry

One entry per corpus document, emitted by the first pass (index-once/query-many).

| field | type | meaning |
|---|---|---|
| `path` | string | doc path (repo-relative, prefixed with repo for cross-repo corpus) |
| `content_hash` | string | hash of doc content at indexing time — the ledger key |
| `date_range` | [string, string] | ISO date range the doc covers |
| `projects` | list of string | projects mentioned |
| `event_markers` | list of object | `{ "marker": string, "line": int, "descriptor": string }` — which stage-0 marker hit, where, and a one-line descriptor of the event |
