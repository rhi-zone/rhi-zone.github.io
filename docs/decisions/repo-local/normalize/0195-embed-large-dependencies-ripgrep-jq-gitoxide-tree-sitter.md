# ADR-0195: Embed large dependencies (ripgrep, jq, gitoxide, tree-sitter) rather than shelling out

- Status: Accepted
- Date: 2026-05-29

**Context.** Several core features (text search, --jq output filtering, git-history analysis, parsing) could be implemented either by shelling out to external binaries on $PATH or by embedding the equivalent Rust libraries. Shelling out risks silent failure on NixOS, containers, CI, or managed systems where PATH contents are not guaranteed.

**Decision.** Embed the libraries directly: rg via grep_regex/ignore, jq via jaq, git via gix (gitoxide), and tree-sitter. A feature that depends on an external binary being in $PATH is treated as a suggestion, not a feature. Git write operations (worktree add/remove) are the only sanctioned shell-out, because gix doesn't support them and they're confined to budget metrics, not the critical analysis/rules path.

**Alternatives rejected.**
- *Shell out to rg/jq/git binaries on $PATH* — Users on NixOS, containers, CI, or systems managed by someone else cannot guarantee PATH contents; a tool that silently produces no output or errors cryptically because rg or git isn't present is unreliable. The alternative — a tool that works on the developer's machine but fails in CI — is worse than a large binary.

**Consequences.** normalize grep, --jq filtering, and git analysis work identically everywhere with no PATH requirement. The cost is larger binary size and longer compile time, accepted as the right tradeoff for a reliable developer tool. Establishes a general rule echoed in the anti-patterns list ('Shelling out when a Rust crate exists. Use gix not git'). Mined from: /home/me/git/rhizone/normalize/docs/architecture-decisions.md (513-514), /home/me/git/rhizone/normalize/docs/architecture-decisions.md (529-530), /home/me/git/rhizone/normalize/docs/architecture-decisions.md (537-538).
