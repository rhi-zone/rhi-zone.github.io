# ADR-0178: Parallel execution via explicit handles and poll, no hidden global scheduler

- Status: Accepted
- Date: 2026-05-29

**Context.** Running multiple tools/tests concurrently from Lua needs a concurrency model; needed to decide between an implicit scheduler and explicit handle values.

**Decision.** Concurrency is expressed with explicit handle values plus a pure poll function (moonlet.poll over handles); there is no hidden global scheduler state.

**Alternatives rejected.**
- *A global scheduler/runtime that tracks running tasks implicitly* — Hidden global state is rejected; handles are explicit values and poll is a pure function over them.

**Consequences.** Async API is built on user-held handles; poll/any_running/wait_all operate over handle arrays; no global async state to reason about or leak. Mined from: /home/me/git/rhizone/moonlet/docs/design/moss-integrations.md (210), /home/me/git/rhizone/moonlet/docs/design/moss-integrations.md (229).
