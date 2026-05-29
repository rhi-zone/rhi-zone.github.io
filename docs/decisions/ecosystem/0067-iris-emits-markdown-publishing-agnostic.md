# ADR-0067: Iris emits markdown, publishing-agnostic

- Status: Accepted
- Date: 2026-05-29

**Context.** Iris produces shareable content (blog-post style). The design had to decide whether Iris owns the publishing step or stops at content output.

**Decision.** Iris outputs markdown to stdout (or a file via --output) and has no built-in publishing. It stays workflow- and blog-software-agnostic; the user decides where output goes (VitePress, Hugo, Ghost, etc.).

**Alternatives rejected.**
- *Build in publishing automation to a specific static site generator / blog platform* — Markdown is a universal format that is easy to pipe, redirect, and integrate; coupling Iris to a particular publishing target would make it less universal. Frontmatter generation is at most a future consideration, not built in.

**Consequences.** Iris stays a content generator, not a publishing pipeline; integration with any SSG is downstream and the user's responsibility. Adding SSG-specific frontmatter generation remains a possible future enhancement. Mined from: /home/me/git/rhizone/zone/docs/design/iris.md (133), /home/me/git/rhizone/zone/docs/design/iris.md (140).
