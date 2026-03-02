# Rainbow

**Optics-based reactivity for the web.**

::: info Status: Idea ○
No code yet — project just scaffolded.
:::

Rainbow is a TypeScript library that grounds web state management in an actual algebra. Lenses and prisms are first-class composable values with laws you can reason about. Derived state is structural, not imperative — declare relationships once, consistency is automatic.

## Motivation

Most UI state management frameworks give you primitives but no algebra. Derived state requires explicit synchronization (`useEffect`, `watch`); relationships between state are imperative rather than structural. Forms, selections, panel contexts — all require hand-written sync code that's correct until it isn't.

Optics make the structure visible. `on name input_string` doesn't just wire a widget — it declares that this part of the UI corresponds to this part of the state. The structure of the program *is* the structure of the data.

## Design

- **Lens**: focus on a field of a product type — read, write, compose
- **Prism**: focus on a case of a sum type — match, inject, compose
- **Reactivity**: automatic propagation grounded in the optic graph, not imperative subscriptions
- **Runtime agnostic**: works with Node, Deno, and Bun — no framework lock-in

The model is language-agnostic. TypeScript is the deployment target; the algebra holds regardless of runtime.

## Prior art

- [Unicorn](https://github.com/art-w/unicorn) — OCaml GUI library with 7 algebraic combinators. Proves the model is viable; rainbow is the TypeScript translation of the same insight.
- [optics-ts](https://github.com/akheron/optics-ts) — Type-safe optics for TypeScript. Structural foundation without the reactivity layer.
- [react-hook-form](https://react-hook-form.com/) — Reinvents optics, stringly-typed and without laws. Evidence that developers want the model.

## Links

- [GitHub](https://github.com/rhi-zone/rainbow)
- [Documentation](https://docs.rhi.zone/rainbow/)
