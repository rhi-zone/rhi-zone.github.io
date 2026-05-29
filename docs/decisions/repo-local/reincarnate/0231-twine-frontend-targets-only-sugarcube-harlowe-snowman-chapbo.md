# ADR-0231: Twine frontend targets only SugarCube and Harlowe; Snowman and Chapbook are excluded

- Status: Accepted
- Date: 2026-05-29

**Context.** Twine has four story formats. The frontend must decide which to parse. Coverage of real-world games and the value of lifting each format vary widely.

**Decision.** The Twine frontend targets SugarCube and Harlowe only. Snowman and Chapbook are explicitly not supported.

**Alternatives rejected.**
- *Support Snowman* — Not a scripting language — passages are raw JavaScript with template tags and jQuery, with no macro DSL to parse. Lifting it would be pointless: the source is already the target, and very few published games use it.
- *Support Chapbook* — Minimal adoption, a unique inserts+modifiers syntax with no meaningful ecosystem; not worth the parser investment until there is real demand.

**Consequences.** SugarCube and Harlowe cover the overwhelming majority of Twine games; Harlowe is treated as the higher-value target (slower runtime, weak save system, extension-hostile syntax). Adding Snowman/Chapbook is gated on demonstrated demand. Mined from: /home/me/git/rhizone/reincarnate/docs/architecture.md (79-80), /home/me/git/rhizone/reincarnate/docs/architecture.md (85-86).
