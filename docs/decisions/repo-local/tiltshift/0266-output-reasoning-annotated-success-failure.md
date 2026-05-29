# ADR-0266: Output is reasoning-annotated, not success/failure

- Status: Accepted
- Date: 2026-05-29

**Context.** Binary parsing libraries conventionally return a boolean/result (parse succeeded or failed). tiltshift targets agents and non-expert humans who need the implicit RE knowledge made explicit. The design had to decide what the tool returns.

**Decision.** Every output is annotated with why: what was found and where, a confidence score with contributing signals, the reasoning for the interpretation, what alternatives were considered and why they ranked lower, and what remains unexplained with suggested next targets. Weak signals must compound into confident hypotheses rather than remaining separate weak guesses.

**Alternatives rejected.**
- *Return success/failure like most binary parsing libraries* — "Most binary parsing libraries return success/failure" — insufficient for agents who can't use visual hex-editor tooling and need explicit reasoning; feedback richness is the stated differentiator

**Consequences.** Every signal must carry confidence, contributing factors, and rejected alternatives through the API. The SignalKind representations and confidence formulas are obligated to expose reasoning. Raises implementation cost but is the core product differentiator. Mined from: /home/me/git/rhizone/tiltshift/DESIGN.md (106), /home/me/git/rhizone/tiltshift/DESIGN.md (114).
