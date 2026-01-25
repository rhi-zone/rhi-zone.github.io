# Interconnect

**Federation protocol for persistent worlds.**

::: info Status: Idea ○
Conceptually mature with excellent documentation (protocol design, security model, import policies, architecture). Zero implementation—the hard problem (protocol design) is solved and documented, ready for implementation of `interconnect-core` and basic protocol types.
:::

Interconnect enables habitat servers to form interconnected networks where players can travel between worlds owned by different authorities.

## Key features

- **Authoritative Handoff** - Single server owns each world, no state merging
- **Intent-Based Protocol** - Clients send intent, servers compute results
- **Two-Layer Architecture** - Replicated substrate (static), authoritative simulation (dynamic)
- **Import Policies** - Customs validation for player transfers between worlds

## Why not state merging?

Traditional federation (like Matrix) merges state from multiple servers. This creates attack surfaces:

- State resolution DoS
- History rewriting
- Split-brain attacks

Interconnect avoids these by using single-authority ownership. When you move between worlds, you disconnect from Server A and connect to Server B.

## Ghost mode

When authority connection is lost:
- World desaturates visually
- Player becomes observer (client-side collision only)
- Static world data (substrate) remains visible
- Universe pauses, doesn't disappear

## Links

- [GitHub](https://github.com/rhi-zone/interconnect)
- [Documentation](https://rhi.zone/interconnect/)
