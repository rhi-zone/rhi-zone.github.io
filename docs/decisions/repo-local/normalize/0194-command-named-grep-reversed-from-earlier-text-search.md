# ADR-0194: Command named grep, reversed from the earlier text-search name

- Status: Accepted
- Date: 2026-05-29

**Context.** The text-pattern-matching command was originally named text-search specifically to stop AI agents from confusing it with unix grep (positional file args, BRE/ERE regex). In practice the rename did not solve that problem.

**Decision.** Use normalize grep for text pattern matching, reverting the text-search name. Short unix-inspired names (grep, view, edit) are the CLI's style. The remaining unix-confusion risk (ripgrep regex, not unix grep regex) is mitigated by documenting the dialect in CLAUDE.md rather than by renaming.

**Alternatives rejected.**
- *Keep the command named text-search* — The rename didn't solve the problem it was designed to solve — agents confused text-search just as much as grep (wrong syntax, wrong regex dialect) — and it caused its own confusion (agents tried normalize search or normalize find instead). grep is universally understood and fits the CLI's short unix-style naming.

**Consequences.** grep is the canonical name; search/find are transparent aliases. Regex dialect confusion is handled by documentation, not naming. Sets precedent that agent-confusion problems aren't necessarily solved by renaming away from familiar terms. Mined from: /home/me/git/rhizone/normalize/docs/architecture-decisions.md (147), /home/me/git/rhizone/normalize/docs/architecture-decisions.md (143).
