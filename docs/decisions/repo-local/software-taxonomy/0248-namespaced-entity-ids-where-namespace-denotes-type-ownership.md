# ADR-0248: Namespaced entity ids where namespace denotes type, not ownership

- Status: Accepted
- Date: 2026-05-29

**Context.** Entities of many kinds (programs, classes, orgs, people, formats) share one record shape and one id space; ids must be stable, pattern-checkable, and reconcilable with third-party imports.

**Decision.** All entity ids use `<type>:<slug>` form (exactly one colon, pattern `^[a-z0-9][a-z0-9_-]*:[a-z0-9][a-z0-9_-]*$`); no bare ids. The namespace indicates type, not ownership — biology-lens kingdoms still use `class:` despite being biology-owned. Third-party imports use source-specific prefixes (`@wd:` for Wikidata).

**Alternatives rejected.**
- *Bare (un-namespaced) ids* — Explicitly disallowed — 'No bare ids, no double colons'; namespacing gives type-checkable, collision-resistant ids across a shared id space
- *Namespace by owning lens* — Rejected: namespace indicates type not ownership, so biology-owned class entities still use the `class:` namespace

**Consequences.** Validator enforces the id pattern strictly. Reserves source-prefix namespaces (`@wd:`) for the Wikidata reconciliation in phase 5. Type is read off the id namespace. Mined from: /home/me/git/pterror/software-taxonomy/CLAUDE.md (36), /home/me/git/pterror/software-taxonomy/CLAUDE.md (56).
