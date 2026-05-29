# ADR-0116: Emergence over flags: qualities arise from parameter interaction, never declared

- Status: Accepted
- Date: 2026-05-29

**Context.** Personality, mood, habits, and clinical patterns could each be represented by an explicit flag/label that prose checks (the shortcut), or by configurations of continuous parameters that produce behavior.

**Decision.** The simulation never labels or declares. Personality is a configuration of continuous parameters; mood emerges from neurochemistry over time; habits form from accumulated observed choices; clinical patterns arise when parameters land in certain configurations. Prose renders the behavior rather than naming it. The governing test: is this quality declared, or does it emerge from how underlying parameters interact?

**Alternatives rejected.**
- *Use explicit flags/labels to declare qualities (e.g. a personality flag, a 'depressed' switch, a diagnosed condition)* — Declaration is a shortcut that makes the simulation announce what it's doing; emergence from interacting parameters is what makes the world feel real, so flags are rejected even though they're simpler to implement and query.

**Consequences.** Applies everywhere — chargen, behavioral systems, prose. No flag may stand in for an emergent quality; e.g. the stored trans boolean is removed in favor of derived isTrans() over identity dimensions. Prose may not name a recognizable pattern; it must render the behavior. Constrains all future feature design toward parameterization. Mined from: /home/me/git/paragarden/existence/docs/design/philosophy.md (57), /home/me/git/paragarden/existence/docs/design/philosophy.md (61).
