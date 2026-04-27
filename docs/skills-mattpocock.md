# Matt Pocock's Skills — Running Review

Source: [mattpocock/skills](https://github.com/mattpocock/skills) — cloned to `~/git/mattpocock-skills/` on 2026-04-27.

This document is a permanent record of our skill-by-skill review of the collection: what we adopted, what we adapted, what we dropped, and why. Updated as we work through the list.

## Review methodology

- Go one skill at a time, fully, before moving on
- For each skill: read all files (SKILL.md + any bundled reference docs), evaluate whether each part earns its place given what we know about how sessions actually work in this ecosystem, then decide: adopt as-is / adapt / skip
- Adaptations are recorded here with rationale; the adapted version lives in `~/.claude/commands/`

---

## improve-codebase-architecture

**Status:** Adopted with adaptation  
**Source:** `~/git/mattpocock-skills/improve-codebase-architecture/` (SKILL.md + LANGUAGE.md + DEEPENING.md + INTERFACE-DESIGN.md)

### What the skill does

Surfaces architectural friction and proposes "deepening opportunities" — refactors that turn shallow modules (interface nearly as complex as implementation) into deep ones (large behaviour behind a small interface). Uses a structured vocabulary (module, seam, adapter, depth, leverage, locality) and a grilling loop that updates `CONTEXT.md` inline as decisions crystallize.

The core insight: documentation as a side effect of a conversation actually gets done. "I'll write that up later" doesn't.

### Part-by-part evaluation

**Enforced vocabulary (LANGUAGE.md)** — Keep. "Deletion test" is the strongest part: imagine deleting the module, if complexity vanishes it was a pass-through. "Leverage" and "locality" name two distinct things callers vs. maintainers get from depth, which is a useful framing. "Seam" vs. "boundary" avoids DDD overloading. LANGUAGE.md earns its place as a separate file.

**Explore phase** — Keep. Subagent-based codebase exploration before presenting candidates prevents the failure mode of charging ahead with a specific proposal before understanding the space.

**"Don't propose interfaces yet, ask which candidate to explore"** — Keep. Sessions repeatedly show the failure mode: Claude proposes a solution, user redirects, time is wasted. Gating on user selection is discipline that sessions need.

**Grilling loop with inline CONTEXT.md updates** — Keep, and strengthen. The inline update is the best part of the skill. Decisions made in one session get re-litigated in the next because they weren't captured; this addresses that directly.

**ADR gate (three-part test)** — Dropped. The lack of ADR infrastructure in this ecosystem is intentional: most design decisions are ephemeral or self-evident from the code. The ADR gate is well-designed but adds ceremony for a format we've decided not to use.

**"Create CONTEXT.md lazily (only when needed)"** — Flipped to eager. We audited six repos and all six warrant CONTEXT.md (reincarnate, crescent, interconnect, defocus, tiltshift, normalize). Waiting for the skill to discover this opportunistically defers work we've already validated.

**"One adapter = hypothetical seam, two = real seam"** — Keep as heuristic, not hard rule. Useful forcing function against premature abstraction, but in a research-oriented ecosystem designs legitimately precede implementations.

**DEEPENING.md** — Keep unchanged. Dependency categorization (in-process / local-substitutable / remote / true external) is a useful framework for deciding how to test across a seam, and the "replace, don't layer" testing strategy directly addresses a pattern we see in sessions.

**INTERFACE-DESIGN.md** — Keep, with one change: remove the reference to `migrate-to-shoehorn` (TypeScript-specific, not relevant). The parallel sub-agent approach ("design it twice" — minimize interface / maximize flexibility / optimize for common case) is a strong pattern for forcing consideration of alternatives before committing.

### CONTEXT.md ecosystem audit

As part of adopting this skill, we audited six repos for vocabulary density and session-based confusion evidence:

| Repo | Verdict | Key signal |
|------|---------|------------|
| **reincarnate** | Yes — highest priority | TODO.md documents Law 2 violations; sessions repeatedly re-explain Type::Unknown vs. inference failure |
| **crescent** | Yes — high priority | Explicit user frustration; type inference re-explained across multiple sessions |
| **interconnect** | Yes — high priority | Novel protocol vocabulary (substrate/simulation, ghost mode, passport) agents are still orienting to |
| **defocus** | Yes | 20 candidate terms; draws from capability security, event sourcing, functional programming |
| **tiltshift** | Yes | Signal→hypothesis→constraint feedback loop is non-obvious; 16 specialized extractors |
| **normalize** | Yes — medium priority | Real API/CLI vocabulary friction (view vs list, incoming vs outgoing, fact vs rule) |

All six warrant CONTEXT.md. Priority order for drafting: reincarnate → crescent → interconnect → defocus → tiltshift → normalize.

---

---

## tdd

**Status:** Skipped

The skill's procedural discipline (tracer bullet, red-green-refactor, vertical slices) is lightweight enough to not need a skill. Its theory of good tests — "behavior through public interfaces, not implementation details" — is too thin for this ecosystem, and its vertical-slice cadence can produce tests that parrot implementation rather than checking invariants.

The ecosystem's actual good tests (from ooxml, wick, rescribe) don't ask "given this input, do I get this output?" They ask:
- What must always be true regardless of implementation? (mathematical identities, logical laws)
- Do independent implementations agree? (parity across backends/tiers)
- Does transformation preserve what matters? (roundtrip, semantic fidelity)
- What must never happen? (panic, data loss — fuzz is the right tool)

The anti-horizontal-slice doctrine (don't write all tests before all implementation) is valid but not worth a skill on its own.

**Output:** [`docs/testing.md`](/testing) — a testing philosophy doc derived from ecosystem prior art, covering the invariant hierarchy, fuzz strategy, and when to write which kind of test.

---

---

## grill-me

**Status:** Skipped — superseded by `domain-model`

Same core instruction (relentless one-at-a-time interview, recommend answers) but without glossary awareness or inline CONTEXT.md updates. `domain-model` is strictly better for this ecosystem now that six repos have CONTEXT.md files.

---

## domain-model

**Status:** Adopted with adaptation

The same interview discipline as `grill-me` plus: challenge against the glossary, sharpen fuzzy language, cross-reference stated behavior against code, update CONTEXT.md inline as decisions crystallize. `disable-model-invocation: true` — pure instruction injection.

**Cross-reference caveat** — proven during review: when the skill finds a contradiction between stated design and code, it must surface it to the user rather than silently patching docs to match code. Autonomous agents get this wrong (they rationalize the code as intentional). The skill is only safe with a human in the loop at that decision point.

**Dropped:** CONTEXT-MAP.md convention (no multi-context repos in the ecosystem) and ADR gate (same call as `improve-codebase-architecture`).

**Eagerly creates CONTEXT.md** if absent — six repos already seeded, so this fires immediately rather than bootstrapping from scratch.

---

---

## zoom-out

**Status:** Skipped

The skill is a one-line prompt ("I don't know this code, give me the module map") with `disable-model-invocation: true`. Solves the problem of getting oriented in unfamiliar code by priming for a wider-scope answer.

But normalize already solves this better: `normalize view <dir>` returns actual structural data, `normalize grep` finds callers. If normalize's output isn't enough to orient, that's signal about normalize's coverage or output, not a reason to paper over it with a prompt skill. The SUMMARY.md convention is the static pre-computed version of the same thing.

---

## caveman

**Status:** Skipped

Ultra-compressed communication mode that drops articles, filler, and pleasantries to cut token usage ~75%.

Skipped because the framing is wrong on two levels:

1. **Conversational verbosity is an artifact of the chat UI, not intrinsic to LLMs.** "I'd be happy to help with that" exists because chat interfaces train the expectation; LLMs themselves are completion engines, and well-prompted completions don't include this prose. The fix is upstream — in how agents are prompted — not a compression toggle on top.

2. **Multi-turn is the weaker mode anyway.** Instruct tuning makes single-shot completion strong; each additional turn re-feeds context, drifts attention, and accumulates conversational noise. Compressing a multi-turn dialogue is patching the artifact of the weaker interaction mode rather than choosing the stronger one.

For token-sensitive autonomous agents, the right architecture is bounded single-shot interactions (subagents, well-scoped commands, one-shot grilling). Caveman patches multi-turn chat after the fact when the better move is not having the multi-turn chat in the first place.

This reframes some adopted patterns: `domain-model`'s "ask one at a time" works because each question is a tight single-shot decision, not because dialogue is good. `handoff` exists because long sessions degrade. The pattern is keeping interactions bounded, not compressing them.

---

*More skills to follow.*
