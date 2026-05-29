# ADR-0126: XML tags as structural delimiters in the default template, not markdown headers

- Status: Accepted
- Date: 2026-05-29

**Context.** The default prompt template needs structural framing around entity facts and Discord messages, both of which themselves contain markdown.

**Decision.** The default template uses XML tags (`<defs for="name">`, `<memories for="name">`, `<embed>`, `<component>`) as structural delimiters rather than markdown headers. Corollary: embed.toJSON() dumps full embed JSON inside <embed>; it must not be downgraded to a prose summary.

**Alternatives rejected.**
- *Markdown headers as structural framing* — entity facts and Discord messages both contain markdown, so headers used as framing visually blend with the content they frame; XML tags are unambiguous as structure and don't conflict with LLM tool-call syntax

**Consequences.** Template structure is visually separable from markdown content; embed fidelity (full JSON) is preserved as a deliberate contract that 'verbosity' complaints cannot override. Mined from: /home/me/git/exoplace/hologram/docs/design/decisions.md (7), /home/me/git/exoplace/hologram/docs/design/decisions.md (9).
