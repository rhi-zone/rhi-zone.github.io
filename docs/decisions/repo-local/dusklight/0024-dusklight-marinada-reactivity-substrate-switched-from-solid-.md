# ADR-0024: Dusklight/Marinada: reactivity substrate switched from Solid.js to Rainbow

- Status: Accepted
- Date: 2026-05-29

**Context.** The May 5 dusklight session on Marinada hit Gap 2 — the JIT's blanket rejection of effectful code, which forced developers to drop to the interpreter. Marinada's effect-aware reactivity layer initially used Solid.js, an arbitrary choice the user pushed back on. Choosing the reactivity substrate determined whether effectful reactive code could be JIT-compiled, so an effect-aware reactivity substrate was needed.

**Decision.** Switch the reactivity substrate from Solid.js to Rainbow (the rhi ecosystem's optics-based reactivity, @rhi-zone/rainbow-ui), using Rainbow signals for effect-aware code in reactive contexts, because Rainbow signals unblock the JIT's previous blanket rejection of effectful code (Gap 2).

**Alternatives rejected.**
- *Solid.js as the reactivity substrate (or adopt @vue/reactivity)* — Solid.js was an arbitrary choice the user objected to and did not unblock the JIT's rejection of effectful code (Gap 2); Rainbow signals in reactive contexts let effectful code run and reduce JIT rejection.

**Consequences.** Dusklight now depends on Rainbow as its reactivity layer, aligning it with the rhi ecosystem. Rainbow integration (via compileEffectful + Rainbow) partially closes Gap 2 by unblocking effectful code in reactive contexts; pure perform cases still fall back to the interpreter and remain open. Module-import resolution (Gap 1) remains deferred, with hosts providing resolver implementations. This decision recurs across two introspection sources — the May 5 daily log and the 2026-04-26–2026-05-09 synthesis — confirming it as a deliberate, durable architectural choice. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-05-05.md (24), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-05-05.md (76), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-26-2026-05-09.md (49).
