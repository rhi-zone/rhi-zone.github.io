# Open-threads candidates — session mining (2026-03-25 → 2026-05-24)

Staged output from the Opus mining subagent dispatched 2026-05-24. Not yet
promoted into `docs/open-threads/`. The handoff session should review this
list, decide which to file, and convert the picks to one `.md` per thread in
the same shape as `docs/open-threads/worldbuilding-namespace.md`. Delete this
file once promotion is complete.

## Method recap

- ~6155 sessions across 49 projects scanned via `normalize sessions stats`
  (project-day aggregates).
- Triage-first: broad `--grep` on user messages with deferral / design-question
  / scope / cross-project keyword families across all projects. ~1500
  candidate-moments after stripping task-notification noise.
- Spot-deep-reads on ~10 high-signal sessions plus the in-tree
  `docs/introspection/investigations/2026-05-20-whats-wrong/synthesis.md`.
- Cross-checked against project TODOs, CLAUDE.md, `claude-code-guide.md`, the
  software-taxonomy `TODO.md` Open Questions section (commit `50bf4e1`), and
  the existing registry entry. ~8 unique threads survived dedup.

## Recommended for registry (ranked by cross-project relevance)

### 1. harness-orchestrator-fit

**Question:** Does the Claude Code harness assume an orchestrator-class model?

- **Projects touched:** all (cross-cutting; surfaces in crescent, reincarnate,
  hologram, normalize sessions); meta-investigation lives in github-io
- **First raised:** session `7b1ce10e` (2026-05-13 → 2026-05-20 quote), user
  message: "CLEARLY claude code's harness is not designed for sonnet top level
  agents at all"
- **Also surfaced in:** `9e8bf1e4` (reincarnate, 2026-04-22, 149-subagent HM
  session), `033086a7` (reincarnate, 199 subagents); synthesis at
  `docs/introspection/investigations/2026-05-20-whats-wrong/synthesis.md`
  explicitly names this as untested
- **Status:** open — explicitly flagged "no agent tested this directly"
- **Working answer:** none
- **Why registry, not TODO:** affects which model defaults belong in CLAUDE.md
  across all repos; shapes future scaffolding
- **Predicted test:** same task with Opus vs Sonnet as top-level orchestrator
  on coupled subagent work
- **Suggested filename:** `harness-orchestrator-fit.md`

### 2. domain-generator-corpus

**Question:** Would a generator-corpus (worked examples + counterexamples)
outperform a rule-corpus (CLAUDE.md) for the failing constraint classes
(no-specialcase, no-bandaid, specialcasing-vs-generalization)?

- **Projects touched:** all (claude-config layer); meta-investigation lives in
  github-io
- **First raised:** synthesis "Hypotheses no one tested but the data implies"
  — H-DOMAIN-GENERATOR-COMPRESSION
- **Also surfaced in:** May 13 "Counterweight: don't fake confidence" rule
  (`7521987c`) held up as the working case; bandaid-style rules are failing
  cases
- **Status:** open
- **Why registry, not TODO:** every repo's CLAUDE.md is downstream
- **Suggested filename:** `domain-generator-corpus.md`

### 3. design-decisions-convention

**Question:** What's the standard filename + pointer pattern for prior design
decisions across the ecosystem, and what's the cutoff between ephemeral and
load-bearing?

- **Projects touched:** crescent, hologram, defocus, interconnect, myenv,
  scribble, portals, tiltshift, chub-stage-factory (partial adoption)
- **First raised:** session `74867717` (hologram, 2026-05-03): "some stuff
  might be poisoning CLAUDE.md and can go in prior design decisions? with a
  very short pointer from CLAUDE.md for 'for design decisions/questions, check
  <link here>'?"
- **Also surfaced in:** `82f8c396` (defocus, 2026-05-03), `e511dc6f` (crescent,
  2026-05-13), `37565687` (io, 2026-04-27)
- **Status:** open — partial adoption: some repos have `DESIGN.md` (portals,
  tiltshift, chub-stage-factory), some `docs/design.md` (myenv, scribble), one
  `docs/design-decisions.md` (interconnect); github-io has no convention
