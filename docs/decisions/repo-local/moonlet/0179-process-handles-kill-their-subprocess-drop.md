# ADR-0179: Process handles kill their subprocess on drop

- Status: Accepted
- Date: 2026-05-29

**Context.** Streaming handles wrap live subprocesses; needed a lifecycle policy for what happens when a handle is garbage-collected without explicit completion.

**Decision.** A handle kills its subprocess when the handle is dropped, ensuring explicit cleanup and no orphan processes (with a possible future opt-out detach()).

**Alternatives rejected.**
- *Let the subprocess continue running after the handle is dropped* — Would leave orphan processes; killing on drop gives explicit cleanup.

**Consequences.** Handle Drop impl calls kill(); detaching is a deferred low-priority future addition; scripts cannot accidentally leak background processes. Mined from: /home/me/git/rhizone/moonlet/docs/design/moss-integrations.md (526).
