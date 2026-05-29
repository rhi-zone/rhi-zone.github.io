# ADR-0277: Unshape is a library defining the plugin contract; the host handles loading

- Status: Accepted
- Date: 2026-05-29

**Context.** Third-party code must be able to extend unshape with custom operations, but different hosts have radically different needs: a game engine wants only built-in ops, a DAW has an existing Lua system, a standalone tool wants a WASM sandbox, an internal tool wants trusted native plugins.

**Decision.** Unshape (rhi-unshape-core) defines only the contract: op traits, a serialization format, and a registry interface. The host application is responsible for plugin discovery, loading, and sandboxing. Optional adapter crates (wasm-plugins, lua, native C ABI) implement common loading models but are not mandatory.

**Alternatives rejected.**
- *Build a plugin system into unshape that every host must use* — Forcing a single plugin system on everyone conflicts with the modular philosophy; different hosts have incompatible loading/sandboxing/trust requirements

**Consequences.** Unshape stays a library, not a framework; core has no loading mechanism. Hosts choose loading appropriate to their context. Plugins are referenced by type name in serialized graphs; unknown type names fail deserialization with a clear error. Mined from: /home/me/git/rhizone/unshape/docs/design/plugin-architecture.md (6), /home/me/git/rhizone/unshape/docs/design/plugin-architecture.md (16).
