# ADR-0020: New repos copy git from a template repo; never git init

- Status: Accepted
- Date: 2026-05-29

**Context.** Scaffolding new repos requires establishing git history and config. The choice was between initializing a fresh repo with `git init` or seeding from a prepared template repo.

**Decision.** New repos copy `.git` from `~/git/0000000_pterror` (a template repo with proper history/config); `git init` is explicitly disallowed.

**Alternatives rejected.**
- *Initialize new repos with `git init`* — It would lose the template repo's proper history and config that the scaffolding depends on; the explicit instruction is 'Do NOT use `git init`.'

**Consequences.** Every new repo inherits the template's git history/config by copying `.git`; scaffolding procedure depends on the `0000000_pterror` template existing. Mined from: /home/me/git/rhizone/github-io/scaffolding/README.md (36).
