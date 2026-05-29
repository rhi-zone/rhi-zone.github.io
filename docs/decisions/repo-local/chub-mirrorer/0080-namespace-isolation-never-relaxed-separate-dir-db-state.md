# ADR-0080: Per-namespace isolation is never relaxed (separate dir, DB, and state)

- Status: Accepted
- Date: 2026-05-29

**Context.** Multiple chub namespaces (characters, lorebooks, presets, extensions) can be mirrored, possibly in one invocation. They could share output/state to reduce duplication, or each be fully isolated.

**Decision.** Each namespace is mirrored independently with its own output directory and sqlite DB; even in multi-namespace runs, isolation is never relaxed, and per-invocation `OUTPUT_DIR`/`DB_PATH` overrides are ignored when multiple namespaces are selected.

**Alternatives rejected.**
- *Share state/output across namespaces, or honor OUTPUT_DIR/DB_PATH overrides during multi-namespace runs* — Namespaces don't share state and can run in any order; relaxing isolation would couple their outputs and break the run-in-whatever-order guarantee, so overrides are explicitly ignored for multi-namespace runs.

**Consequences.** Namespaces can be run in any order independently; multi-namespace runs cannot redirect a single shared output/DB; the VPN guard and API-key check run once before the namespace loop, and a failing namespace logs and continues with non-zero final exit. Mined from: /home/me/git/pterror/chub-mirrorer/README.md (50), /home/me/git/pterror/chub-mirrorer/README.md (36).
