# Introspection

Activity logs and session analysis for the rhi ecosystem.

## Log Structure

- `log/` — weekly snapshots, named by end date (e.g. `2026-02-25.md`). Read the most recent first when evaluating direction or focus.
- `log/daily/` — daily session summaries, `YYYY-MM-DD.md`, one day across all projects.
- `log/synthesis-*.md` — cross-cutting pattern analysis over a date range.

Check these before asking "what should we work on?" or "what were we focused on?"

## Updating Daily Logs

Run via a subagent (Sonnet, general-purpose). The main session cannot execute these commands directly.

1. Backup sessions:
   ```bash
   rsync -a --update ~/.claude/projects/ /mnt/ssd/ai/claude-sessions/projects/ && rsync -a --update ~/.claude/history.jsonl /mnt/ssd/ai/claude-sessions/history.jsonl && rsync -a --update ~/.claude/usage-data/ /mnt/ssd/ai/claude-sessions/usage-data/
   ```
   `--update` skips destination files newer than source (safe for incremental runs). `usage-data/` holds pre-computed `/insights` facets — incremental, worth preserving.

   Also archive `/insights` reports into the append-only history dir (run every backup pass, right after the rsync above):
   ```bash
   mkdir -p /mnt/ssd/ai/claude-sessions/insights-history/ && cp -n ~/.claude/usage-data/report-*.html /mnt/ssd/ai/claude-sessions/insights-history/
   ```
   `/insights` reports are otherwise ephemeral — the source dir only retains the latest timestamped file. `cp -n` (no-clobber) into the sibling `insights-history/` dir builds an append-only archive that the `--update` mirror of `usage-data/` cannot clobber. The `report-*.html` glob intentionally excludes the `report.html` alias (no dash), so only unique timestamped reports are archived.

2. Find missing days: list `docs/automated-introspection/log/daily/` and diff against today.

3. Spawn haiku agents in parallel, one per missing day. **Never invoke `normalize` directly for this** — go through the private-project exclusion wrapper instead, so excluded projects' sessions are never read into the generating agent's context in the first place (not filtered/redacted after generation):
   ```bash
   CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects tooling/normalize-excluding-private.sh sessions messages --all-projects --role user --since YYYY-MM-DD --until YYYY-MM-DD+1 --limit 0 --show-usage
   ```
   Each writes to `docs/automated-introspection/log/daily/YYYY-MM-DD.md`. Quiet days: note as such. Include `## Token Usage` with per-session output tokens and cache hit ratios.

   **Private-project exclusion.** `tooling/normalize-excluding-private.sh` wraps the `normalize` binary: it reads directory basenames from `.git/info/private-names` (machine-local, gitignored-by-design — see that file for the current list), resolves each to its mangled `~/.claude/projects/`-style dir name, and builds a scratch dir of symlinks to every *other* project before calling `normalize` with `CLAUDE_SESSIONS_DIR` pointed at that scratch dir. `--all-projects` then only ever sees the non-excluded dirs — normalize has no idea the private ones exist, so the agent generating the log never sees their content either. This is the default; only bypass it (call `normalize` directly) for known one-off ecosystem-only investigations where you've separately confirmed no private project is in scope.

   Effect on daily logs: a day where a private project is the *only* activity gets no mention of it at all — same as if nothing happened that day (no "1 private session" placeholder, no count that includes it). A day with both ecosystem and private-project activity still gets a log, but every count/list in it is built only from the non-excluded sessions — the private activity is fully absent, not summarized down.

   Before writing the draft to disk, pipe it through the hash guard: `echo "$draft" | tooling/check-private-name-hashes.js -` (or `tooling/check-private-name-hashes.js -` fed the draft on stdin). Exit 0 means clean; exit 1 prints the offending token(s) — redact and recheck before writing the file. This catches protected names pre-write, ahead of (and independent of) the commit-time hook check in `.githooks/pre-commit`. It stays in place as a second layer even with the exclusion wrapper — the wrapper stops private *sessions* from being read, the hash guard catches private *names* if they get typed/pasted into a draft some other way.

   If synthesis insights feel thin: re-run agents on existing logs with `--show-usage` output, instructing them to flag token outliers (debugging churn, cold-start cache inefficiency, architectural output spikes). Then re-run opus synthesis.

4. Add new days to sidebar in `docs/.vitepress/config.ts` under Daily Logs.

5. If a week or more of new days: spawn an opus agent to read all daily logs and write/update `docs/automated-introspection/log/synthesis-<start>-<end>.md`. Tell it CLAUDE.md conventions may have evolved over the period. Same as step 3: go through `tooling/normalize-excluding-private.sh` for any session re-querying, and pipe the draft through `tooling/check-private-name-hashes.js -` before writing to disk.

**Scope note:** this exclusion procedure applies going forward only. Daily logs already published before it was adopted are not being retroactively regenerated under it.

6. Commit and push.

## Session Data

Claude Code deletes session `.jsonl` files based on `cleanupPeriodDays` in `~/.claude/settings.json` (default 30). Currently `999999` to prevent deletion. Cannot use `0` — [bug #23710](https://github.com/anthropics/claude-code/issues/23710) silently disables transcript persistence.

Backup location: `/mnt/ssd/ai/claude-sessions/`.

Before any session analysis (run via a subagent):

1. Re-backup:
   ```bash
   rsync -a --update ~/.claude/projects/ /mnt/ssd/ai/claude-sessions/projects/ && rsync -a --update ~/.claude/history.jsonl /mnt/ssd/ai/claude-sessions/history.jsonl && rsync -a --update ~/.claude/usage-data/ /mnt/ssd/ai/claude-sessions/usage-data/
   mkdir -p /mnt/ssd/ai/claude-sessions/insights-history/ && cp -n ~/.claude/usage-data/report-*.html /mnt/ssd/ai/claude-sessions/insights-history/
   ```
2. Run with `CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects` prefix, not from `~/.claude/`.

Session analysis (same private-project exclusion as daily logs — see above):
```bash
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects tooling/normalize-excluding-private.sh sessions stats --all-projects --limit 0 --group-by project,day --since YYYY-MM-DD --until YYYY-MM-DD --compact
```

Structural exploration:
```bash
~/git/rhizone/normalize/target/debug/normalize view <file>     # structural outline with line numbers
~/git/rhizone/normalize/target/debug/normalize view <dir>      # directory structure
```
