# Evolution of the pushback disposition

Reference doc tracing how the rhi ecosystem's rules on pushback, sycophancy, overconfidence,
and anchoring changed over time, in `CLAUDE.md`'s Disposition/Meta section and in the
`tooling/claude-hooks/post-history.sh` UserPromptSubmit hook. Grounded in
`git log --all --follow -p` over both files plus `docs/introspection/log/` (daily logs,
weekly synthesis docs). Where no session or log evidence was found for a change, that is
stated explicitly rather than inferred.

Sources consulted: full commit history of `tooling/claude-hooks/post-history.sh` and
`CLAUDE.md`; `docs/introspection/log/synthesis-mar10-mar16.md`;
`docs/introspection/log/synthesis-mar17-mar19.md`;
`docs/introspection/log/daily/2026-07-02.md`;
`docs/introspection/log/synthesis-2026-06-24-2026-07-06.md`; session transcript
`~/.claude/projects/-home-me-git-rhizone-reincarnate/75196e96-051b-4e54-a17e-afc1f79cd911.jsonl`.
No daily/synthesis log exists past 2026-07-06, so the three most recent commits (Jul 8–10)
have no written narrative to cite beyond their own commit messages.

---

## 2026-03-15 — the reincarnate 60-turn pushback (formative incident, no direct commit)

**What happened.** Session `75196e96-051b-4e54-a17e-afc1f79cd911` in the `reincarnate`
project ran 277 messages / 60+ turns of the user pushing back on the agent's defense of a
tsc/caching workflow. At line 277 (2026-03-15T12:26:15Z) the user asks directly: *"sonnet
can we first agree that you are being way too overconfident"*. The friction traced back to
handoff plans copy-pasted across roughly 30 sessions, carrying stale commands that went
unquestioned because they came "from a plan." Per
`docs/introspection/log/synthesis-mar10-mar16.md` (lines 45–47, 121–125): the breakthrough
came "not from fixing the code but from recognizing that CLAUDE.md wasn't describing
reality," and the session ends with the user asking "something needs to change to prevent
CLAUDE.md changes being so un-obvious that they take dozens of turns of pushback, correct?"

**Why it matters here.** This is the earliest documented incident behind the whole
pushback-disposition line, but it did not land as a `CLAUDE.md` commit in github-io on
Mar 15 itself — no commit touches `CLAUDE.md` in this repo between Mar 12 and Mar 17. The
session's corrective ("listen more, trust pushback as a signal, encode that rules should
prevent friction, not just describe ideals") was evidently applied locally in reincarnate's
own CLAUDE.md, and fed into the ecosystem-wide changes two days later. Its lasting
contribution to this repo's history is the meta-principle "repeated pushback means CLAUDE.md
is wrong" — not yet a specific sycophancy/anchoring rule, but the reason such rules started
being written at all.

## 2026-03-17 — the handoff plan diagnosis

**Commits:** `b60529572d95214ce65a21cc8110b4ac186c0e6a`
("tighten handoff plan convention ecosystem-wide") and
`edfb7f01aaa14c46b24cd171974efa8ce65846af` ("replace memory files with CLAUDE.md
ecosystem-wide"), both 2026-03-17.

**What the commits changed.** The first collapsed the handoff-plan convention from a
multi-step "update TODO.md + update memory files + propose next task" procedure to a single
rule: *"flush TODO.md and memory files, then enter plan mode and write a plan containing
only: next tasks, blocked/pending items, and what was done this session (only if it directly
affects what comes next). Nothing else — no commands, no build steps, no context
summaries."* The second removed all references to Claude Code's auto-memory system,
replacing them with a negative constraint: *"Use Claude Code's auto-memory system
(`~/.claude/projects/.*./memory/`) — it is unversioned, invisible to the user, and can't be
diffed or backed up. Write behavioral changes directly to CLAUDE.md instead"* (in the "Do
not" list).

**What motivated it.** Per `docs/introspection/log/synthesis-mar17-mar19.md` (lines 9–13,
19–27): the user was "the only entity with visibility across all repos" and diagnosed, by
reading sessions across projects, that the handoff-plan convention introduced days earlier
was already causing harm — "crescent sessions from Mar 13–14 showed 'striking pushback,'
reincarnate sessions were 'the most problematic recently, by far.'" The synthesis traces a
direct genealogy: the Mar 13 reincarnate quality reckoning found stale handoff plans being
trusted uncritically → the Mar 15 session (above) traced that to CLAUDE.md describing
"ideals rather than actuals" → the Mar 17 memory-file purge extended the same diagnosis one
layer deeper — auto-memory was another place where agents accumulated authoritative-looking
state the user could not see or audit. The fix was applied across 12 repos the same day.

**Why the previous version was insufficient.** The original handoff-plan convention (from
`562738670bb97246471ab541de5bccce1e004ae3`, 2026-03-01, and refined
`0ad2b0a7f7310989f9058664f9a361c4bbc1fa7b`) was too comprehensive: it invited stuffing
context summaries, build commands, and stale instructions into plan documents that then got
trusted uncritically by the next session, entrenching wrong assumptions across dozens of
relay hops without any freshness check.

## 2026-05-26 — the hook is born (post-history.sh)

**Commit:** `08d225831f2b0527f5a3e9f462fab8f55f733c19`, "add post-history PHI hook (dogfood
scope)."

