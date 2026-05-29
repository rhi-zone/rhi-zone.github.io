# ADR-0227: Full recompilation with High-Level Emulation, never interpreter bundling

- Status: Accepted
- Date: 2026-05-29

**Context.** Legacy engines (Flash, Ren'Py, GameMaker, Twine, VB6, etc.) could be revived two ways: bundle the original runtime as a WASM interpreter (inkjs, Parchment, renpyweb, libqsp-WASM) and run the original bytecode, or decompile the user logic to typed IR and recompile it while detecting-and-replacing the engine's standard library with a native implementation. The choice determines what the output IS and what every frontend/backend must produce.

**Decision.** Reincarnate performs full recompilation, not interpretation. User logic is decompiled to a typed IR, optimized, and re-emitted in a modern target language. Original runtime libraries are detected at API boundaries and replaced with native equivalents (the HLE / High-Level Emulation approach) rather than emulated instruction-by-instruction. The original runtime is fully replaced; the emitted code is a normal program, not a scripted engine.

**Alternatives rejected.**
- *Bundle an existing interpreter (inkjs, Parchment, renpyweb, libqsp-WASM) as a WASM runtime* — These are 'quick deploy' alternatives, not the goal; an emulator is not decompilation. Bundling produces an opaque scripted engine, not editable type-safe source, and forecloses cross-target optimization and instantiability.
- *Instruction-by-instruction emulation of the original runtime* — HLE does not emulate, it replaces: recognizing API boundaries and swapping modern implementations makes the output actually run natively and removes the original runtime entirely. Per-instruction emulation keeps the dead runtime alive and yields no maintainable artifact.

**Consequences.** Every frontend must identify library boundaries and attach metadata; the recompiler job is two-fold (translate user logic + replace runtime libraries). Translating `MovieClip.gotoAndStop(3)` is useless without a native `MovieClip`, so the replacement runtime is treated as a first-class concern. Constrains all current and planned frontends/backends equally. Mined from: /home/me/git/rhizone/reincarnate/docs/architecture.md (5), /home/me/git/rhizone/reincarnate/docs/architecture.md (102-104), /home/me/git/rhizone/reincarnate/CLAUDE.md (7).
