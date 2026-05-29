# ADR-0142: Hologram message templating migrates to sandboxed Nunjucks, replacing the custom template engine

- Status: Accepted
- Date: 2026-05-29

**Context.** Hologram first built a custom role-based template engine (with blocks like {% block system %}) to replace imperative message building, then evolved to a third-party engine. The custom engine was a recent decision being reconsidered.

**Decision.** Migrate hologram's structured messaging to Nunjucks with runtime security (sandboxing dangerous methods like .repeat()/.match()) and a safe ReDoS-resistant regex parser, replacing the just-built custom template engine.

**Alternatives rejected.**
- *Keep the custom in-house template engine* — The migration is framed as learning from early decisions; the custom engine was abandoned in favor of Nunjucks, with security constraints (sandboxing, safe regex) layered on rather than reinventing them.

**Consequences.** Templating now depends on Nunjucks with a security sandbox and a safe regex parser; the custom engine path is superseded. Future template/expression work must respect the sandbox constraints. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-01-30.md (13), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-01-30.md (72).
