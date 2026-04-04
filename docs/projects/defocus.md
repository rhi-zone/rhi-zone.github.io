# defocus

**World substrate for interactive narrative, IF, and stateful simulations.**

::: info Status: Idea ○
Architecture designed. Core primitives defined. No implementation yet.
:::

defocus is the substrate that interactive fiction, CYOA, and stateful narrative games have always independently reinvented — objects with state, rules that transform state based on player choices, text rendered over that state. Every IF tool (Twine, Inform 7, the adult IF games like DoL/TiTS) reinvents this from scratch, in incompatible formats, without reusable components or LLM integration.

defocus separates the world model from the runtime. The protocol is the product: a well-defined world format (objects + messages + rules as ASTs) that any runtime can implement. Same world file, any deployment.

## Key features

- **Objects + messages** — everything is an object; all interaction is message passing; rules are what objects do when they receive messages
- **Rules as ASTs** — no parser, no syntax errors; rules are structured data, editable visually, diffable, serializable
- **Lazy refinement** — objects are stubs until observed; simulation depth scales with attention; the world exists at the level of detail the story needs
- **Opt-in persistence** — snapshot-only, event log (enables deterministic replay and branching), or both
- **Text as a rendering layer** — prose is a compositor over state, not the architecture
- **LLM as rule source** — NPC behavior driven by LLMs grounded in persistent object state; outputs logged for deterministic replay

## Use cases

- Twine/CYOA replacement with real state model and data-driven rules
- Shared infrastructure for adult IF games (body tracking, relationship systems, world state)
- LambdaMOO/MUD modernization
- LLM RP frontend with branching chats (world state as tree, not flat history)
- IF worlds with coherent LLM-driven NPCs
- LLM-powered social simulations

## Runtimes

| Runtime | Use case |
|---------|----------|
| Rust | Server, persistent worlds, full engine |
| WASM (from Rust) | Browser, complex games |
| TypeScript (native) | Browser, lightweight, static HTML deployments |
| Lua (Crescent) | Embedded, scripting |

## Relationship to other projects

**Interconnect** is the complementary network layer — defocus worlds can expose an Interconnect `Authority` adapter for multiplayer/federation, but the adapter is optional. defocus runs fine standalone.

**existence** (`para-garden`) independently invented the text-as-rendering-layer architecture and observation sources + prose compositor pattern — a reference implementation of what defocus generalizes.
