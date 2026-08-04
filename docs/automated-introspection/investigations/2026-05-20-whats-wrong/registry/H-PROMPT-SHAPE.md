# H-PROMPT-SHAPE

## Claim

Certain prompt patterns — overlong CLAUDE.md, conflicting system reminders, hook noise — measurably degrade output quality. Projects with the largest CLAUDE.md files should show higher frustration and error rates than structurally similar projects with leaner context.

## Predictions

1. High-frustration projects (crescent, normalize, hologram) have larger CLAUDE.md than low-frustration projects.
2. System-message density (skill/hook injections per session) correlates with error rate.
3. Projects with minimal CLAUDE.md show lower pushback rates even on comparably complex work.

## Evidence For

**CLAUDE.md sizes for high-frustration projects** (from audit covering 2026-04-15 to 2026-05-13, 228 strong pushback events):
- crescent: 32,591 bytes — 45% of all frustration events (103/228), 5 sessions with >10 pushback events each
- normalize: 18,859 bytes — 7% of events
- hologram: 23,269 bytes — 8% of events
- reincarnate: 15,307 bytes — 10.5% of events

**Structurally simpler low-frustration projects for comparison:**
- ascent-interpreter: 14,991 bytes, 2.0% tool error rate, <5 frustration events
- ooxml: 12,255 bytes, 3.4% tool error rate, <5 frustration events
- server-less: 15,722 bytes, 3.5% error rate, <5 frustration events

**System message density** (skill/hook injections, role=system, measured per session):
- unshape: 0.74/session (26 system msgs / 35 sessions)
- aspect: 0.52/session (32 / 61)
- crescent: 0.46/session (47 / 103)
- ooxml: 0.48/session (22 / 46)
- fuwafuwa: 0.005/session (13 / 2424) — autonomous agent, almost no injections

High system-message density does not correlate cleanly with frustration: ooxml has 0.48 injections/session but minimal pushback; fuwafuwa has near-zero injections but 55 frustration events (driven by memory-system complaints, not prompt shape).

**Crescent's CLAUDE.md accumulation pattern is itself evidence.** The audit found multiple sessions where the dominant user trigger was Claude reactively proposing CLAUDE.md additions after single failures ("STOP. NO BANDAIDS, WHAT THE FUCK"). A bloated CLAUDE.md is both symptom and amplifier: it grows because violations happen, and growing it creates more surface for future conflicts.

**Session b2f1c01b (github-io, 2026-05-13)** — the current investigation session — arrived with multiple system-reminder injections (deferred-tools, skill-list, environment reminder) on every turn. This is not quantitatively tied to an outcome quality difference in available data, but is the prompt-shape the hypothesis was designed to test.

## Caveats

**Major confound: complexity, not size.** Crescent (32KB CLAUDE.md) is a Lua type system with deep design constraints; ooxml is a well-specified format library. The frustration differential is equally explained by task complexity and design ambiguity. A CLAUDE.md that is large *because the domain is complex* may be large for legitimate reasons.

**CLAUDE.md size is not context noise.** The global CLAUDE.md (`~/.claude/CLAUDE.md`, 516 bytes) is trivially small. Project CLAUDE.md sizes (12–32KB) are substantial but not clearly above a model's attention threshold. There is no measurement of whether rules in a 32KB CLAUDE.md are followed less often than rules in a 12KB one.

**System-reminder density does not correlate with frustration.** The analysis found fuwafuwa (0.005 injections/session) with high frustration; ooxml (0.48/session) with near-zero. Hook noise appears uncorrelated with user affect in this data.

**`system-reminder` tag not found in session messages.** Searching for the literal string "system-reminder" across 4,656 sessions returned 2 results (both discussing the mechanism, not injected by it). The harness likely injects skill/hook content into system-role messages without the tag being preserved in `.jsonl` logs, limiting direct measurement.

**Causation unresolvable.** Even if large-CLAUDE.md correlates with frustration, the causal arrow likely runs: complex project → frustrated user → accumulated rules → large CLAUDE.md. This hypothesis cannot distinguish that from: large CLAUDE.md → model confusion → frustration.

## Queries Used