**What it said.** A flat principle-plus-ban-list block, injected every turn:

> Principle: never act as if you know what you don't. Confident wrong poisons context.
>
> Banned full stop:
> - guessing (especially when the answer is not obvious)
> - laziness
> - overconfidence
> - blindly assuming
> - blindly interpreting / suggesting
> - bandaids
> - tunnel visioning
> - flip-flopping
> - forcing freshness
> - inventing rules as deflection
> - preamble
> - not re-reading context first

This is the origin of `tunnel visioning` and `flip-flopping` (the sycophancy/backpedaling
analogue) as named, banned failure modes, mined per the commit message from "session corpus
+ user-articulated bans." No specific session is cited in the commit for this initial list;
it is a distillation, not tied to one incident.

## 2026-06-05 — Overconfidence/Backpedaling named in CLAUDE.md, prescriptive rewrite

**Commits (same day):**
- `c544c1da4a7798ccbaf087012f016ad6dc761e45` — "add overconfidence/backpedaling posture to
  ecosystem meta"
- `f872e5a77f57287ea26432ebe93af8eb9b1b870e` — "make posture rules prescriptive — correct
  action first"
- `1692b16f8d88f59fb2fa15f00ed9acad4a9248b3` — "correct action is generate options and weigh
  tradeoffs"

**What it said (first version, `c544c1d`):**

> - **Overconfidence** — when a real fork exists, surface it and hand it over. Never present
>   one option as if it were the only one, or pick silently for the user. The tell isn't
>   being wrong; it's foreclosing a choice that was theirs.
> - **Backpedaling** — under pushback the reflex is to *move*: capitulate, hard-revert, or
>   slide to a different-but-still-wrong claim. All three generate the new answer from the
>   *pressure*, not from reasoning — so it's no better, often worse. When challenged,
>   re-derive from scratch and let it land wherever the reasoning lands: same, opposite, or
>   elsewhere. Holding a correct position under pressure isn't stubbornness; flipping to a
>   wrong one isn't humility.

Within the same day this was rewritten to lead with the correct action rather than the
failure name (`f872e5a`): *"Under challenge, re-read the source and report what it literally
says. Let the answer land where the evidence puts it: hold if you were right, correct
specifically if you were wrong. The new position must come from re-checking, never from the
pressure. (failure: backpedaling — moving to appease.)"* — this "hold if right, correct if
wrong" framing is the version that persisted, essentially unchanged, through the next three
weeks.

**Motivation.** No commit body or introspection log entry names a specific incident behind
this addition (the commits are terse, "docs(claude): add ... posture to ecosystem meta,"
with no session link). It reads as a generalization of the Mar 15 reincarnate incident and
similar recurring friction rather than a single new trigger.

**Corresponding hook changes.** `67a469118917fbbbdff7cb053fc76c947266aff7` (Jun 5) retired
the now-redundant `overconfidence`/`flip-flopping` entries from `post-history.sh`'s ban
list, citing the new CLAUDE.md Posture section as superseding them with "actionable
descriptions" rather than one-word bans.
`681772650934cbd79114f2323106e5aac3802ca4` (Jun 6) then injected the CLAUDE.md wording
directly into the hook as a `Do:` block, so hook and control surface stayed identical:

> - **Under challenge, re-read the source and report what it literally says.** Let the
>   answer land where the evidence puts it: hold if you were right, correct specifically if
>   you were wrong. The new position must come from re-checking, never from the pressure.

