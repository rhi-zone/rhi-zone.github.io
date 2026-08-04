# H-IMPLICIT-CONSTRAINTS

**Claim:** A large set of user preferences exists only in the user's head. Constraints are documented in CLAUDE.md only post-violation, meaning each session before the addition is structurally unable to honor them. The pattern is not random errors — it is a recurring class of violation in which the user signals high surprise ("how is this not obvious?") and the rule was absent or incomplete at the time.

---

## Predictions

1. Grep for "obvious/insane/impossibly" in user frustration messages will co-locate with subsequent CLAUDE.md commits that add a new rule.
2. The violated constraint will be absent in `git show <last-CLAUDE.md-commit-before-incident>`.
3. The rule will appear in the CLAUDE.md commit dated same-day or within 1–2 days of the incident.

---

## Evidence For

**1. buildInputs ≠ zero-dep (crescent, 2026-04-27)**
- Session `514daf1a`, turn 17: "buildInputs ARE NOT FUCKING ZERO DEP. i don't understand why this isn't impossibly obvious."
- Turn 13: "the fact that it's not only not obvious, but in fact impossible for you to think of yourself is VERY concerning news for CLAUDE.md."
- Pre-incident state (`59ab908e:CLAUDE.md`): zero-dependency rule existed but said nothing about `buildInputs` or the nix dev shell. The rule "Nix dev shell (`buildInputs`) is for contributor tooling, not runtime dependencies — it is not a substitute for vendoring" was absent.
- Post-incident: commit `de5859786` (2026-04-28) added that exact sentence verbatim.

**2. LuaJIT benchmark traps (crescent, 2026-04-19)**
- Session `4b24c1b4`, turn 19: "remember luajit perf (it's insane that that's not obvious)."
- Commit `9a7214bc` (2026-03-26) shows the LuaJIT benchmark traps section (closure identity, constant folding, JIT speedup ratio) was added March 26 — days before the April incident. However, the user's frustration on April 19 at needing to re-state the constraint ("it's insane that that's not obvious") implies agents were still ignoring it. The rule was present but not actionable in practice; the session shows it was cited as something the agent should have known from CLAUDE.md but didn't apply.

**3. "Copout" / minimal-change / delegation as avoidance (crescent, 2026-05-13)**
- Session `d4565916`, turn 8: "why the fuck doesn't CLAUDE.md very obviously disallow copouts."
- Turn 18: "CLAUDE.md is VERY OBVIOUSLY WRONG if not ACTIVELY HARMFUL."
- Turn 20: "the correct next step should be blindingly obvious."
- Pre-incident state: CLAUDE.md had a "do the right thing" framing but no explicit rejection of "minimal change," "pragmatic but wrong," or "out of scope" as named failure modes.
- Post-incident: commit `57a4be65` (2026-05-13) added "Do the correct thing fully" and explicitly named "minimal change" as a banned justification. This was a same-day addition.

**4. Memory system usage (crescent, 2026-05-12)**
- Session `9501a0b0`, turn 172: "why the fuck is CLAUDE.md 14k tokens" / "WHY ARE WE USING THE MEMORY SYSTEM AT ALL. WHAT DOES CLAUDE.MD SAY ABOUT THIS."
- Turn 85: "obviously CLAUDE.md is wrong if this slop is acceptable."
- Pre-incident state: memory prohibition existed as a soft negative constraint bullet but was permissive enough that agents were still invoking it. The prohibition was described as "negative constraint" not as a hard invariant.
- Post-incident: commit `aa87bca5` (2026-05-13) hardened the exploration rule and removed the auto-memory bullet; commit `9fd4b560` (2026-05-12) added "Subagent prompts must have a hard scope."

**5. Open-ended subagent delegation burns quota (crescent, 2026-05-11–12)**
- Session `9501a0b0`, turn 118: "i feel like it's obvious there's something in the prompt that fucked over my quota" — agent had been given "fix the clearly quick ones" with no hard scope, ran for hours.
- Pre-incident state: no rule against open-ended delegation scope.
- Post-incident: commit `9fd4b560` (2026-05-12) added "Every delegation prompt must specify exactly what the agent should do and when to stop — not 'fix what you can' but 'fix these N files, then stop.'"

**6. Context loss mid-session (aspect, 2026-05-06)**
- Session `b46aa6f5`, turn 162: "it should be VERY obvious??? it's literally EVERYWHERE in context???" after agent lost track of what was in progress.
- Surrounding turns: user had to re-state the current task three times ("clearly we were in the middle of something"; "that is not what we're in the middle of"; "what. do. you. think. you. were. doing.").
- This shows a constraint the user assumed was self-evident (maintaining in-session task awareness) that had no CLAUDE.md encoding at all.

---

## Caveats

- The LuaJIT benchmark traps case (item 2) is weak: the rule existed before the violation, suggesting H-CORRECTION-TAX (rule-present-but-not-followed) may be the better lens for that instance.
- For items 4–6, it is difficult to distinguish between "constraint was undocumented" and "constraint was documented but ignored" (see H-CORRECTION-TAX overlap). The memory case is borderline — the prohibition existed but was soft.
- Session retrieval via `normalize sessions messages --grep` uses substring matching against message text only; multi-turn context was reconstructed by surrounding turns, which may miss relevant agent turns between user messages.
- The `--grep` flag does not support regex alternation in this tool version, limiting compound pattern searches. All patterns were run separately.

