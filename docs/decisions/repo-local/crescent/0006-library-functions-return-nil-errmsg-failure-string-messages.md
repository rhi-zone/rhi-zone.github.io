# ADR-0006: Library functions return (nil, errmsg) on failure with string messages, never error objects/codes

- Status: Accepted
- Date: 2026-05-29

**Context.** Every lib/ library needs a uniform error-handling contract so libraries compose without glue code. A choice was needed between exceptions, error objects/codes, and value-based error returns.

**Decision.** Library functions return the value on success and (nil, errmsg) on failure, where errmsg is a human-readable string — no error objects, no error codes. Libraries never throw except for programming errors (wrong argument type, nil where disallowed); data errors are not programming errors. If callers must distinguish error kinds, the function gets variants rather than structured error types. A raw/unwrapped variant may throw but must be named _raw and documented; the public API always returns (nil, errmsg).

**Alternatives rejected.**
- *Throw exceptions for data errors, or return structured error objects / error codes* — Throwing on data errors and structured error objects/codes break uniform composability across libraries; the contract mandates string messages and variant functions instead of error kinds.

**Consequences.** Callers can rely on a single error-return shape across every library; error kinds are expressed via function variants and human-readable strings; throwing is reserved strictly for programming errors. Forecloses introducing an error-object/error-code type into public library APIs. Mined from: /home/me/git/rhizone/crescent/docs/conventions.md (17-18), /home/me/git/rhizone/crescent/docs/conventions.md (15-16).
