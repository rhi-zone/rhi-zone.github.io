# ADR-0241: Single protocol-neutral #[app] metadata attribute, superseding per-macro metadata

- Status: Accepted
- Date: 2026-05-29

**Context.** Every protocol that exposes application identity (OpenAPI info, CLI header/--version, config file path, OpenRPC/MCP/AsyncAPI specs) needs the same name/description/version/homepage. Before #[app] this was inconsistent: #[program(...)] covered CLI, HTTP hardcoded the struct name as OpenAPI title, and other protocols had no way to express metadata.

**Decision.** Introduce #[app(name, description, version, homepage)] as a shared, protocol-neutral attribute that generates no code itself but is read by all derives on the same impl block. It supersedes the per-macro metadata attributes (#[program(name/description/version)], #[cli(version)]), which are deprecated but kept for backwards compatibility until a major version removes them. Per-preset inline keys override #[app] for that preset only.

**Alternatives rejected.**
- *Per-macro metadata attributes (#[program(...)] for CLI, struct name as OpenAPI title, nothing for other protocols)* — Inconsistent: each protocol expressed identity differently or not at all, with no single source of truth. #[app] centralizes the metadata so every protocol consumes the same fields.
- *A binary-level #[app] that all services inherit* — Listed as an open question and judged 'Probably not -- keep it per-impl'; each impl block owns its own metadata independently.

**Consequences.** Metadata has one canonical home consumed by all protocols; name inference applies context-specific casing (kebab for paths/CLI, Title Case for OpenAPI title). version defaults to env CARGO_PKG_VERSION and requires explicit version=false to disable. Old per-macro attributes remain only as deprecated shims pending a major bump. Acronym handling in title case and binary-level app remain open. Mined from: /home/me/git/rhizone/server-less/docs/design/app-metadata.md (14), /home/me/git/rhizone/server-less/docs/design/app-metadata.md (106), /home/me/git/rhizone/server-less/docs/design/app-metadata.md (158).
