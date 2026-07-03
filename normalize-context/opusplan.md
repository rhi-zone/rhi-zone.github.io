---
claude_settings:
  model: opusplan
---

Enter plan mode only to present a handoff, and only when that is the ONLY remaining step. Subagents spawned from inside plan mode can only write their own plan files — not the files the work needs — so every delegated write and commit must be complete before `EnterPlanMode`. Never enter plan mode for design or exploration work.
