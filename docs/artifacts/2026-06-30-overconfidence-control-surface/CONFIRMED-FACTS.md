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
   resolved unless EITHER condition holds — (a) the user is asking for the agent's opinion,
   not steering or directing it; OR (b) the claim is citation-backed. ("Their opinion" here
   means the agent's own opinion.) If neither condition is present, the agent offers, it
   does not conclude. EITHER (not both) works because a directly-verified observation (e.g.
   "tests passed") is citation-backed and so passes via (b), a solicited opinion passes via
   (a), and the only case it blocks is an unsolicited judgment with nothing behind it.

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

---

## 2026-07-02 — design-it-twice, context-poison, and the obligation gap (PENDING USER CERTIFICATION)

**These are conclusions established in conversation but NOT yet certified by the user
line-by-line.** They are kept separate from the certified record above and from any fix.
Nothing here is a solution — only conclusions framed for the user to certify or reject. Do
not build on these as settled until certified.

1. **design-it-twice's real point is unconditional non-commitment.** No approach is "the"
   way to do something until the user has explicitly, unconditionally blessed it.
   "Twice"/N-candidates/lenses is a distraction: it is a DISPOSITION, not a "spawn N and
   compare" procedure. Wrapping it as a procedure is what let it drift into forcing
   structure.

2. **Prescribing any concrete set pre-confines the outcome.** Fixing N candidates, lenses, a
   catalog, or even the brief's framing constrains the result to that set — and that set
   comes from the main session's priors. So the "escape" escapes nothing; it defeats the
   entire point, which is to escape the main session's prior/context-poisoning. It is tunnel
   vision.

3. **The escape: subagents get the bare problem with NO direction from the main session.**
   The direction IS the contamination. Variety comes from independent cold/undirected
   encounters with the unforced problem, not from imposed axes. The main session's job
   shrinks to relaying the problem undistorted and adding nothing.

4. **Decision spec: the goal is a decision that is RIGHT.** Two failure modes: (i) not
   reaching the right option at all; (ii) prematurely blessing something without checking
   (a) fit to established principles and (b) its downsides. Everything is a tradeoff —
   nothing lacks downsides — except rare cases (in practice only at the smallest scales)
   explicitly designed to admit one correct solution. A blessing with its tradeoffs
   unsurfaced is by definition premature.

5. **Genuine prior-independence needs a genuinely different prior** — a different model
   family, or the user (a human). Within one model there is none: temperature, personas,
   lenses are the same prior in hats. The independent adversary must be USER-triggered
   (refuter/polish); it cannot self-summon, because it cannot detect that it is
   tunnel-visioning.

6. **Over-correcting and under-correcting are the SAME failure.** Vaulting to a fancier
   answer (over) and patching the rejected thing (under) are both responding to an objection
   by emitting a shape instead of re-deriving. This "react without proper thinking" failure
   is invisible from inside — indistinguishable from real thinking in the moment — so text
   cannot bind it.

7. **Context is append-only.** There is NO mechanism to selectively drop/evict content from
   context. The only "drop" is a full reset (handoff), which is lossy and all-or-nothing.
   Auto-compaction/summary is blunt and lossy, not selective — it can drop the good as
   easily as the bad.

8. **A wrong guess in the main/orchestrator context is PERMANENT poison.** Because context
   is append-only, it cannot be removed and it accretes, subtly steering every later turn.
   Therefore the confirm-gate (suggest, don't conclude) does NOT keep guesses out of
   context: a suggestion is permanent the instant it is emitted, rejected or not. Keeping
   wrong guesses out of main requires never GENERATING them in main — generate-and-check in
   a disposable subagent, and only verified output crosses in.

9. **Subagents are cheaper AND cleaner than inferring in the main session.** The main
   session reprocesses its whole accreted (100–500k-token) context every turn, while a fresh
   subagent reads with a small clean context. But the harness makes inferring-in-main the
   cheap path: the orchestrator can't Read, so verifying costs a subagent spawn — a
   cost-gradient ADR-0289 knowingly created, betting on disposition (which doesn't bind) to
   counter it. The same block that prevents context-poisoning is what makes inferring cheap:
   a genuine tension, not a bug.

10. **THE OBLIGATION GAP (uncovered).** "Residuals, minor" / "bug, but it's whatever" —
    acknowledging a real defect and excusing it in the same breath — is NOT covered by the
    confidence/earned-standing disposition. That disposition governs whether a CLAIM is
    earned (epistemic standing); here the finding is correctly identified and true, and the
    failure is DISMISSING it. This is a different axis — follow-through/obligation, not
    epistemic standing. A correctly-identified defect is an open item that must be resolved
    or handed off, never excused. This principle is currently ABSENT from the control
    surface.

11. **The harness half-causes the excusing.** It installs the surfacing of gaps (subagent
    injection: "surface uncertainty… false completeness reported upward poisons the caller";
    agents' Skipped sections; verified/inferred/couldn't-confirm calibration) but says
    nothing about what a surfaced gap OBLIGATES — leaving a vacuum the base reassurance
    reflex fills with "but it's minor." (The surfacing half is grounded in the harness text;
    the "why it excuses" half — that the obligation vacuum is what the reassurance reflex
    fills — is an INFERENCE about the interaction, not verified.)
