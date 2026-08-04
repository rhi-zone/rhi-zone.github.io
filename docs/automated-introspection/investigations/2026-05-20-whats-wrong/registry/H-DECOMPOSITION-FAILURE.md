# H-DECOMPOSITION-FAILURE

## Claim

Parallel subagent dispatch succeeds when subtasks are genuinely independent (separate files, separate libraries), but fails silently when they share mutable state (a single evolving IR file, a multi-phase rewrite). In the failing case, each subagent fixes the world as it read it; later subagents overwrite earlier fixes or operate on stale assumptions. The symptom is repeated re-dispatch of the same logical task — not retries after error, but the orchestrator dispatching again because the prior result didn't hold.

## Predictions

1. High-subagent sessions in reincarnate and crescent show duplicate task dispatch at meaningfully different rates.
2. The duplicated tasks in reincarnate target a small set of shared files (not a broad task surface).
3. A postmortem or "failed" signal exists for a session with high duplicate dispatch.
4. Crescent's library-building sessions (truly isolated subtasks) show near-zero duplication and no postmortem.

## Evidence For

**Session `033086a7` — Reincarnate Phase 1–7 Rewrite (199 subagents, 407 user messages, 207h)**

This is the clearest case. The session executed a planned 7-phase rewrite of Reincarnate's IR and type system. Subagents were dispatched to implement each phase, but phases are not independent: Phase 2 transforms depend on Phase 1 IR types; Phase 3 pass manager depends on Phase 2; etc.

Duplicate dispatch analysis:
- `type_infer.rs` edits: 6 subagents with near-identical prompts
- `Type::Struct(String)` removal: dispatched at least 4 times with slightly different wording ("delete", "completely remove", "completely eliminate", "remove all uses of")
- `TypeDecl` redesign: 2× dispatch
- Phase 1 implementation: 3× dispatch (incremental rewrite v1, clean rewrite v1, incremental rewrite v2)
- Phase 2: 2× dispatch; Phase 5: 2× dispatch; Phase 6: 2× dispatch; Phase 7: 2× dispatch
- Build/clippy/test runners: dispatched 5× with nearly identical prompts

User-visible signals of breakdown embedded in subagent first_messages:
- `agent-acompact-1884bd7c854b7ffa`: `"both agents running is... perhaps concerning"`
- `agent-acompact-8e2b501d559ff9a3`: `"???????????????????????? two agents doing the same thing?"`
- Explicit postmortem: `agent-a65afb34f3da35f38`: `"Do a postmortem on why the 'Phase 1–7 rewrite' of the Reincarnate decompiler failed to meet its goals."` (30 tool calls)

**Session `9e8bf1e4` — Reincarnate HM Type Inference (149 subagents, 200 user messages, 380h)**

Same pattern, different scope. This session attacked `constraint_solve_hm.rs` directly. That single file received 12 distinct "edit this file" dispatches, plus 8 more under slightly different prompts. A revert subagent (`agent-aaea5a9a03692834b`) was dispatched to undo a prior agent's work on `constraint_collect.rs`. The revert itself is direct evidence of integration failure: a prior agent's change was incompatible with subsequent state.

**Contrast — Session `74176a04` — Crescent Library Building (443 subagents)**

443 subagents built Lua libraries for the crescent monorepo. Each library is genuinely isolated (separate directory, no cross-library dependencies in the build tasks). Deduplication check: 443 total tasks, 429 unique first-message prefixes (14 duplicates = 3.2%). The 14 duplicates are retries on failed builds, not integration collisions. No postmortem. No user signals of breakdown.

This is the clean-parallel baseline: dispatch works when subtasks don't share mutable state.

## Caveats

- The reincarnate sessions are extremely long (207h, 380h of elapsed time). Some duplicate dispatch may be deliberate re-attempts after the user reviewed intermediate output, not silent failure. The user was present.
- "Both agents doing the same thing" appears as a subagent first_message, suggesting the user noticed and commented inline — but we cannot confirm from first_message alone whether this caused a coordination failure or was caught before damage.
- The crescent typechecker error-reduction session (`c0dbc248`, 259 subagents) shows high duplication (e.g., "Sequential type-error cleanup worker" dispatched 65 times) but this appears intentional — sequential workers processing a queue, not parallel agents racing. The distinction matters: sequential-with-queue is not decomposition failure even if re-dispatched.
- We cannot see actual commit history or diff outcomes from this data — we infer integration failure from re-dispatch patterns and explicit postmortem presence, not from direct observation of conflicting edits.
- Cache caveat: high cache hit rates mean subagents may all be reasoning from the same cached context snapshot, making shared-state bugs invisible until runtime.

## Queries Used

