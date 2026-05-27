# H-CONTEXT-DRIFT

**Claim:** Long sessions or sessions with many tool calls degrade in output quality; corrections made late in a session don't propagate to earlier-formed conclusions; auto-compaction loses key signal.

---

## Predictions

1. Explicit user reprimands about the model ignoring something "already said" should cluster in the later turns of long sessions, not be uniformly distributed.
2. Sessions that hit auto-compaction should show a quality discontinuity near the compaction boundary.
3. High-turn sessions should carry a disproportionate share of the pushback events catalogued across the corpus.

---

## Evidence For

**1. "Check further up in context" — explicit late-turn context failure (session `9501a0b0`, crescent, 175 turns)**

The model proposed a `fix` subcommand. User: "I'VE LITERALLY ALREADY SAID" → "check. fucking. further up. in context." This happens at approximately turn 145–155 of a 175-turn session. The information was present in the session; the model had not retained or attended to it by the late segment. The user then asked directly: "did this session start with a compaction?" (turn ~170), treating compaction as the likely cause. Follow-up: "what's the first message in the compaction" — confirming suspicion that compaction had fired and stripped the earlier instruction.

**2. Prior pushback audit confirms high-turn sessions as hot spots**

An earlier audit agent (`b2f1c01b`, 2026-05-13) found: crescent sessions alone accounted for 103 of ~228 strong-pushback turns (45%). The hot sessions by pushback count are all long or multi-day sessions: `4b24c1b4` (436 user msgs, 26 pushbacks), `9501a0b0` (175 turns, 22 pushbacks), `cabdea3b` (12 pushbacks). The five highest-pushback sessions are all crescent sessions spanning multiple days — consistent with both context accumulation and compaction exposure.

**3. "You were right it's useless" then ignored — compaction erases prior agreement (session `db532ce7`, normalize)**

User message (2026-03-26, 07:20): "one of the main issues: i said before compaction something like 'what should -2 do' and you were like 'you're right it's useless' and did your own thing. what is the issue here." This directly names compaction as the mechanism by which an agreed-upon decision was lost. The model continued as if the agreement had not occurred.

**4. Tunnel-vision reprimands in-scope (2026-03-20–2026-05-20)**

"you're still tunnel visioning" (`db532ce7`), "why the FUCK do you keep restricting things. stop inventing things" (`1768635a`), "why the fuck do you keep running release when 0.3.1 is CLEARLY not done" (`b638eaa2`). These suggest a pattern where the model locks onto a local conclusion and ignores contradicting context that remains in-window — distinct from compaction but still a form of context drift.

---

## Caveats

**Confound: task difficulty, not context length, may explain crescent clustering.** Crescent has the most complex domain (typed Lua type system). The same model behavior on a simpler task might be corrected quietly; on crescent, every wrong answer is visibly and immediately wrong. High pushback rate could reflect domain difficulty causing more frequent wrong answers, not context drift per se.

**"User repeated for emphasis" vs "model forgot":** several in-scope "you keep doing X" messages are ambiguous. "why do you keep running release" (`b638eaa2`) could mean "you've done this twice in this session after I told you not to" (forgetting) or "this is a recurring across-session pattern" (a different problem, closer to H-CORRECTION-TAX). The per-session evidence is stronger for `9501a0b0` where the forgotten instruction is demonstrably from the same session.

**Counter-evidence — long sessions that stayed coherent:** Session `a02bc091` (private-recipient-b, 427 user messages, 493h wall time) has no notable pushback signal and a smooth progression from "clean up worktrees?" through a sustained build effort. Session `90fc4edb` (io, 448 user messages) similarly lacks the frustration clustering seen in crescent. This means session length alone is insufficient — domain complexity and the density of design constraints in-context are likely co-factors.

**Compaction observations are sparse.** Only two sessions show explicit compaction-as-cause language in the in-scope window (`db532ce7`, `9501a0b0`). The phenomenon may be underreported: the user often doesn't know compaction fired and attributes the drift to other causes.

---

## Queries Used

