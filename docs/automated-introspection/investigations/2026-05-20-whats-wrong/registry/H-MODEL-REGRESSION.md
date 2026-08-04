# H-MODEL-REGRESSION

**Claim:** Opus 4.7 (or a recent model) is meaningfully worse at certain task classes than predecessors, causing a detectable quality drop in the ecosystem.

**Predictions:**
- Direct user complaints naming a model version as worse
- Quality degradation correlated with model-switch events
- Higher tool error rates or output-token volatility post-model-release

---

## Evidence For

1. **Single explicit model-UX complaint (2026-05-13).** User states: "CLEARLY claude code's harness is not designed for sonnet top level agents at all" and requests switching to opus for main sessions + design subagents. This is the strongest signal: the user perceived Sonnet-as-main-agent as structurally inadequate — but note this is about *harness fit* (sonnet as orchestrator) not a version regression.

2. **Repeated "use opus subagents to not fuck it up this time" (2026-05-06).** Implicit that prior Sonnet-delegated subagent work underperformed. Context: io session, delegating a non-trivial task. Suggests opus is perceived as more reliable for complex subagent work.

3. **"maybe opus would do better" (legacy, 2026-03-22).** Passing comment about writing quality — opus vs. unspecified predecessor. Weak; said jokingly.

---

## Evidence Against

- **No version-specific regression complaints.** Zero user messages name "4.7" or "Opus 4.7" as worse than a predecessor. The single 4.7 model-name occurrence in logs is a local-command output showing the switch *to* Opus 4.7, not a complaint about it.
- **Model switches are improvements, not regressions.** Every observed switch event is user requesting opus *upgrade* (crescent 2026-04-20, io 2026-05-13, multiple subagent dispatches). Direction is consistently "switch to opus to fix things," not "switch away from opus because it got worse."
- **Pushback audit found no model-version correlation.** The 228 strong-pushback events concentrate in crescent (45%) and io (24%) and are explained by task-class hardness and harness behavior (overconfidence, reactive CLAUDE.md patching, tunnel vision) — not by model version changes.
- **Tool error rate is high (114k lines over ~60 days) but not model-attributable.** The errors are dominated by cargo test/clippy/bench retry loops in ascent-interpreter and long debug cycles in crescent — both structural, not correlated with any model release boundary.
- **No temporal intensification signal.** Frustration markers are spread across the window with crescent as the constant. No inflection point maps to a plausible model release date.

---

## Caveats

- Cache reuse is 99.99% (9000:1 cache_read:input ratio); token volume stats are blind to quality. This analysis was restricted to output tokens, tool errors, and user-affect signals per instructions.
- The corpus has no explicit model-version tagging per turn, so per-model quality comparison is impossible without session-level metadata.
- "Sonnet as orchestrator is wrong" is a harness-fit argument, not a model-regression argument. It predicts opus > sonnet for orchestration — not that any model has gotten worse over time.

---

## Queries Used

```bash
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --all-projects --role user \
  --since 2026-03-20 --until 2026-05-20 \
  --grep "model|opus|sonnet|haiku|worse|dumber|regression|4\.7|4\.5|4\.6" \
  --compact --limit 0

CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --all-projects --role user \
  --since 2026-03-20 --until 2026-05-20 \
  --grep "switch.*opus|use opus|not fuck it up|CLEARLY claude|sonnet top level|sonnet is|haiku is" \
  --compact --limit 0

CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --all-projects --errors-only \
  --since 2026-03-20 --until 2026-05-20 --compact --limit 0
```

---

## Status

**dead**

No evidence of version-specific regression. User affect signals are explained by task hardness (crescent typechecker, complex subagent orchestration) and a harness-fit issue (Sonnet as main orchestrator). Model switching is universally *toward* opus as an upgrade, never away from a recently degraded model. The hypothesis cannot be distinguished from "hard tasks are hard."

---

## Adjudicated Status

**dead.** Phase A populated and immediately killed the hypothesis; nothing in Phase B contradicts. The one real signal (the "harness not designed for Sonnet top-level agents" complaint on 2026-05-13) is a harness-fit observation, not a version regression — and it points outward toward H-PROMPT-SHAPE / orchestration design, not at a degraded model. The user's framing "Claude Code is performing worse" is not supported as a model-version claim. H-CACHE-MASKS-DEGRADATION correctly notes that aggregate token metrics could not detect a regression if one existed, but the cache-independent signals (tool errors, user-affect grep, switch direction) all point the same way: no version regression observable.
