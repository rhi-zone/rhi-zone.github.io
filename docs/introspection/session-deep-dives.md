# Session Deep Dives

Follow-up analysis of specific sessions flagged in the [aggregate analysis](./session-analysis), re-run January 31, 2026 using normalize `ac34fe00` which added command breakdown and retry hotspot detection to `sessions show --analyze`.

## High-Rework Sessions

### dew `28d418c3` — $18.39, 455 turns

The poster child for **Cargo.toml thrashing**.

| Metric | Value |
|--------|-------|
| Tool calls | 427 |
| Parallel opportunities | 252 |
| Corrections | 6 |
| Build failures | 8 |
| Peak context | 154.7K |
| Cost | $18.39 (Sonnet) |

**Command breakdown:**

| Category | Calls |
|----------|-------|
| git | 54 |
| test | 51 |
| lint | 16 |
| build | 4 |
| search | 3 |

Top: `cargo test` (51), `git add` (15), `git commit` (14), `cargo clippy` (9), `cargo fmt` (7)

**File thrashing — the core problem:**

| File | Reads | Edits | Total |
|------|-------|-------|-------|
| `dew-linalg/Cargo.toml` | 6 | 14 | 20 |
| `dew-complex/Cargo.toml` | 5 | 12 | 17 |
| `dew-cond/Cargo.toml` | 6 | 11 | 17 |
| `dew-quaternion/Cargo.toml` | 5 | 12 | 17 |
| `dew-scalar/Cargo.toml` | 5 | 11 | 16 |
| `dew-linalg/src/lib.rs` | 6 | 8 | 14 |
| `dew-scalar/src/lib.rs` | 7 | 7 | 14 |

Five Cargo.toml files each touched 16-20 times. The pattern: edit one Cargo.toml, build fails, fix it, repeat for the next crate. The same dependency change applied incrementally rather than batch-edited across all crates first.

**Context pressure:** Hit 141.7K (near the ~155K limit) by turn 90. Recovered after summarization but climbed back to 114.8K.

**Root cause:** Iterative dependency wiring across 5 crates without batching. Each crate's Cargo.toml and lib.rs edited in isolation, with build/test cycles between each, instead of planning all changes upfront and building once.

**Already addressed:** The scaffolding CLAUDE.md template now includes "When making the same change across multiple crates, edit all files first, then build once."

---

### normalize `6b847726` — $9.17, 293 turns

Sequential tool chains and Bash-as-search.

| Metric | Value |
|--------|-------|
| Tool calls | 277 |
| Parallel opportunities | 243 |
| Corrections | 4 |
| Command failures | 17 |
| Peak context | 148.4K |
| Cost | $9.17 (Sonnet) |

**Command breakdown:**

| Category | Calls |
|----------|-------|
| other | 54 |
| git | 33 |
| search | 25 |
| build | 14 |
| lint | 14 |
| test | 9 |
| install | 6 |

Top: `normalize` (30), `grep` (17 via Bash), `cargo build` (12), `cargo test` (9), `cargo clippy` (8)

**Key issue — Bash grep instead of Grep tool:** 17 `grep` calls routed through Bash instead of the native Grep tool. This is both less efficient (no parallel batching) and inflates context with raw terminal output. May already be resolved by Claude Code's own improvements to tool preference — needs verification on newer sessions.

**Single-file churn:** `sessions/show.rs` touched 33 times (12 reads, 19 edits, 2 writes). The agent repeatedly re-read and re-edited the same file rather than planning a complete change.

**Parallelization waste:** 243 opportunities identified — the largest single block was turns 222-275 (54 sequential API calls that could have been batched). This includes long chains of `Bash → Bash → Bash...` that are independent commands.

**Context hit 148K** at turn 203 — dangerously close to the limit. Recovered after summarization at turn 232 to 60K, then climbed back to 111K by session end.

---

### normalize `bc20cfe9` — $1.42, 74 turns

Continuation of `6b847726`. Much better behaved.

| Metric | Value |
|--------|-------|
| Tool calls | 69 |
| Parallel opportunities | 51 |
| Corrections | 1 |
| Command failures | 4 |
| Peak context | 79.0K |
| Cost | $1.42 (Sonnet) |

Worked on the same files (`sessions/mod.rs`, `sessions/show.rs`) but stayed compact. Context never exceeded 79K. Only one correction. This shows that session length itself is a factor — the same work done in a fresh session is cheaper due to lower context accumulation.

## High-Cost Repos

Previous analysis flagged sketchpad ($7.78/session), ooxml ($5.01/session), and rescribe ($4.58/session) as the most expensive per-session. Deep dives reveal the averages were skewed:

### rescribe `036d34ec` — $85.81, 2078 turns

The outlier that inflated rescribe's per-session average. A greenfield build session that scaffolded the entire rescribe document conversion library — 20+ reader/writer crates — in one marathon sitting.

| Metric | Value |
|--------|-------|
| Tool calls | 2,009 |
| Edits | 698 |
| Bash calls | 565 |
| Writes | 257 |
| Corrections ("Let me fix") | 66 |
| Command failures | 159 |
| Cargo tests | 148 |
| Git commits | 101 |
| `mkdir` calls | 50 |
| WebSearch + WebFetch | 37 |
| Peak context | 154.7K |
| Cost | $85.81 (Sonnet) |

