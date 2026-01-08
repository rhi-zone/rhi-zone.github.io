# Bloom

**A persistent multiplayer world runtime.**

Bloom is a LambdaMOO-inspired system built on Lua with persistent entity storage. Create scriptable objects, rooms, NPCs, and more in a capability-secured environment.

## Key Features

- **Multiplayer** - Real-time interaction with other users in a persistent world
- **Scriptable** - Custom scripting with Lua for dynamic content and object behaviors
- **Multi-frontend** - Access via Web, Discord, or Terminal (TUI)
- **Capability Security** - Fine-grained permission system based on object capabilities

## Architecture

Bloom separates concerns into:

- **Core** - Entity system, persistence, capability model
- **Scripting** - Lua runtime with sandboxing
- **Frontends** - Discord bot, web interface, TUI

## Links

- [GitHub](https://github.com/rhizome-lab/bloom)
- [Documentation](https://rhizome-lab.github.io/bloom/)
