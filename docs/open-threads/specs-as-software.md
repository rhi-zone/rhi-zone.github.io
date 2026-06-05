# Specs as software

**Project(s) touched:** software-taxonomy (primary); cross-resonance with concord (API bindings IR), paraphase (format conversion), rescribe (format adapters), ooxml

**Status:** Open — noted in software-taxonomy `TODO.md`; surfaced to the registry for its cross-project angle

**Surfaced in:** founding session `b933d7e2` — software-taxonomy `TODO.md` "Open questions from the founding session"

---

## The question

Is `@spec:` / `@protocol:` a software-taxonomy-only namespace, or does it
deserve to be a **shared ecosystem concept** that concord, paraphase, and
rescribe can reference?

## Why this is a registry thread

concord, paraphase, rescribe, and ooxml all sit on spec-shaped artifacts and
would benefit from a shared entity type. The decision determines whether those
projects ever interop with software-taxonomy's knowledge graph — which is why it
isn't purely a software-taxonomy TODO item.

## What's still open

- No decision on whether the namespace is shared or local.
- If shared: the entity type and where it lives (software-taxonomy core vs. a
  neutral shared definition) are undefined.

## Working answer

None — currently a software-taxonomy-local namespace by default.
