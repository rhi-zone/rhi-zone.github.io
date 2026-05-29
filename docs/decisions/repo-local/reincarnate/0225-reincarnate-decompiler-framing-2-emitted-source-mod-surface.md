# ADR-0225: Reincarnate is a decompiler (framing 2): emitted source is the mod surface, no IR mutation API

- Status: Accepted
- Date: 2026-05-29

**Context.** Investigating a modded reference decompilation raised the question of whether Reincarnate should ship an IR-based modding framework, which forced a more fundamental question: what is Reincarnate? Three framings were on the table — preservation tool, decompiler/lifter, and continuous-lift platform — each implying a different mod surface and different core architecture.

**Decision.** Reincarnate is framing 2: a decompiler that produces working, type-safe, maintainable code; the TypeScript IS the artifact. The mod surface is the emitted TypeScript itself (edit it like any codebase); no IR mutation API is built. Upstream updates are handled by forward-porting mods via git cherry-pick or manual merge, the same as any fork.

**Alternatives rejected.**
- *Framing 1 — preservation tool (success = playable in a browser)* — Under this framing interpreter bundling would be equally valid, but that is rejected; preservation framing leaves the no-bundling law without justification.
- *Framing 3 — continuous lift platform with IR overlays that survive re-lifts (semantic modding)* — Only makes sense when the upstream game keeps updating; requires an IR mutation API. Explicitly not a priority — lifting more dead engines is far more valuable, and modding infrastructure must not influence core pipeline architecture.

**Consequences.** Makes the existing laws coherent (no interpreter bundling, behavioral equivalence, honest representation, instantiability). No IR mutation API is built. Framing 3 is parked as a possible future tangent. The IR-based-modding investigation is closed. Mined from: /home/me/git/rhizone/reincarnate/docs/adr/003-project-identity-and-mod-surface.md (25), /home/me/git/rhizone/reincarnate/docs/adr/003-project-identity-and-mod-surface.md (40).