```bash
# Find top parent sessions by subagent count
jq '.sessions | map(select(.parent_id != null)) | group_by(.parent_id) | map({parent_id: .[0].parent_id, count: length}) | sort_by(-.count) | .[0:20]' /tmp/subagents_json.txt

# Identify project for each top parent
jq '[.sessions[] | select(.parent_id == "033086a7-0c1f-4180-96b9-d18f271473cb")] | .[0:3] | map({path, first_message: .first_message[:120]})' /tmp/subagents_json.txt

# Find duplicate task dispatch in reincarnate sessions
jq '[.sessions[] | select(.parent_id == "033086a7-0c1f-4180-96b9-d18f271473cb") | .first_message[:80]] | group_by(.) | map(select(length > 1)) | map({msg: .[0], count: length})' /tmp/subagents_json.txt

# Find "both agents" / "two agents" user signals
jq '[.sessions[] | select(.parent_id == "033086a7-0c1f-4180-96b9-d18f271473cb") | select(.first_message != null) | select((.first_message | contains("two agents")) or (.first_message | contains("both agents")))] | map({id, first_message: .first_message[:200]})' /tmp/subagents_json.txt

# Count unique vs total in crescent clean-parallel case
jq '[.sessions[] | select(.parent_id == "74176a04-2b9b-4ac1-9c88-9d88d28511f5") | select(.first_message | startswith("Build `lib/"))] | map(.first_message | split("`")[1]) | unique | length' /tmp/subagents_json.txt

# Generate session list for analysis
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects ~/git/rhizone/normalize/target/debug/normalize sessions list --all-projects --mode subagent --limit 0 --json > /tmp/subagents_json.txt
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects ~/git/rhizone/normalize/target/debug/normalize sessions list --all-projects --mode all --limit 0 --json > /tmp/all_sessions.json
```

## Status

**Alive — well-supported.**

The reincarnate Phase 1–7 rewrite session (`033086a7`) is a confirmed case: multi-phase interdependent rewrite, high duplicate dispatch of the same tasks, explicit user signals of concurrent agent confusion, and a dedicated postmortem subagent. The 149-subagent HM type inference session (`9e8bf1e4`) shows the same pattern at smaller scale with an explicit revert as evidence of integration failure. The crescent library-building session (`74176a04`, 443 subagents, 3.2% duplication) is a clean positive case showing parallel dispatch works when tasks decouple.

The mechanism is consistent: agents dispatched to edit shared evolving files each read the file at dispatch time, apply their change, and commit. A subsequent agent reads the post-commit state, finds their assumed preconditions violated (or satisfied differently), and is re-dispatched. The orchestrator has no transactional view across parallel agents.

**Interaction with H-DESIGN-CEILING:** Both hypotheses activate on the same sessions. Distinguishing them requires asking whether the rewrites failed because of architectural complexity (design ceiling) or because parallel subagents clobbered each other's progress. The postmortem evidence and re-dispatch patterns suggest decomposition failure is a proximate cause independent of design ceiling.

## Red-Team Verdict

**Partially falsified on mechanism; core claim survives.**

Three falsification angles investigated:

**1. Reincarnate dispatches were sequential, not parallel.** Examining subagent metadata for sessions `b7bb63a1` (IntrinsicKind elimination) and `e0005489` (with-block inlining) shows clearly labeled sequential phases (Step A → A-remainder → B plan; Phase A → B → C), not concurrent parallel dispatch. The implement/revert cycles in `459550c8` (`param_lower_bounds` implemented, reverted, re-implemented three times) are sequential orchestration iterations, not agents racing on shared state. The hypothesis labels these as "parallel decomposition failure" but the actual failure mode is better described as H-CONTEXT-DRIFT: the orchestrator re-dispatching on stale assumptions about what prior agents accomplished, not multiple agents simultaneously clobbering the same file.

**2. Positive cases for parallel dispatch on coupled tasks are sparse.** The normalize `00f33df1` session (15 subagents, explicitly parallelized) worked cleanly and was user-ratified ("nice. let's continue?" / "alright, time to flesh out the fixtures"). But those subagents worked on different language fixture files — genuinely decoupled. The normalize `b638eaa2` session (70 subagents) used worktrees for isolation on shared-state tasks, suggesting the ecosystem has already adapted to the problem. No confirmed case of parallel agents succeeding on truly coupled shared state was found.

**3. High subagent counts correlate with frustration, not success, in reincarnate.** Sessions `b7bb63a1`, `e0005489`, `459550c8`, and `1510181d` all show user frustration signals ("you fucking idiot", "why the fuck", "guessing"). The hypothesis is correct that something is failing; the question is whether it's parallel-dispatch collision or sequential-context-drift. The subagent metadata shows sequential phasing, but the outcome (repeated re-dispatch) matches either mechanism.

**Conclusion:** The core claim — parallel dispatch works when tasks decouple, fails when they share state — is supported. But the "failing" reincarnate sessions appear to fail through sequential re-dispatch with context drift, not through literal parallel collision. The hypothesis conflates two distinct failure modes into one mechanism. The crescent positive case (`74176a04`) and normalize positive case (`00f33df1`) both succeed because of genuinely decoupled task surfaces, confirming the independence requirement. Reformulate: the failure mode is orchestrator context loss causing re-dispatch on stale assumptions, which is most severe (and most likely to be attributed to decomposition failure) when subtasks share mutable state.

---

## Adjudicated Status

**alive (reformulated).** The mechanism is real but the red-team's reformulation is correct: in the cited reincarnate sessions the agents were sequentially dispatched, so the failure mode is *orchestrator stale-state*, not literal parallel collision. The strongest specific evidence is `agent-a65afb34f3da35f38`, an explicitly dispatched postmortem on a failed multi-phase rewrite — that subagent exists only if the orchestrator already knew the rewrite had failed. Pair with the `74176a04` clean-parallel case (443 subagents, 3.2% duplication, no postmortem): the independence axis is the discriminator. The reformulated claim is: *orchestrator-level state evolves under subagent work, and the orchestrator does not consistently re-read shared mutable state before each dispatch, producing re-dispatch on stale assumptions*. This is a sibling of H-CONTEXT-DRIFT but at the orchestrator scope rather than the per-turn scope — the orchestrator's "context" is the set of assumptions about completed subagent work, which decays the same way in-session context does.
