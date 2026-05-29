# ADR-0103: No custom plugin registry; plugins resolve to ES modules via npm/jsr/URL/local

- Status: Accepted
- Date: 2026-05-29

**Context.** A plugin-centric tool needs a distribution and discovery story. The default expectation for an extensible app is a bespoke plugin registry/marketplace.

**Decision.** Plugins are ES modules exporting a manifest. Distribution uses npm/jsr for published plugins, URLs for direct install, and local paths for personal plugins — explicitly no custom registry. User scripts are not a separate concept: everything is a plugin.

**Alternatives rejected.**
- *A custom plugin registry/marketplace* — Rejected ("No custom registry") in favor of reusing existing ES-module distribution channels (npm/jsr/URL/local)
- *A separate user-script mechanism distinct from plugins* — Rejected — the open question resolved to "No distinction — everything is a plugin"

**Consequences.** No registry infrastructure to build or maintain; all distribution channels resolve to ES modules. Promotion path exists ("promote to plugin") for ad-hoc settings. Manifests declare capabilities, parsers, patterns, renderers, and ops. Mined from: /home/me/git/rhizone/dusklight/docs/architecture.md (228), /home/me/git/rhizone/dusklight/docs/architecture.md (248).
