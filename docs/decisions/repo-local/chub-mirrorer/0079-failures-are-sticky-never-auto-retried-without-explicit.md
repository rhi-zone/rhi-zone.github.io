# ADR-0079: Failures are sticky; never auto-retried without explicit flag

- Status: Accepted
- Date: 2026-05-29

**Context.** Per-download retries use bounded exponential backoff up to MAX_RETRIES before a card is marked `failed`. On subsequent runs, the tool could either auto-retry previously-failed cards or treat the failed state as terminal.

**Decision.** Once MAX_RETRIES is exhausted a card is recorded as `failed` and stays failed across runs; re-attempting failed cards requires the explicit `--retry-failed` flag. Without it, failures are sticky.

**Alternatives rejected.**
- *Automatically re-attempt previously-failed cards on every subsequent run* — Auto-retrying would repeatedly spend work on cards that may be permanently unavailable; making failures sticky keeps resumed runs cheap, with retry gated behind an opt-in flag.

**Consequences.** Resumed runs skip known failures by default, keeping them fast; recovering transiently-failed cards requires deliberately passing `--retry-failed`. `retry_count` is persisted in `mirror_state`. Mined from: /home/me/git/pterror/chub-mirrorer/README.md (60).
