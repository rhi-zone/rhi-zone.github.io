# ADR-0078: Default mirror mode is full-catalog backfill, not incremental top-up

- Status: Accepted
- Date: 2026-05-29

**Context.** The tool's purpose is emergency backup of the entire chub catalog. A run could either default to the cheap incremental behavior (stop early, skip already-mirrored cards) or to the expensive full pass that re-fetches a full definition for every card including ones already mirrored as PNGs.

**Decision.** The default `bun run mirror` walks the entire catalog and fetches a full `ChubCard<true>` definition for every card, including the thousands already mirrored. This exhaustive mode is the default and the point of the tool; incremental behavior is opt-in via `--incremental`.

**Alternatives rejected.**
- *Make the cheap incremental mode (stop after 3 consecutive fully-mirrored pages, skip the full-def backfill) the default* — Incremental skips the full-definition backfill pass, which would defeat the tool's stated purpose as an emergency backup; it is relegated to opt-in for quick top-up runs after the initial full archive completes.

**Consequences.** Every default run is expensive and slow on first run (mitigated by being resumable). Operators must explicitly pass `--incremental` for fast top-ups, and `--backfill-only` to run only the backfill pass over known stubs. Mined from: /home/me/git/pterror/chub-mirrorer/README.md (56), /home/me/git/pterror/chub-mirrorer/README.md (58).
