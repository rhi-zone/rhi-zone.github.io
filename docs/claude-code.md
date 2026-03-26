# Using Claude Code: What We Learned from 8,500 Sessions

What does Claude Code actually look like at scale? We spent two months building a 30+ project ecosystem with Claude Code as our primary development tool, on a Claude Max 20x subscription. We instrumented everything — every session, every tool call, every token. Here's what the data says.

## The numbers

**58 days** (Jan 27 – Mar 26, 2026). **8,471 sessions** (2,458 interactive, 6,013 subagent). **25,000 turns**. **73M output tokens** from interactive sessions, **61M** from subagents. At API rates, this would be **$13,374** for interactive sessions and **$6,993** for subagents — but we ran on Claude Max, so the actual cost was a flat subscription. The API-equivalent figures are still useful for understanding *relative* costs: which projects consume the most, where waste happens, what optimizations actually matter.

The ecosystem spans 30+ projects — Rust libraries, a Lua runtime, game design tools, a documentation site, data transformation pipelines, creative writing projects. Everything from a code intelligence tool that analyzes its own sessions to an autonomous Discord bot that ran for weeks unsupervised.

## CLAUDE.md layering: machine, project, module

Most guides tell you to put a `CLAUDE.md` in your project root. That's necessary but incomplete. We found three layers, each solving a different problem:

### Global (`~/.claude/CLAUDE.md`): machine facts

This is the controversial one. Global CLAUDE.md is unversioned and invisible to collaborators — that's why most advice says to avoid it. But that's exactly right for **machine-local facts** that don't belong in any repository.

Our system runs NixOS. Developer tools aren't globally installed — they're provided per-project via Nix flakes and direnv. Without a global CLAUDE.md saying this, the agent tried `python3` 326 times across projects that never had it. Each failure is cheap. 326 of them across 58 days adds up — not in cost, but in wasted turns and context.

```markdown
# Global Rules

## Environment

This is a NixOS system. Developer tools are provided per-project
via Nix flakes + direnv. Do not assume python3, node, npm, or
cargo are globally available.
```

Three lines. Machine-specific, inherently unversioned, prevents a class of errors no project CLAUDE.md can catch.

### Project root (`CLAUDE.md`): conventions and architecture

This is the standard layer — build commands, architecture overview, coding conventions. The key insight: **be specific about what the agent shouldn't do**, not just what it should.

Our project CLAUDE.md files include negative constraints ("do not use `--no-verify`", "do not use path dependencies in Cargo.toml") because we learned from data that the agent gravitates toward shortcuts when stuck. The negative constraints are more valuable than the positive ones.

### Nested (`crates/foo/CLAUDE.md`): module-specific context

For monorepos or projects with distinct subsystems. Claude picks up the relevant CLAUDE.md based on where it's working. Useful when a crate or module has conventions that differ from the project root — its own error handling pattern, its own test strategy, its own dependencies.

## The 40% context tax

Interactive sessions waste **40% of billed input tokens on redundant context**. The uniqueness ratio across 2,458 interactive sessions is only 60.2% — meaning 40% of what you're paying for is the agent re-reading the same context it already has.

Subagent sessions are dramatically better: **89% uniqueness** (only 11% redundant). The difference is session length. Long interactive sessions accumulate context that gets re-sent every turn. Short, focused subagent sessions don't.

**What this means in practice:**

- A session that runs for 4 hours costs more per unit of work than four 1-hour sessions
- Delegating to subagents isn't just about parallelism — it's about context efficiency
- When you notice a session drifting or context getting heavy, starting fresh is cheaper than continuing

## Subagents are 4.7x cheaper per session

| Metric | Interactive | Subagent |
|--------|-----------|----------|
| Sessions | 2,458 | 6,013 |
| API-equivalent cost | $13,374 | $6,993 |
| API-equivalent per session | $5.44 | $1.16 |
| Output tokens | 73.3M | 61.3M |
| Uniqueness ratio | 60.2% | 89.0% |
| Redundant context | 9,048M | 1,621M |

A common misconception: "sub-agents multiply cost." They multiply *sessions*, but each session is dramatically cheaper. The net effect is that subagent-heavy workflows cost less per unit of work while getting more done in parallel.

