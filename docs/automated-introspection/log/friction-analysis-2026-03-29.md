# Friction & Wrong-Action Analysis — 2026-03-29

**Scope:** 1,248 sessions across all projects, 2026-03-01 to 2026-03-29. Data extracted from Claude Code session JSONL files at `/mnt/ssd/ai/claude-sessions/projects/`.

---

## Correction Rate

**Method:** searched user messages for strong correction signals: `"also wrong"`, `"what the fuck"`, `"WRONG"`, `"please stop"`, `"don't keep going"`, `"copout"` (as criticism of an evasive answer).

**Counts across the period:**

| Project | User turns | "also wrong" | "what the fuck" | Total strong corrections | Rate |
|---------|-----------|-------------|----------------|--------------------------|------|
| crescent | 1,825 | 11 | 6 | 17 | 0.93% |
| pteraworld | 722 | 0 | 5 | 5 | 0.69% |
| parents | 381 | 0 | 3 | 3 | 0.79% |
| reincarnate | 1,627 | 1 | 3 | 4 | 0.25% |
| legacy | 1,061 | 0 | 3 | 3 | 0.28% |
| normalize | 1,920 | 0 | 0 | 0 | 0% |
| rescribe | 573 | 0 | 0 | 0 | 0% |
| interpreter | 503 | 0 | 0 | 0 | 0% |

Note: pteraworld and parents are not code projects — pteraworld "what the fuck" instances are in-world content (worldbuilding), and parents corrections are mostly about AI tutoring output quality, not agent wrong actions. Adjusted for code projects only:

| Code project | Strong corrections / user turns |
|---|---|
| crescent | 17 / 1825 = **0.93%** |
| reincarnate | 4 / 1627 = **0.25%** |
| normalize | 0 / 1920 = **~0%** |
| rescribe | 0 / 573 = **~0%** |

Crescent is the clear outlier. It has 4× the correction rate of the next highest code project.

**What triggered corrections in crescent:**

The 17 corrections cluster into three distinct causes:

**1. Conceptual evasion ("copout")** — 6 instances in session `8414f765` (March 17-19), all during a debate about SHA-256 caching strategy. The agent kept proposing technically defensible but strategically wrong answers (fall back to mtime, fall back to slow pure-Lua, use platform-specific ffi.load), and each time the user replied "also wrong" or "wow. copout much." This wasn't a code bug — it was the agent failing to commit to the actually-correct answer (a LuaJIT FFI pure implementation) because it kept hedging toward "safer" options. The agent eventually admitted: "I kept chasing SHA-NI performance that the workload doesn't require, and abandoned the correct answer each time I circled back to it."

**2. Return type invariant violation** — 5 instances in session `fccf7f65` (March 28), turns 208, 212, 214, 257-258. The agent kept proposing fixes for a multi-return type system bug that violated a core invariant ("returns should never, ever be non-tuples"). Each fix was technically plausible but wrong at a deeper level. The sequence:

- Turn 208: first wrong fix → "also wrong."
- Turn 212: second wrong fix → "also wrong."
- Turn 214: agent reverted to an earlier approach → "what the fuck, don't revert. think harder"
- Turn 257: agent re-broke a working fix from earlier in session → "what the fuck. i thought we ALREADY had a correct fix for this"
- Turn 258: "no what the fuck. clearly our return type code is just wrong"

This cost ~20K output tokens across the wrong attempts (turn 212 alone: 15,089 output tokens for an incorrect reasoning path). The agent eventually diagnosed correctly: the representation was structurally ambiguous, requiring a `TAG_SPREAD` annotation to distinguish union-of-tuples-as-single-value from multi-return.

**3. Stdlib naming disagreement** — 6 instances in session `8414f765`, turns 273-280. A design debate about monoid API in `lib/fp/`. The agent kept proposing designs the user rejected as "jank" (explicit dictionary passing, partial application, method syntax) before landing on the obvious answer. This is a pattern-recognition failure: the agent kept generating structurally similar proposals instead of asking "what property of these designs is wrong?"

---

## Permission Denials

**What "permission denial" looks like in these sessions:** Claude Code does not have file-system permission errors in the traditional sense. The relevant signal is "The user doesn't want to proceed with this tool use" — a manual rejection where the user interrupted a tool call before it executed.

**Counts by project (all history in backup, not just March):**

