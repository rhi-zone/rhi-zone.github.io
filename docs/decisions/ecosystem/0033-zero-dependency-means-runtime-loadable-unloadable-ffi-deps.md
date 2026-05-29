# ADR-0033: Zero-dependency means runtime-loadable: unloadable FFI deps are violations

- Status: Accepted
- Date: 2026-05-29

**Context.** Apr 27 surfaced that crescent has no working FFI infrastructure — the vendored LuaJIT fork has ffi.load() disabled and no authoritative sqlite3 build source exists. Four sessions cycled through buildInputs/bundling/vendoring fixes before the user locked the constraint.

**Decision.** The zero-dependency constraint is defined to include the runtime-loadability of FFI dependencies: an FFI dependency that cannot be loaded at runtime (e.g. via buildInputs) is a zero-dep violation, full stop. This was made explicit in CLAUDE.md.

**Alternatives rejected.**
- *Satisfy the dependency via Nix buildInputs* — buildInputs are not zero-dep; the user locked the constraint: 'buildInputs ARE NOT ZERO DEP.'
- *Bundle sqlite3.c / vendor sqlite.dll for Windows only* — Rejected as bad solutions during the FFI crisis; still leaves runtime FFI loading broken across platforms.

**Consequences.** Crescent cannot rely on FFI for capabilities like sqlite; a crescent-native socket library surfaced as backlog instead. The constraint is now documented in CLAUDE.md, forecloses buildInputs-based fixes ecosystem-wide. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-26-2026-05-09.md (13).
