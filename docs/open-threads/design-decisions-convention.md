# Design-decisions convention

**Project(s) touched:** crescent, hologram, defocus, interconnect, myenv, scribble, portals, tiltshift, chub-stage-factory (partial adoption); controlled by github-io propagation tooling

**Status:** Open — partial, inconsistent adoption

**Surfaced in:** session `74867717` (hologram, 2026-05-03: "some stuff might be poisoning CLAUDE.md and can go in prior design decisions? with a very short pointer from CLAUDE.md"); also `82f8c396` (defocus), `e511dc6f` (crescent), `37565687` (io)

---

## The question

What is the standard filename + pointer pattern for prior design decisions across
the ecosystem, and where is the cutoff between ephemeral and load-bearing?

## Current state

- `DESIGN.md`: portals, tiltshift, chub-stage-factory
- `docs/design.md`: myenv, scribble
- `docs/design-decisions.md`: interconnect
- github-io: no convention

## The tension

The user has rejected formal ADRs ("the lack of adr infra is intentional, a lot
of the decisions imo are ephemeral/not load bearing") while simultaneously asking
individual repos for design-decisions docs. The unresolved part is the
ephemeral/load-bearing cutoff — what earns a durable record vs. what stays in
the session log.

## Why this is a registry thread

Controlled by github-io's propagation tooling; the moment a convention is chosen
it propagates to every repo.

## Working answer

None — three competing filename patterns, no decision recorded.