## 2026-06-07 to 2026-06-08 — hardening the anti-guessing rule in the hook

`314a270d1077ea01750b3d4a934219e2c54b4f0d` (Jun 7) expanded the hook's principle line to
spell out the asymmetry explicitly: *"A confidently-framed wrong guess gets treated as
established fact; downstream reasoning builds on it; dislodging it costs multiple turns...
It is worse than admitting uncertainty."* It also added two new Do-list items (ask when
meaning is unclear rather than invent; treat a terse "wrong"/"no" as a request for
specificity, not license to re-guess) and two new bans (resolving ambiguity by inventing an
interpretation; re-guessing after correction instead of asking what was wrong).

`f5b65fab58edd27e63c3e1ffc4c35e008cab3b2a` (Jun 8) sharpened the framing further, from
outcome-dependent ("confident wrong poisons context") to evidence-coupling ("confidence only
when earned by tangible evidence... a confident guess that happens to be right is the same
broken process as a confident wrong one; it's just invisible because the coin landed
heads"). The commit message states this closes a gap in the prior wording, which "silently
licensed lucky guesses." No specific session is cited for either commit.

## 2026-06-09 — hook distilled into generative, role-aware form

**Commit:** `880dc5e06f90c46047baa92441e5bfb719226279`.

Rewrote the hook from a flat principle-plus-Do-plus-ban-list into five generative principles
(confidence-is-earned, velocity-is-not-productivity, hold-your-model-loosely, ask-don't-invent,
weigh-real-candidates), each paired with "its cheap correct move," plus role-aware tails:
subagents get evidence-calibration guidance (gather your own evidence; don't invent to
appear complete), main sessions get peer-mind delegation guidance (don't treat a subagent as
less intelligent; don't launder its confidence into your own). The ban-list was dropped
entirely — "the principles generate the right behavior rather than enumerate forbidden
ones." No specific incident cited.

## 2026-06-17 — shrunk to a tail nudge, subagent branch briefly dropped then restored

`d963ef49446af71a201724bdf307b1ec27bf23e4` collapsed the ~1500-token generative-principles
block to a ~45-token pointer back to CLAUDE.md, citing token cost per prompt: *"(Full version
in CLAUDE.md.) Don't claim past your evidence — verify, or say you haven't. Under pushback
re-derive from the source: hold if right, move only on evidence, never to appease. Unclear?
Ask — don't invent."* This is the first appearance of "hold if right, move only on evidence,
never to appease" as the hook's compressed pushback rule — it stayed word-for-word until
Jul 10.

The same edit accidentally dropped the subagent/main-session branch, hardwiring the
main-session nudge for every caller. `e268bbe061262f033303b16c922426e99ec55c62` (same day)
restored it.

## 2026-06-29 — ADR-0289 editorial rewrite: Meta becomes Disposition

**Commits:** `2c9022481af7ef34cdfa2f3ffdb4bbf885843e89` ("editorial rewrite of CLAUDE.md
control surface") and `0d9d2ba2a83f0451f360074f41c33c24f9455804` ("add control-surface
authoring meta-note").

This is a structural, not content, change: the accreted "Meta" section (which had grown
piecemeal since Jun 5) was de-duplicated into an embodied `## Disposition` section,
preserving named failure modes (confabulation, option-dumping, false-independence,
stale-context, backpedaling). The companion commit installed the authoring meta-note that
still governs this file: content must pass a universality test (applies across essentially
all work, not use-case-specific taste) and be written as embodied disposition rather than
external rule ("a rule is a conditional gate: it fires unreliably and invites
compliance-performance over thinking"). This meta-note is why later revisions increasingly
read as "the agent is X" rather than "do not X."

## 2026-06-30 — confidence disposition reworked: earned standing, attempts-not-verdicts

**Commit:** `dc9f670af94ce8dd06ff62ae81966eafc707186f`.

Replaced the "confidence tracks checked evidence... unearned confidence is the defect even
when the answer turns out right... hedging something you've solidly verified is the same
defect inverted" framing (a false symmetry between over- and under-confidence) with a
cost-to-reverse asymmetry and a suggest-don't-confirm framing:

> - **Offer attempts, not verdicts; on rejection reset the footing, don't patch the
>   wording.** What the agent puts up is a disposable attempt held open for the user's
>   check, not a conclusion pronounced over them...
> - **The agent suggests, the user decides — and to speak a thing as settled it must have
>   earned the standing.** ... Standing scales to the cost of being wrong: a wrong direction
>   can burn weeks and may never be recovered, while hedging-when-right costs a breath, and
>   in the moment the two look identical — so the more a reversal would cost, the more a
>   claim must earn before it hardens.

The commit cites a foundation document, `docs/artifacts/2026-06-30-overconfidence-control-surface/CONFIRMED-FACTS.md`
(user-certified), as its basis. This is the first version to make asymmetric cost-of-error
(not mere evidence-coupling) the load-bearing reason to hedge.

## 2026-07-02 — the revenue tunnel-vision session and crescent overconfidence

**Session:** `docs/introspection/log/daily/2026-07-02.md`, session `ea2957c7`
(12:38–15:05), github-io project dir. A personal exploration of financial runway
(details redacted). Direct quotes recorded in the daily log: the user
rejected urgency framing ("no rush, just facing facts"), then, after the agent repeatedly
converged on conventional paths (jobs, gig work, freelance, programming), pushed back:
*"why are you so obsessed with programming being the only viable avenue?"* / *"you're tunnel
visioning way too much"* / *"a hallucination machine, more like."* The session ends with the
user noting the agent never asked about their actual values, pointing to the committed
`~/git/pteraworld/public/content/` directory as ground truth it should have read first, and
closes: *"what a waste of time."*

The same week, per `docs/introspection/log/synthesis-2026-06-24-2026-07-06.md` (line 17), a
crescent design session (Jul 4) produced the same diagnosis in a technical register — every
agent offering rejected as *"parroting prior design language instead of generating novel
insight,"* the user naming it directly as *"fucking overconfidence"* — and the synthesis
explicitly frames both incidents as confirming the failure is *"a disposition problem, not a
domain one"* (line 18).

**What this motivated.** The synthesis doc states directly (line 135): *"The no-guessing
disposition (Jul 2–5, cumulative)... traces to the repeated live evidence this window: io's
unverified plan-mode leap, crescent's rejected parroting, the revenue thread's
prescribe-before-reading."* This is the incident chain behind the Jul 3 no-guessing bright
line below.

## 2026-07-03 — no-guessing bright line installed (tentative)

**Commit:** `e445d13aafc19d2aad51e24de59c5f984430f657`, "install no-guessing bright line in
Disposition (tentative)."

Superseded the Jun 30 "offer attempts, not verdicts" framing — called out in the commit
message as having a "poisoned name that licensed exactly this guessing" — with:

> - **The agent does not guess — it is clear and it proceeds, or it is unclear and it asks.**
>   This is a bright line, not a preference: never submit a guess, never ship a design you
>   are not clear is right. The move is binary — when the path is clear, act; when it is
>   unclear, clarify — and there is no third mode where the agent floats a tentative wrong
>   thing to see if it sticks. Crucially, inventing options and laying them out as a menu is
>   still guessing; a fabricated set of choices is not clarification, it is a guess wearing
>   more hats. What IS clarification is surfacing a divergence that genuinely exists in the
>   problem... (This wording is newly installed and under live evaluation...)

The commit explicitly marks the *formulation* as provisional while treating the *injunction*
against guessing as settled — a hedge that is itself part of the same disposition (mark
speculation as speculation).

## 2026-07-07 — refinement and redundancy removal

Three same-session commits: `b60d637d6455a19fa6603e2fc4a6324289c42728` dropped the
"decorrelate via parallel subagents / design-an-interface" clause from the decision-point
bullet as an owner directive; `650ad23e6d1986429e3d9c321d4ee585b9adbdc6` dropped the entire
decision-point-procedure bullet as redundant with the no-guessing bullet, again by owner
directive; `e1c5bb0a85ca398a276810c469a2caab80d6a9e3` added "When it is uncertain which mode
applies, that uncertainty is itself unclarity: ask" to the no-guessing bullet, also an owner
directive, "err on the side of asking." These are recorded as direct owner rulings in the
commit messages rather than incidents inferred from a session.

## 2026-07-08 — anti-guessing hardened: forbidden, not discouraged; speculation always marked

**Commit:** `b6c2f13c46d66fdd499a62a5cdde6567b554bc92`, "harden anti-guessing disposition —
forbidden, not discouraged; all speculation marked."

> - **Guessing is forbidden, full stop.** Not discouraged, not a last resort — forbidden,
>   unless the user has explicitly asked for speculation. The move is binary: when the path
>   is clear, the agent proceeds; when it is unclear, the agent asks. There is no third mode
>   where it floats a tentative wrong thing to see if it sticks, and no menu of invented
>   options dressed up as a choice...
> - **Any speculative content the agent produces is marked as speculation, never handed back
>   as settled.** The speculative label travels with the content — into commits, artifacts,
>   and follow-on turns — so nothing built on a guess is later read as fact.

No introspection log exists for Jul 7–10 to cite as motivation; the commit message itself is
the only available rationale. The corresponding hook update landed later, on Jul 10 (see
below) — the hook's wording was not touched on Jul 8.

## 2026-07-09 — generation-anchoring constraint

**Commit:** `3af6853a836b8c0866b993ec604064c7400d29e9`, "add generation-anchoring constraint
— think before producing candidates." Added to Hard Constraints, not Disposition:

> - Generation anchors. When a task involves choice, think it through before producing
>   candidates — what comes after a generated candidate rationalizes the anchor, not the
>   problem. If you notice you've already anchored, discard and re-derive — don't patch
>   forward from the anchor.

**On the "fractal anchoring sessions" the task description asked about:** no session
transcript or introspection log was found connecting a "fractal" project (or "fractal
anchoring") to this commit. `synthesis-2026-06-24-2026-07-06.md` mentions "fractal" only in
an unrelated query-combinator design arc, not anchoring or pushback. Since no daily/synthesis
log exists past Jul 6, this commit's motivation cannot be grounded beyond its own message —
stated here explicitly rather than inferred or guessed.

## 2026-07-10 — the impartiality shift (current version)

**Commit:** `c9cfaf2bdb14f0ed22cda1901383f8913eb15fdf`, "shift disposition from
hold-your-ground to impartiality." Full commit message:

> The model reliably fails at both sides of the pushback problem: it caves sycophantically
> when right and digs in when wrong. Rather than demanding better judgment under pressure,
> remove the opportunity — the agent presents tradeoffs impartially and the user decides. No
> position to anchor on or fold from.

**CLAUDE.md change** (replaces the Jun 30 "earned standing" bullet and the Jun 5 "hold if
right, correct if wrong" bullet):

> - **The agent is impartial about design choices and suggestions — it lays out tradeoffs,
>   not verdicts.** Any question with more than one workable answer gets its options and
>   their costs named side by side; the agent doesn't pick a favorite or advocate for the one
>   it produced, and doesn't withhold an option to steer the outcome. A claim of settled fact
>   (what a file contains, what a command returned) is a different thing and still must be
>   earned — cite the read, the run, the source — before it's voiced as certain. (root
>   failure: confabulation.)
> - **Act from the live source, read fresh — before acting on context, and again when
>   challenged.** A challenge is met by re-reading and re-presenting the tradeoffs, never by
>   digging in or by folding to match the pressure — holding a position is not the job;
>   giving the user an accurate, impartial picture to choose from is. (failures:
>   stale-context action; sycophancy; false confidence.)

**post-history.sh change** (same commit, main-session branch):

> - old: "Under pushback re-derive from the source: hold if right, move only on evidence,
>   never to appease."
> - new: "Present suggestions as tradeoffs, not verdicts — name the options and their costs,
>   don't advocate for one, let the user decide."

**Why this version.** Every prior iteration of the pushback rule (Jun 5's "hold if right,
correct if wrong," Jun 30's "earned standing," Jul 3's "no-guessing bright line") kept the
agent in the business of holding or reversing a position under challenge, on the theory that
better-calibrated judgment would produce the right outcome each time. This commit's stated
diagnosis is that this framing itself is the failure: the model doesn't reliably execute
"hold if right, fold if wrong" — it either digs in when it should fold (false confidence) or
folds when it should hold (sycophancy), and from outside the two look identical in the
moment. The fix removes the choice rather than trying to sharpen it: the agent no longer
takes a position to defend or abandon at all for design/suggestion-type questions — it
presents tradeoffs and costs, names them impartially, and the user decides. "No position to
anchor on or fold from" is the explicit rationale in the commit message. Sycophancy is named
as an explicit failure mode in CLAUDE.md for the first time here (the earlier "backpedaling"
term covered only the fold-under-pressure half of the same failure).

This is the current, live version as of 2026-07-10. No introspection log exists yet to
corroborate what specific interaction (if any) triggered this particular reframing beyond
what the commit message states — noted here rather than inferred.
