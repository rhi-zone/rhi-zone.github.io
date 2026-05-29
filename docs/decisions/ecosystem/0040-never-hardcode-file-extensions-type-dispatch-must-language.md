# ADR-0040: Never hardcode file extensions; type dispatch must be language-agnostic

- Status: Accepted
- Date: 2026-05-29

**Context.** normalize's type graph was discovered to dispatch on hardcoded file extensions, which broke for any language not explicitly listed.

**Decision.** Prohibit hardcoded file extensions in dispatch logic; type-graph dispatch must be language-agnostic. Encoded as the CLAUDE.md rule 'Never, ever hardcode file extensions' and applied across the affected code.

**Alternatives rejected.**
- *Keep hardcoded per-extension dispatch in the type graph* — Hardcoded dispatch broke for unlisted languages — a concrete discovered defect — motivating a rebuild as language-agnostic dispatch.

**Consequences.** Type graph rebuilt as language-agnostic dispatch; the prohibition is a behavioral rule applied wherever extension dispatch appears. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar4.md (105), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar4.md (141).
