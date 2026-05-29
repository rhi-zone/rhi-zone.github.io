# ADR-0186: Build the graph dynamically via code, not a visual node editor

- Status: Accepted
- Date: 2026-05-29

**Context.** Prior art (ComfyUI, n8n, Node-RED, and the team's own abandoned maki) all use visual node-based editors for orchestration workflows.

**Decision.** Nanites builds the graph dynamically via Rust code, not visually. It keeps the benefits of node editors (inspection, serialization, replay) without the visual editor.

**Alternatives rejected.**
- *Visual node-based editor (as in maki / ComfyUI / n8n)* — Node-based editors are 'programming with worse ergonomics'; maki proved MCP + typed schemas + multi-provider AI was right but the node-based UI was a dead end.

**Consequences.** No visual editor will be built; orchestration is authored as code. maki's architecture (MCP typed tool interface, JSON Schema wire types) is inherited without the editor. Mined from: /home/me/git/rhizone/nanites/docs/design/platform.md (128), /home/me/git/rhizone/nanites/docs/design/platform.md (130).
