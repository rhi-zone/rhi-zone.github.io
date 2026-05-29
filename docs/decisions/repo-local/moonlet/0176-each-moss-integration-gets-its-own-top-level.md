# ADR-0176: Each moss integration gets its own top-level Lua global, not nesting under moss.*

- Status: Accepted
- Date: 2026-05-29

**Context.** Adding moss-tools and moss-packages bindings; needed to decide the Lua namespace layout given existing integrations (llm, sessions, moss).

**Decision.** Each integration is exposed as a separate top-level Lua global (tools.*, packages.*), consistent with existing integrations, rather than nesting new modules under moss.*.

**Alternatives rejected.**
- *Nest the new bindings under the existing moss.* namespace* — Nesting under moss.* would create false coupling between independent integrations that users enable individually.

**Consequences.** All future integrations follow the independent top-level global convention; users enable only what they need; no integration's namespace implies dependence on another. Mined from: /home/me/git/rhizone/moonlet/docs/design/moss-integrations.md (130), /home/me/git/rhizone/moonlet/docs/design/moss-integrations.md (145).
