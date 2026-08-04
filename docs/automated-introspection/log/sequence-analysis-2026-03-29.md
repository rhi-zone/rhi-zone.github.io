# Sequence Pattern Analysis — 2026-03-29

Analysis of tool call sequence patterns across all projects (March 2026) using
`normalize sessions patterns` and `normalize sessions stats`. 1,238 sessions
across 25 projects analyzed.

---

## Retry Spirals (Bash → Bash → Bash)

The population transition matrix shows that after a Bash call, the agent returns
to Bash **78.5% of the time** — the highest self-loop in the dataset. This
isn't inherently a problem (many Bash sequences are legitimate pipelines), but
the per-project retry hotspot data reveals where this becomes wasteful.

### Crescent — luajit test loop (208 failures / 1375 attempts)

The dominant spiral. The agent runs `luajit lib/test/cli.lua` as its primary
feedback loop while developing the static typechecker. Each test run after an
edit generates a Bash → Edit → Bash cycle, and the cycle repeats across hundreds
of turns in sessions like `8414f765` (793 turns, 1.3M output tokens). The
failures are **not** retriable errors — they are real test failures where the
type system implementation doesn't yet match the expected output. The agent is
doing the right thing (fix, re-run), but the volume is high because the typechecker
feature surface is large and each constraint-solving change produces cascading
failures.

**Secondary spiral:** `cat` (47 failures / 201 attempts) — used to inspect files
inline in Bash rather than using the Read tool, causing Bash→Bash→Bash when the
output needs further processing.

### Reincarnate — cargo run deadestate fixture (144 failures / 3105 attempts)

The agent uses `cargo run -p reincarnate-cli -- check --manifest ~/reincarnate/gamemaker/deadestate/reincarnate.json`
as its integration test oracle. This invocation recompiles and runs the full
pipeline against a large game project fixture. With 4,809 total `cargo run` calls
and 151 errors, most runs succeed — but the sheer volume (running after nearly
every edit) means the aggregate token cost is enormous (~160M output tokens just
for this command). This is a **build + integration test loop**, not a retry spiral
per se. The cost comes from the fact that a reincarnate CLI run produces verbose
output and the agent often runs it several times in succession (checking before,
stashing, checking after, unstashing, checking again).

### Normalize — normalize CLI self-application (241 failures / 2175 attempts)

The normalize project is unique: the agent uses the normalize CLI to explore its
own source while simultaneously rebuilding it. When normalize is rebuilt with a
bug, subsequent `normalize view` or `normalize grep` calls fail until the bug is
fixed. This creates a tight Bash → Edit → Bash cycle where failures accumulate.
The high failure count (11%) reflects the inherently unstable state of a codebase
under active development being used as its own navigation tool.

A distinct sub-pattern: **git commit failures** (191 failures / 586 attempts, 32%
failure rate). These are pre-commit hook failures — `cargo fmt` finds formatting
issues, or `cargo clippy` catches a newly introduced lint. The pattern is:
`git add` → `git commit` → hook fails → `Edit` (fix) → `git add` → `git commit`
(succeeds). This is by-design behavior from `.githooks/pre-commit`, not a bug.

### Existence — cd-as-cwd-workaround spiral (68 failures / 1005 attempts)

The existence project revealed a striking pattern: 1,005 `cd` calls with 68
failures (7% failure rate) in 7 sessions. The agent prepends `cd <project_root> &&`
to almost every Bash command because the shell state resets between calls. This
is the expected workaround, but it means every single command is a two-part
operation. The 68 failures come from `cd` failing when a git worktree path no
longer exists (worktrees are created and deleted within sessions for parallel
subagent work, and the orchestrating agent sometimes tries to cd into a deleted
worktree).

**git cherry-pick spiral** (42 failures / 107 attempts, 39% failure rate): this
project does complex branch-merging and cherry-picking to consolidate subagent
worktree branches back to main. Conflicts are common; each conflict requires
resolution steps before cherry-pick can proceed.