```bash
# System-reminder tag grep (returned 2 results, both incidental)
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --grep "system-reminder" --all-projects \
  --since 2026-03-20 --until 2026-05-20 --limit 0

# System-role message counts (used to compute per-session density)
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --role system --all-projects \
  --since 2026-03-20 --until 2026-05-20 --limit 0 \
  | grep "^\[" | grep -oE "\] [a-z-]+ " | sort | uniq -c | sort -rn

# Per-repo error rates and session counts
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions stats --by-repo --limit 0 \
  --since 2026-03-20 --until 2026-05-20

# Frustration signal grep (sourced from prior audit in session b2f1c01b)
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --grep "wrong" --all-projects --role user \
  --since 2026-03-20 --until 2026-05-20 --limit 20

# CLAUDE.md sizes
find /home/me/git -name "CLAUDE.md" -maxdepth 3 | xargs ls -la | sort -k5 -n
```

## Status

**Wounded.** The size correlation exists (crescent is both largest CLAUDE.md and highest frustration), but the confound is too strong to separate from task complexity. The hook-noise sub-claim is not supported: system-reminder injection is either not logged in a searchable form or uncorrelated with frustration. The reactive-bandaid pattern — where frustration *causes* CLAUDE.md growth, not the reverse — is better evidenced than the causal direction this hypothesis requires. Recommend treating CLAUDE.md bloat as a symptom tracked under **H-CORRECTION-TAX** rather than an independent cause.

## Red-Team Verdict

**Kill confirmed. The hypothesis does not survive independent investigation.**

**Counter-examples break the size-frustration correlation.** Direct measurement across 2026-03-20 to 2026-05-20 finds no monotonic relationship between CLAUDE.md size and tool error rate:

| Project | CLAUDE.md lines | Sessions | Success rate |
|---------|----------------|----------|--------------|
| rescribe | 502 | 28 | 96.6% |
| server-less | 311 | 53 | 96.5% |
| hologram | 367 | 338 | 92.5% |
| crescent | 256 | 103 | 96.1% |
| normalize | 185 | 269 | 95.0% |
| ascent | 143 | 38 | 98.0% |
| wick | 105 | 12 | 96.4% |

Rescribe (502 lines, the largest CLAUDE.md found) shows *higher* success than crescent (256 lines, highest frustration per the prior audit). Success rates cluster 95–97% regardless of prompt size. The 92.5% outlier is hologram, a Discord bot with 338 sessions — more plausibly explained by external API variability than prompt length.

**Hook noise is not measurable and possibly near-zero.** The chain-blocking hook's own debug log shows one denial across the entire investigation window — and that denial was generated by this red-team session itself. No historical hook refusals appear in the searchable session record. Hook noise cannot degrade output you cannot find evidence of.

**The fuwafuwa 55 events are definitively not prompt-shape complaints.** Fuwafuwa is a fully autonomous agent: its "user" turns are scheduled wake messages (`you're fuwafuwa. autonomous session...`), not human feedback. There is no human present to express frustration. The "55 frustration events from a different cause" the prior agent identified are the May 2026 memory-system poisoning complaint cluster (`"it is invisible and is actively poisoning context permanently"`) — a complaint about MCP memory tools writing into context, not about CLAUDE.md length or hook noise.

**The one genuine prompt-shape complaint is a rescue attempt, not evidence.** Session b2f1c01b (2026-05-12) contains `"can we tidy up CLAUDE.md btw? all this fluff is proving problematic for attention"` — a user explicitly naming prompt verbosity as causing attention degradation. This is the strongest signal for the hypothesis. However: (1) it is a single event; (2) it occurred mid-session after substantive work, not as a session-opening failure; (3) the prior audit identified this session as one where CLAUDE.md had already grown reactively from accumulated violations. The causation is indistinguishable from the confound.

**Conclusion:** The sub-claims disaggregate cleanly. Size-frustration: confounded and directionally wrong in the available data. Hook noise: undetectable, possibly zero at current threshold settings. System-reminder density: already shown uncorrelated by the prior agent. The hypothesis as stated — that prompt patterns *measurably degrade output* — has no measurement supporting it. The single real signal (b2f1c01b user quote) shows user-perceived attention degradation, but cannot be isolated from task complexity or the reactive-growth confound. Treat as dead.

---

## Adjudicated Status

**dead as causal claim; survives only as a symptom.** The red-team's per-project table is the killer evidence: rescribe (502 CLAUDE.md lines, 96.6% success) outperforms crescent (256 lines, lower success), and overall success rates cluster 95–97% regardless of size. The causal arrow runs *complex domain → frustration → reactive CLAUDE.md growth*, not the reverse. The 2026-05-12 "all this fluff is proving problematic for attention" comment is real but n=1 and confounded. Importantly: the reactive-bandaid mechanism this hypothesis named is *real*, but its home is H-CORRECTION-TAX, where it appears as the reactive-CLAUDE.md-bandaid violation class. Prompt-shape as an independent ecosystem-level driver is not supported.
