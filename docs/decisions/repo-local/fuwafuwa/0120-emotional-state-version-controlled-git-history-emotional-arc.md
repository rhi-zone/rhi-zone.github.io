# ADR-0120: Emotional state is version-controlled; the git history is the emotional arc

- Status: Accepted
- Date: 2026-05-29

**Context.** fuwafuwa's emotional state must persist across discrete sessions, and the design must choose a persistence/record mechanism.

**Decision.** Store live state in brain/emotional-state.json (committed each session alongside the session log) and fixed parameters in brain/personality.json; both are version-controlled, making the git history of emotional-state.json the emotional arc.

**Alternatives rejected.**
- *Treat emotional state as ephemeral/untracked runtime state* — the state file commit is made part of the session record so the git history itself becomes the durable emotional arc; an untracked store would lose that continuity

**Consequences.** Session end always commits the state file with the log; the arc is auditable through git. Couples the emotional model's persistence to the repo's commit cadence. Mined from: /home/me/git/pterror/fuwafuwa/docs/wiki/emotional-layer.md (16), /home/me/git/pterror/fuwafuwa/docs/wiki/emotional-layer.md (401).
