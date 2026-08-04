# Harness orchestrator fit

**Project(s) touched:** all (cross-cutting; surfaces in crescent, reincarnate, hologram, normalize sessions); meta-investigation lives in github-io

**Status:** Open — explicitly flagged "no agent tested this directly"

**Surfaced in:** session `7b1ce10e` (2026-05-13 → 2026-05-20: "CLEARLY claude code's harness is not designed for sonnet top level agents at all"); also `9e8bf1e4` (reincarnate, 149-subagent session), `033086a7` (reincarnate, 199 subagents); named as untested in `docs/automated-introspection/investigations/2026-05-20-whats-wrong/synthesis.md`

---

## The question

Does the Claude Code harness assume an orchestrator-class top-level model? If the
top-level agent must coordinate many coupled subagents, is a smaller model
(Sonnet) at the top a structural mismatch rather than a tuning problem?

## Why this is a registry thread

The answer determines which model defaults belong in CLAUDE.md across **every**
repo and shapes future scaffolding. No single repo owns it.

## What's still open

- No agent has run the controlled comparison.
- **Predicted test:** same task with Opus vs Sonnet as the top-level
  orchestrator over coupled subagent work; compare coordination failures, lost
  agreements, and rework.

## Working answer

None.
