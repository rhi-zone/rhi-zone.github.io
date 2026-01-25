# Dusklight

**Universal UI client with control plane.**

::: info Status: Idea ○
Well-developed design documentation (philosophy, architecture, plugin system). TypeScript/bun setup ready. Zero implementation code—past the raw idea stage due to strong documentation, but no working codebase yet to validate the design.
:::

Dusklight is an infinitely configurable UI for viewing, mutating, and controlling data—static files, network streams, video, audio, binary formats, and more.

## Key Features

- **Format-agnostic** - JSON, JSONL, protobuf, msgpack, SSE, video, audio, binary
- **Source-agnostic** - Filesystem, HTTP, WebSocket, stdin
- **Control plane** - Not just read-only; trigger actions, mutate state
- **User-configurable** - Define custom views for any data shape
- **Live updates** - Streaming data with real-time rendering

## Use Cases

- **Log viewers and debuggers** - View and interact with running systems
- **API explorers** - Inspect and trigger endpoints
- **Stream monitors** - Real-time data visualization
- **Project hubs** - Unified dashboard for rhi workflows
- **Binary inspectors** - Format-agnostic data exploration

## Project Hub

For rhi projects, Dusklight becomes the unified dashboard:

- View habitat world state, trigger actions
- Monitor Resurrect extraction progress
- Inspect Paraphase pipeline status
- Control any data-producing system

## Links

- [GitHub](https://github.com/rhi-zone/dusklight)
- [Documentation](https://rhi.zone/dusklight/)
