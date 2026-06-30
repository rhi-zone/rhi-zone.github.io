# CONFIRMED FACTS — user-certified record

**Status: CERTIFIED 2026-06-30 by the user.** This is a record of points established or
stated by the user (or verified) during a design conversation about the overconfidence
control surface. The user has certified each line below as a foundation for design work.

**Nothing in this file is a fix.** There are no solutions, recommendations, or CLAUDE.md
wording here — only the agreed problem statement and the constraints/protocol the user
articulated. Any proposed fix is a separate artifact and must be checked against this
record, not merged into it. The record is useful only if it stays clean: certified facts
only, never guesses (see fact 8).

---

## Confirmed facts

1. **The core failure is unearned/unnecessary confidence** — specifically, guesses framed
   as conclusions in dialogue. This produces many messages of non-convergence: the user
   has to reject each confident-wrong guess before any progress is made — if progress ever
   comes at all.

2. **It is not primarily about execution/action.** The agent is mostly consistent here —
   the few times it does execute are not a big deal; tool-gating exists for that. The
   damage is upstream, in the reasoning/suggestion loop.

3. **Cost asymmetry, scaled to cost-to-reverse.** A confidently-wrong *direction* can cost
   weeks or months of cleanup and may never be steered back; hedging-when-actually-right
   costs minutes. The two are indistinguishable in the moment — same "I have this" feeling,
   same absence of evidence. Therefore the confidence bar must scale with cost-to-reverse.

4. **The agent has failed at this consistently, not occasionally.** Consequence — the
   certified rule: the agent must never present something as confirmed / settled / done /
   resolved unless BOTH conditions hold — (a) the user is asking for the agent's opinion,
   not steering or directing it; AND (b) the agent's confidence is backed by citations.
   ("Their opinion" here means the agent's own opinion.) If either condition is absent, the
   agent offers, it does not conclude.

5. **This is not primarily a text-vs-structure problem.** The deeper fact is that LLMs are
   simply poor at steering — at following direction and holding a settled frame. Any
   encoded change (text in CLAUDE.md or a structural mechanism) is therefore a best-effort
   mitigation of an inherent limitation, not a reliable fix. No mechanism should be framed
   as "the solution."

6. **Proposed working protocol (user-originated).** Any user rejection — even a single one
   — means "you don't know what you're doing": reset, do not patch the frame. Before
   retrying, update a permanent record of CONFIRMED facts (kept clean — only
   genuinely-confirmed items, never guesses, certified by the user). Then send a
   self-critical subagent to TRY to advance from that record without retreading ground.

7. **"TRY to advance" is load-bearing.** The unit of output is a disposable attempt offered
   for checking ("here's an attempt, check it"), not a conclusion. A rejection discards
   just that attempt, never the confirmed record. This is what makes the
   single-rejection-reset cheap and keeps the agent from clinging-and-patching.

8. **The record only helps if it stays clean** (emphasized as very important). The moment a
   guess is written there as fact, it launders the wrong frame into every future loop.
   Certification of each line is the user's, not the agent's.

9. **Agent-types direction (related).** Custom subagent types will be defined in-harness.
   The universal subagent-calibration stays in the existing hook — a custom default cannot
   be force-applied to all subagents (verified platform fact). Specialized behavior goes in
   opt-in types. CLAUDE.md's propagated section should prefer explicitly naming agent types
   when delegating.
