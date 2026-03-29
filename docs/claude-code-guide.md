# Claude Code Guide

A practical guide to getting more out of Claude Code.

## CLAUDE.md layering

Claude Code reads `CLAUDE.md` files for project context. Most guides only mention the project-level file, but there are three layers that solve different problems:

### Global (`~/.claude/CLAUDE.md`)

Machine-local facts that don't belong in any repository. Things like your OS, package manager, and what tools aren't globally installed.

```markdown
This is a NixOS system. Developer tools are provided per-project
via Nix flakes + direnv. Do not assume python3, node, npm, or
cargo are globally available.
```

Global CLAUDE.md is unversioned — that's usually cited as a reason to avoid it. But machine facts are inherently local and unversioned, so this is exactly the right place for them.

### Project root (`CLAUDE.md`)

Conventions, architecture, build commands. The standard layer.

One underrated practice: **negative constraints** are more valuable than positive ones. The agent gravitates toward shortcuts when stuck — `--no-verify` to skip a failing hook, path dependencies to avoid publishing, string errors instead of proper types. Explicitly forbidding these is more effective than hoping the agent follows conventions.

### Nested (`crates/foo/CLAUDE.md`, `docs/CLAUDE.md`)

Module-specific context for monorepos or projects with distinct subsystems. Claude picks up the relevant files based on where it's working. Useful when a module has its own conventions, test strategy, or dependencies.

## Session length and context efficiency

Long interactive sessions accumulate context that gets re-sent every turn. The longer a session runs, the more you pay for redundant context — tokens the model has already seen but that get billed again.

Subagent sessions are much more efficient because they're short and focused. Each subagent starts fresh with only the context it needs.

**Practical advice:**

- When a session has drifted from its original purpose, start a new one
- Delegate independent subtasks to subagents rather than doing everything in one session
- Use `/compact` to compress context when a session gets heavy

## Subagents over local LLMs for bulk work

For bulk tasks (processing many files, running parallel analyses, generating tests), parallel subagents on Haiku are faster and cheaper than local LLM inference. Each subagent gets structured tool use, error handling, and web access — with no local infrastructure to maintain.

Local LLMs still have a role for **privacy-sensitive tasks** where data genuinely can't leave your machine. For everything else, the API wins on speed and capability.

## Reduce output noise

Every command that dumps verbose output into context is a cost multiplier. The agent reads the full output, which expands the context for every subsequent turn.

Prefer quiet or minimal output flags for commands the agent runs repeatedly:

- `cargo test -q` — only prints failures (vs full test list + compilation)
- `cargo build --message-format=short` — shorter compiler diagnostics
- `RUST_BACKTRACE=0` — unless actively debugging a panic
- `--quiet` / `--silent` flags on any build tool that supports them

This is especially impactful for build-test-fix loops, where the agent may run tests dozens of times in a session.

## Scope your reads and greps

The largest context consumers aren't command outputs — they're **unbounded file reads and grep results**. A single grep across a codebase can dump hundreds of thousands of characters into context. Reading an entire 3,000-line file when you need 50 lines wastes context on every subsequent turn.

**Practical advice:**

- **Read specific line ranges** when you know roughly where the relevant code is. Use structural tools (outlines, AST viewers) to find the right section first.
- **Limit grep results** — prefer targeted patterns over broad searches. If a grep returns more than a screenful, it's probably too broad.
- **Don't re-read large files** — if you already read a file earlier in the session, reference what you learned rather than reading it again.
- **Use structural exploration** before diving in. A tool that shows you function signatures and type definitions with line numbers lets you target reads precisely.

## The retry spiral

The most expensive failure mode: the agent hits an error, retries the same command, hits the same error, retries again — potentially hundreds of times without bailing out.

This typically happens when:
- A command fails due to environment issues (sandboxing, missing tools)
- The agent doesn't understand *why* it failed, only *that* it failed
- There's no CLAUDE.md rule or deny list to stop it

**Structural fixes:**

- **Deny lists** in `.claude/settings.json` — block commands known to fail in your environment
- **CLAUDE.md constraints** — tell the agent what tools aren't available and what to do instead
- **Session monitoring** — if you see a session churning on the same error, kill it early

Prompting the agent to "stop retrying" doesn't reliably work once it's in a loop. Prevention beats intervention.

