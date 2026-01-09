# Cambium

**Pipeline orchestrator for data conversion.**

Cambium is a type-driven route planner for asset pipelines. Instead of writing conversion recipes, you declare source and destination—Cambium finds the path.

## Key Features

- **Route planning** - Declare intent, Cambium finds the conversion path
- **Normalized options** - One vocabulary maps to tool-specific flags
- **Plugin architecture** - Converters are dynamic libraries
- **Agent-friendly** - Two-phase plan→execute for LLM integration

## How It Works

```bash
# Task runner: you write the recipe
blender --background --python export.py -- input.blend output.glb

# Cambium: you declare intent
cambium convert model.blend optimized.glb --optimize
```

## Use Cases

- Game asset pipelines (textures, meshes, audio)
- Batch image/video conversion
- Format migration
- Any "I have X, I need Y" transformation

## Links

- [GitHub](https://github.com/rhizome-lab/cambium)
- [Documentation](https://rhizome-lab.github.io/cambium/)