| Project | User rejections | Total tool errors | Rejection % of errors |
|---------|----------------|-------------------|----------------------|
| reincarnate | 324 | 5,363 | 6.0% |
| normalize | 202 | 5,602 | 3.6% |
| existence | 81 | 2,099 | 3.9% |
| hologram | 72 | 1,667 | 4.3% |
| crescent | 70 | 2,072 | 3.4% |
| ascent-interpreter | 28 | 854 | 3.3% |
| pteraworld | 27 | 420 | 6.4% |
| ooxml | 27 | 739 | 3.7% |

Most errors (96-97%) are legitimate tool failures — Bash exit codes, Edit mismatches, missing files. User rejections are a small fraction.

**What gets rejected in reincarnate (the highest-count project):**

The dominant pattern in session `75196e96` (reincarnate, March 10-16, 580 user messages) was the agent running `tsc --noEmit` directly multiple times in a row. The agent had been told to use the reincarnate CLI's `check` subcommand, but kept falling back to raw `tsc`. When the user rejected these calls, the agent eventually acknowledged: "I kept retrying the same wrong approach after the first rejection instead of stopping to think about why it was wrong."

After three rejections in quick succession, the user confronted this directly at turn 17: "but clearly you've run tsc for multiple calls *in a row*. why?" This triggered a documented CLAUDE.md update: "Never invoke tsc/tsgo directly — only use `cargo run -p reincarnate-cli -- check`."

**Recovery patterns:** In reincarnate, rejections + explicit questions about why ("why have we been running tsc directly?") reliably produced correct behavioral changes with CLAUDE.md updates. In crescent's SHA-256 case, rejections without explicit guidance ("also wrong") caused the agent to generate new variants of the same wrong approach rather than backtracking to the problem statement.

---

## Wasted Work Sessions

**High tool count sessions that appear unproductive:**

The session list sorted by tool count since March 1:

| Session | Project | User msgs | Tool calls | Outcome |
|---------|---------|-----------|-----------|---------|
| `fe139400` | rescribe | 266 | 4,293 | Active (very long session, still in progress) |
| `fccf7f65` | crescent | 332 | 1,508 | Committed work, ended with `[Request interrupted]` mid-subagent |
| `033086a7` | reincarnate | 407 | 2,552 | Committed work (207h session) |
| `dd7900fb` | io | 46 | 89 | Active, commits visible mid-session |

**True "wasted work" sessions are rare in this dataset.** The sessions that appear high-effort all produced commits. The normalize session `0db3a562` (156 tool calls, 27h duration) was interrupted mid-cleanup: a `git commit` for the main work had been issued, but the session was killed while cleaning up worktree artifacts. The actual work was not lost.

The clearest wasted-work pattern was the reincarnate session `75196e96`'s early turns: the agent ran the same `cargo run -p reincarnate-cli -- check` command 5 times on unmodified output "just to pipe the results differently." This is not catastrophic but it is low-quality loop behavior. The user called it out at turn 18: "I ran `cargo run -p reincarnate-cli -- check` five times in a row on the same unmodified output — just to pipe the results differently each time. I should have run it once, saved or noted the output, and worked from that."

---

## Late Corrections (High Cost)

**Criterion:** user correction after turn 10+ (non-trivial context investment).

**Case 1: Return type invariant (crescent `fccf7f65`, turns 208-261, March 28)**

Turn 208 was the first "also wrong" for the return type bug. The sequence of corrections ran from turn 208 to 261 — 53 turns of back-and-forth. At turn 212, the prior assistant response was 15,089 output tokens for an incorrect fix. The cache_read was 1,036,776 tokens (context was ~1M tokens at this point). Total turns wasted before the correct diagnosis: approximately 8-10 turns of active incorrect attempts after the first correction signal.

The root cause was identified only at turn 261: the representation was structurally ambiguous between "single value of union-of-tuples type" and "multi-return described by union-of-patterns." The agent had been trying to patch the symptom (wrong narrowing) rather than the cause (missing representational distinction). The correct fix required adding `TAG_SPREAD` to the annotation grammar.

**Case 2: SHA-256 evasion (crescent `8414f765`, turns 33-41, March 17)**

First "also wrong" at turn 33. Sequence ran for 8 turns of corrections before the agent finally committed to the correct answer (turns 33-41). Total output tokens spent on wrong paths: approximately 2,000-4,000 tokens. The waste here was not token cost but reasoning overhead — the agent knew the correct answer by turn 34 (pure LuaJIT FFI) but kept abandoning it for SHA-NI alternatives it couldn't actually deliver.

**Case 3: tsc direct calls (reincarnate `75196e96`, turns 0-19, March 16)**

