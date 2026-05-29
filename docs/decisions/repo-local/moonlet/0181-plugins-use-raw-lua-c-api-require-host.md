# ADR-0181: Plugins use the raw Lua C API and require, not a host-owned string capability registry

- Status: Accepted
- Date: 2026-05-29

**Context.** Designing the dynamic plugin system; needed to decide how plugins expose capabilities to Lua and how they couple to the host.

**Decision.** Plugins are standard Lua C modules loaded via require, using the raw lua_State C API (not mlua wrappers), with the module path as identity; capabilities are userdata constructed by the module rather than fetched from a central string registry like moonlet.capability("fs", ...).

**Alternatives rejected.**
- *A central string-keyed capability registry, e.g. moonlet.capability("fs", ...)* — Ownership of the string name is ambiguous, names conflict between plugins, discovery is opaque, and it is not Lua-idiomatic.
- *Plugins coded against mlua wrappers* — Coupling to mlua is rejected; plugins use the raw Lua C API for a stable C ABI boundary.

**Consequences.** Plugin boundary is a C ABI (libloading + Lua C API); namespacing comes from module paths (moonlet.fs, rhizome.moss); no central registry to arbitrate names; LuaJIT FFI for the plugin boundary is left as an open question. Mined from: /home/me/git/rhizone/moonlet/docs/design/plugin-architecture.md (11), /home/me/git/rhizone/moonlet/docs/design/plugin-architecture.md (56-59).
