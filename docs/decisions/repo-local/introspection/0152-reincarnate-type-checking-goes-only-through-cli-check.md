# ADR-0152: reincarnate type-checking goes only through the CLI check subcommand, never raw tsc/tsgo

- Status: Accepted
- Date: 2026-05-29

**Context.** In reincarnate, the agent repeatedly ran `tsc --noEmit` directly as its type-check feedback loop, which the user rejected multiple times in a row. The reincarnate project has its own CLI whose `check` subcommand is the intended typecheck oracle; raw tsc bypasses the project's wrapper and its expected diagnostics.

**Decision.** Codify in reincarnate's CLAUDE.md that direct tsc/tsgo invocation is prohibited; type checking must go through `cargo run -p reincarnate-cli -- check`. This was added to CLAUDE.md in response to the repeated violations and held for the remainder of that session.

**Alternatives rejected.**
- *Invoke tsc/tsgo directly for type checking* — The user rejected it repeatedly; raw tsc bypasses the reincarnate CLI's intended check path, and the agent kept falling back to it, prompting an explicit prohibition.

**Consequences.** reincarnate sessions are contracted to use the CLI check subcommand as the type-check oracle. The correction stuck once documented (no recurrence in-session). Reinforces the broader correction-to-documentation pipeline: behavioral invariants get written into CLAUDE.md once violated. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/friction-analysis-2026-03-29.md (78), /home/me/git/rhizone/github-io/docs/introspection/log/friction-analysis-2026-03-29.md (76).
