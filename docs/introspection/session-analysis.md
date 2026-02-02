# Session Analysis

Comprehensive analysis of Claude Code usage across the rhi ecosystem, generated January 2026 using `normalize sessions stats --all-projects --by-repo` and `normalize sessions show --analyze`.

**2329 sessions | 119,146 tool calls | ~$4,177 estimated cost (Sonnet)**

## Aggregate Overview

| Metric | Value |
|--------|-------|
| Sessions | 2,329 |
| Total turns | 129,193 |
| Tool calls | 119,146 |
| API calls | 109,371 |
| Total tokens | 33.7B (incl. cache) |
| Avg context per call | 81,881 tokens |
| Cache savings | 85.3% |

### Tool Distribution

| Tool | Calls | Share |
|------|-------|-------|
| Bash | 48,050 | 40.3% |
| Edit | 23,369 | 19.6% |
| Read | 21,818 | 18.3% |
| Glob | 8,212 | 6.9% |
| Grep | 6,076 | 5.1% |
| TodoWrite | 4,770 | 4.0% |
| Write | 3,791 | 3.2% |
| Task | 895 | 0.8% |
| Other | 2,165 | 1.8% |

Bash dominates at 40%. This is partially inherent (Rust repos need `cargo` for build/test/clippy/fmt), but the sequential chaining patterns suggest significant waste.

## Per-Repo Breakdown

### Cost and Volume

| Repo | Sessions | Cost | $/session | Turns | Avg ctx |
|------|----------|------|-----------|-------|---------|
| unshape | 295 | $683 | $2.31 | 19,931 | 83,255 |
| normalize | 162 | $678 | $4.18 | 18,502 | 89,228 |
| hologram | 434 | $369 | $0.85 | 12,635 | 76,997 |
| io | 321 | $332 | $1.03 | 12,123 | 71,438 |
| sketchpad | 41 | $319 | **$7.78** | 7,769 | **96,781** |
| ooxml | 58 | $291 | **$5.01** | 7,933 | **91,974** |
| wick | 117 | $225 | $1.92 | 6,278 | 84,418 |
| parents | 237 | $201 | $0.85 | 8,920 | 62,981 |
| server-less | 59 | $181 | $3.07 | 5,553 | 84,800 |
| zone | 124 | $150 | $1.21 | 4,525 | 78,821 |
| lotus | 62 | $148 | $2.39 | 4,036 | **92,050** |
| rescribe | 30 | $137 | $4.58 | 3,790 | **89,516** |
| paraphase | 32 | $135 | $4.22 | 4,381 | 81,849 |
| moonlet | 79 | $78 | $0.99 | 2,556 | 73,457 |
| aspect | 60 | $75 | $1.25 | 3,565 | 65,724 |
| pad | 24 | $43 | $1.81 | 1,741 | 75,665 |
| hub | 32 | $36 | $1.13 | 1,089 | 87,971 |
| portals | 47 | $28 | $0.59 | 1,146 | 64,596 |
| myenv | 13 | $20 | $1.55 | 541 | 76,797 |
| playmate | 22 | $10 | $0.45 | 341 | 61,565 |
| keybinds | 15 | $9 | $0.60 | 578 | 47,928 |
| herbarium | 11 | $7 | $0.60 | 213 | 68,174 |
| concord | 9 | $11 | $1.26 | 362 | 80,709 |
| pteraworld | 6 | $5 | $0.80 | 329 | 48,936 |

**Key observations:**
- **sketchpad** ($7.78/session) and **ooxml** ($5.01/session) are the most expensive per-session. Both have high avg context (97K, 92K) suggesting large codebases that inflate every API call.
- **normalize** and **rescribe** are also expensive per-session ($4.18, $4.58) with high context (89K each).
- **hologram** and **parents** are cheap per-session but have the most sessions (434, 237), so their total spend adds up.

## Pain Point 1: Sequential Bash Chains

The dominant tool pattern in nearly every repo is long `Bash -> Bash -> Bash -> Bash -> Bash` chains. These represent the agent running commands one-at-a-time when many could be parallelized.

| Repo | 5+ Bash chains | % of all tool patterns |
|------|---------------|----------------------|
| unshape | 4,548 | dominant |
| parents | 4,228 | dominant |
| server-less | 2,234 | dominant |
| paraphase | 1,873 | dominant |
| io | 1,583 | dominant |
| normalize | 1,358 | dominant |
| zone | 1,013 | dominant |
| wick | 1,002 | dominant |
| moonlet | 959 | dominant |
| ooxml | 1,105 | dominant |

**What's happening:** The agent runs `cargo build`, waits, runs `cargo test`, waits, runs `cargo clippy`, waits, runs `cargo fmt --check`, waits. Each is a separate API round-trip. In the normalize session analyzed, this pattern accounted for **217 parallelizable API calls** in a single session.

**Fix:** CLAUDE.md guidance to batch cargo commands: `cargo fmt -- --check && cargo clippy -- -D warnings && cargo test` in a single Bash call.

## Pain Point 2: Glob Spam

Several repos show chains of 5+ consecutive Glob calls as a top pattern:

| Repo | 5+ Glob chains |
|------|----------------|
| normalize | 1,012 |
| pad | 982 |
| paraphase | 969 |
| hologram | 893 |
| wick | 767 |
| io | 699 |
| rescribe | 681 |

