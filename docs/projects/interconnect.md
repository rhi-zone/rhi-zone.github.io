# Interconnect

**Federation protocol for persistent worlds.**

Interconnect enables Lotus servers to form interconnected networks where players can travel between worlds owned by different authorities.

## Key Features

- **Authoritative Handoff** - Single server owns each world, no state merging
- **Intent-Based Protocol** - Clients send intent, servers compute results
- **Two-Layer Architecture** - Replicated substrate (static), authoritative simulation (dynamic)
- **Import Policies** - Customs validation for player transfers between worlds

## Why Not State Merging?

Traditional federation (like Matrix) merges state from multiple servers. This creates attack surfaces:

- State resolution DoS
- History rewriting
- Split-brain attacks

Interconnect avoids these by using single-authority ownership. When you move between worlds, you disconnect from Server A and connect to Server B.

## Ghost Mode

When authority connection is lost:
- World desaturates visually
- Player becomes observer (client-side collision only)
- Static world data (substrate) remains visible
- Universe pauses, doesn't disappear

## Links

- [GitHub](https://github.com/rhi-zone/interconnect)
- [Documentation](https://rhi.zone/interconnect/)