```bash
# Longest sessions by wall duration, in-scope
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions list --all-projects --since 2026-03-20 --until 2026-05-20 \
  --sort duration --limit 30 --compact

# User reprimand patterns
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --all-projects --since 2026-03-20 --until 2026-05-20 \
  --role user --grep "you keep|stop doing|you forgot|you missed|you ignored" \
  --limit 0 --compact

# Compaction/context-loss language
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --all-projects --since 2026-03-20 --until 2026-05-20 \
  --role user --grep "compaction|compact|context.*lost|after compaction" \
  --limit 0 --compact

# "As I said" / "said before" patterns
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --all-projects --since 2026-03-20 --until 2026-05-20 \
  --role user --grep "as I said|like I said|said before|I said earlier" \
  --limit 0 --compact

# Late turns of hot crescent session 9501a0b0 (175 turns)
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --project /home/me/git/rhizone/crescent \
  --session 9501a0b0 --role user --turn-range 130-175 --compact

# Pushback distribution already computed by prior audit subagent in session b2f1c01b (2026-05-13)
```

---

## Status

**Alive — moderate strength.**

The compaction-as-cause signal is real but sparse (two explicit instances). The late-turn clustering of "you already said this" corrections in `9501a0b0` is the cleanest evidence. The prior audit's finding that crescent's 5 hottest sessions all have high turn counts and high pushback rates is consistent but not causal — domain difficulty is a viable alternative explanation. The hypothesis survives but needs the crescent confound addressed to be rated strong.

**Key unresolved question:** Are there high-turn sessions in crescent where quality held, or does every long crescent session accumulate corrections? If the latter, domain difficulty explains the clustering. If long crescent sessions vary — some clean, some catastrophic — session-level context load is the more likely driver.

---

## Red-Team Verdict

**Partially falsified — the "length causes drift" variant is weak; the "compaction loses signal" variant survives but is narrower than claimed.**

**Findings:**

1. **Long sessions stay coherent without frustration.** Crescent `fccf7f65` (641 user messages, 16 522 raw lines, 23 compaction events): zero genuine user frustration about forgotten state. private-recipient-b `a02bc091` (427 user messages, 6 compactions): zero. These directly falsify the prediction that high-turn sessions carry disproportionate pushback. Session length is not the cause.

2. **"Already said" complaints measure recent-context failure (1–6 turns), not long-distance drift.** The "wrong / also wrong / still wrong" cluster in normalize `0db3a562` spans turns 2155–2175 — the original topic ("hard dependency on git") was introduced 4 turns before the first correction. The model was iterating bad answers in the same reasoning chain, not forgetting something said many turns earlier. This matches H-CORRECTION-TAX more than H-CONTEXT-DRIFT.

3. **Post-compaction failures are real but topic-specific, not state-wipe.** In crescent `8414f765`, the frustration cluster at lines 1987–2126 follows the compaction at line 1931 by only 56 lines. The specific failure: model proposes solutions to a known-constraint problem (SHA-256 implementation) without honouring a constraint established pre-compaction. This is consistent with compaction signal loss — but it is one cluster in a 12 971-line session that otherwise runs clean. Compaction is a narrow risk, not a general degradation mechanism.

4. **Pre-compaction sessions show the same pattern.** Crescent `fccf7f65` line 224 (before compaction fires at line 916) shows an early-session reasoning loop. The failure mode precedes compaction, so compaction cannot be the root cause for that instance.

**Verdict:** H-CONTEXT-DRIFT should be decomposed. "Length degrades quality" — falsified by the large coherent sessions above. "Compaction loses specific prior agreements" — survives (two direct cases: `db532ce7` and `9501a0b0`). "Corrections don't propagate" — reclassify as H-CORRECTION-TAX; turn distance is uniformly short (2–6 turns), not long-distance context drift. The core risk is a narrow but real compaction hazard for high-stakes design decisions made just before context rollover.

---

## Adjudicated Status

**alive (decomposed and narrowed).** Length-causes-drift is dead: `fccf7f65` (641 user messages, 23 compactions, zero pushback) and `a02bc091` (427 messages, 6 compactions, zero) directly falsify it. Compaction-loses-specific-prior-agreements survives on two clean cases (`db532ce7`, `9501a0b0`) where the user explicitly diagnosed compaction as cause. The T_ANY wrong-answer chain absorbed from H-DESIGN-CEILING is short-distance recent-context failure (2–6 turn span), not long-context decay — better labeled "within-chain reasoning loop." This hypothesis is the orchestrator-context sibling of H-DECOMPOSITION-FAILURE (reformulated): both are about stale assumptions surviving past the point where the underlying state changed. The narrowed alive form is: *compaction can silently strip high-stakes prior agreements; short-distance reasoning loops occur where context is present but unattended*. Neither is a general "long = bad" claim.
