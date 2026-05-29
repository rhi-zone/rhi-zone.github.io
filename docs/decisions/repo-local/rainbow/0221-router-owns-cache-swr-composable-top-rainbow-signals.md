# ADR-0221: Router owns no cache; SWR is composable on top via rainbow signals

- Status: Accepted
- Date: 2026-05-29

**Context.** TanStack Router ships a built-in SWR cache and loaderDeps tracking. Rainbow-router had to decide whether caching is a router concern.

**Decision.** The router has no built-in caching. SWR is composable on top with a time-based invalidation signal; the router doesn't own that concern. loaderDeps tracking is dropped because loaders read signals and reactivity handles re-runs naturally.

**Alternatives rejected.**
- *Built-in SWR cache and loaderDeps tracking (TanStack-style)* — Caching is composable via rainbow signals rather than baked in; loaderDeps is redundant because loaders reading signals get reactive re-runs for free.

**Consequences.** Loaders return `RemoteData<T>` signals; cancellation via AbortSignal on navigation. App-level caching strategy is left to the consumer to compose. Keeps router core minimal. Mined from: /home/me/git/rhizone/rainbow/docs/design/router.md (60), /home/me/git/rhizone/rainbow/docs/design/router.md (217-218).
