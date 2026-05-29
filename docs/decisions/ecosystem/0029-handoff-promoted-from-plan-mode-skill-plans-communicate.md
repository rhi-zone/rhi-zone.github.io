# ADR-0029: Handoff promoted from plan mode to a skill; plans communicate intent, not directives

- Status: Accepted
- Date: 2026-05-29

**Context.** The handoff/plan-mode protocol was producing plans that were read as authoritative without preceding research, so "next tasks" in plans were unreliable. This is part of the AI-collaboration model spanning all repos.

**Decision.** Promote handoff to a skill (the `/handoff` command), and have handoff plans communicate intent rather than authoritative directives. Plan-mode handoff is replaced by the `/handoff` command.

**Alternatives rejected.**
- *Keep handoff in plan mode with plans listing authoritative "next tasks" / directives* — Plans were being read as authoritative without preceding research and "next tasks" were unreliable; plan mode was not ephemeral enough

**Consequences.** Handoff is now a skill; plans should express intent for the next session to investigate rather than directives to follow blindly. Already implemented per the git log. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-01-2026-04-20.md (125).