### Fuwafuwa — bun server polling (1067 failures / 9091 attempts, 12% failure rate)

The fuwafuwa project runs many autonomous sessions (687 total) where the agent
checks Discord, Moltbook, and other services via `bun scripts/discord.ts` and
`bun scripts/mb.js`. The 1,067 bun failures are **not** retried errors in the
usual sense — they include: rate limits, empty results (non-zero exit), network
timeouts, and services being unavailable. The agent pattern is:
```
bun discord check
bun moltbook check
bun discord check (again after writing a reply)
```

This accounts for the `2×: Bash → Bash` pattern observed in the transition data
for fuwafuwa. The 9,091 bun calls across 687 sessions is ~13 calls per session —
appropriate for an autonomous social presence agent.

---

## Context Bombs (Read → Read → Read)

The population transition matrix shows Read → Read at **37.2%** — the second
highest self-loop. This reflects a common pattern: the agent reads multiple
related files sequentially when building a mental model before making changes.

### Crescent — TODO.md re-reads (5-7 reads per session at turn 2)

The most striking context bomb is in crescent: TODO.md is read **6-8 times** in
many sessions, often at or near turn 2. The file has grown to ~39-42KB across the
period. The pattern is:

```
Turn 2: read TODO.md  (39KB)
Turn 2: read TODO.md  (39KB)  ← same file, same session
Turn 2: read TODO.md  (37KB)
```

These are not reads from separate subagents — they appear within the same turn's
tool sequence. The likely cause: the agent is checking whether a TODO item has
already been resolved by a previous edit, reads the file, makes a small edit, then
re-reads to verify the edit was applied correctly. Across 59 sessions, this pattern
generates substantial redundant context load.

### Normalize — analyze.rs re-reads (4-5 reads per session)

The `crates/normalize/src/commands/analyze/` module appears in the top largest
results 5 times (at 44-49KB each), across different sessions. Each session starts
fresh and re-reads the same core analysis files. Because the file is at the
boundary of a single Read (50KB limit), multiple reads are sometimes needed to
cover it. This is unavoidable given the file size, but it's a signal that
`analyze/mod.rs` may benefit from being split.

### Reincarnate — large source files (5 files at 43-48KB)

The reincarnate project has several files that appear repeatedly across sessions:
- `crates/backends/reincarnate-backend-typescript/src/ast_printer.rs` — 1 read at 48KB
- `crates/core/reincarnate-core/src/transforms/const_fold.rs` — multiple reads at 43-46KB

These are architectural files that every session needs for context. Because the
codebase is under a full rewrite, the agent re-reads foundational files from scratch
each session. The **token efficiency score of 50.0%** (lowest of any project) —
meaning half of all input tokens were redundant cache repetition — confirms this
is the most context-inefficient project.

### Vela — whole-file reads during OS dev (190 Read calls across 4 sessions)

The vela OS project reads extremely large files: page table code at 47KB, scheduler
at 46KB, task manager at 83KB. These are read **twice** within the same session
(page_table.rs appears identically at turns 19 and 23). This is a context bomb
driven by genuinely large, irreducible OS kernel files. The agent re-reads after
making edits to verify correctness — reasonable, but expensive.

### Existence — TODO.md growth (31-36KB, read 6-8 times per session)

The existence TODO.md has grown large (~32-36KB) and is read repeatedly:
at turn 0 (orientation), after delegating to subagents (turn 2, 13, 16), after
receiving subagent results (turn 106, 111), and before planning the next task
(turn 202). Each session thus reads this one file 5-8 times, contributing
~160-280K tokens of redundant input per session.

---

## Edit Loops (Edit → Edit → Edit)

The transition matrix shows Edit → Edit at **41.5%** — the highest tool
self-loop in the dataset. This reflects two distinct behaviors:

### Legitimate batch edits

The most common pattern: implementing a planned change that touches many files.
In reincarnate's full-rewrite sessions, the agent edits `ir/ty.rs`, `ir/inst.rs`,
`ir/block.rs`, `ir/module.rs`, `ir/func.rs` in sequence — 5-6 consecutive edits
within a single turn, each touching a different IR definition file.