- **Tension:** user has rejected formal ADRs ("the lack of adr infra is
  intentional, a lot of the decisions imo are ephemeral/not load bearing")
  while simultaneously asking individual repos for design-decisions docs
- **Why registry, not TODO:** controlled by github-io's propagation tooling
- **Suggested filename:** `design-decisions-convention.md`

### 4. context-md-adoption

**Question:** Should `CONTEXT.md` be a mandatory ecosystem-wide artifact, or
remain opt-in per-project?

- **Projects touched:** crescent, defocus, interconnect, tiltshift, normalize,
  reincarnate (have it); all others (don't)
- **First raised:** `37565687` (io, 2026-04-27): "what about subagents to seed
  CONTEXT.md or whatever?"
- **Also surfaced in:** the `improve-codebase-architecture` skill (this repo)
  assumes it exists
- **Status:** open — partial adoption, no decision recorded
- **Why registry, not TODO:** convention question; affects scaffolding + the
  propagation toolchain
- **Suggested filename:** `context-md-adoption.md`

### 5. out-of-scope-stance

**Question:** Should the ecosystem-wide CLAUDE.md explicitly forbid "out of
scope" as a deferral pattern, and how does that interact with legitimate
project-boundary discipline?

- **Projects touched:** all
- **First raised:** session `6842c90d` (io, 2026-04-25): "the moment we call
  something out of scope is the moment we fail"
- **Also surfaced in:** `e6ae6069` (crescent, 2026-04-26): "doing things
  halfway is unacceptable? similarly with delaying anything indefinitely (or
  even worse, omit it entirely) with the excuse of 'it's out of scope'"
- **Status:** open — stance articulated twice across two repos, never codified
- **Why registry, not TODO:** would propagate to all repos
- **Suggested filename:** `out-of-scope-stance.md`

### 6. claude-md-saturation-curve

**Question:** Across the ecosystem, is CLAUDE.md churn approaching saturation
(rule set converging on the implicit-constraint set) or still mining (new
rules per violation isn't falling)?

- **Projects touched:** all (crescent's 98 commits / 60 days is the canonical
  signal)
- **First raised:** synthesis "What we still don't know" — "no measurement of
  whether commits-per-violation is rising (saturating) or falling (still
  mining)"
- **Status:** open — measurable but unmeasured
- **Why registry, not TODO:** measurement crosses every repo; tooling fits
  github-io introspection
- **Suggested filename:** `claude-md-saturation-curve.md`

### 7. compaction-loss-rate

**Question:** What is the actual rate at which compaction silently strips
load-bearing prior agreements?

- **Projects touched:** all interactive sessions; tooling fits normalize
- **First raised:** synthesis — "two confirmed cases over 60 days is sparse;
  users don't always notice when an agreement is lost, so the count is a
  floor"
- **Also surfaced in:** `db532ce7` (normalize), `9501a0b0` (crescent) — both
  single confirmed compaction-loss instances
- **Status:** open — measurement-blocked
- **Why registry, not TODO:** detector would live in normalize or github-io
  tooling; question crosses all interactive work
- **Suggested filename:** `compaction-loss-rate.md`

### 8. specs-as-software

**Question:** Is `@spec:` / `@protocol:` a software-taxonomy-only namespace,
or does it deserve to be a shared ecosystem concept that concord, paraphase,
rescribe can reference?

- **Projects touched:** software-taxonomy (primary); cross-resonance with
  concord (API bindings IR), paraphase (format conversion), rescribe (format
  adapters), ooxml
- **First raised:** founding session `b933d7e2` — listed in software-taxonomy
  `TODO.md` "Open questions from the founding session"
- **Status:** noted in software-taxonomy TODO; surfaced here because
  concord/paraphase/rescribe/ooxml all sit on spec-shaped artifacts and would
  benefit from a shared entity type
- **Why registry (not just software-taxonomy TODO):** the decision affects
  whether concord/paraphase/rescribe ever interop with software-taxonomy's
  knowledge graph
- **Suggested filename:** `specs-as-software.md`

## Considered and rejected

- `worldbuilding-namespace` — already seeded as the registry's first entry.
- `post-history-hints` (session `dd7900fb`) — resolved: doc landed in
  `docs/claude-code-guide.md`; tooling exists in `tooling/claude-hooks/`.
- `handoff-skill-across-ecosystem` (session `4c7311e2`) — resolved in same
  session; skill propagated.
- `compositional-crescent` (session `2bd5b966`) — landed in crescent
  `docs/principles.md` ("make the computer small").
- `mattpocock-skills-cross-reference` (session `37565687`) — resolved (skills
  now live in `tooling/claude-commands/`).
- `lore-folklore-lens`, `temporal-developed-by`, `worldbuilding-sub-lens`,
  `adversarial-scalability-subagent` — already in software-taxonomy TODO "Open
  questions from the founding session" (commit `50bf4e1`).
- `rescribe-vs-paraphase boundary` — addressed in `rescribe/TODO.md`
  (horizontal sweeps explicitly out of scope; thin IR adapters).
- `settings-menus-as-sister-project` (session `ef0142c8`, keybinds) — too
  early; one-off speculation that hasn't recurred.
- `lua2ts pack-load timing` (crescent handoff doc `0d29df43`) — pure
  crescent-internal; lives in crescent TODO.
- `crescent typechecker v5 vs v4 over-scope` (session `a9ec0954`) — pure
  crescent-internal; lives in `TODO-typecheck.md`.
- `dusklight HM-typechecker reuse` (session `d7d48724`) — venting moment, not
  a sustained design thread.

## Notes on the corpus

High-signal cross-project threads cluster around two attractors:

1. **The claude-config layer** (CLAUDE.md, CONTEXT.md, design-decisions docs,
   generator-corpus, post-history hints) — most candidates here, because the
   user routinely articulates the failure mode in one repo but the fix lives
   in github-io's propagation tooling.
2. **Measurement gaps** named in the May 20 synthesis but never converted
   into work items.

Single-project deferrals overwhelmingly get captured into that project's
TODO.md within the same session, so the surviving cross-project residue is
small. The May 20 investigation
(`docs/introspection/investigations/2026-05-20-whats-wrong/`) is the densest
unmined source — its "Hypotheses no one tested" and "What we still don't
know" sections are essentially a pre-staged registry waiting to be filed.

## Key files referenced

- `docs/introspection/investigations/2026-05-20-whats-wrong/synthesis.md`
- `docs/open-threads/{index,worldbuilding-namespace}.md`
- `/home/me/git/pterror/software-taxonomy/TODO.md` (lines 140–180)
- `docs/claude-code-guide.md`
- `/home/me/git/rhizone/crescent/docs/principles.md`

---

## Scope B — Active work in progress (snapshot 2026-05-24)

Per-project, terse. Based on `git status` + unpushed commits across all
ecosystem repos as of 2026-05-24 and `normalize sessions stats` for the last 7
days (2026-05-17 → 2026-05-24).

### crescent
- **In motion:** typechecker v5 — op-sem CHKT + HOUnify extension landed; perf
  re-gate PASS. Substrate work for parked-map / HOUnify; world substrate
  (genre-neutral) design doc landed alongside.
- **Unpushed:** 309 commits ahead of `origin/master` — heavy backlog of
  typechecker v4/v5 work, docs, polish.
- **Uncommitted:** none.

### reincarnate
- **In motion:** Law 2 fixes (constraint_collect guard, array_like_fids), runtime
  bodies expansion (type predicates, point_in_*), `_rt` threading via IR.
- **Unpushed:** 30 commits ahead.
- **Uncommitted:** `.claude/` (untracked — usual local config dir).

### chub-stage-factory
- **In motion:** Waves 2A/2E/2F/2I library consolidation; LLM-PIPELINE patterns,
  synergy composers (14), embeddings + LlmPipeline primitives; REFERENCE +
  PATTERNS + README + ROADMAP + TODO consolidation.
- **Unpushed:** 72 commits ahead.
- **Uncommitted:** `flake.lock` added, `flake.nix` modified, `.normalize/`
  untracked.

### github-io (this repo)
- **In motion:** open-threads-candidates draft (Scope A from first pass, Scopes
  B/C now). `docs/introspection/investigations/2026-05-20-whats-wrong/` is
  untracked — the synthesis the first pass mined.
- **Unpushed:** 1 commit ahead.
- **Uncommitted:** `drafts/open-threads-candidates.md` (this file, untracked),
  `docs/introspection/investigations/` (untracked, contains the May 20
  what's-wrong investigation).

### rainbow
- **In motion:** TODO.md edits in progress (modified, uncommitted).
- **Unpushed:** none.
- **Uncommitted:** ` M TODO.md`, `?? packages/core/.normalize/` (cache dir,
  gitignore territory).

### scribble
- **In motion:** TODO.md draft (untracked).
- **Unpushed:** none.
- **Uncommitted:** `?? TODO.md`.

### postmortem (paragarden)
- **In motion:** TODO.md edits.
- **Uncommitted:** ` M TODO.md`, `?? .normalize/`.

### solarium (paragarden)
- **In motion:** TODO.md + maybe-rules.md drafts (both untracked).
- **Uncommitted:** `?? TODO.md`, `?? maybe-rules.md`, `?? .normalize/`.

### ashwren / fuwafuwa
- **In motion:** autonomous bot state files only (`brain/*-state.json`,
  `brain/session.lock`). These are intentional runtime mutations, not human
  in-progress work. fuwafuwa has 1183 sessions in the last 7 days (autonomous
  loop); ashwren has none in the active window.

### hologram
- **In motion:** 5 interactive sessions in the last 7 days. Recent commits not
  examined in detail; no unpushed local commits, no dirty files.

### normalize
- **In motion:** 4 interactive sessions in the last 7 days. No unpushed commits,
  no dirty files. Likely consolidation/triage work.

### Quiet (no recent activity, no dirty state)
- gels, motif, unshape, wick, playmate, defocus, tiltshift, paraphase, rescribe,
  concord, moonlet, dusklight, deskspace, interconnect, myenv, portals, zone,
  nanites, server-less, profile, rhi.zone, exo.place, aspect, noncanon,
  existence, legacy, divergence, matrix-gen, software-taxonomy,
  statosphere-guide, statosphere-studio, keybinds, ascent-interpreter, ooxml,
  claude-code-hub, sketchpad.

### Drafts mid-thought (this repo, `drafts/`)
- `drafts/chess-position.md` — committed 2026-05-23, the tragic-yuri fork
  sequence; live thread.
- `drafts/her.md` — committed 2026-05-22, persistent-self primitive as crescent
  dogfood; live thread.
- `drafts/game/DESIGN.md` — untracked design doc for the unnamed sandbox game;
  in-progress.
- `drafts/open-threads-candidates.md` — this file.

## Scope C — Abandoned sessions (NEEDS USER ATTENTION)

Sessions that were left hanging and never explicitly closed. Ranked by recency
(most recent first — those are the easiest to remember and resume).

**Method:** scanned 2,128 interactive (non-bot) sessions across the
`/mnt/ssd/ai/claude-sessions/projects` corpus, age 14–60 days, with ≥120s
duration and ≥8 user messages (filters out trivial probes). Read the tail of
the top 80 candidates via `normalize sessions show ... --json`. Cross-referenced
against `/handoff` plans (these are intentional closes, not abandonment),
against git logs around the session end, and against successor sessions.

Overwhelmingly, sessions either end with an explicit closer (`Done.`,
`Pushed.`, `Clean.`, `Bye!`, `Catch you later!`), with a `/handoff` plan
written to TODO.md (intentional close), or with `[Request interrupted by
user]`. The genuinely-abandoned set — assistant-last with no explicit closure,
or interrupted-and-never-resumed — is small.

### 1. `0e6fcd81` — crescent — last activity ~2026-04-10
- **What it was doing:** "Implement the following plan: # Static Typechecker
  for Crescent" — large planned implementation session (82 turns).
- **Where it stopped:** `[Request interrupted by user for tool use]`.
- **Signals matched:** 1 (mid-execution interrupt), 4 (interrupted mid-tool).
- **Successor sessions:** typechecker work continued vigorously on crescent
  (309 unpushed commits, v4→v5 rewrite). This specific plan was likely
  superseded.
- **Uncommitted work in repo:** crescent clean of dirty files; typechecker
  v4/v5 evolved into a different design.
- **Suggested action:** formally close — superseded by the v4/v5 work.
- **Resume hint:** if you want to understand what this plan said, read the
  session's first user message (the full plan text is preserved there).

### 2. `8d2d8933` — server-less — last activity ~2026-04-25
- **What it was doing:** "do we have decent errors based on our input types? …
  we know the exact structure of input" — investigating type-driven error
  messages for server-less inputs.
- **Where it stopped:** `[Request interrupted by user for tool use]` mid-Bash.
- **Signals matched:** 1 (mid-execution interrupt), 4.
- **Successor sessions:** one server-less session on 2026-04-26
  (`bf0b9005`, also interrupted). No deeper follow-up.
- **Uncommitted work in repo:** server-less clean; commit `3d4549e` renamed
  `FailedPrecondition` → `UnprocessableEntity` around the period but unrelated.
- **Suggested action:** convert to TODO entry in `~/git/rhizone/server-less/TODO.md`
  ("type-driven input error messages — verify current state").
- **Resume hint:** the user wanted ergonomic errors that exploit known input
  structure rather than generic validation messages.

### 3. `37565687` — github-io — last activity ~2026-04-30
- **What it was doing:** mining mattpocock skills repo for skills to adopt;
  worked through several, landed `ubiquitous-language` skip + Relationships /
  Grouping extraction into `CONTEXT.md` format guidance.
- **Where it stopped:** assistant: `"Done. Next?"` — explicit open-ended
  prompt, user never replied.
- **Signals matched:** 1, 4 (asked question, no answer).
- **Successor sessions:** none picked up the mattpocock mining specifically.
  Later io sessions moved to different topics.
- **Uncommitted work in repo:** none — all skill decisions were committed
  (`73640da`, `cfbee09`).
- **Suggested action:** formally close — the skill-mining task is logically
  complete; remaining mattpocock skills can be re-mined later or left.
  Optionally, convert remaining skills list to a TODO entry.
- **Resume hint:** check `docs/skills-mattpocock.md` for which skills were
  evaluated; pick up from any remaining unmarked ones.

### 4. `d54a9d63` — github-io — last activity ~2026-05-09
- **What it was doing:** mirroring Wildbow's Ward at parahumans.net to
  `/mnt/ssd/books/wildbow/ward/`. After httrack crashes, switched to wget;
  finished at 245M / 1,636 files.
- **Where it stopped:** assistant: `"Ward done — 245M, 1,636 files. That looks
  right for a full serial."` Confirmation message, no user reply.
- **Signals matched:** 1 (assistant-last, no reply), no successor.
- **Successor sessions:** none on the topic. `/mnt/ssd/books/wildbow/ward/`
  still exists.
- **Uncommitted work in repo:** none (mirror is not in a repo).
- **Suggested action:** archive — task completed; the absence of a "thanks"
  reply is just early end-of-session, not lost work. Verify the mirror is
  intact and call it.
- **Resume hint:** other Wildbow serials may have been on the implicit list
  (Worm, Pact, Twig). Re-prompt only if you want more mirroring.

### 5. `b638eaa2` — normalize — last activity ~2026-05-09
- **What it was doing:** session-end `/handoff` skill; updated `TODO.md` with
  0.4 semantic-analysis anchor, committed (`80de403d`), pushed.
- **Where it stopped:** assistant thinking `"I'm ready to call ExitPlanMode
  and signal that the handoff plan is complete."` — the ExitPlanMode call
  itself never resolved (likely process killed mid-call).
- **Signals matched:** 4 (mid-tool, hung in plan mode).
- **Successor sessions:** TODO.md is in the canonical state; the handoff
  succeeded.
- **Uncommitted work in repo:** none — work was committed before the hang.
- **Suggested action:** archive — work is durable; only the closing tool call
  hung.
- **Resume hint:** none needed; the 0.4 plan is in `TODO.md`.

### 6. `6842c90d` — github-io — last activity ~2026-04-30
- **What it was doing:** discussion sparked by "spicy, awful idea time" + a
  LessWrong "rise of parasitic AI" link (169 turns) — drifted through many
  topics, ending on browser-based local UIs for notes/tracking apps and
  whether LuaJIT would work on Termux (no, Android disallows JIT, would fall
  back to interpreter).
- **Where it stopped:** assistant: `"Yeah. Interpreter mode is still Lua,
  still runs, just slower. For the kinds of apps we're talking about — notes,
  tracking, navigation — that's fine. Not a blocker."`
- **Signals matched:** 1 (assistant-last, conversational dangler).
- **Successor sessions:** no direct continuation of the Termux / LuaJIT-mobile
  thread.
- **Uncommitted work in repo:** none.
- **Suggested action:** convert to open-threads-registry entry — the "Lua /
  LuaJIT on mobile (Android / Termux)" question is a recurring substrate
  decision that affects crescent/moonlet's deployment story. Even with
  interpreter fallback, the question of whether a mobile crescent target is
  in scope is unresolved.
- **Resume hint:** the conversation rooted in "out of scope is the moment we
  fail" — see Scope A item `out-of-scope-stance`. Related.

### 7. `9e8bf1e4` — reincarnate — last activity ~2026-04-26
- **What it was doing:** "umm hi let's check recent/in progress activity?" —
  large session (231 turns) recovering context on reincarnate state. Ended
  with a `/handoff` plan ("Session 27 → 28 handoff").
- **Where it stopped:** assistant called ExitPlanMode with a full handoff
  plan. Looks like an intentional close.
- **Signals matched:** none clean; explicit `/handoff`.
- **Suggested action:** archive — explicit handoff. Mentioned for
  completeness because it's a 231-turn session that surfaced in the
  candidate list; the handoff is the close.

### 8. `0a7c6668` — crescent — last activity ~2026-04-10
- **What it was doing:** plan mode for AI API library (`lib/ai/`) — designing
  the `lib/ai/` interface and submitting a long plan via ExitPlanMode.
- **Where it stopped:** assistant emitted ExitPlanMode with the AI library
  plan. No follow-up in same session.
- **Signals matched:** 1 (plan submitted but no user response in session).
- **Successor sessions:** `lib/ai/` work has continued (the `ai_*` references
  in crescent's commit log).
- **Suggested action:** archive — plan landed in some form via subsequent
  work.

### 9. `0743f05f` — parents (private-recipient-a) — last activity ~2026-04-10
- **What it was doing:** `Implement the following plan: # Handoff: Remaining
  Audit Items` — continuation of a prior audit handoff.
- **Where it stopped:** `[Request interrupted by user]`.
- **Signals matched:** 1, 4.
- **Successor sessions:** parents has had subsequent sessions; this specific
  handoff continuation may or may not have been picked up.
- **Uncommitted work in repo:** not checked (parents lives outside the
  ecosystem table — `~/git/private-recipient-a`).
- **Suggested action:** convert to TODO entry in
  `~/git/private-recipient-a/TODO.md` if not already there.

### 10. `d18e162b` — parents — last activity ~2026-05-10
- **What it was doing:** updating stale `FreeWrite.tsx` comment, creating
  `docs/PACE_METRIC.md`.
- **Where it stopped:** assistant summary of two completed tasks, no user
  reply. Looks complete.
- **Signals matched:** 1 (assistant-last) but content suggests clean
  completion.
- **Suggested action:** archive — work landed.

### 11. `d7d48724` — dusklight — last activity ~2026-05-05
- **What it was doing:** large dusklight session (117 turns), ended with a
  `/handoff` ExitPlanMode for Marinada / Dusklight.
- **Suggested action:** archive — explicit handoff.

### 12. `e6ae6069` — crescent — last activity ~2026-04-27
- **What it was doing:** `system_dashboard` task, 73 turns, ended with
  ExitPlanMode `# Handoff — Session Context`.
- **Suggested action:** archive — explicit handoff.

### 13. `4239817c` — existence — last activity ~2026-04-11
- **What it was doing:** sim-audit improvements (read categorization) over 90
  turns, ended with `# Session Handoff` ExitPlanMode plan.
- **Suggested action:** archive — explicit handoff.

### 14. `01805bae` — crescent — last activity ~2026-04-13
- **What it was doing:** 440-turn deep typechecker session, ended with
  `# Session Handoff Plan` ExitPlanMode.
- **Suggested action:** archive — explicit handoff.

### 15. `24f387a0` — private-recipient-b — last activity ~2026-04-11
- **What it was doing:** 35-turn session ending with `# Handoff Plan —
  Session 5` ExitPlanMode (4 security fixes mentioned).
- **Suggested action:** archive — explicit handoff.

### Sessions where the tail looks like clean completion but the session-close ritual was skipped (informational, no action needed)

These appeared as assistant-last in the candidate sweep but the content shows
the work landed cleanly:

- `93776229` (hologram, 14d) — mention-cache eviction guarantee explained,
  pushed.
- `b46aa6f5` (io, 16d) — "Everything's pushed. Good session-close state."
- `008c110b` (hologram, 18d) — hardcoded hook path fixed, `info` findings
  non-blocking.
- `5bfb1ca1` (hologram, 18d) — "Pushed and running."
- `74867717` (hologram, 20d) — `/sendnote` command, "Up and running."
- `2971d62d` (parents, 22d) — three merges pushed.
- `a02bc091` (private-recipient-b, 22d) — worktrees + 200 stale branches cleaned, only
  master left.
- `bf390fa6` (pteraworld, 22d) — copymd userscript improvement.
- `27e65ec5` (crescent, 24d) — direnv exit error, "No response requested."
- `df3b57fa` (io, 24d) — "No worries — sorry for the runaround."
- `4ebc4eca` (io, 27d) — claude-code-guide subagent git identity caveat added.
- `3d598b73` (io, 28d) — cost-alarm discussion, ended on agreement.
- `adb52f90` (ashwren, 28d) — "ashwren now has a pulse."
- `dfd5bcca` (crescent, 28d) — "Done. What's the distraction?"
- `4c7311e2` (io, 29d) — propagate-skill.sh documented, "Clean."
- `f7295128` (nixos, 30d) — dma-buf double-counting explained.
- `a5b60c78` (normalize, 31d) — daemon stop verification.
- `cbbe0005` (sketchpad, 31d) — agent worktrees committed as gitlinks.
- `d6ddc4c3` (unshape, 32d) — plasticity/moi parity audit completed.
- `3b90dba1` (hologram, 33d) — "Up at 22:33:08."
- `dbca2615` (hologram, 33d) — "Pushed. We're good."
- `d7fd2a2f` (io, 34d) — `normalize-context/` symlink decision committed.
- `36484a2d` (website, 35d) — Apps Script GmailApp auth fixed.
- `ffe41dfe` (io, 37d) — `/handoff` skill trigger conditions, 29 repos pushed.
- `bfa025fd` (me, 38d) — `nixpkgs#graphicsmagick.out` fix.
- `7284a6d3` (io, 41d) — ST clone / character browser discussion.
- `c1f85f0e` (io, 41d) — three pushed, legacy remote URL fixed.
- `bce01010` (nixos, 43d) — "~75GB freed in total."
- Plus many sessions at the 44d cliff with explicit `Bye!` / `See ya!` /
  `Goodbye!` / `Catch you later!` closers (12+ such cases:
  `02c84dad`, `03260e18`, `03ec0380`, `06aa45e3`, `093e9b4d`, `0b89bb4d`,
  `0bb57bc6`, `0be3ae48`, `0c08d849`, `0d2de403`, plus more in the deeper
  tail).

## Scope C summary

- **80 substantial 14-to-60-day-old sessions** read in tail-only mode (top
  candidates by recency, with user_messages ≥ 8 and duration ≥ 120s).
- **6 genuinely abandoned sessions warranting user attention** (items 1, 2, 3,
  4, 6, 9 above): two interrupted (`0e6fcd81` crescent, `8d2d8933`
  server-less), one asked an open question with no reply (`37565687`
  github-io), two left assistant-last on a complete-task confirmation
  (`d54a9d63`, `b638eaa2` — both archivable but worth a glance), one drifted
  into an unresolved substrate question (`6842c90d` — Lua-on-mobile).
- **9 explicit-handoff sessions** that surfaced in the candidate list but are
  intentional closes (`9e8bf1e4`, `0a7c6668`, `d7d48724`, `e6ae6069`,
  `4239817c`, `01805bae`, `24f387a0`, `0a6094dd`, `48a4c8a0`, `0dea159d`,
  `0f60c336`, `05516755`, `2c0fddb0`, `9cd186b4`).
- **40+ sessions** that ended with a clean closer (`Done.` / `Pushed.` /
  `Clean.` / `Bye!`) — no action needed.
- **All under 60 days old**, so the user can plausibly still remember context.
- **Uncommitted work in any abandoned-session repo:** none directly tied to
  the abandoned sessions. `crescent` has 309 unpushed commits and
  `chub-stage-factory` has 72, but those are forward-progress, not stale work
  from abandoned sessions.
- **Patterns observed:**
  - The `/handoff` skill is doing its job — most "long old session" cases
    surface as explicit ExitPlanMode handoffs that landed work in TODO.md.
  - The 44-day cliff in the data is the corpus boundary
    (`/mnt/ssd/ai/claude-sessions/projects` has densest data after
    2026-04-10).
  - github-io (`io`) accumulates the most "assistant-last, no reply" tails
    because it's where exploratory cross-cutting conversations happen —
    these aren't lost work, they're dropped threads. The Lua-on-mobile
    thread (`6842c90d`) is the only one with substrate-level implications.
  - No power-outage cluster: no concentration of mid-tool interrupts on the
    same day. Interrupts are spread out and look like deliberate user kills.
- **No action required for fuwafuwa / ashwren autonomous loops** — those
  sessions intentionally end mid-state and rehydrate via `session.js
  start`/`end` machinery; the persistent state lives in `brain/*.json`.

---

## Scope C2 — Soft-abandoned sessions (forward-looking sign-off, no user reply)

Refined pass: the previous Scope C used mechanical end-state detection
(mid-tool interrupts, explicit "asked question + no reply") and missed the
dominant population — sessions where the assistant's final message implies
more work (next steps, soft questions, conditional offers, dangling
observations) and the user simply moved on. Per user clarification: forward-
looking sign-offs are NOT closers.

**Method:** enumerated all 544 interactive (non-fuwafuwa/ashwren/hologram-bot)
sessions in 2026-03-25 → 2026-05-10 with `duration_seconds ≥ 120` and
`user_messages ≥ 8`. Excluded the 60 already-filed session IDs from Scope C.
Extracted the final assistant text message of each session via `normalize
sessions show --json` in parallel (16 jobs). Pattern-matched the tail against
soft-abandon signals (`want me to`, `shall i`, `let me know if`, `next:`,
`remaining:`, `should we`, `what would you like`, `we still need`, trailing
`?`, conditional offers, etc.) — yielded 55 candidates. Filtered out 12 that
were explicit handoff-plan sessions (the tail says "Let me write the
handoff", "ready for handoff", "Final session summary:" — these mean the
`/handoff` skill was about to run or just ran). 43 remained.

Note: 462 of 493 scanned sessions bucket at the 44d age (corpus boundary
around 2026-04-10), so most of these are old; resume cost is high but they
are exactly the "forgotten session" cluster the user flagged. The 14d and
26d entries are the actionable recent ones.

### Per-project clusters (ranked by count)

#### reincarnate — 10 sessions

Heavy soft-abandon cluster. reincarnate accumulates plan-writing sessions
where the assistant asks "ready to dispatch?" or "what do you want to tackle
first?" and the user moves on. The project also has its own `MEMORY.md` and
`TODO.md` so much of the work is genuinely persisted — these tails are
mostly orchestration friction, not lost work.

- `09050a8b` (44d): "Good to restart now. Everything worth keeping is persisted... 4 commits this session, Dead Estate error breakdown in TODO.md"; successor: continued reincarnate work; action: archive (work persisted).
- `308dd55e` (44d): "What needs updating? The plan file or TODO.md?"; soft question, no reply; action: close (orchestration ambiguity, not work loss).
- `35abf860` (44d): "All 4 tasks are done. Summary: ..."; reads as completion but no closer; action: archive.
- `4c1b6ece` (44d): "It's where all the other transform passes live..."; explanatory, dangling implication that pass-placement decision needs resolving; action: TODO entry if not already there.
- `cf90d69e` (44d): "Committed. Ready to dispatch the implementation, or is this a good handoff point?"; soft offer; action: close (user implicitly chose handoff).
- `d481cb56` (44d): "What would you like to adjust?"; open question, no reply; action: close.
- `de3bbdc4` (44d): "Yes. What do you want to tackle first? Most actionable unblocked item is the `arrayLocalSet` panic..."; concrete next-task offer; verify: is `arrayLocalSet` panic still open in `reincarnate/TODO.md`? If not, archive; if yes, resume hint.
- `e08b6f99` (44d): "Plan is written. Ready for next session to pick it up and run the three parallel audit agents."; explicit hand-off to "next session"; action: verify the 3 parallel audit agents ran.
- `e777266f` (44d): "Want me to just exit plan mode and start implementing the warning diagnostics directly?"; explicit "Want me to?" with no reply; action: TODO entry — "warning diagnostics" implementation status unclear.
- `e7dc4062` (44d): "First let me write the new TODO item and update memory before the handoff:"; mid-flow truncation; action: archive if TODO.md got the entry.

#### normalize — 7 sessions

- `123da53e` (44d): "Good. Ready to pick up the next item — trigram suggestions for symbol-not-found, or one of the cross-repo analysis gaps?"; explicit two-way next-step offer; action: verify trigram suggestions or cross-repo analysis landed.
- `465003dc` (44d): "Priorities 1-3 are all done... Worth doing — it's small and fixes a legitimate gap. Let me do the handoff:"; mid-flow truncation; action: archive if handoff landed.
- `4fc0db00` (44d): "Let me update TODO.md first, then hand off."; mid-flow truncation; action: verify TODO.md update committed.
- `8b908703` (44d): "Here's the pillar status: Done / exceeded target..."; pillar-status report, implied "what next" not asked; action: archive (informational tail).
- `8e2afd0b` (44d): "Also need to add the TODO item about auditing string params that should be enums."; dangling TODO, in-flow; action: verify "audit string params for enum candidates" is in normalize TODO.md.
- `934ae1e1` (44d): "What would you like to adjust?"; open question; action: close.
- `e7500210` (44d): "...the new session starts fresh and can investigate cleanly. But for a plan on a different topic mid-session, investigate..."; meta-conversation about handoff timing; action: close (philosophical).

#### io (github-io) — 7 sessions

These are the classic "exploratory cross-cutting conversation" tails the
previous pass already flagged as a pattern.

- `18ad2c06` (44d): "Probably not worth the overhead for solo work." re `dev/active/` per-feature TODO layout; action: registry candidate — "per-feature TODO layout" as ergonomics decision.
- `43fac5ae` (44d): "New session would be cleaner... What's the current state of moss session analysis?"; asked a question, no reply; action: close (the question got answered later when normalize sessions tooling matured).
- `54c7d657` (44d): "All 13 repos committed. The memory system is now explicitly banned everywhere..."; declarative summary, no forward question; action: archive.
- `58f451fe` (44d): "Everything from the architecture TODO is done. The remaining open items are all parked or explicitly blocked..."; observation of blocked items; action: archive (blocks are tracked).
- `8b8df9f4` (44d): "As for next steps — I'd say start a session in `motif/` directly..."; explicit pointer to motif/; action: verify motif/ work started (it did — see ecosystem table).
- `8dbd1890` (14d) **MOST RECENT**: "The species floor is invisible and the human ceiling feels like catastrophe. The scale of what we consider normal is completely broken."; philosophical dangler from a cross-cutting conversation; action: registry candidate — recurring theme but no concrete work item.
- `b695ca4b` (44d): "is there a plan to fix the hash index, or is that being deferred to QBE/dynasmrt?"; explicit open question (about a sub-agent's reasoning); action: close (was about an agent's behavior, not a real plan).

#### unshape — 4 sessions

- `2f8ad113` (44d): "Yep! Clean working tree, 8 commits ready to push:..."; reads as ready-to-push state, no closer; action: verify the 8 commits got pushed.
- `6c167a4c` (44d): "I notice some design issues: 1. Unused infrastructure... 2. Doppler not integrated..."; explicit 2-item observation list; action: TODO entry — "delay buffer unused; doppler not integrated" in unshape/TODO.md.
- `9eb0b411` (44d): "Committed `2895153`. Summary of what we did: ... Code added to resin-image: composite/drop_shadow/glow/bloom..."; summary trailer, no forward; action: archive.
- `aa696f9a` (44d): "Both open tasks from the session start are resolved. The TODO.md is updated. Nothing..."; clean completion; action: archive.

#### rescribe — 2 sessions

- `a431db77` (44d): "42 fixtures exist, 44 items unchecked. Many unchecked items map to things the html reader should handle... This is a large vertical. Let me enter plan mode to hand off..."; mid-flow truncation; action: verify the html-reader-gaps plan landed in rescribe TODO.md.
- `e97262e5` (44d): "All committed. Clean working tree, 6 commits ahead of origin. Fresh session makes sense..."; explicit "ready for fresh session"; action: verify those 6 commits got pushed.

#### pteraworld — 2 sessions

- `72f4bd58` (44d): "What would you like to change about the handoff?"; soft question; action: close.
- `97d69bd8` (44d): "Yep, we're in a good spot. All pushed... Let me know if the transitions or scaling need tuning later."; conditional offer; action: close (offer for refinement, not a real loose end).

#### interpreter (ascent-interpreter) — 2 sessions

- `2132e15c` (44d): "What would you like to work on next?"; open question; action: close.
- `7101d200` (44d): "Let me make it unambiguous:"; mid-flow truncation re CLAUDE.md "short plan" wording; action: verify the wording change committed.

#### existence — 2 sessions

- `30788afc` (44d): "The plan at `/home/me/.claude/plans/fluffy-rolling-meadow.md` is comprehensive... Let me present it for your sign-off."; awaiting sign-off, never given; action: registry candidate — `fluffy-rolling-meadow.md` plan exists, status unclear.
- `444ab029` (44d): "It wasn't in TODO.md to begin with — it was only in the code. Now commit:"; mid-flow truncation; action: verify the commit landed.

#### aspect — 2 sessions

- `4186c0d5` (44d): "I'd defer the version archive to a follow-up commit after Phase 1 core lands..."; explicit deferral of a feature; action: TODO entry — "world pack version history (Y.Doc / IndexedDB)" in aspect TODO.md.
- `68198b17` (44d): "Sure. What's in the next batch?"; user dropped the conversation; action: close.

### Standalone candidates (one-off per project)

- `4fd62328` — comfyui — 26d: "If you want it faster at upscale res, the usual moves are tiled diffusion..."; conditional offer; action: close (optimization advice, no real loose end).
- `36241a4b` — private-recipient-b — 44d: "Looking at what's left after this session: Substantive work: - GUI first-run wizard + ts-morph integration... still needs design work"; explicit "what's left" list; action: registry / TODO entry — private-recipient-b has a clear unfinished feature surface.
- `8a6b9ba4` — crescent — 44d: "Memory updated. TODO.md has the full list — the key next-session items are: `x = x or default` pattern; Discriminated union narrowing..."; explicit next-session item list; action: archive — items are in TODO.md, the crescent typechecker has since evolved (v4→v5) so list is likely superseded.
- `e0e0a560` — pad — 44d: "Done! Remaining in TODO: Email extension, RSS/Atom feed extension, Screenshot OCR, zstd compression, Unusual hours detection, Non-Linux inotify fallback. Continue? Screenshot OCR could be interesting..."; explicit "Continue?" with concrete pick; action: registry — pad has 6 listed open extensions, "Screenshot OCR" was the suggested next; check whether pad still exists.
- `54eb307b` — wick — 44d: "Done! Updated TODO.md and pushed all commits. The integer numeric type support is complete and live."; declarative closer despite "Done!"; action: archive.

### Summary

- **Total soft-abandoned: 43 sessions** (after excluding the 6 from Scope C, the 12 explicit-handoff trailers, and the ~146 explicit-closer sessions in the same window).
- **Top 3 project clusters:** reincarnate (10), normalize (7), io (7).
- **Highest-priority for user attention** (recent or strongest implied-work signal):
  1. `8dbd1890` (io, 14d) — most recent; philosophical "species floor invisible / human ceiling catastrophe" dangler; registry candidate as a recurring framing.
  2. `4fd62328` (comfyui, 26d) — only other sub-30d entry; resolvable as "close, advice was given".
  3. `30788afc` (existence, 44d) — `fluffy-rolling-meadow.md` plan awaiting sign-off that never came; either approve or discard the plan file.
  4. `e777266f` (reincarnate, 44d) — explicit "Want me to start implementing the warning diagnostics?" with no answer; concrete unfinished work item.
  5. `36241a4b` (private-recipient-b, 44d) — has an explicit unfinished-feature-surface list (GUI wizard, CLI scaffold) that belongs in private-recipient-b/TODO.md or registry if not there.
- **Pattern observations:** the dominant population is exactly what the user described — sessions where the assistant ends with a soft question ("What would you like to adjust?", "Ready to dispatch?", "Want me to...?"), a forward-looking "Let me write the handoff" mid-flow truncation, or a numbered "what's left" trailer. They cluster on projects with high orchestration density (reincarnate, normalize) and high cross-cutting discussion (io). Roughly half are recoverable as "the work persisted via TODO.md or commits, the assistant just didn't say 'done'", and half are genuine loose ends — most concretely the explicit "Want me to..." questions (`e777266f` reincarnate, `e08b6f99` reincarnate audit agents) and the design-deferral observations (`6c167a4c` unshape doppler integration, `4186c0d5` aspect version history, `36241a4b` private-recipient-b GUI). Bot/autonomous projects produced zero soft-abandoned tails as expected (they have machine end-states). No project outside the existing ecosystem table surfaced.
