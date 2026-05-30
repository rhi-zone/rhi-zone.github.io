# ADR-0009: Browser app rendering: app realm emits virtual structures, host paints (Option B); no DOM in the realm

- Status: Accepted
- Date: 2026-05-29

**Context.** After isolating execution, the question remained how app UI reaches the screen. There is also a latency requirement: UX must stay responsive across VPN/proxy links (50ms to multi-second latency), ruling out architectures where every interaction is a server round-trip.

**Decision.** Resolved to Option B: the app realm produces virtual structures (VNode/Element shapes) and the host paints them in the host's realm. This is consistent with the allow-list realm, which removes document/Element/Node entirely — there is no DOM in the realm to render into. Reactive logic needing sub-100ms response runs in the app's browser realm; daemon round-trips happen async with optimistic concurrency.

**Alternatives rejected.**
- *Option A — app owns its iframe DOM directly, stub composes iframes into a layout* — Iframes are heavy, cross-iframe composition is awkward (no flex/grid), inter-app DOM interaction needs explicit protocols, and DOM-in-realm conflicts with the allow-list bootstrap that removes the DOM.
- *Option C — hybrid (simple apps B, complex apps A)* — Two rendering models to maintain, authors pick wrong, cap surface differs; A's DOM-in-realm shape still conflicts with the allow-list bootstrap.
- *Server-rendering / vanilla LiveView-Hotwire pattern (every interaction a round-trip)* — Violates the latency requirement — UX must stay responsive over VPN/proxy links with up to multi-second latency.

**Consequences.** App UI is a structural VNode tree returned to the host, not direct DOM manipulation; direct DOM APIs are banned in the realm; one rendering model platform-wide; reactive interactivity lives browser-side with async optimistic daemon sync. Mined from: /home/me/git/rhizone/crescent/docs/platform_isolation.md (1087-1088), /home/me/git/rhizone/crescent/docs/platform_isolation.md (180-182).