Similarly in normalize, after a `cargo insta accept` cycle, the agent updates
multiple snapshot files (5 files in succession) plus CHANGELOG.md and SUMMARY.md.

### Correction loops

The crescent data reveals a genuine correction loop: `6×: Edit → Edit`,
`5×: Edit → Edit → Edit`, `4×: Edit → Edit → Edit → Edit`. These appear in the
typechecker sessions where the agent makes an edit, runs luajit to check, gets a
type error, makes another edit to the *same file*, runs luajit again. Because the
normalize data doesn't capture which file is being edited, it's hard to distinguish
"editing multiple files" from "repeatedly editing one file" without reading
individual sessions.

### Edit → Bash dominant pattern (35.6%)

After an Edit, the agent runs Bash 35.6% of the time — this is the `cargo build`
/ `luajit` / `cargo test` verify step. The ratio Edit→Edit (41.5%) vs Edit→Bash
(35.6%) suggests that batch editing phases are slightly more common than single-
edit-then-verify cycles.

---

## Top Offending Projects

Ranked by total cost (March 2026):

| Project | Sessions | Cost | Dominant Pattern |
|---------|----------|------|------------------|
| **reincarnate** | 47 | $1,336 | `cargo run` integration loop, large file reads, 50% token redundancy |
| **normalize** | 160 | $1,057 | Pre-commit hook failures, self-application instability, snapshot churn |
| **crescent** | 59 | ~$500 | luajit test spiral (208 fails), TODO.md re-reads, correction edit loops |
| **vela** | 4 | $29 | Whole-file OS kernel reads (83KB), nix develop failures (89 calls, 3 errors) |
| **existence** | 7 | $132 | cd-cwd workaround (1005 cd calls), cherry-pick conflicts, TODO.md re-reads |
| **interpreter** | 28 | — | Read → Bash pattern, large file reads (77KB TODO.md) |

Note: fuwafuwa ($7/session avg across 687 sessions) looks expensive in aggregate
but is well-optimized per-session for an autonomous social agent.

---

## Pattern Classification Summary

### Class 1: Legitimate high-volume work (not actionable)
- Reincarnate's cargo run loop — this is integration testing a large real-world fixture
- Fuwafuwa's bun calls — autonomous session polling is inherently high-frequency
- Normalize's pre-commit failures — hooks catching real issues

### Class 2: File size context bombs (structural)
- Crescent TODO.md (39-42KB), existence TODO.md (32-36KB), interpreter TODO.md (77KB)
- Reincarnate and normalize large source files (43-49KB each)
- These create redundant load every session

### Class 3: Re-read spirals (addressable)
- TODO.md read 6-8 times per session in crescent and existence
- Same file read twice within a single turn (vela page_table.rs)
- Likely cause: verify-after-edit pattern without using view with line ranges

### Class 4: Correction edit loops (addressable in crescent)
- The `6×: Edit → Edit → Edit → Edit → Edit → Edit` chains in crescent
- Likely: incremental type annotation fixes where each fix reveals the next

### Class 5: Shell state workaround (structural, NixOS-specific)
- The `cd <root> && <command>` pattern in existence (1005 cd calls)
- Caused by shell state reset between Bash calls in the Claude Code environment
- Not a retry spiral but inflates Bash call counts significantly

---

## Recommendations

### 1. Split large TODO.md files (existence, crescent, interpreter)

Files above ~20KB that are read multiple times per session should be split into
focused documents. The crescent TODO.md is the clearest case: it's read 6-8
times per session because agents need different sections at different points.
Splitting into `TODO-typechecker.md`, `TODO-stdlib.md`, `TODO-runtime.md` would
let agents read only the relevant section.

**Applicable to:** crescent, existence (TODO.md at 32-36KB), interpreter
(TODO.md at 77KB).

### 2. Use `normalize view file:start-end` for large files

