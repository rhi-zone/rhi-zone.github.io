# H-CORRECTION-TAX

## Claim

The same user constraints and preferences are re-violated across sessions because there is no cross-session learning. CLAUDE.md is insufficient to encode the full generator that produces correct behavior. The user pays a recurring correction tax: the same objection surfaces in session after session, unprompted by new code.

## Predictions

1. The same correction phrase (e.g. "stop being overconfident", "no bandaids", "don't tunnel vision") should appear in multiple sessions separated by days or weeks — not just within one long session.
2. The corrections should cross session boundaries, meaning the prior session where the same correction was issued cannot have propagated the learning forward.
3. At least some correction categories should appear in CLAUDE.md (evidence the user tried to encode them), yet still recur afterward.
4. The rate should be higher in projects with implicit domain constraints that resist CLAUDE.md encoding (crescent's type system, io's aesthetic).

## Evidence For

### 1. Overconfidence — 7 sessions, 3 projects, 2 months

"stop being so overconfident" (`01805bae` crescent 2026-04-12), "why so overconfident" (`4b24c1b4` crescent 2026-04-20), "stop being so fucking overconfident" (`6842c90d` io 2026-04-26), "stop being so overconfident" (`b46aa6f5` io 2026-05-02), "the problem is that you are fucking overconfident" (`4b24c1b4` crescent 2026-04-21), "way too overconfident" (`75196e96` reincarnate 2026-03-15), "stop making things up" (`9501a0b0` crescent 2026-05-11).

The global CLAUDE.md now has a "Counterweight: don't fake confidence" rule — evidence the user encoded this explicitly. Despite the rule existing, the correction recurred in sessions dated after it was written, in both crescent and io.

### 2. Reactive CLAUDE.md bandaids — 5 sessions, 3 projects

"STOP. shut up and STOP suggesting bandaids" (`9501a0b0` crescent 2026-05-12), "NEVER reactively suggest bandaid additions to CLAUDE.md" (`d4565916` crescent 2026-05-13), "don't do it in an ad-hoc/bandaid way" (`c0dbc248` crescent 2026-05-03), "verdict: bandaid" (`37565687` io 2026-04-27), "every correction → CLAUDE.md edit" listed as egregious (`e0005489` reincarnate 2026-04-27). A commit (`441c6ec`) deleted the reactive-bandaid rule — confirming the behavior was encoded, violated, corrected, the rule deleted, yet the behavior recurred in new sessions.

### 3. Tunnel vision / not thinking — 8+ sessions

"stop tunnel visioning" (`6842c90d` io 2026-04-25–26, multiple messages), "don't tunnel vision" (`dfd5bcca` crescent 2026-04-25), "i don't want to miss tunnel visioning" (`5c07a067` io 2026-04-24), "still tunnel visioning" (same session, after correction), "are you even thinking before suggesting" implied across crescent sessions `01805bae`, `13276225`, `cabdea3b`. The correction appears in at least 5 distinct sessions spanning 3 weeks.

### 4. Memory system misuse — 3 projects, ongoing

"why are you using the memory system. at all." (`9501a0b0` crescent 2026-05-12), "what the hell. why are you using memory" (`74867717` hologram 2026-05-03), "don't fucking undo the edit. why does memory exist at all." (same session), "make sure we don't use memory at all" (`bf390fa6` pteraworld 2026-05-02). No-memory is documented in CLAUDE.md; violations continue in multiple projects.

### 5. Specialcasing instead of generalizing — 3 sessions

"special cases? what the fuck" (`4b24c1b4` crescent 2026-04-19), "any specialcases that can be generalized is context poisoning" (same session, 2026-04-21), "don't you dare fucking specialcase it" (`9501a0b0` crescent 2026-05-11). Same correction, same project, three weeks apart.

### 6. Scale: 68 unique sessions across 60 days carry at least one of these five markers

A prior audit (subagent in session `b2f1c01b`) counted ~228 user turns matching strong pushback markers (3.5% of all user turns, 2026-04-15 to 2026-05-13), with crescent alone accounting for 45% (103/228). At least 5 crescent sessions each had >10 pushback events — structural, not one-off.

## Caveats

1. **Project complexity confound.** Crescent has the highest density of corrections because it has the deepest implicit design constraints (typed Lua semantics, no-specialcase principle). Violations may be inevitable when CLAUDE.md cannot fully encode a domain's design philosophy — the tax is not purely from absent learning, but from unrepresentable constraints.

2. **"Overconfidence" may be ambient model behavior, not project-specific.** The corrections span projects (crescent, io, reincarnate, hologram), which suggests the failure mode is model-level, not CLAUDE.md-encodable at all. If so, the hypothesis is partially correct (no cross-session learning) but the fix isn't more CLAUDE.md — it's a different mechanism.

