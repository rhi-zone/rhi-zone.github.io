# ADR-0177: Missing external tools surface as Lua errors, not status fields

- Status: Accepted
- Date: 2026-05-29

**Context.** moss-tools runs external binaries (linters, test runners) that may not be installed; needed a convention for how absence is reported to Lua callers.

**Decision.** When a tool is not available, the binding raises a Lua error (caught via pcall), rather than returning a result struct with an availability field.

**Alternatives rejected.**
- *Return a value such as {available = false} that callers inspect* — Would force callers to check a field on every call; errors are the idiomatic Lua mechanism.

**Consequences.** All tool/test bindings raise errors on unavailability; explicit is_available() exists for pre-checks; callers use pcall for failure handling. Mined from: /home/me/git/rhizone/moonlet/docs/design/moss-integrations.md (171), /home/me/git/rhizone/moonlet/docs/design/moss-integrations.md (186).
