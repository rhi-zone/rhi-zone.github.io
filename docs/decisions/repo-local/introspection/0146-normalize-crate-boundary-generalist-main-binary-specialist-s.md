# ADR-0146: normalize crate boundary: generalist in main binary, specialist in separate crates

- Status: Accepted
- Date: 2026-05-29

**Context.** Vendoring ripgrep/ast-grep and adding sessions/architecture/graph functionality grew normalize's binary. A rule was needed for what belongs in the main binary versus extracted crates.

**Decision.** Generalist functionality stays in the main normalize binary; specialist functionality (sessions, architecture queries, graph analysis) lives in separate crates. normalize-output and normalize-view were consolidated into one crate; normalize-graph and normalize-architecture were extracted as separate modules.

**Alternatives rejected.**
- *Keep all functionality (including specialist sessions/architecture/graph analysis) in the main binary* — Binary bloat — vendored deps like ripgrep (6.4MB) and added subcommands grew the release binary several MB; specialist code in the main binary makes everyone pay for niche features, so specialists are pushed to separate crates.

**Consequences.** New normalize functionality is triaged by the generalist/specialist test to decide crate placement; the main binary stays lean while specialist crates carry niche cost. Establishes a size-vs-modularity rule applied repeatedly in subsequent crate-extraction decisions. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-04.md (9), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-04.md (27).