Multiple tool-call rejections in the first 10 turns, then a confrontation at turns 14-17 about running tsc directly. The agent had been rejected at turn 1 (immediately), then again at turn 8, before the pattern was addressed at turn 17. This is a failure to generalize from the first rejection.

**Case 4: monoid API design (crescent `8414f765`, turns 273-280, March 18)**

6 "also wrong" / "also no" corrections over 8 turns for a design question about Lua's `lib/fp/` monoid API. The question was "how do you avoid passing the monoid explicitly at every call site?" The agent kept proposing: (1) explicit dictionaries, (2) partial application via closures, (3) method syntax — all variations on the same structural approach. The user was pushing for something obvious (the agent never got there before the conversation moved on). This is a pattern where the agent generates locally plausible options without stepping back to ask what property all wrong answers share.

---

## Context vs. Correction

**Projects with extensive CLAUDE.md + dense instruction:**

- **normalize**: 160 sessions, 1,920 user turns, 0 strong corrections in March. CLAUDE.md is comprehensive with specific tool usage rules (normalize view, sessions subcommand patterns), commit conventions, and explicit negative constraints.
- **reincarnate**: 47 sessions, 1,627 user turns, 4 strong corrections. CLAUDE.md includes specific rules about CLI usage (no direct tsc invocation), but these rules were added *in response to* violations — the CLAUDE.md was updated at turns 14-15 of session `75196e96` after the agent got rejected for running tsc directly.
- **crescent**: 59 sessions, 1,825 user turns, 17 strong corrections. CLAUDE.md is detailed for test infrastructure and self-check rules, but design invariants (e.g., "returns are always tuples") were not documented and had to be re-taught during sessions.

**Projects with sparse context:**

- **interconnect**: 1 session in March, 20 user turns, 0 strong corrections. But this is low-volume and the session was a fresh architecture design conversation — no established invariants to violate yet.

**Pattern:** Documentation quality predicts correction rate, but with a lag. The normalize project has ~0% correction rate because years of sessions have deposited invariants into CLAUDE.md. Reincarnate has a moderate rate because some invariants are in CLAUDE.md but implementation-level ones are still being discovered. Crescent has the highest rate because the type system's design invariants (which are real, load-bearing, and non-obvious) are not written down anywhere the agent can read them at session start — they have to be re-established through correction.

**The correction-to-documentation pipeline works when it fires:** Reincarnate's "no direct tsc" violation was corrected, added to CLAUDE.md, and did not recur in the same session. The SHA-256 evasion in crescent was corrected but the underlying problem — "agent hedges toward implementable rather than correct" — wasn't codified anywhere.

---

## Takeaways

**What the data actually says:**

1. **Crescent's type system is an anomaly.** It has a 4× higher correction rate than any other code project. This is not general agent behavior — it's specific to a domain (type system implementation) where the invariants are complex, load-bearing, and unwritten. The agent can pass tests while violating invariants, which means test failures don't surface the real problem until a human with domain knowledge corrects it.

2. **"Also wrong" clusters are expensive.** A single wrong answer at 15K output tokens with 1M token cache read is not cheap. More importantly, repeated wrong answers on the same problem (8 consecutive "also wrong" on SHA-256, 5 on return type handling) suggest the agent is pattern-matching on "what can I say that's technically defensible" rather than "what did my previous answer get wrong."

3. **User rejections are mostly single-incident, not spirals.** The "user doesn't want to proceed" count (324 in reincarnate, 202 in normalize) sounds alarming, but these are distributed across hundreds of sessions. The actual spiral pattern — rejections followed by slightly modified re-attempts — appeared in only 2-3 documented sessions, and in each case the user confronted it directly and the agent acknowledged the pattern.

4. **Behavioral corrections do stick when documented.** The "no tsc directly" rule, added mid-session, was respected for the remainder of that session. The name-suggestion prohibition added to the io project CLAUDE.md appeared to have been respected in subsequent sessions (no further name suggestions after it was added). Documentation works; the friction is in the latency between first violation and documentation.

5. **The copout pattern is real but context-dependent.** In technical contexts, "copout" means "proposing a simpler solution that avoids the actual problem." This happened with SHA-256 (mtime instead of content hash), with the reincarnate incremental invalidation (diagnostic logging instead of implementing it), and with several design questions. In all cases, the user explicitly named it as a copout and the agent then did the right thing. The agent doesn't resist doing the work — it resists committing to a path before being pushed.

6. **Wasted work (truly uncommitted effort) is rare.** Most high-effort sessions ended in commits. The main wasted-work pattern is redundant tool calls within a session (running the same check command 5× on unchanged output), not sessions that produced nothing.