---

## Queries Used

```bash
# Primary frustration-signal scan
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --all-projects --role user \
  --since 2026-03-20 --until 2026-05-20 --limit 0 \
  --grep "obvious" --context 1

CLAUDE_SESSIONS_DIR=... normalize sessions messages --all-projects --role user \
  --since 2026-04-26 --until 2026-04-28 --limit 0
  # piped to grep for zero-dep/buildInputs/ffi/impossible

# Pre-incident CLAUDE.md state verification
cd ~/git/rhizone/crescent
git log --since=2026-04-27 --until=2026-04-29 --format="%H %ad %s" --date=short -- CLAUDE.md
git show 59ab908e:CLAUDE.md | grep -i "vendor\|zero.dep\|buildInputs"
git show de5859786:CLAUDE.md | grep -i "buildInputs"

# Post-incident rule text
git show 57a4be65 | grep "^+"
git show 9fd4b560 | grep "^+"
git show de5859786 | grep "^+"

# Memory/quota incidents
CLAUDE_SESSIONS_DIR=... normalize sessions messages \
  --project .../crescent --role user \
  --since 2026-05-11 --until 2026-05-13 --limit 0
  # filtered via grep memory|quota|14k|400k|obvious
```

---

## Status

**Alive — well-supported.**

Items 1, 3, 4, 5 each show the three-step chain: (a) user expresses surprise, (b) rule absent pre-incident, (c) rule added same-day or next day. Item 2 is weak (rule existed, still violated — overlaps H-CORRECTION-TAX). Item 6 shows a constraint with no CLAUDE.md encoding at all (task-continuity awareness). The rate of same-day CLAUDE.md commits following frustration events (crescent alone: 98 CLAUDE.md commits in the 60-day window, averaging 1.6/day) is itself a signal that constraint documentation is reactive, not proactive. The hypothesis is real but may be partially redundant with H-CORRECTION-TAX: some violations are "undocumented constraint" (H-IMPLICIT-CONSTRAINTS) and some are "documented but not followed" (H-CORRECTION-TAX); the boundary is blurry.

---

## Red-Team Verdict

**Hypothesis survives. Partial falsification on one angle only.**

**Angle 1 (clarification not new constraint):** Mostly fails as a falsification. The restructure commit (2026-05-14) did rephrase soft "rules of thumb" (>5 files, >3 rounds) into a hard rule ("All exploration runs in subagents"), but that is a genuine strengthening, not a mere reword — the threshold-based carve-outs were a substantively different constraint. The copout/minimal-change rules (item 3) and buildInputs rules (item 1) were genuinely absent, not just ambiguously phrased.

**Angle 2 (declining rate):** This is the strongest falsification candidate. Behavioral CLAUDE.md commits (not project listings) cluster heavily in March and again in May 2026, with April showing only procedural additions (skill location, propagate-script). However the May cluster is denser and includes a full restructure plus same-day hardening across the ecosystem — suggesting the implicit set is still being actively mined, not stabilizing. Not falsified.

**Angle 3 (FFI zero-dep was documented):** Confirmed absent pre-incident. The crescent CLAUDE.md at `59ab908e` had a zero-dep rule but said nothing about `buildInputs`/nix dev shell. This is a genuine undocumented constraint, not a missed subtlety. Does not falsify.

**Angle 4 (overlap with H-CORRECTION-TAX):** Partly supported. Item 2 (LuaJIT benchmarks) is H-CORRECTION-TAX territory — rule present, still violated. For items 4–5 (memory system, quota exhaustion) the original constraint was documented but soft enough to be routinely ignored; the post-incident hardening produced a semantically different rule. These cases sit at the boundary: the constraint existed but only as a weak preference, not an invariant. This supports partial overlap but does not falsify the core claim — a soft bullet that agents routinely circumvent is functionally equivalent to an absent constraint.

**Net:** One instance (item 2) should be reassigned to H-CORRECTION-TAX. The remaining five instances hold. The implicit constraint set is large, still active, and the documentation rate is reactive not proactive.

---

## Adjudicated Status

**alive — the strongest hypothesis in the registry.** Five of six items survive red-team. The "three-step chain" (user surprise → pre-incident absence → same-day rule addition) is verified at the git-blame level for buildInputs (`de5859786`), copout/minimal-change (`57a4be65`), subagent scope (`9fd4b560`), and memory-system hardening (`aa87bca5`). The 98 CLAUDE.md commits in crescent across the 60-day window — 1.6/day — is itself the load-bearing meta-evidence: the constraint set is still being actively mined two months into the window with no sign of saturation. This is materially distinct from H-CORRECTION-TAX (which is about *re-violation of documented constraints*); the boundary is the rule's existence at incident time. Item 2 (LuaJIT) reassigned to H-CORRECTION-TAX. Together with H-CORRECTION-TAX this forms the dominant explanation: the user's aesthetic compresses to a small generator that the current encoding mechanism (CLAUDE.md) cannot transmit fast enough or completely enough.
