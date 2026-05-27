# H-CACHE-MASKS-DEGRADATION

**Status: CONFIRMED (epistemic constraint, not a behavioral finding)**

---

## Claim

Cache hit rates are so consistently high that model quality changes — regressions or improvements — produce no observable signal in any of the token-volume or cost metrics we currently track. Absence of metric change is not evidence of model stability.

---

## Predictions

1. Cache efficiency should be ≥93% across the 60-day window, consistently, with little variance across sub-periods.
2. Even first-turn messages within sessions should show large cache_read relative to raw input — meaning "novel context" sessions are nearly nonexistent.
3. H-MODEL-REGRESSION specifically cannot be falsified by aggregate token stats alone, because model outputs are generated from cached-context prompts that bypass the token counters dominated by that cache.

---

## Evidence For

### Cache Statistics (2026-03-20 → 2026-05-20)

| Metric | Value |
|--------|-------|
| Total input tokens | 3.4M |
| Total cache read tokens | 30,252.9M |
| Total cache write tokens | 727.5M |
| Cache efficiency | **100.0%** (displayed as 99.99% in raw JSON) |
| Cost without cache | $428,047 |
| Actual cost | $19,633 |
| Cache savings | $408,414 (95.4% of would-be cost) |

Across three sub-windows (Mar 20–Apr 10, Apr 10–Apr 30, Apr 30–May 20), cache efficiency reads **100.0% in every period** — no degradation, no noise. This is not 93–97%; it is effectively total saturation.

### Even First Turns Are Cache-Dominated

Sampling first-turn messages (turn-range 1-1) shows:

```
[in:8  out:1132 cache_read:92337  cache_create:1535]
[in:14 out:2620 cache_read:172322 cache_create:4189]
[in:6  out:36   cache_read:32443  cache_create:247]
[in:9  out:1516 cache_read:200685 cache_create:2278]
```

Ratio of cache_read to input: roughly **10,000:1**. The prompt that sees the model for the first time in a session is already 99.99% cached. There is no "novel-context" session class that provides a clean-room view of model quality.

### Metric Sensitivity Analysis

Metrics **not** sensitive to model quality changes under these conditions:
- Total token counts (dominated by cache_read, which is model-independent)
- Cost (same — 95%+ is cache savings, insensitive to output quality)
- Cache write volume (grows with session length, not with quality)
- Session counts, turn counts (structural, not quality)

Metrics that **are** partially sensitive:
- **Output token counts** — model responses are not cached; a model that produces longer or shorter outputs will show here. However, output length correlates weakly and noisily with quality.
- **Tool error rates** — if model quality drops and it makes more incorrect tool calls, errors-only sessions would capture this. This is currently tracked in stats but not baselined over time.
- **User-affect signals** — explicit corrections, frustration markers (searched via grep) are quality-sensitive. These bypass cache entirely.
- **Turn count per session** — more turns to reach a result is a weak proxy for model difficulty/quality.

---

## Caveats

- This hypothesis is epistemic, not behavioral. "Cache masks degradation" is only a problem if degradation exists and we need to detect it. The absence of a detection method does not assert that degradation is occurring.
- The 100.0% figure may be a display artifact of rounding at scale (raw JSON shows 99.98866%). Variance across sessions likely exists but is invisible in aggregates.
- High cache also means that if the model *improved* significantly in a new version, we also cannot detect it — the hypothesis is symmetric.
- Tool error rates and user-affect signals are genuinely cache-independent quality proxies, but neither has been baselined across the window. They could be extracted and would constitute the most direct quality signal available.

---

## Hypotheses Vulnerable to This Caveat

| Hypothesis | Vulnerability |
|------------|---------------|
| H-MODEL-REGRESSION | Cannot be tested by token volume or cost trends; would require error-rate or affect-signal analysis |
| H-CONTEXT-DRIFT | Token-based "context size" metrics are cache-inflated; actual novel-context per turn is tiny |
| H-PROMPT-SHAPE | Prompt length (as measured by token count) is almost entirely cached; model only sees a thin novel slice |
| H-DESIGN-CEILING | Any "quality" claim derived from session metadata (not output content) is cache-contaminated |

Hypotheses **not** vulnerable (they don't rely on quality metrics):
- H-GOVERNANCE-BREACH (behavioral: did the model do a forbidden thing — a binary outcome)
- H-MOMENTUM-LOSS (structural: session gaps, project stalls — calendar facts)
- H-CORRECTION-TAX (behavioral: same violation repeated — greppable)

---

## Queries Used

```bash
# Full-window aggregate cache efficiency
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  ~/git/rhizone/normalize/target/debug/normalize sessions cost \
  --all-projects --since 2026-03-20 --until 2026-05-20 --limit 0 --compact

# Sub-window cache efficiency (run 3x with different --since/--until)
CLAUDE_SESSIONS_DIR=... normalize sessions cost \
  --all-projects --since 2026-03-20 --until 2026-04-10 --limit 0 --compact

# First-turn message cache ratios
CLAUDE_SESSIONS_DIR=... normalize sessions messages \
  --all-projects --since 2026-03-20 --until 2026-05-20 \
  --limit 20 --show-usage --turn-range 1-1
```

---

## Red-Team Verdict

*(Not red-teamed in Phase B — this is an epistemic constraint, not a behavioral claim. Phase C adjudication retains it as confirmed.)*

---

## Adjudicated Status

**alive (confirmed epistemic constraint).** 100.0% cache efficiency across all sub-windows, 10,000:1 cache_read-to-input ratio even on first turns. This is not a hypothesis about what's wrong; it is the methodological constraint that determined what evidence was admissible in Phase A/B. It correctly predicted that H-MODEL-REGRESSION could not be killed by token-volume analysis alone — that hypothesis was killed instead by cache-independent signals (switch-direction, user-affect grep). The hypothesis's most important downstream implication: any future "is the model getting worse?" question must be answered with tool-error baselines, user-affect deltas, and turn-to-resolution metrics — not aggregate cost or token counts.
