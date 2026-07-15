# Investigation: Jevons Paradox and AI — Substrate as the Lever

## Central Question

The standard Jevons paradox framing of AI efficiency suggests the problem is unsolvable: more efficient AI → cheaper usage → more usage → total compute climbs. Demand is framed as unbounded (infinite knowledge, infinite code to write, recursive parallel subagents amplifying every human request). Is this true, or is there a lever that attacks the problem at the source?

## Key Insight Chain

1. **Recursion mechanics**: AI agents spawn subagents when tasks are too complex to handle in one shot. They hit the base case (stop recursing) when the task is small enough to do directly.

2. **The expansion factor**: What determines the base case? The complexity of the substrate the agent is working with.
   - Better substrate → earlier base case → shallower recursion tree → less total compute.
   - This is not attacking demand (which may be unbounded) or supply (efficiency gains).
   - It attacks the *expansion factor* between "what was asked" and "what gets executed."

3. **Ceremony is the hidden multiplier**: Most codebases are not logic; they are ceremony stamped out mechanically.

## Case Study: Large Production SaaS (626k lines)

**Scale breakdown:**
- 297k lines across 97 packages — but only 50–60k is business logic. The rest is infrastructure ceremony.
- Real logic across the entire app: ~10–15k lines.
- Other 600k+ lines: substrate does not absorb the ceremony.

**Business logic layer** (50–60k lines):
- Average use cases are 70–87% ceremony: input validation, fetch, audit write, event publish, result construction.
- A 5-line business decision costs ~60 lines to express.

**UI layer** (229k lines):
- A projector abstraction exists that reduces pages by 80%, but it's only half-applied.
- Hand-written pages run 1700+ lines of repetitive DOM construction and event wiring.

## The Thesis

If the substrate handled the ceremony (persistence, audit, events, validation, UI projection), apps shrink dramatically. An AI working on a 10–15k line app hits the base case immediately — no deep recursion, no subagent tree. This attacks the Jevons expansion factor at the root.

## The Hard Problem

Building a substrate that absorbs ceremony without just hiding it behind different complexity. Decades of attempts (ORMs, frameworks, code generators, low-code) show the complexity survives — it moves somewhere else. The real challenge is building one that *genuinely eliminates* the ceremony rather than *relocating* it.

This needs honest investigation, not hand-waving.

## Connected Project: crescent

**Scope**: "An operating system in Lua" whose goal is to cover "the entire surface area of software."

**Principles include**: "Make the computer small."
- For any given app, the surface it needs is bounded (tautologically).
- The more of that surface crescent covers, the less AI needs to generate or recurse over.

## Status

- **Thread**: Recorded.
- **Open hard question**: How to build a substrate that genuinely eliminates ceremony vs. relocating it.
- **Solution status**: No solution proposed yet.
- **Next vector**: Investigate what makes ceremony hard to eliminate (is it a property of the problem domain, or a property of how we've been building platforms?).

## Implications

If substrate-driven ceremony reduction is viable:
- AI can work on meaningfully smaller codebases.
- Recursion depth for the same user request shrinks.
- Total compute per request shrinks, even if request volume grows.
- This is orthogonal to efficiency gains; it's an architectural brake on the expansion factor itself.

If it's not viable (ceremony is fundamental):
- Jevons paradox is indeed unsolvable at the substrate level.
- The only lever would be demand management or efficiency exhaustion (hitting physical limits).

## Related Concepts and TODOs

- **Ceremony taxonomy**: What categories of ceremony exist in typical apps? (data validation, type scaffolding, lifecycle management, projection, audit, etc.)
- **Substrate design principles**: What makes a substrate absorb ceremony vs. move it?
- **crescent investigation**: How does "operating system in Lua" approach ceremonial absorption? What's the scope?
- **Measurement**: How to measure "genuine elimination" vs. "relocation"?