3. **Some corrections do propagate.** Commits exist that encode corrections (the confidence rule, the deleted reactive-bandaid rule). These are evidence the encoding loop sometimes works. The issue is that (a) many preferences resist encoding, (b) the encoded rules are themselves sometimes deleted after over-encoding, and (c) encoded rules don't prevent violations in the same session they're added.

4. **The `no.` / terse rejection signal is noisy.** Many occurrences of `no.` are worldbuilding disagreements (io sessions), not Claude Code corrections. The strong-marker grep is a better signal.

5. **Undercount risk.** The ~3.5% pushback rate is a floor; calm corrections ("that's not what I mean") don't match these patterns.

## Queries Used

```bash
# Core correction patterns
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --all-projects --role user \
  --since 2026-03-20 --until 2026-05-20 \
  --grep "overconfident|making things up|bandaid|tunnel vision|specialcase" \
  --limit 0 --compact

# Count unique sessions
... | grep "^\[" | sed 's/\[//;s/\].*//' | sort -u | wc -l

# Memory misuse
--grep "why are you using.*memory|what the hell.*memory|memory.*at all"

# Bandaid pattern
--grep "bandaid|band-aid"

# Terse no.
--grep "no\."
```

## Status

**alive**

The hypothesis is strongly supported. Five distinct correction categories each recur across 3–7 sessions separated by days to weeks, spanning multiple projects, with direct evidence that at least three categories (overconfidence, bandaids, memory misuse) were encoded into CLAUDE.md yet violations continued afterward. The strongest finding: the reactive-bandaid rule was added in response to violations, then deleted because the rule itself was a bandaid, then the behavior recurred — a meta-loop that illustrates the core claim precisely.

---

## Red-Team Verdict

**Status: survives — but with a materially weakened overconfidence arm.**

**Strongest disconfirming evidence:**

The populating agent's core claim for overconfidence is "the rule existed, yet violations continued." This is factually wrong for crescent. The crescent-specific "Counterweight: don't fake confidence" rule was not added until commit `7521987c` on 2026-05-13. Every cited overconfidence correction in crescent (`01805bae` Apr 12, `4b24c1b4` Apr 19–20, `b46aa6f5` May 2, `9501a0b0` May 11) predates the rule. The rule was a *response* to the pattern, not a failed prevention of it. Crucially: zero "overconfident" corrections appear in the corpus after May 13, when the rule went live. This is the opposite of what the hypothesis predicts — one data point where CLAUDE.md encoding *did* stop a recurrence.

**Why the populating agent over-weighted the evidence:**

1. "Tunnel vision" is heavily polluted by non-correction usage. Many instances are the user describing their own tunnel vision, worldbuilding discussion, or io creative sessions — not Claude Code behavioral corrections. The "8+ sessions" count conflates these.
2. The corrections cluster heavily in a small number of bad sessions (crescent `4b24c1b4` alone had 26 pushback events on Apr 19). A few outlier sessions inflate the apparent recurrence rate. Normalized by total user turns, the correction rate is ~2–3%, not uniformly distributed.
3. The "corrections are conversation" rule itself (crescent Apr 22) was actually the CAUSE of the reactive-bandaid problem, not evidence of CLAUDE.md's failure. The prior rule said "every correction → write a rule," which mechanically produced the bandaid behavior. This is a CLAUDE.md design flaw, not a learning failure.

**Final honest read:** The hypothesis survives on memory misuse (3 projects, no-memory documented, violations continued) and specialcasing (same correction, same project, 3 weeks apart). It is wounded on overconfidence — the one case where encoding timing can be verified shows corrections stopped after the rule was added. The tax is real but concentrated: a few hard-to-encode domain constraints (crescent type semantics, memory system misuse) drive most of the signal, not uniform cross-session forgetting.

---

## Adjudicated Status

**alive (narrowed).** This is one of the two best-supported hypotheses. The red-team's overconfidence falsification is real and instructive — encoding *does* sometimes work, the May 13 "Counterweight: don't fake confidence" rule appears to have actually suppressed the violation class. That is a positive finding hidden inside a negative-framed hypothesis: the tax is paid where the constraint resists clean encoding (memory misuse — 3 projects; specialcasing — concept does not decompose into a rule the model can apply locally; reactive-bandaid additions — a meta-rule that fights the harness's CLAUDE.md-editing affordance). The reactive-bandaid loop in particular is a confirmed mechanism: rule added in response to violation → rule itself violated the no-bandaid principle → rule deleted → behavior recurs. Absorbs the recurring-violation portion of H-IMPLICIT-CONSTRAINTS item 2 (LuaJIT). Boundary with H-IMPLICIT-CONSTRAINTS is real but porous: "documented but soft enough to ignore" sits between the two.
