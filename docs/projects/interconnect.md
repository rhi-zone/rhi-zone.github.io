# Interconnect

**Connective substrate for authoritative rooms.**

::: info Status: Idea ○
Protocol design is conceptually mature with documentation (security model, import policies, architecture). Early implementation of `interconnect-core` with Authority trait and wire protocol types. Next priority: generalize types beyond game-specific domain, add transport abstraction, build process-as-room spike.
:::

Interconnect is the protocol layer that lets clients connect to authorities. A room is anything with an owner that accepts connections: a game world, a social feed, a running process, an autonomous agent. The protocol defines what a connection is — intents in, snapshots out, authority semantics, explicit boundaries. Transport-agnostic: WebSocket, Unix socket, Discord bot, HTTP.

## Key features

- **Authority over consensus** — Single owner per room, no state merging
- **Intent-based protocol** — Clients send intent, authorities compute results
- **Two-layer architecture** — Replicated substrate (static), authoritative simulation (dynamic)
- **Import policies** — Validation for client transfers between rooms
- **Multiple authorities** — A client can be connected to several authorities at once; Discord is an authority, your agent is an authority

## Why not state merging?

Traditional federation (like Matrix) merges state from multiple servers. This creates attack surfaces:

- State resolution DoS
- History rewriting
- Split-brain attacks

Interconnect avoids these by using single-authority ownership. When you move between rooms, you disconnect from Authority A and connect to Authority B.

## Ghost mode

When authority connection is lost:
- Client knows authority is unreachable
- Client becomes observer (read-only access to substrate)
- Static room data (substrate) remains available
- Room pauses, doesn't disappear

## Related projects

- [Playmate](/projects/playmate) — Game design primitives for world interactions

## Links

- [GitHub](https://github.com/rhi-zone/interconnect)
- [Documentation](https://rhi.zone/interconnect/)
