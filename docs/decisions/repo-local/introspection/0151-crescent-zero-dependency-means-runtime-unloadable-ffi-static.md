# ADR-0151: Crescent zero-dependency means no runtime-unloadable FFI; static-linked native libs vendored in-repo, not via Nix buildInputs

- Status: Accepted
- Date: 2026-05-29

**Context.** Implementing the cap_dispatch refactor required SQLite (via FFI), but crescent inherited a vendored LuaJIT fork where ffi.load() is disabled, and there was no authoritative SQLite build for Linux/macOS. Several proposed fixes were examined against crescent's zero-dependency constraint.

**Decision.** FFI dependencies that cannot be loaded at runtime count as zero-dependency violations. Native libraries must be vendored as statically-linked binaries (for Linux and macOS, not Windows-only) inside the crescent repo; Nix flake buildInputs do not satisfy the zero-dependency constraint. Full implementation deferred until SQLite static vendoring is resolved.

**Alternatives rejected.**
- *Put FFI deps in flake buildInputs* — Wrong on NixOS; buildInputs are not zero-dep ('buildInputs ARE NOT ZERO DEP')
- *Bundle sqlite3.c into LuaJIT, or vendor sqlite.dll for Windows only* — Bundling into LuaJIT is unviable because FFI is already broken; Windows-only DLL is unacceptable since Linux + macOS static builds are needed

**Consequences.** Cap dispatch refactor blocked on test infrastructure until static SQLite is vendored for Linux+macOS. CLAUDE.md flagged for explicit zero-dependency guidance. Possible use of patchelf + ld-musl for portable ELF binaries. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-04-27.md (27), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-04-27.md (35), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-04-27.md (30).
