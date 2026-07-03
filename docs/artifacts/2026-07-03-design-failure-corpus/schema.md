# Schemas — event records, mapping table, corpus index

All are JSONL: one object per line, append-only. See [README.md](README.md) for ledger
semantics (hash-keyed, incremental/convergent) and the privacy rule on transcript-sourced
records. This file is the ONLY document handed to mining agents (plus their chunk); it is
deliberately theory-neutral.

## Event record

One record = one verbatim quote documenting one descriptive event. Records carry
observations only — never conclusions, never interpretation.

| field | type | meaning |
|---|---|---|
| `id` | string | unique record id (stable across re-runs) |
| `event_type` | enum | `decision_made` \| `decision_reversed` \| `correction_issued` \| `correction_repeated` \| `revert` \| `oscillation` \| `abandonment` \| `completion_success` \| `cost_note` \| `other_notable` |
| `quote` | string | verbatim quote from the source — no paraphrase, no ellipsis-splicing that changes meaning |
| `source` | object | `{ "path": string, "lines": [start, end] }` |
| `session_id` | string or null | session id, if the source names one |
| `date` | string | ISO date of the underlying event (not of extraction) |
| `project` | string | project the event concerns |
| `extraction` | object | `{ "model": string, "agent_id": string }` |
| `verification` | object | `{ "status": "unverified" \| "verified" \| "rejected", "verifier_note": string }` |
| `notes` | string | extractor context notes — descriptive only, no conclusions |

Lifecycle: records are born `unverified` (extraction), and become `verified` or
`rejected` at verification. Only `verified` records are visible to any downstream stage.

## Mapping-table entry

Produced ONLY downstream, on the verified ledger — never at extraction. Extraction agents
neither see nor emit this schema's instances.

| field | type | meaning |
|---|---|---|
| `record_id` | string | id of the verified event record being mapped |
| `hypothesis_id` | string | id of the register entry the record is mapped to |
| `stance` | enum | `supports` \| `refutes` \| `complicates` |
| `mapper` | object | `{ "model": string, "agent_id": string }` |
| `audit_status` | enum | `unaudited` \| `audited` \| `rejected` |

## Index entry

One entry per corpus document, emitted by the first pass (index-once/query-many).

| field | type | meaning |
|---|---|---|
| `path` | string | doc path (repo-relative, prefixed with repo for cross-repo corpus) |
| `content_hash` | string | hash of doc content at indexing time — the ledger key |
| `date_range` | [string, string] | ISO date range the doc covers |
| `projects` | list of string | projects mentioned |
| `event_markers` | list of object | `{ "marker": string, "line": int, "descriptor": string }` — which pre-filter marker hit, where, and a one-line descriptor of the event |