**The worst file churn in the ecosystem:**

| File | Reads | Edits | Writes | Total |
|------|-------|-------|--------|-------|
| `crates/rescribe/Cargo.toml` | 27 | 157 | 0 | **184** |
| `Cargo.toml` (workspace) | 25 | 55 | 0 | 80 |
| `crates/rescribe-cli/src/main.rs` | 8 | 67 | 0 | 75 |
| `crates/rescribe/src/lib.rs` | 16 | 50 | 0 | 66 |
| `FORMATS.md` | 9 | 33 | 1 | 43 |

157 edits to a single Cargo.toml — roughly one edit every 13 turns. Each new reader/writer crate needed its dependency added to the main library, the workspace, and the CLI. The pattern repeated for ipynb, odt, docbook, fb2, pod, fountain, bibtex, csl-json, markdown (two backends), and many more.

**What was happening:** For each format, the agent:
1. `mkdir` the crate directory
2. Write `Cargo.toml` and `lib.rs`
3. Edit workspace `Cargo.toml` to register the crate
4. Edit `crates/rescribe/Cargo.toml` to add the dependency
5. Edit `crates/rescribe/src/lib.rs` to add the re-export
6. `cargo build` → fail → fix → repeat
7. `cargo test` → fail → fix → repeat
8. `cargo clippy` → fix warnings
9. WebSearch/WebFetch format specifications mid-implementation
10. `git add` + `git commit`

With 20+ formats, this cycle repeated the entire session. One correction every ~31 turns, one command failure every ~13 turns. Context hit 154K (the limit) at turns 207, 621, 1242 — at least 3 summarization resets, each losing accumulated context about the codebase structure.

**The longest unbroken tool chain** was turns 506-633: **128 consecutive single-tool API calls** without any user interaction or parallelization. This single stretch could theoretically have been compressed to 1 batched call.

**Context growth pattern** shows the session was effectively 5+ sub-sessions stitched together by summarization resets:
- Turns 0-207: 14.6K → 101.3K (format readers phase 1)
- Turns 207-621: reset → 136.9K (format readers phase 2)
- Turns 621-828: reset → 58.6K (recovery, writers)
- Turns 828-1242: → 136.3K (more writers + transforms)
- Turns 1242-1863: → 42.6K (cleanup, integration)
- Turns 1863-2078: final stretch

Each reset lost context about previously created crates, forcing re-reads (280 Read calls total). Breaking this into per-format sessions would have avoided the resets entirely and produced better code with less rework.

### sketchpad `ab4ca8dd` — $0.19, 16 turns

The interactive session was tiny: mostly `git -C` and `gh repo` commands. The high per-session average came from other sessions (possibly agent sessions from hub testing).

### ooxml `4739e0ce` — $0.04, 7 turns

Just a quick commit session — 3 Bash calls (git log, add, commit). Negligible cost.

## Hub Agent Sessions

The hub-spawned agent sessions (`agent-*`) were **non-interactive functionality tests** during claude-code-hub development, not production usage.

| Session | Repo | Turns | Tools | Cost | Notes |
|---------|------|-------|-------|------|-------|
| `agent-af3501f` | server-less | 384 | 383 | $5.51 | 376 `ls` commands (early test iteration) |
| `agent-aefeb60` | server-less | 1 | 0 | $0.02 | Warmup test |
| `agent-acbd5a3` | server-less | 1 | 0 | $0.02 | Warmup test |
| `agent-a904a54` | dew | 4 | 3 | $0.01 | Glob + Read, then stopped |
| `agent-a92d4e2` | dew | 1 | 0 | $0.00 | Warmup test |

Not meaningful for efficiency comparison — these reflect hub development iteration, not failed productive sessions. The `agent-af3501f` session's 376 sequential `ls` calls are an artifact of early non-interactive mode testing.

## Key Takeaways

1. **Cargo.toml batching works.** The scaffolding template already addresses the dew session's core problem. Repos that adopted the "edit all files first, then build once" rule should show improvement.

2. **Session length correlates with cost superlinearly.** The normalize continuation session (`bc20cfe9`, 74 turns, $1.42) did similar work to a chunk of its predecessor (`6b847726`, 293 turns, $9.17) but at a fraction of the cost. Context accumulation is the main driver.

3. **Monster sessions should be avoided.** The rescribe session ($85.81, 2078 turns) demonstrates that very long sessions hit context limits repeatedly, triggering summarization cycles that lose detail. Multiple focused sessions are cheaper and produce better results.

4. **Single-file churn** (33 touches on one file) suggests the agent would benefit from read-plan-edit-once discipline — reading a file, planning all needed changes, and applying them in one pass rather than incrementally.

5. **Bash grep usage** may already be declining as Claude Code improves its own tool routing. Worth verifying on newer sessions before adding CLAUDE.md rules.

---

*Analysis performed with normalize `ac34fe00` on January 31, 2026. Command breakdown and retry hotspot detection are new features in this version.*
