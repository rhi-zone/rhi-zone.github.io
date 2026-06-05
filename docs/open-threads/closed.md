# Closed / Archived Threads

Audit trail for items that were considered for the registry and **dropped** —
because they were resolved, superseded, moot, or already owned in a project's
`TODO.md`. Recorded here (rather than deleted) so the decision is traceable.

A thread that was *promoted* and later resolved should also be moved here with
a one-line reason.

---

## Registry meta

- **registry-purpose-fix** — The index previously stated the registry was for
  "questions that touch the ecosystem boundary / cross-project conventions."
  That framing was wrong: the registry's purpose is *open work not expected to
  land soon* (liveness), not *cross-repo scope*. Resolved by rewriting
  `index.md`'s filing criteria (this same change). Single-repo paused arcs now
  explicitly qualify.

## Dropped during the 2026-06-05 triage (mined 2026-03-25 → 2026-05-24)

These came out of the `drafts/open-threads-candidates.md` mining pass. Each was
evaluated against the liveness criterion and dropped. Session IDs preserved for
audit.

### Already resolved / landed (re-verified 2026-06-05)

- `dd7900fb` — post-history hints — landed in `docs/claude-code-guide.md`; tooling in `tooling/claude-hooks/`.
- `4c7311e2` — handoff skill across ecosystem — resolved same session; skill propagated.
- `2bd5b966` — compositional-crescent — landed in crescent `docs/principles.md`.
- `37565687` — mattpocock skills cross-reference — resolved; skills live in `tooling/claude-commands/`. (Same session also did the skill-mining sweep; logically complete.)
- `de3bbdc4` / reincarnate `arrayLocalSet` panic — resolved: `arrayLocalSet → Op::SetIndex` (commit `4d53495`); no longer a runtime call.
- `2f8ad113`, `e97262e5` (unshape/rescribe "verify the N commits got pushed") — repos clean, 0 ahead of upstream on 2026-06-05; the commits pushed.
- `8b6a9ba4`, `0e6fcd81`, `8a6b9ba4` — crescent typechecker plans/sessions — superseded by the v4→v5→v7 rewrite (crescent at `cc02d077` "verify v7 MR0 certificate digests").

### Superseded / already in software-taxonomy TODO (commit `50bf4e1`)

- `lore-folklore-lens`, `temporal-developed-by`, `worldbuilding-sub-lens`, `adversarial-scalability-subagent` — already in software-taxonomy "Open questions from the founding session."
- `rescribe-vs-paraphase boundary` — addressed in `rescribe/TODO.md` (horizontal sweeps out of scope; thin IR adapters).

### Single-repo work already owned in a project TODO.md (not parked → not registry)

These are real open work, but each is *actively owned and tracked in its own
repo's TODO.md*, so per the liveness discriminator they are live TODO backlog,
not parked open threads.

- `36241a4b` — private-recipient-b GUI/setup wizard + ts-morph config — tracked across `private-recipient-b/TODO.md` (wizard items at lines 444/626 already struck done; config-reconciler work in Phase 3 / lines 655–662). Repo actively progressing.
- `e0e0a560` — pad extensions (Email, RSS/Atom, Screenshot OCR, zstd, inotify fallback) — listed in `pad/TODO.md` lines 53–62; repo has recent commits. Owned backlog.
- `4c1b6ece` — reincarnate transform-pass placement — belongs in `reincarnate/TODO.md`.
- `e777266f` — reincarnate warning diagnostics — "Warning Diagnostics for Game-Author Bugs" section exists in `reincarnate/TODO.md` (line ~2194); owned there.
- `6c167a4c` — unshape doppler integration / delay buffer — `unshape/TODO.md` item.
- `4186c0d5` — aspect world-pack version history (Y.Doc / IndexedDB) — deferred-to-follow-up; `aspect/TODO.md` item.
- `8d2d8933` — server-less type-driven input error messages — `server-less/TODO.md` item.
- `0743f05f` — private-recipient-a audit handoff — outside the ecosystem table; `~/git/private-recipient-a/TODO.md`.

### Moot / self-answered / no concrete work item

- `18ad2c06` — per-feature `dev/active/` TODO layout — the session's own conclusion was "probably not worth the overhead for solo work." Self-answered; no open decision.
- `8dbd1890` — "species floor invisible / human ceiling catastrophe" — philosophical framing from a cross-cutting conversation; no concrete work item attaches. Recurring theme, not a thread.
- `43fac5ae`, `b695ca4b` (io) — questions that got answered later as tooling matured / were about an agent's behavior, not a plan.
- `308dd55e`, `cf90d69e`, `d481cb56`, `934ae1e1`, `e7500210`, `72f4bd58`, `97d69bd8`, `2132e15c`, `68198b17`, `4fd62328` — orchestration-ambiguity / soft-question / advice tails ("What would you like to adjust?", "Ready to dispatch?", conditional offers). Not work loss; closed.

### Explicit-handoff or clean-completion tails (intentional closes, not abandonment)

Surfaced in the candidate sweep as "assistant-last" but the work landed via a
`/handoff` plan, a commit, or a clean confirmation. No registry action.

- Explicit `/handoff`: `9e8bf1e4`, `0a7c6668`, `d7d48724`, `e6ae6069`, `4239817c`, `01805bae`, `24f387a0`.
- Clean completion / durable work, ritual skipped: `d54a9d63` (Ward mirror, 245M/1636 files complete), `b638eaa2` (normalize 0.4 anchor committed), `d18e162b` (parents), `35abf860`, `09050a8b`, `e7dc4062`, `465003dc`, `4fc0db00`, `8b908703`, `54c7d657`, `58f451fe`, `8b8df9f4`, `9eb0b411`, `aa696f9a`, `9bb0e9b8`/`a431db77` (rescribe html-reader plan — verify against `rescribe/TODO.md` if resumed), `54eb307b` (wick), `444ab029`, `7101d200`, and the 40+ explicit-closer (`Done.`/`Pushed.`/`Clean.`/`Bye!`) sessions enumerated in the mining draft.
