# Playmate

**Game design primitives library in Rust.**

::: info Status: Growing ◔
Well-planned project in early execution. Comprehensive architecture docs, design philosophy, and API documentation exist. ~800 lines of GDScript proof-of-concept in Godot, but no Rust core implementation yet. Next: define core crate boundaries, implement playmate-spatial.
:::

Playmate provides reusable game design primitives for common gameplay patterns. Built with game development in mind, it integrates well with engines like Bevy.

## Key Features

- **State Machines** - Game logic primitives for AI, animation, and gameplay
- **Character Controllers** - Movement systems for various game types
- **Camera Controllers** - Common camera behaviors (follow, orbit, first-person)

## Philosophy

Playmate extracts common patterns from game development into reusable, composable primitives. Rather than building everything from scratch, you assemble gameplay systems from well-tested building blocks.

## Links

- [GitHub](https://github.com/rhi-zone/playmate)
- [Documentation](https://rhi.zone/playmate/)
