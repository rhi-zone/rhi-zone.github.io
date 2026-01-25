# Myenv

**Unified tool configuration and project scaffolding.**

::: info Status: Fleshed Out ◐
~4.4K lines of Rust across 4 crates (cli, core, seed, store). Core features implemented: tool dependency management, config generation, watch/diff modes, manifest parsing, seed scaffolding, variable resolution. Backlog: tool registry integration, format auto-detection.
:::

Myenv manages tool configs from a single `myenv.toml` manifest and scaffolds new projects from seed templates.

**Repository:** [github.com/rhi-zone/myenv](https://github.com/rhi-zone/myenv)

## What Myenv does

- **Generate** — `myenv.toml` → per-tool native configs
- **Validate** — Check configs against tool schemas before writing
- **Template** — Variable substitution, shared values across tools
- **Scaffold** — Create new projects from seed templates

## What Myenv does NOT do

- **Run tools** — That's moonlet's job
- **Manage execution order** — That's moonlet's job
- **Install tools** — Use your package manager

## The invisible manifest

`myenv.toml` is the **source of truth** but is **invisible at runtime**. Tools never read it directly—they only read their generated native configs.

```
myenv.toml  →  myenv generate  →  .moonlet/config.toml
                                  →  .reincarnate/config.toml
                                  →  .dew/config.toml
```

This keeps tools simple and decoupled from myenv.

## Example manifest

```toml
# myenv.toml
[project]
name = "my-project"
version = "0.1.0"

[variables]
assets = "./assets"

[reincarnate]
source = "./dump/game.exe"
output = "{{assets}}/raw"

[dew]
pipeline = "main.dew"
input = "{{assets}}/raw"
output = "{{assets}}/processed"
```

Running `myenv generate` creates `.reincarnate/config.toml` and `.dew/config.toml`. Tools read their native configs—no special runtime behavior.

## Seeds

Pre-configured starter templates:

- **seed-archaeology** — Lifting legacy games (reincarnate + unshape)
- **seed-creation** — New game projects from scratch
- **seed-lab** — Full ecosystem sandbox

## Related projects

- [Zone](/projects/zone) - Provides seed templates for scaffolding

## Links

- [GitHub](https://github.com/rhi-zone/myenv)
