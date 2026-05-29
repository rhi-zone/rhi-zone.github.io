# ADR-0166: Delegate async runtime to the consumer in server-less

- Status: Accepted
- Date: 2026-05-29

**Context.** server-less 0.3.0 added async CLI entrypoints, forcing a decision about how the library handles the async runtime: own/bundle one or rely on the consumer's.

**Decision.** server-less delegates the async runtime choice to the consumer via a feature-gated tokio dependency, and emits helpful errors when tokio is absent rather than bundling or mandating a runtime.

**Alternatives rejected.**
- *Bundle/mandate a specific async runtime inside server-less* — Would couple consumers to the library's runtime choice; delegating to the consumer and emitting helpful errors when tokio is absent keeps the library runtime-agnostic.

**Consequences.** server-less stays runtime-agnostic; async entrypoints (cli_run_async, cli_run_with_async) are feature-gated on tokio; consumers control runtime selection and get diagnostic errors when the runtime is missing. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar5-mar9.md (68).
