# ADR-0063: busier dogfood stack: SPA (Lit + rainbow + Bun/Hono), not SSR or a meta-framework

- Status: Accepted
- Date: 2026-05-29

**Context.** The busier tutoring platform (dogfood app for rainbow) needed a stack decision. The prior SolidStart setup had persistent issues (Vinxi/Node ESM split, bun:sqlite in SSR context, hydration mismatches).

**Decision.** Clean SPA + dedicated API server: Lit (Web Components) rendering, @rhi-zone/rainbow reactivity, rainbow-router, Zag.js components, Vite build; backend Hono on Bun, libSQL+Drizzle, better-auth. No SSR.

**Alternatives rejected.**
- *SSR via SolidStart / Nuxt / Astro* — The app is entirely authenticated with zero SEO-relevant routes, so SSR's first-paint latency advantage is irrelevant; SolidStart v2 (Nitro) isn't stable yet, Nuxt's 'maturity' isn't the goal vs standards-based primitives, and Astro gets awkward for interactive dashboards with complex mutation flows.

**Consequences.** SPA wins after first load (instant navigation, parallel fetches, no HTML round-trip); the SolidStart pain points disappear. rainbow owns reactive state, Lit owns rendering, each layer independently replaceable. Worth revisiting SolidStart v2 once beta lands. Mined from: /home/me/git/rhizone/rainbow/docs/design/stack.md (39-40), /home/me/git/rhizone/rainbow/docs/design/stack.md (42-44).
