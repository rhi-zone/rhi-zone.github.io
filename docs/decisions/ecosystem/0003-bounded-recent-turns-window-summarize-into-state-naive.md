# ADR-0003: Bounded recent-turns window with summarize-into-state, not naive chat accumulation

- Status: Accepted
- Date: 2026-05-29

**Context.** Long LLM chats degrade because each turn blindly appends prior turns, dragging in old hallucinations and irrelevant text. The library had to decide how prompts treat conversation history.

**Decision.** Treat world state as the durable substrate, a bounded recent-turns window as valid stylistic-continuity input, and distant chat as something to summarize into Timeline events / observation updates / structured state and drop from raw text. The chat log is a curated derived view, never blindly accumulated.

**Alternatives rejected.**
- *Unreflective accumulation — append each turn to the previous verbatim* — Drags in old hallucinations, mistakes, awkward beats, and irrelevant text that degrade quality over time; this is identified as why long Chub/SillyTavern/AI Dungeon chats degrade.

**Consequences.** Distant turns are never handed back verbatim; they must be reduced to structured state. Establishes Timeline/observation summarization as the durable mechanism for history. Mined from: /home/me/git/pterror/chub-stage-factory/CLAUDE.md (33), /home/me/git/pterror/chub-stage-factory/CLAUDE.md (37).
