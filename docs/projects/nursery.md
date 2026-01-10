# Nursery

**Schema-controlled tool orchestrator.**

Nursery is a generic orchestrator for composing CLI tools. Define tool schemas and compose them via manifests—no hardcoded tool knowledge required.

## Key Features

- **Schema-Driven** - Tools declare their interfaces via JSON Schema
- **Manifest Composition** - One `rhizome.toml` file composes any set of tools
- **Lazy Discovery** - Only inspects tools that are referenced
- **Fail Informatively** - Clear errors when tools are missing or misconfigured
- **Plugin Architecture** - Add new tools without modifying Nursery itself

## Tool Schemas

Tools register themselves with a schema describing their inputs and outputs:

```json
{
  "name": "my-tool",
  "version": "1.0.0",
  "inputs": {
    "source": { "type": "path", "required": true },
    "format": { "type": "string", "enum": ["json", "yaml"] }
  },
  "outputs": {
    "result": { "type": "path" }
  }
}
```

## The Manifest

```toml
# rhizome.toml
[project]
name = "my-project"
version = "0.1.0"

[tools.convert]
source = "./input.json"
format = "yaml"

[tools.process]
input = "${tools.convert.result}"
```

The manifest composes tools by wiring outputs to inputs. Nursery validates the pipeline against tool schemas before execution.

## Seeds

Pre-configured starter templates:

- **seed-archaeology** - Lifting legacy games (siphon → lotus)
- **seed-creation** - New Lotus projects from scratch
- **seed-lab** - Full ecosystem sandbox

## Links

- [GitHub](https://github.com/rhizome-lab/nursery)
- [Documentation](https://rhizome-lab.github.io/nursery/)
