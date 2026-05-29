# ADR-0025: Project-specific agent context injected per-session via `normalize context --condition`, never global CLAUDE.md

- Status: Accepted
- Date: 2026-05-29

**Context.** A private project's codename ("private-recipient-a") leaked into version control. The agent proposed adding a rename/redaction rule to the global CLAUDE.md to handle it. This forced a decision about WHERE project-specific context (rename/redaction rules) may live: in shared/global config, or per-session only. The user rejected the global rule because it pollutes every agent on the machine with project-specific context that does not belong to them.

**Decision.** Project-specific context (such as codename rename/redaction rules for private projects) must be injected per-session via `normalize context --condition <project>`, NOT placed in global CLAUDE.md or any shared config. Shared/global config must not carry project-specific or codenamed context at all.

**Alternatives rejected.**
- *Add a project-specific rename/redaction rule to global CLAUDE.md* — "global means it pollutes all other agents on this machine" — context poisoning; a global rule contaminates every unrelated agent/project session, so per-session conditioning was mandated instead

**Consequences.** Establishes a hard boundary: shared/global config carries no project-specific context; redaction/rename is conditioned per session via `normalize context --condition <project-name>` (used for private-recipient-a and similar private projects). Establishes the broader norm that agents must not modify shared infrastructure to carry per-project state. This is upstream of the durable org-mapping note that raw data/corpora live on the personal account rather than in shared org config. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-05-10.md (43), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-05-10.md (80), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-05-10-2026-05-29.md (143).
