# ADR-0057: Crescent reimplements the substrate in pure Lua, with no dependency on the Rust crate

- Status: Accepted
- Date: 2026-05-29

**Context.** A Lua orchestration surface is wanted; the question is whether it binds to the Rust nanites crate or reimplements it.

**Decision.** Crescent reimplements the substrate as a general orchestration library in pure Lua (not called 'nanites') — same design patterns, different language, no dependency on the Rust crate. Many providers are OpenAI-compatible, so crescent can hit them directly without a per-provider SDK.

**Alternatives rejected.**
- *Have crescent bind to / depend on the Rust nanites crate* — Reimplementing the patterns in pure Lua avoids a cross-language dependency; the design patterns transfer without coupling the Lua surface to the Rust crate.
- *Use Vercel AI SDK for the provider layer* — AI SDK is TypeScript-only, not an option for Rust; rig serves the Rust surface and crescent can call OpenAI-compatible APIs directly.

**Consequences.** Two independent implementations of the substrate (Rust nanites, Lua crescent) with no shared dependency; provider access in Lua goes direct to OpenAI-compatible endpoints. Mined from: /home/me/git/rhizone/nanites/docs/design/platform.md (137), /home/me/git/rhizone/nanites/docs/design/platform.md (138).
