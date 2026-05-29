# ADR-0085: Introspect-aware UI components use bridged mode (explicit availableVerbs/onVerbInvoke props), not a threaded StageIntrospect

- Status: Accepted
- Date: 2026-05-29

**Context.** Wave 2E's 14 UI primitives must surface stage verbs. The design had to choose how a component gets the verb list and invocation path.

**Decision.** Components accept the IntrospectAware shape and default to bridged mode: the stage passes availableVerbs + onVerbInvoke explicitly and the component stays pure-render. Plain mode (legacy verbs/onClick) and wired mode (pass full stage, component queries itself) are supported but bridged is the recommended default.

**Alternatives rejected.**
- *Thread `stage: StageIntrospect` through every component prop (wired-only)* — Tried as a thought experiment and rejected: it leaks the stage's full verb namespace into every component, defeats verbFilter, and makes testing each component require a full mock stage. Bridged mode is one level of indirection cheaper.

**Consequences.** Every action-surfacing Wave 2E component takes availableVerbs/onVerbInvoke; verbFilter remains usable and components stay unit-testable without a mock stage. Wired mode remains a convenience only. Mined from: /home/me/git/pterror/chub-stage-factory/docs/WAVE-2E-DESIGN.md (159-163), /home/me/git/pterror/chub-stage-factory/docs/WAVE-2E-DESIGN.md (128-132).
