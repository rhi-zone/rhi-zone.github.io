# Paraphase

**Pipeline orchestrator for data conversion.**

::: info Status: Fleshed Out ◐
~82K lines of Rust across 7 crates (core, plugin, serde, image, video, audio, cli). Production-ready CLI with 18 serialization formats, 14 image formats, memory budgeting, and comprehensive documentation including ADRs. Main gaps: audio/video encoders and schema-dependent formats.
:::

Paraphase is a type-driven route planner for asset pipelines. Instead of writing conversion recipes, you declare source and destination—Paraphase finds the path.

## Key features

- **Route planning** - Declare intent, Paraphase finds the conversion path
- **Normalized options** - One vocabulary maps to tool-specific flags
- **Plugin architecture** - Converters are dynamic libraries
- **Agent-friendly** - Two-phase plan→execute for LLM integration

## How it works

```bash
# Task runner: you write the recipe
blender --background --python export.py -- input.blend output.glb

# Paraphase: you declare intent
paraphase convert model.blend optimized.glb --optimize
```

## Use cases

- Game asset pipelines (textures, meshes, audio)
- Batch image/video conversion
- Format migration
- Any "I have X, I need Y" transformation

## Related projects

- [rescribe](/projects/rescribe) - Lossless document conversion (complementary transformation domain)

## Links

- [GitHub](https://github.com/rhi-zone/paraphase)
- [Documentation](https://rhi.zone/paraphase/)