## Git operations fail more than you'd expect

Pre-commit hooks, authentication, merge conflicts, and staging issues all contribute to surprisingly high git failure rates. Each failed commit or push triggers a retry cycle where the agent reads the error, attempts a fix, and tries again.

This is mostly fine — pre-commit hooks catching real issues is good. But be aware:

- **Pre-commit hooks** that run formatters or linters will fail on first commit, then pass after the agent fixes the issue. This is a known cost of "correct by default" workflows.
- **SSH/auth issues** cause push failures that the agent can't fix. If pushes fail consistently, fix the auth configuration rather than letting the agent retry.
- **Never use `--no-verify`** to skip hooks. Fix the underlying issue instead.

## Post-history context injection

CLAUDE.md loads at session start — before the conversation history. By the time the agent is deep in a task, that context is far back and increasingly diluted. Some guidance benefits from being injected *after* the history, right before the agent processes your prompt, where it's freshest.

Claude Code's `UserPromptSubmit` hook fires on every prompt and can return `additionalContext` that gets injected at that position. The simplest implementation is a shell script:

```bash
#!/usr/bin/env bash
# ~/.claude/hooks/hints.sh
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | grep -o '"prompt":"[^"]*"' | cut -d'"' -f4)

HINTS="Prefer cargo test -q over cargo test."

if echo "$PROMPT" | grep -qi "read\|file\|explore"; then
    HINTS="$HINTS\nUse a structural outline tool before reading large files."
fi

printf '{"additionalContext":"%s"}' "$(echo -e "$HINTS" | sed 's/"/\\"/g')"
```

