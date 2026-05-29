# ADR-0011: Browser-side app source format is JS + JSDoc, not TypeScript or mandatory Lua

- Status: Accepted
- Date: 2026-05-29

**Context.** Apps shipping browser UI need a source format. The toolchain-cost and air-gap constraints conflict with shipping a compiler. A primary authoring format had to be chosen for the distributed form.

**Decision.** Primary source format is standard JS with JSDoc type annotations: runs in the browser with no transpile step, type-checked in the author's dev environment via the TS Language Server with // @ts-check. No bundled compiler, no tsc shipped with apps, no Lua typechecker shipped with apps. lua2ts remains an optional source path whose output target is JS + JSDoc so the distributed form is uniform; Lua stays crescent's daemon language.

**Alternatives rejected.**
- *TypeScript with .ts source format* — App distribution would need to ship the TS compiler (~10MB) or require authors to pre-build; JS + JSDoc gets the same type-safety with zero toolchain cost.
- *Lua as the mandatory browser-side source* — Would require shipping a Lua typechecker plus transpiler bundle with the platform; authors who already know JS shouldn't be forced through that ceremony.

**Consequences.** Distributed browser apps are plain JS; type-checking is an author-dev-env concern via JSDoc; a single shared .d.ts declares the realm allow-list, cap signatures, and bridge protocol. lua2ts is opt-in, never required, and must target JS+JSDoc output. Mined from: /home/me/git/rhizone/crescent/docs/platform_isolation.md (845-847), /home/me/git/rhizone/crescent/docs/platform_isolation.md (860-863).
