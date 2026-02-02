# Ecosystem TODO

Tracking issues for cross-project work.

## Branding Migration: rhizome → rhi

**Status:** Blocked - do this AFTER namespace audit and project name finalization

Migrate from "rhizome" branding to "rhi" to match rhi.zone domain:
1. **Namespace audit**: Check crates.io availability for all project names
   - Identify which projects need prefixes (namespace collision)
   - Decide: rescribe-style (no prefix) vs normalize-style (needs prefix)
2. **GitHub org rename**: rhi-zone → rhi-zone
   - Note: `rhi` org is taken on GitHub, so we'd use `rhi-zone`
   - Update all git remotes across ecosystem repos
   - Can script with gh cli + git remote set-url
3. **Crate prefix migration**: rhi-* → rhi-*
   - Update all Cargo.toml workspace members
   - Update all internal crate references
   - Update imports in all projects
4. **Documentation updates**:
   - CLAUDE.md in all repos
   - README.md in all repos
   - docs/about.md, docs/projects/*
   - Update branding/philosophy to explain "rhi" as shorthand
5. **Domain configuration**: See rhi.zone planning section below

**Prerequisites:**
- [ ] Complete project name audit (which need botanical renames?)
- [ ] Finalize rescribe integration
- [ ] Finalize server-less rename
- [ ] Test GitHub org rename on a dummy org first

## rhi.zone Domain Planning

**Status:** Ideas phase - needs refinement before implementation

### Subdomain Structure

**Project-specific docs:**
- `normalize.rhi.zone` → Normalize documentation
- `moonlet.rhi.zone` → Moonlet documentation
- `unshape.rhi.zone` → Unshape documentation
- etc. (makes each project feel independent under unified brand)

**Functional subdomains:**
- `docs.rhi.zone` → Main ecosystem docs (what's currently at root)
- `api.rhi.zone` → Unified API gateway (if built)
- `play.rhi.zone` → Interactive playground/demos
- `pkg.rhi.zone` → Package index/search (like docs.rs but for rhi)

### Root Domain (rhi.zone)

Landing page options:
- Interactive project switcher with ecosystem visualization
- Live demos of each project in action
- Playground: Try Wick expressions, Normalize queries, Unshape generation in-browser
- Status dashboard: Build status, release versions across projects

### Short URLs

Pattern: `rhi.zone/{project-initial}/{topic}`
- `rhi.zone/m/view` → Normalize view command docs
- `rhi.zone/s/plugin` → Moonlet plugin docs
- `rhi.zone/r/audio` → Unshape audio docs
- Short, memorable links for common docs pages

### TODO

- [ ] Design landing page mockup
- [ ] Decide on subdomain strategy (project subdomains vs all under docs.rhi.zone)
- [ ] Plan short URL scheme and routing
- [ ] Implement DNS configuration
- [ ] Set up subdomain deployments
- [ ] Build landing page
- [ ] Create playground infrastructure

## Session Analysis

Re-analyzed 2026-01-31 using normalize `ac34fe00` (command breakdown + retry hotspot detection).

### High-Rework Sessions (re-analyzed)

**wick `28d418c3`** — $18.39, 455 turns, 252 parallel opportunities
- Cargo.toml thrashing confirmed: 5 crate Cargo.toml files each touched 16-20 times (reads + edits)
- `dew-linalg/Cargo.toml` worst at 20 touches. Each `src/lib.rs` also hit 11-14 times.
- Command mix: 54 git, 51 cargo test, 16 cargo clippy/fmt — testing dominated
- 6 corrections, 8 build failures (compile errors + fmt diffs + bad git flags)
- Peak context 154.7K. Context hit warning zone at turn 90.
- **Root cause**: Iterative dependency wiring across 5 crates without batching edits.

**normalize `6b847726`** — $9.17, 293 turns, 243 parallel opportunities
- `sessions/show.rs` had 33 touches (12 reads, 19 edits, 2 writes) — single-file churn
- Top Bash commands: `normalize` (30 calls), `grep` (17 calls via Bash instead of Grep tool)
- 4 corrections, 17 command failures (compile errors, missing `cargo-insta`, fmt diffs)
- Context approached limit at turns 145, 174, 203 — recovered after summarization at 232
- **Root cause**: Using Bash grep instead of Grep tool (17 calls), sequential tool chains

**normalize `bc20cfe9`** — $1.42, 74 turns, 51 parallel opportunities
- Continuation of `6b847726`. Same file (`sessions/mod.rs`, `show.rs`) + plan file churn.
- 1 correction, 4 command failures. Context stayed under 80K.
- Compact session, well-behaved compared to predecessor.

### High-Cost-Per-Session Repos (re-analyzed)

Previous averages were skewed by outlier sessions:

- **rescribe** `036d34ec` — **$85.81**, 2078 turns, 1549 parallel opportunities. Monster session: 698 edits, 565 Bash calls, 257 writes, 148 cargo tests, 101 git commits. Context hit 154K multiple times. This single session inflated the repo's $/session average.
- **sketchpad** `ab4ca8dd` — $0.19, 16 turns. Mostly git/gh operations. The high average likely came from agent sessions.
- **ooxml** `4739e0ce` — $0.04, 7 turns, 3 Bash calls. Tiny commit session. High average from other sessions.

### Agent vs Interactive Comparison

These hub-spawned sessions were from testing non-interactive functionality in claude-code-hub, not production usage.

| Session | Type | Turns | Tools | Cost | Notes |
|---------|------|-------|-------|------|-------|
| server-less `agent-af3501f` | agent | 384 | 383 | $5.51 | **376 `ls` commands** — test run |
| server-less `agent-aefeb60` | agent | 1 | 0 | $0.02 | Warmup test |
| server-less `agent-acbd5a3` | agent | 1 | 0 | $0.02 | Warmup test |
| wick `agent-a904a54` | agent | 4 | 3 | $0.01 | 2 Glob + 1 Read, then stopped |
| wick `agent-a92d4e2` | agent | 1 | 0 | $0.00 | Warmup test |
| server-less `742e1e3a` | interactive | 44 | 38 | $1.05 | Compact, efficient |
| server-less `35376b4a` | interactive | 136 | 126 | $5.31 | Used Task tool, higher context |

Most agent sessions were non-interactive functionality tests, not failed productive sessions. The `agent-af3501f` session's 376 `ls` calls reflect early hub development iteration.

### Actionable Patterns for CLAUDE.md

Based on the analysis, these patterns cause the most waste:

1. **Cargo.toml thrashing** (wick): Batch dependency changes across crates instead of editing one-by-one. Plan all changes, then apply. Already addressed in scaffolding template's Workflow section.
2. **Bash grep instead of Grep tool** (normalize): 17 `grep` calls via Bash instead of using the Grep tool. May already be fixed by Claude Code's own tool preference improvements — needs verification on newer sessions.
3. **Sequential tool chains** (all sessions): 198-376 parallelizable calls per session. The biggest single source of wasted API calls.
4. **Single-file edit churn** (normalize): 33 touches on one file. Read-plan-edit-once pattern needed.

### TODO

- [x] Re-run analysis after `show --analyze` improvements land in normalize
- [x] Compare agent-spawned vs interactive session efficiency
- [ ] Track per-repo $/session trends over time (need periodic re-runs)
- [ ] Identify which CLAUDE.md changes actually reduce Bash chain length (need before/after data)
- [x] Investigate rescribe `036d34ec` in detail — greenfield build, 20+ crates scaffolded, 184 touches on one Cargo.toml, 66 corrections, 159 failures. Documented in session-deep-dives.md.
- [x] Add CLAUDE.md rules: "Minimize file churn" rolled out to 16 repos (rescribe blocked by ooxml-wml dep)
- [x] Verify Bash grep vs Grep tool issue — partially structural. normalize sessions use bash grep inside shell loops (cross-repo ops), other repos use Grep tool normally. Not a CLAUDE.md issue.

## Myenv Integration: `--schema` Support

Add `--schema` flag to CLI tools for Myenv integration per [tool-integration.md](https://github.com/rhi-zone/myenv/blob/master/docs/tool-integration.md).

When invoked with `--schema`, the tool prints a JSON Schema describing its configuration and exits.

### Projects with CLIs

- [x] **normalize** - Code intelligence CLI
- [ ] **lotus** - World runtime CLI
- [ ] **paraphase** - Pipeline orchestrator (no CLI yet)
- [ ] **wick** - Expression language (no CLI yet)
- [ ] **myenv** - Ecosystem orchestrator (has CLI, needs schema)

### Implementation

Use `schemars` crate to derive JSON Schema from config structs:

```rust
use schemars::JsonSchema;

#[derive(JsonSchema)]
struct Config { ... }

if args.get(1) == Some(&"--schema".to_string()) {
    let schema = schemars::schema_for!(Config);
    println!("{}", serde_json::to_string_pretty(&schema).unwrap());
    return;
}
```