**What's happening:** The agent is doing file discovery one glob pattern at a time. For example, searching for `*.rs`, then `*.toml`, then `*.md`, then `*.ts`, etc., each as a separate tool call.

**Fix:** Use the Task/Explore agent for broad file discovery. When doing targeted searches, batch multiple globs into a single call or use `normalize view <dir>` for structural overview.

## Pain Point 3: Repeated File Thrashing

Individual session analysis reveals excessive re-reading and re-editing of the same files. The worst example from a wick session:

| File | Reads | Edits | Total touches |
|------|-------|-------|---------------|
| `dew-linalg/Cargo.toml` | 6 | 14 | 20 |
| `dew-cond/Cargo.toml` | 6 | 11 | 17 |
| `dew-quaternion/Cargo.toml` | 5 | 12 | 17 |
| `dew-complex/Cargo.toml` | 5 | 12 | 17 |
| `dew-scalar/Cargo.toml` | 5 | 11 | 16 |
| `dew-linalg/src/lib.rs` | 6 | 8 | 14 |
| `dew-scalar/src/lib.rs` | 7 | 7 | 14 |

**What's happening:** Incremental edits that break the build, leading to read-edit-build-fail-read-fix cycles. The agent makes a change to one Cargo.toml, finds the build broken, fixes it, but then needs to make the same change to 5 other Cargo.toml files -- one at a time.

**Fix:** CLAUDE.md guidance to plan multi-file changes upfront. When making the same change across crate Cargo.toml files, do all edits before building.

## Pain Point 4: Context Pressure

Sessions regularly approach the ~155K token context limit:

| Session | Repo | Peak context | Effect |
|---------|------|-------------|--------|
| 28d418c3 | wick | 141.7K | Approaching limit |
| 6b847726 | normalize | 131.0K | Approaching limit |
| (aggregate) | sketchpad | avg 96.8K | Consistently high |
| (aggregate) | ooxml | avg 92.0K | Consistently high |
| (aggregate) | lotus | avg 92.1K | Consistently high |

**What's happening:** Long sessions accumulate context from tool results (especially cargo build output, large file reads). The normalize session showed context growth from 10K to 131K over 283 turns.

**Fix:** Use `normalize view` to get structural outlines instead of reading entire files. Use offset/limit for targeted reads. In long sessions, prefer the Task agent to offload exploration.

## Pain Point 5: Error-Driven Rework

"Corrections & Apologies" (the agent saying "Let me fix") correlate with wasted cycles:

| Session | Repo | Corrections | Build errors |
|---------|------|-------------|--------------|
| 28d418c3 | wick | 6 | 8 command failures |
| 6b847726 | normalize | 4 | 17 command failures |
| b70ecf3d | unshape | 1 | file-not-found, token limit |

Common error patterns across all sessions:
- **cargo fmt failures after edits** - agent doesn't run fmt proactively
- **Compilation errors from incremental changes** - untested assumptions
- **"File does not exist"** - agent guessing at file paths
- **"File has not been read yet"** - agent trying to write without reading first
- **Token limit exceeded** - reading large files without offset/limit

## Pain Point 6: Underused Tools

| Tool | Calls | Share | Note |
|------|-------|-------|------|
| Task (subagents) | 895 | 0.8% | Drastically underused for exploration |
| AskUserQuestion | 139 | 0.1% | Agent rarely asks for clarification |
| EnterPlanMode | 158 | 0.1% | Rarely plans before acting |
| Grep | 6,076 | 5.1% | Often Bash grep/rg used instead |

The agent defaults to sequential Bash commands for exploration when Task/Explore agents would be more efficient and context-friendly.

## Actionable Changes

Based on this analysis, the following changes have been rolled out across ecosystem repos:

### 1. Auto-Format Pre-Commit Hook

**Changed:** Pre-commit hooks across all Rust repos now run `cargo fmt --all` (apply) instead of `cargo fmt --all -- --check` (check-only). The hook also stages the formatted changes with `git add -u`.

**Why:** A huge portion of the Bash chains were `cargo fmt --check` → fail → `cargo fmt` → re-stage → retry. The agent no longer needs to think about formatting at all — it's handled at commit time.

**Affected repos:** All Rust repos in the ecosystem (normalize, unshape, wick, moonlet, paraphase, rescribe, concord, reincarnate, server-less, playmate, portals, zone, myenv, interconnect, ooxml). Scaffolding template updated.

### 2. Cargo Command Batching

**Added** `## Workflow` section to all Rust repo CLAUDE.md files:

```
Batch cargo commands to minimize round-trips:
  cargo clippy --all-targets --all-features -- -D warnings && cargo test
After editing multiple files, run the full check once — not after each edit.
```

### 3. Multi-File Edit Discipline

**Added** to all multi-crate workspace CLAUDE.md files:

```
When making the same change across multiple crates, edit all files first, then build once.
```

### 4. Structural Exploration

**Added** `normalize view` availability note to all repo CLAUDE.md files. Not prescriptive — just making it known as an option for structural outlines of files and directories.

### 5. Scaffolding Template

Updated `scaffolding/CLAUDE.md` and `scaffolding/.githooks/pre-commit` to include all the above for new repos.

---

*Analysis performed with `normalize sessions` across `~/.claude/projects/`. Data covers all sessions through January 2026.*
