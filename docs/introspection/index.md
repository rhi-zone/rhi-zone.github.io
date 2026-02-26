# Introspection

Analysis of how the rhi ecosystem is built - patterns, costs, and pain points observed across agent sessions.

These pages are generated from [Normalize](https://docs.rhi.zone/normalize/) session analysis (`normalize sessions stats`, `normalize sessions show --analyze`) run across all ecosystem repos.

## Pages

- [Session Analysis](./session-analysis) - Comprehensive analysis of 2329 Claude Code sessions across the ecosystem (January 2026)
- [Session Deep Dives](./session-deep-dives) - Per-session analysis of flagged high-rework, high-cost, and agent sessions

## Activity Log

Periodic snapshots of ecosystem activity — what's moving, what it costs, what shipped. Aligned to Mon–Sun weeks. Session cost data available from Jan 26 onward.

| Week | Active Repos | Commits | Cost | Focus |
|------|-------------|---------|------|-------|
| [Dec 15–21](./log/2025-12-21) | 1 | 709 | — | normalize only: call graphs, external index |
| [Dec 22–28](./log/2025-12-28) | 1 | 697 | — | normalize only: highlight queries |
| [Dec 29–Jan 4](./log/2026-01-04) | 1 | 314 | — | normalize only: agent v2 |
| [Jan 5–11](./log/2026-01-11) | 14 | 729 | — | ecosystem explosion: 14 repos scaffolded |
| [Jan 12–18](./log/2026-01-18) | 16 | 388 | — | zone + unshape lead, behavioral patterns rollout |
| [Jan 19–25](./log/2026-01-25) | 19 | 923 | — | peak breadth, ecosystem renames, server-less OpenAPI |
| [Jan 26–Feb 1](./log/2026-02-01) | 21 | 444 | $4,358 | crates.io prep, hologram permissions, session analysis |
| [Feb 2–8](./log/2026-02-08) | 8 | 354 | $1,617 | reincarnate emerges, ooxml complete WML, motif scaffolded |
| [Feb 9–15](./log/2026-02-15) | 9 | 666 | $1,756 | "two at a time": reincarnate + existence |
| [Feb 16–22](./log/2026-02-22) | 6 | 613 | $1,079 | reincarnate + existence steady, tightest focus |
| [Feb 23–26](./log/2026-02-25) | 9 | 594 | $895 | crescent scaffolded, rescribe fixtures, ooxml OMML |

## Patterns

### What keeps a project active

Projects stay active when they have **external pull** — a reason to keep working beyond the initial scaffolding.

| Pull type | Projects | Why it works |
|-----------|----------|-------------|
| **Daily tool use** | normalize | You use it to analyze your own work |
| **External community** | reincarnate, ooxml | GameMaker porting community; Office format users |
| **Active users** | hologram | Discord RP community using it daily |
| **The work demands content** | existence | The game itself needs writing |
| **Concrete format coverage** | rescribe | Measurable — N formats supported, fixture pass rates |
| **Upstream dependency** | server-less | normalize will consume it; actively gaining features |

### Why things go dormant

- **Feature complete**: wick (expression language), keybinds (keybind/command palette library, used in ptera.world and reincarnate), ooxml (Office Open XML — codegen'd from schemas)
- **Sufficient for now**: unshape — fleshed out, no pressing use case to push further
- **Dependency chains**: zone → moonlet → portals all went dormant together. Zone (Lua tooling) lacked a pressing use case, so its runtime (moonlet) and its capability system (portals) had nothing to serve
- **Superseded by sibling**: aspect (card-based identity exploration) set aside for existence; moue (BDCC fork) set aside for existence
- **Decomposed into other projects**: lotus (MOO framework) → reed → normalize-surface-syntax; lotus's capability-based runtime → moonlet + portals
- **Sunsetted**: herbarium (repology-but-worse — repology already did the hard unification work, unusable due to licensing); prose (program synthesis experiment — concluded writing programs is hard, needs more disciplined approach grounded in prior art)
- **On hold / forgotten**: pad (file workspace — forgotten about)
- **Waiting for demand**: playmate (game primitives without a game that needs them), interconnect (federation protocol without services to federate), concord (API codegen without APIs to bind)

### Architecture: tools, not repos

The ecosystem is highly modular. normalize has 30 crates — 10+ are standalone tools with their own CLIs that are *also* composed into a single meta-CLI. server-less is the mechanism that makes this cheap (one impl → many protocols, derive CLI/API/library interfaces from one implementation).

This means repos are organizational boundaries, not product boundaries. "What do you work on next" isn't "which repo" — it's "what capability do you add to the toolbelt." The dormant repos aren't stalled projects; they're namespaces containing crates that can be pulled in as dependencies when something needs them.

### The scaffolding question

The Jan 5–25 explosion (1→14→19 active repos in 3 weeks) scaffolded the full vision cheaply — most repos got <50 commits. Having structure ready means starting instantly when demand appears. The cost of premature scaffolding is low; the cost of not having it when needed is context-switching to set up infrastructure.

### Focus strategy

"Two at a time" emerged naturally by Feb 9 — pick two projects with real pull, in complementary cognitive modes (systems/compiler + creative/design). Active repo count dropped from 19 to 6. The remaining repos get maintenance touches, not feature pushes.

### Project maturity (as of Feb 26, 2026)

**Shipped / feature complete:**
- wick, keybinds, ooxml, unshape (sufficient)

**Active, with clear trajectory:**
- **normalize** — daily-use tool, grows with the ecosystem. No "done" state — it's the meta-tool.
- **reincarnate** — Harlowe frontend mostly complete. SugarCube, GML, Flash in progress. Goal: support many major runtimes (Ren'Py, RPG Maker, Inform, etc.). Long runway.
- **existence** — open-ended by design. Core systems mostly set in stone but perpetually fleshable. Technically usable now.
- **server-less** — actively gaining features. normalize will consume it.
- **rescribe** — 30+ formats, growing fixture coverage. No product consuming it yet.
- **hologram** — stable, active users.
- **crescent** — just scaffolded, initial import done.

**Scaffolded, waiting for demand:**
- gels, motif, deskspace, concord, interconnect, playmate, dusklight, moonlet, portals, zone
