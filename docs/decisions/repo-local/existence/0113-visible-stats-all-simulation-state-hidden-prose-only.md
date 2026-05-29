# ADR-0113: No visible stats; all simulation state hidden, prose is the only UI

- Status: Accepted
- Date: 2026-05-29

**Context.** A simulation game with 28 neurochemical systems, sleep debt, finances, relationships needs a way to communicate internal state to the player. The default for such systems is numeric/bar UI (stats screens, mood meters).

**Decision.** The game surfaces no stats and no numbers. All simulation state is hidden; the player experiences state only through prose tone, word choice, and what is mentioned vs. omitted. The same moment reads differently depending on hidden state, and that text difference IS the interface.

**Alternatives rejected.**
- *Surface stats/numbers (stat screens, mood bars, visible meters)* — Visible numbers would break the 'power anti-fantasy' framing of constrained agency without judgment and let the player optimize against legible mechanics; the design insists prose must carry everything so the player feels things they cannot name.

**Consequences.** Every system must expose its state through prose shading rather than display widgets; prose generation becomes load-bearing infrastructure (the NT-shading pipeline). The player cannot directly read mechanics, only infer them. Forecloses any stats/HUD surface. Mined from: /home/me/git/paragarden/existence/README.md (3), /home/me/git/paragarden/existence/CLAUDE.md (61).
