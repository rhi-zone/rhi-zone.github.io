# ADR-0159: Crescent platform tooling is self-referential (editor is a card)

- Status: Accepted
- Date: 2026-05-29

**Context.** Crescent needed to decide whether its own authoring tools (card editor, lorebook editor, chat viewer) would be privileged native components or run as ordinary platform apps.

**Decision.** The card editor, lorebook editor, and chat viewer are themselves cards (Lua scripts) running inside the platform — a bootstrapping constraint that forces the platform's capability API to be complete enough to express its own tools.

**Alternatives rejected.**
- *Implement the editors/tooling as privileged native code outside the app/card model* — Rejected because making the tools cards forces the capability API to be expressive enough to build the platform's own tooling, guaranteeing the API is complete for third parties

**Consequences.** The capability API can never be less expressive than what the bundled tools require; any tooling feature must be reachable through caps available to ordinary cards. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-01-2026-04-20.md (119).
