# ADR-0022: Back up Claude Code session JSONL to /mnt/ssd before 30-day deletion

- Status: Accepted
- Date: 2026-05-29

**Context.** The introspection program (weekly snapshots, friction/sequence analyses, cost tables) is built entirely on Claude Code session .jsonl files. It was discovered that Claude Code silently deletes these files after ~30 days, which would permanently destroy the raw material the entire introspection/analysis layer depends on.

**Decision.** Treat Claude Code session JSONL files as a corpus to be preserved out-of-band: back them up to /mnt/ssd/ai/claude-sessions/ rather than relying on Claude Code's own retention. All later session analyses (friction, sequence, cost) read from this backup path, not from the live Claude Code store.

**Alternatives rejected.**
- *Rely on Claude Code's native session retention as the source for introspection* — Claude Code deletes session .jsonl files after ~30 days (undocumented), so any analysis depending on sessions older than a month would lose its source data.

**Consequences.** Session analysis tooling (e.g. normalize sessions, friction/sequence analyses) reads from /mnt/ssd/ai/claude-sessions/projects/ as the canonical archive. The introspection corpus is durable beyond the 30-day window. Open: nothing in-source specifies a rotation/retention or integrity policy for the backup itself. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/2026-02-25.md (51), /home/me/git/rhizone/github-io/docs/introspection/log/friction-analysis-2026-03-29.md (3).