The Read tool reads entire files. For files over 20KB, the agent should be
instructed (in CLAUDE.md) to use `normalize view <file>` first (structural
outline) then read specific sections with line ranges. The normalize CLAUDE.md
already documents this pattern — it should be propagated to reincarnate and
crescent.

**Add to crescent/CLAUDE.md, reincarnate/CLAUDE.md, existence/CLAUDE.md:**
```
For large files (>20KB), use `normalize view <file>` first to get structure,
then read specific sections. Do not read a large file in full if you only need
part of it.
```

### 3. Cache TODO.md content across a session (existence, crescent)

When a CLAUDE.md says "read TODO.md at session start," that read should happen
once. Subsequent checks should be in-context. The repeated reads in existence
and crescent suggest the agent forgets the content or treats each subagent's
summary as potentially stale.

For existence specifically: the TODO note `> **Workflow note:** Parallelization
via subagents is always an option.` appears at every read, suggesting the TODO
has accumulated workflow commentary that could be moved to CLAUDE.md, leaving
TODO.md as pure task tracking.

### 4. Document the worktree→cherry-pick failure mode (existence)

The 42 cherry-pick failures in existence come from merge conflicts when
consolidating parallel subagent worktrees. The CLAUDE.md could note: "after
parallel worktrees complete, prefer git merge --no-ff over cherry-pick for
consolidation; cherry-pick on the same files will conflict." Or consider
`git merge --squash` per worktree before merging to main.

### 5. Pre-build reincarnate before integration runs

The reincarnate agent runs `cargo run -p reincarnate-cli` with `--` before
every check. This rebuilds the binary on every call even when source hasn't
changed (Cargo caches this, but the warmup adds latency). Separating
`cargo build -p reincarnate-cli` from `./target/debug/reincarnate-cli check`
would make the intent clearer and allow `2>/dev/null` suppression of build
noise without silencing diagnostic output.

More impactfully: the session data shows the agent checks the same `deadestate`
fixture multiple times in one session (before stash, after stash, etc.). A hint
to "save baseline to a file and diff rather than reading full output each time"
would reduce output token cost.

### 6. Note snapshot churn pattern in normalize CLAUDE.md

The normalize agent repeatedly commits snapshot files (`cli_snapshots__help_root.snap`)
that then conflict on merge from subagent worktrees. This generates
`git checkout --ours/theirs` + re-commit cycles. Adding a note:
"snapshot files in `tests/snapshots/` often need updating after help text
changes — run `cargo insta accept` once after all other changes are committed"
would reduce the multi-attempt pattern.

---

## Cross-Cutting Observations

**The transition matrix reveals the dominant workflow loop:**
`start → Bash (51.6%) → Bash (78.5%) → Edit (3.2%) → Edit (41.5%) →
Bash (35.6%) → Bash → ... → ExitPlanMode (87.5% of ends)`

This is: orient with shell commands, batch edit, verify with shell. The Edit→Edit
loop is the implementation phase; the Bash→Bash loop is the explore+verify phase.
Both are structurally sound. The inefficiency is in *what* the Bash calls contain
(cd overhead, full file reads as cat, redundant fixture runs) rather than the
sequence itself.

**ExitPlanMode has a 27% success rate in normalize (102 errors / 139 attempts).**
This is the highest failure rate of any tool in the dataset for normalize. The
failures happen when the user interrupts (`[Request interrupted by user for tool use]`)
before ExitPlanMode completes — not a coding error. But it confirms that plan mode
is frequently entered and frequently interrupted, suggesting the planning step is
often more exploratory than conclusive.

**reincarnate has 50% token uniqueness ratio** — the worst of any project. This
means half the tokens in every context window are repetition of prior context.
The combination of large source files (43-48KB each), long sessions (avg 1.84M
token context), and a full-rewrite strategy (every session re-reads the same
foundational IR files) drives this. The full-rewrite approach is intentional, but
it creates structural context pressure that won't resolve until the rewrite reaches
a stable architecture.
