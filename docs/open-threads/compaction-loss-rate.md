# Compaction loss rate

**Project(s) touched:** all interactive sessions; detector tooling fits normalize or github-io

**Status:** Open — measurement-blocked

**Surfaced in:** `docs/introspection/investigations/2026-05-20-whats-wrong/synthesis.md` — "two confirmed cases over 60 days is sparse; users don't always notice when an agreement is lost, so the count is a floor"; instances at `db532ce7` (normalize), `9501a0b0` (crescent)

---

## The question

What is the actual rate at which compaction silently strips load-bearing prior
agreements from a session?

## Why this is a registry thread

The question crosses all interactive work, and the detector would live in
normalize or github-io tooling. The confirmed count (two over 60 days) is a
floor, not a measurement — users don't always notice a lost agreement.

## What's still open

- No detector for "an agreement present pre-compaction is absent post-compaction."
- The true rate is unknown; only a lower bound exists.

## Working answer

None — measurement-blocked.
