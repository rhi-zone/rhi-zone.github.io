# Myenv

**Unified tool configuration and project scaffolding.**

::: info Status: Fleshed Out ◐
~4.4K lines of Rust across 4 crates (cli, core, seed, store). Core features implemented: tool dependency management, config generation, watch/diff modes, manifest parsing, seed scaffolding, variable resolution. Backlog: tool registry integration, format auto-detection.
:::

Myenv manages tool configs from a single `myenv.toml` manifest and scaffolds new projects from seed templates.

**Repository:** [github.com/rhi-zone/myenv](https://github.com/rhi-zone/myenv)

## What Myenv Does

- **Generate** — `myenv.toml` → per-tool native configs
- **Validate** — Check configs against tool schemas before writing
- **Template** — Variable substitution, shared values across tools
- **Scaffold** — Create new projects from seed templates

## What Myenv Does NOT Do

- **Run tools** — That's moonlet's job
- **Manage execution order** — That's moonlet's job
- **Install tools** — Use your package manager

## The Invisible Manifest

`myenv.toml` is the **source of truth** but is **invisible at runtime**. Tools never read it directly—they only read their generated native configs.

```
myenv.toml  →  myenv generate  →  .moonlet/config.toml
                                  →  .resurrect/config.toml
                                  →  .dew/config.toml
```

This keeps tools simple and decoupled from myenv.

## Example Manifest

```toml
# myenv.toml
[project]
name = "my-project"
version = "0.1.0"

[variables]
assets = "./assets"

[resurrect]
source = "./dump/game.exe"
output = "{{assets}}/raw"

[dew]
pipeline = "main.dew"
input = "{{assets}}/raw"
output = "{{assets}}/processed"
```

Running `myenv generate` creates `.resurrect/config.toml` and `.dew/config.toml`. Tools read their native configs—no special runtime behavior.

## Seeds

Pre-configured starter templates:

- **seed-archaeology** — Lifting legacy games (resurrect + unshape)
- **seed-creation** — New game projects from scratch
- **seed-lab** — Full ecosystem sandbox

## Links

- [GitHub](https://github.com/rhi-zone/myenv)