For bulk tasks, parallel subagents on Haiku obliterate any local LLM setup. 100+ tokens/sec per agent at 30x parallelism, with structured tool use and error handling — no local 8B model on a GPU comes close, and you don't need to maintain infrastructure.

## The retry death spiral

The single most expensive failure mode: the agent hits an error, retries the same command, hits the same error, retries again. Hundreds of times.

One project accumulated **986 `ls` calls with a 98% failure rate** and **239 `pwd` calls at 100% failure** — all due to a sandboxing issue. The agent never bailed out. At API rates, that's ~$150 worth of tokens on commands that could never succeed.

The fix isn't CLAUDE.md rules (the agent ignores them when stuck in a loop). The fix is structural:

- **Environment signals**: make sure the agent can detect why something fails, not just that it fails
- **Deny lists**: in project `.claude/settings.json`, deny commands that are known to fail
- **Session monitoring**: if you see a session churning, kill it early

## Build-test-fix: where the money actually goes

The largest productive cost center: `cargo test` consumed **135M output tokens** across 4,327 invocations (14% failure rate). This is expected — the build-test-fix loop is the actual work. But cargo test output is *noisy*: full compilation output, every test name, backtraces on failure, pretty-printed assertion diffs.

`cargo test -q` (quiet mode) prints only failures. For a typical test run that passes, this reduces output from hundreds of lines to zero. Across thousands of test runs, this is a significant cost lever.

**General principle**: every tool that dumps verbose output into context is a cost multiplier. Prefer quiet/minimal output flags for any command the agent runs repeatedly:
- `cargo test -q` over `cargo test`
- `cargo build --message-format=short` for shorter compiler output
- `RUST_BACKTRACE=0` unless you're debugging a panic

## Cost is Pareto

Two projects account for 44% of all cost. Five projects account for 62%. The bottom 20 projects combined cost less than the top project alone.

This isn't a problem to fix — it reflects where the actual work is. But it means **optimizing the top 2–3 projects has more impact than optimizing everything else combined**. If your most expensive project has a 94% tool success rate, getting it to 97% saves more than perfecting ten small projects.

## git is surprisingly fragile

| Operation | Attempts | Failure Rate |
|-----------|----------|-------------|
| `git commit` | 9,058 | 10% |
| `git push` | 1,670 | 28% |
| `git add` | — | 8% |
| `git cherry-pick` | 278 | 40% |

The commit failures are mostly pre-commit hooks (formatting, linting). This is actually good — the hooks catch real issues. But each failure costs a retry cycle: the agent reads the error, fixes the issue, re-runs the commit.

Push failures in our case were SSH key configuration (multiple GitHub accounts). Your failure modes will differ, but the point stands: git operations fail more than you'd expect, and each failure is an expensive retry.

## What we track and how

We built session analysis tooling into [normalize](https://docs.rhi.zone/normalize/), our code intelligence tool. It can parse Claude Code session files and compute:

- Per-session and aggregate token usage
- Tool call patterns and success rates
- Command breakdown with error rates
- Context efficiency (uniqueness ratio, redundant tokens)
- Cost estimates across model pricing tiers

We generate [daily activity logs](/introspection/log/) from this data, and periodically synthesize cross-cutting patterns across weeks. This introspection loop — analyzing how we use the tool to use the tool better — is what produced every finding in this guide.

Without instrumentation, you're flying blind. You might notice a session "felt expensive" but you can't tell whether it was productive expensive (large refactor) or wasteful expensive (retry spiral). The data makes the difference visible.

## Key takeaways

1. **Layer your CLAUDE.md files**: global for machine facts, project for conventions, nested for modules. Each layer solves problems the others can't.

2. **Prefer shorter sessions and subagent delegation**: the 40% context tax on long sessions is real. Break work into focused chunks.

3. **Reduce output noise**: quiet flags on build/test commands save significant context over thousands of runs.

4. **Watch for retry spirals**: the agent won't bail out on its own. Structural fixes (deny lists, environment signals) beat prompting.

5. **Optimize your top projects first**: cost follows a power law. Small improvements to your most-used projects outweigh perfecting the long tail.

6. **Instrument everything**: you can't improve what you can't measure. Session analysis turns vague impressions into actionable data.
