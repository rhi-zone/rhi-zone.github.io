# ADR-0065: Dual build output: standalone SPA plus externalized embeddable Vue library

- Status: Accepted
- Date: 2026-05-29

**Context.** The same editor must work both as a standalone tool and embedded inside statosphere-guide. A single deployment shape (SPA only, or library only) would not serve both consumers.

**Decision.** The studio produces dual output: an SPA deployed to GitHub Pages for standalone use, and a Vue library build (dist/statosphere-studio.es.js) for embedding via global component registration. Vue and Pinia must be externalized (not bundled) in the library build.

**Alternatives rejected.**
- *Bundle Vue and Pinia into the library build* — Bundling would duplicate the framework in the embedding host (statosphere-guide); externalizing them is required for clean embedding, so they must not be bundled.

**Consequences.** The build pipeline maintains two targets; the embed contract is `<StatosphereStudio embedded template="...">` with the template prop mapping to a builtin recipe id. Host apps must provide Vue and Pinia. Mined from: /home/me/git/pterror/statosphere-studio/README.md (39), /home/me/git/pterror/statosphere-studio/CLAUDE.md (16).
