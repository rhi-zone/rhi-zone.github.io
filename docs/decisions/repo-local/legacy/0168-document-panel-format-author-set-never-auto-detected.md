# ADR-0168: Document panel format is author-set, never auto-detected

- Status: Accepted
- Date: 2026-05-29

**Context.** The panel renders a document according to a `format` field (thread, document, or default prose). The system could infer the format from the body content, or require the author to declare it.

**Decision.** The `format` frontmatter field is set explicitly by the author and is never auto-detected; absent the field, the document renders as standard prose. The markdown body must be structured to match the declared format.

**Alternatives rejected.**
- *Auto-detect the document format from body content* — Explicitly rejected — 'the author sets this explicitly; it is never auto-detected' — keeping rendering presentation an authorial decision rather than an inference.

**Consequences.** The render pipeline will not guess presentation; authors must declare `format` and structure the body accordingly (e.g. raw HTML for `thread`, paginated `.page` divs for `document`). No auto-detection code path exists to maintain. Mined from: /home/me/git/paragarden/legacy/CLAUDE.md (55).
