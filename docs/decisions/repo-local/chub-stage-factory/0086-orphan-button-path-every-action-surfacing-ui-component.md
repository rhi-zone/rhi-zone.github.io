# ADR-0086: No orphan-button path: every action-surfacing UI component must route clicks through StageIntrospect

- Status: Accepted
- Date: 2026-05-29

**Context.** The UX audit named the largest UX failure as ActionSurface verb buttons in world-primary whose onClick handlers are no-ops (orphaned affordances). Wave 2E had to decide whether a button-that-does-nothing could ever be rendered.

**Decision.** Every Wave 2E component that surfaces actions MUST either receive an onVerbInvoke callback OR derive from availableVerbs() and call invokeVerb() directly. There is no code path that renders a button doing nothing; closing the orphan-button gap is the explicit thing the wave is designed to prevent.

**Alternatives rejected.**
- *Allow components to render verb buttons with caller-supplied (possibly no-op) onClick handlers, as ActionSurface did* — That pattern produced the repo's single largest UX failure (orphaned verb buttons in world-primary); the new components remove the ability to render an action with no wired invocation.

**Consequences.** Action components are forced to bind to a real invocation route at the type level; retrofitting ActionSurface into introspect-mode is mandated rather than shipping a do-nothing button surface. Mined from: /home/me/git/pterror/chub-stage-factory/docs/WAVE-2E-DESIGN.md (33-35), /home/me/git/pterror/chub-stage-factory/docs/WAVE-2E-DESIGN.md (72-74).
