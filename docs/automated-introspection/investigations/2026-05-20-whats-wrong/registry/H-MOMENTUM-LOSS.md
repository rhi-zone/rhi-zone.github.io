# H-MOMENTUM-LOSS

## Claim

Projects stall not from model issues but from architectural design dead-ends that the user defers. The deferral accumulates across sessions until the project goes quiet. Reincarnate's Subtype-constraint design is the canonical suspected case.

## Predictions

1. Reincarnate should show a design question explicitly deferred across multiple sessions, with no resolution session and then a drop in activity.
2. Other projects that went silent should have ended in design uncertainty or open questions, not in clean completions.
3. The silence should be distinguishable from completion: open threads in TODO, unresolved error counts, explicit "next session should..." handoff language.

## Evidence For

### 1. Reincarnate: Subtype constraint deferred across 4 sessions then project goes quiet

The Subtype-constraint design was first flagged in Session 27 (around Apr 9, 40d ago from May 20) with four open design questions written into TODO.md: minimal representation, inheritance-graph sufficiency, fixpoint vs single-pass, and IR-vs-emit-time fallback. It was explicitly deferred as "out of scope for session 28" per the S27→S28 handoff message (`459550c8` 2026-04-25). Session 28 pivoted to smaller mechanical fixes. Session 29 re-entered the subtype thread, found the naive fix regressed 17,257 → +7,420 TS2339 errors, documented this as a "landmine" in TODO.md. Session 30 (`b7bb63a1` 2026-04-27) pivoted to a different architectural change (with-inlining / CFG loop refactor) rather than resolve the subtype design. After that session, reincarnate has had zero sessions in 20 days (as of 2026-05-20).

The project ended with 16,501 open TS errors, an unresolved `_self: unknown` problem (252 TS18046 errors), and a TODO.md that explicitly tracks the subtype constraint as an open design thread. This is not completion — it is a stall at a design junction the user deferred four consecutive times.

### 2. Session counts confirm the drop: 391 sessions before Apr 10, 7 after

First half of window (Mar 20 – Apr 20): 392 reincarnate sessions. Second half (Apr 20 – May 20): 6 reincarnate sessions, all clustered Apr 25–27. After Apr 27: zero. The `with`-inlining work in sessions 29–30 was a productive pivot, not the design resolution — the subtype constraint remains open.

### 3. Other projects silenced around Apr 10 without design blockers as direct cause

Projects that went fully silent before Apr 10 and had no activity afterward: tiltshift (29 sessions, last session ended with clean commit and "see you next session"), existence (157 sessions, last session ended mid-feature with a "pick one of the remaining"), rescribe (30 sessions). These projects ended at varying levels of cleanliness — tiltshift clean, existence mid-feature. The pattern is less crisp than reincarnate; silence correlates with the user's attention shifting (crescent became dominant in Apr–May), not with a specific design blocker.

### 4. Reincarnate's hypothesis is confirmed; ecosystem-wide pattern is weaker

The specific claim about reincarnate (design dead-end → deferral → stall) has direct evidence. The broader claim that this is the **primary** mechanism for project stalls is not supported — many projects went silent around the same time (Apr 10), suggesting a single shift in user attention rather than individual per-project design blockers.

## Caveats

