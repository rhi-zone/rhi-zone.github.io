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

*More skills to follow.*
