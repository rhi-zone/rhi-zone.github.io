# ADR-0203: Plugin format: C ABI dynamic libraries

- Status: Accepted
- Date: 2026-05-29

**Context.** Paraphase needs a plugin system for converters. Four formats were on the table (Rust static crates, WASM, executables, C ABI dylibs), trading off authoring language, performance, sandboxing, and distribution.

**Decision.** Converters are distributed as C ABI dynamic libraries (.so/.dylib/.dll) exporting a fixed C symbol set (paraphase_plugin_version, paraphase_list_converters, paraphase_convert, paraphase_free, paraphase_last_error), discovered from built-ins, $CAMBIUM_PLUGIN_PATH, ~/.paraphase/plugins, and project-local dirs with project-local override.

**Alternatives rejected.**
- *Rust static crates* — Rust-only authoring; Rust has no stable ABI so dynamic loading needs C ABI anyway
- *WASM* — Sandboxed/portable but not native performance and cannot link C libraries (libvips, ffmpeg) directly via FFI without indirection
- *Executables on PATH* — Subprocess overhead; chosen model gives native performance with no subprocess indirection

**Consequences.** Any language producing a C-compatible shared library can author plugins; plugins run in-process with native performance and can link C libs, at the cost of no sandboxing, platform-specific binaries, and an ABI-stability versioning burden. WASM/subprocess fallback left as future options. Mined from: /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (20), /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (24), /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (134).