- Session count conflates autonomous sessions (fuwafuwa's 2,424 sessions are headless cron runs). Human-interactive session counts for non-autonomous projects are the meaningful signal.
- "Stalled" is ambiguous: tiltshift and keybinds silenced around Apr 10 but had clean endings. Counting them as momentum-loss stalls would be wrong — they appear paused, not blocked.
- The subtype-constraint deferral in reincarnate could reflect rational prioritization (the with-inlining pivot eliminated ~241 U5 errors via a cleaner approach), not a design ceiling. The TODO still holds the open thread, and the user may return.
- The 20-day gap since reincarnate's last session is notable but not yet conclusive — the investigation itself is generating sessions that redirect attention.

## Queries Used

```bash
# Session counts by project, both halves of window
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions list --all-projects --since 2026-03-20 --until 2026-04-20 --limit 0 \
  | awk 'NR>1 { n=split($0,a,/  +/); if(n>=6) print a[6] }' | sort | uniq -c | sort -rn

CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions list --all-projects --since 2026-04-20 --until 2026-05-20 --limit 0 \
  | awk 'NR>1 { n=split($0,a,/  +/); if(n>=6) print a[6] }' | sort | uniq -c | sort -rn

# Reincarnate sessions Apr–May
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions list --project /home/me/git/rhizone/reincarnate \
  --since 2026-04-01 --until 2026-05-20 --limit 0

# Subtype deferral evidence (user messages, Apr 24–28)
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --project /home/me/git/rhizone/reincarnate \
  --since 2026-04-24 --until 2026-04-28 --role user --limit 0

# Session 29 end-state (assistant messages, Apr 24–26)
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects \
  normalize sessions messages --project /home/me/git/rhizone/reincarnate \
  --since 2026-04-24 --until 2026-04-26 --role assistant --limit 0 \
  | grep -E "(subtype|handoff|open thread|deferred|next session)"
```

## Status

**Alive — partially confirmed.**

The specific claim about reincarnate is well-evidenced: a design question (Subtype constraint) deferred across sessions 27–30, each session pivoting to a smaller unblocked task, ending in a 20-day gap with 16,501 open errors. The broader ecosystem claim — that this is the dominant stall mechanism — is not confirmed. Most other silenced projects appear to have stalled due to a single user attention shift around Apr 10, not per-project design blockers. The hypothesis should be narrowed: momentum loss from design deferral is real for reincarnate; for other projects, the stall mechanism is likely attention-bandwidth, not design ceiling.

## Red-Team Verdict

**H-MOMENTUM-LOSS is substantially weakened on the reincarnate-specific claim. The broader claim survives with the same caveat the original author already noted.**

Three falsification angles land:

**1. The last session shipped, not stalled.** Session `b7bb63a1` (Apr 27, 7h23m, 73 tool calls, title "subtype-constraint-inference") was actively implementing IR bodies for GML math functions. The session received the full "Delete all handwritten TS" plan and was executing prerequisite steps. Same-day commits confirm real output: `eefd3520` (add IR bodies for ln/math_get_epsilon/is_bool, add Ushr and coercion builtins), `ab9fe9fe` (inline int/uint coercions, add real IR body), `c67eacd4` (add `_rt` as explicit IR param 0 — the IntrinsicKind elimination prerequisite). This is not "pivoting away from the design dead-end" — it is shipping the prerequisite chain for the stated goal (deletion of `runtime.ts`). The session ended mid-implementation (tool use interrupted), not at a design impasse.

**2. 20-day gaps are ecosystem-normal.** Comparing reincarnate (20d gap) to other projects in the same window: defocus 17d, private-recipient-b 18d, pteraworld 18d, comfyui 21d, interpreter 23d, less 24d, sketchpad 27d, unshape 28d, plus a long tail of projects at 40d+ (the window boundary). Reincarnate's 20-day gap is indistinguishable from routine attention cycling. The claim "20 days dormant" requires comparing against baseline cadence; that baseline is multi-week gaps for most projects.

**3. The subtype-constraint deferral is rational sequencing, not avoidance.** The session content shows the user explicitly chose to implement IR-body pipeline prerequisites before tackling the subtype constraint — a dependency ordering decision, not a design ceiling. The TODO still holds the open thread, but a project with a populated execution plan and committed prerequisite work is "design complete, awaiting implementation" rather than "design stalled."

**What survives:** The broader pattern (many projects went quiet due to attention-bandwidth shift around Apr 10, not per-project design blockers) is confirmed, consistent with the original author's own caveat. The daily log description of the Apr 27 reincarnate session as "brief exploration" is inaccurate — the session produced multiple significant commits — which may have inflated the apparent evidence for stalling.

**Revised verdict:** H-MOMENTUM-LOSS should be downgraded from "Alive — partially confirmed" to **"Weak — insufficient evidence for the reincarnate-specific claim; ecosystem-wide claim unsupported."** The 20-day gap is real but explained by attention cycling, not design deadlock. The final session state was implementation-in-progress, not deferred design.

---

## Adjudicated Status

**dead.** The red-team's three angles all land. The 20-day reincarnate gap is indistinguishable from baseline cadence (defocus 17d, private-recipient-b 18d, pteraworld 18d, multiple projects 21–28d). The final reincarnate session shipped three commits implementing prerequisites for the stated goal — that is in-progress execution, not deferred-design stall. The ecosystem-wide silence around Apr 10 is explained by user attention shifting to crescent, not by per-project design dead-ends. The "Subtype-constraint design" thread is still in TODO.md, which is the documented mechanism working as intended (defer-and-record), not the failure mode this hypothesis named.