Wire it up in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "hooks": [{ "type": "command", "command": "~/.claude/hooks/hints.sh" }]
    }]
  }
}
```

The script *is* the configuration. Inline comments explain what fires when. Grep on the prompt for conditional hints. No format to learn, no dependencies.

**What belongs here vs CLAUDE.md:** CLAUDE.md is for stable facts about the project — architecture, conventions, build commands. Post-history injection is for behavioral nudges the agent tends to drift from: things it knows but forgets under pressure, or reminders that are only relevant in specific situations. The position difference matters: post-history injection lands after a long conversation history rather than before it.

**The upgrade path:** when the script gets unwieldy, extract hints into a data file and write a parser. Add keyword matching, then per-project hierarchy, then conditional logic. The hook stays a thin shim. That's a fine problem to have — it means you've accumulated enough hard-won behavioral knowledge to justify structure.

## Corrections are documentation lag

When the agent makes the same mistake twice, the fix isn't to repeat the correction — it's to write the invariant down. Every correction that doesn't produce a CLAUDE.md edit will happen again.

The pattern is reliable: agent violates unwritten rule → correction → rule written in CLAUDE.md → never happens again. The correction *is* the documentation process, just paid for in turns instead of prose. Shortening that loop — writing the rule *before* the session where it would have mattered — is the highest-leverage CLAUDE.md investment.

One useful diagnostic question after a correction: *what rule would have prevented this?* Not "what did I do wrong" — that's already known. The question surfaces the missing invariant and forces it to be written precisely enough to actually work.

**During active design this doesn't apply.** When a design is still being figured out, corrections are the work — you're discovering what the invariants are. Writing them down prematurely encodes the wrong design. The signal that it's time to document is when the same correction happens twice on a settled decision.

## Context poisoning

When the agent goes down a wrong path and gets corrected mid-session, the wrong reasoning stays in context. The correction establishes the right direction, but the earlier wrong reasoning keeps pulling — it's still there, just outvoted. Long sessions with mid-session corrections are especially vulnerable: by turn 50 the context contains both the right answer and a detailed record of all the wrong answers.

The fix is a fresh session. Write down what was learned, end the session, start a new one with the invariant loaded from turn 1 before any wrong reasoning exists. The agent can initiate this — if a significant correction just happened and the session has been long, proposing a handoff is the right call, not pushing through.

`/compact` helps at the margins but doesn't solve it: compaction summarizes the history, and wrong reasoning tends to survive summarization.

## Cost follows a power law

If you work across multiple projects, a small number of them will account for most of your usage. Optimizing the top 2–3 projects (better CLAUDE.md, quieter test output, shorter sessions) has more impact than perfecting everything else combined.

## Instrument your usage

Every intuition we had about what was expensive turned out to be wrong. We assumed build output was the biggest context consumer — it was unbounded file reads. We assumed subagents multiplied cost — they're cheaper per unit of work. We assumed long sessions were productive — they waste 40% of context on redundancy.

You can't fix what you can't see. Without data on your sessions, you're optimizing based on vibes. Even basic tracking — which sessions were long, which had many tool failures, which projects consume the most — turns wrong assumptions into correct ones.

The more granular your instrumentation, the more specific your fixes. Aggregate stats tell you *where* to look. Tool sequence analysis tells you *why* things are expensive. Sorting individual tool results by size tells you *what* to fix. Each layer of visibility produces a different class of insight.

## Multi-repo orchestration

When a change spans multiple repositories — updating a convention, propagating a rename, syncing docs — git status is the first thing to check, not the last.

**Dirty-repo protection.** Before touching any repo, check its working tree. For clean repos, make the change directly. For repos with uncommitted work, write the change to that repo's `TODO.md` and defer — don't interleave your changes with someone else's in-progress work. This keeps cross-repo changes from disappearing into noise.

```bash
git -C ~/git/org/repo status --short
# clean → make changes directly
# dirty → add to ~/git/org/repo/TODO.md
```

**Scope in commit messages.** When a commit touches multiple projects, the scope tells you which one to look at:

```
docs(normalize,moonlet): update install path after rename
feat(playmate): add component model primitives
```

This is especially useful in an org-level docs repo where commits describe changes that happened elsewhere.

**Docs-sync checklist.** Docs fall out of sync because updating them requires touching six places and it's easy to stop at two. Enumerate the places explicitly in CLAUDE.md — not as a reminder, as a checklist. For a new project: the project page, the project table in the overview, the sidebar config, the hero features list, the org profile README. Missing any one of them leaves a dangling reference somewhere.

**Deferred work survives sessions.** `TODO.md` in each repo is the cross-session handoff mechanism for that repo. When a session can't complete work in a repo (dirty tree, blocked dependency, out of scope), write to `TODO.md` rather than holding it in context or leaving a mental note. The next agent session in that repo sees it immediately.

## Unattended automation

Claude Code sessions don't have to be interactive. The `-p` flag runs headless with a prompt passed as an argument; `--dangerously-skip-permissions` skips all permission prompts. Together they enable sessions that run without human oversight — kicked off by a scheduler, a webhook, or a cron job.

The minimal pattern:

```bash
claude -p --dangerously-skip-permissions "your prompt here"
```

**Concurrency guard.** When a scheduler fires every minute, you need to prevent overlapping sessions. A lockfile with zombie detection handles this:

1. On startup: check for a lockfile. If present, verify recent session activity (check the `.jsonl` file mtime). If the session is active, exit. If the lockfile is stale (crashed session), kill the process group, remove the lockfile, continue.
2. Write the lockfile *before* spawning the session (so the next tick sees it immediately).
3. Session cleans up the lockfile when it exits cleanly.

**Pre-check before spawning.** Don't spawn a session for nothing. Query your inputs first — unread notifications, pending events, scheduled work — and only launch a session if there's something to act on. This keeps idle cost near zero.

```
timer fires every minute
  → check for activity (read-only API calls, no side effects)
  → nothing? exit immediately
  → something? write lockfile, spawn session
```

**Session lifecycle with nonces.** If sessions write state (logs, mood, counters), a nonce ties the start and end together cleanly:

```bash
# session start: write nonce to state file, print it
nonce=$(bun scripts/session.js start)

# pass nonce into the session prompt so the agent can end cleanly
claude -p --dangerously-skip-permissions "... run session.js end --nonce $nonce when done"

# session end script: verifies nothing new arrived, then exits 0
```

**Prompt via argument.** The `-p` prompt is the full session instruction. Structure it like a CLAUDE.md section rather than a conversational message: numbered steps, explicit tools, clear termination condition. The agent has no human to ask for clarification.

**When to use unattended sessions.** This pattern is appropriate for agents that have a well-defined loop (check → respond → commit → stop), operate on durable external state (a social platform, a monitoring target, a scheduled report), and have clear termination conditions. Open-ended exploration still benefits from interactive sessions.
