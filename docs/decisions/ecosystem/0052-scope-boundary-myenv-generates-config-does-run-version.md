# ADR-0052: Scope boundary: myenv generates config and does not run or version tools

- Status: Accepted
- Date: 2026-05-29

**Context.** As an 'orchestration layer' / 'configuration manager', myenv could plausibly expand to running tools, ordering execution, and installing/versioning them. The design had to fix what is in scope.

**Decision.** myenv's responsibility is validation and config generation only. Running tools and managing execution order is spore's job; installing/versioning tools is the package manager's job. These are explicit non-goals.

**Alternatives rejected.**
- *myenv also runs tools and manages their execution order* — Explicitly listed under Non-Goals: 'Run tools — That's spore's job' and 'Manage tool execution order — That's spore's job', delegating runtime concerns to spore rather than absorbing them into myenv.
- *myenv installs and versions tools itself* — Listed as a non-goal: 'Install or version tools — Use your package manager', keeping version/install responsibility outside myenv.

**Consequences.** myenv stays a config-generation tool; orchestration/runtime lives in spore and install/version in the package manager. Note: getting-started.md mentions a `myenv run` command and TODO shows tool install commands, indicating some tension with the documented non-goals to resolve. Mined from: /home/me/git/rhizone/myenv/docs/design.md (147), /home/me/git/rhizone/myenv/docs/design.md (148), /home/me/git/rhizone/myenv/docs/design.md (149).
