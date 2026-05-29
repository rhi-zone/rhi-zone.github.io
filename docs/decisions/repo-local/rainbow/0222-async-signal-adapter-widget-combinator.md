# ADR-0222: Async is a signal adapter, not a widget combinator

- Status: Accepted
- Date: 2026-05-29

**Context.** Bridging Promise/async data into the widget algebra (rainbow-ui) needed a model. The obvious option is an async-specific widget combinator like `async(loadingW, resolvedW, errorW)`.

**Decision.** Widgets stay synchronous. Async state is a signal value (`AsyncState<T>` = pending | fulfilled | rejected), produced by `fromPromise` / `fromAsync` and composed with existing combinators (narrow, show). These adapters live in `@rhi-zone/rainbow` core, not rainbow-ui, because they produce signals, not elements.

**Alternatives rejected.**
- *An async widget combinator like `async(loadingW, resolvedW, errorW)`* — Concise but hides state behind the combinator boundary — you can't focus into the resolved value, compose two async sources, or inspect loading state from a parent widget; signal adapters keep the data model flat and composable.

**Consequences.** Async state is inspectable and composable like any signal; consumed via narrow prisms (pending/fulfilled/rejected). `fromAsync` re-runs on dep change and cancels in-flight via AbortSignal. Placement of async primitives in core establishes that anything producing signals belongs in core. Mined from: /home/me/git/rhizone/rainbow/docs/design/ui-elements.md (118-119), /home/me/git/rhizone/rainbow/docs/design/ui-elements.md (149).
