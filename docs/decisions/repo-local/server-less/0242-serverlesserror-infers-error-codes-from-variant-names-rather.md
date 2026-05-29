# ADR-0242: ServerlessError infers error codes from variant names rather than requiring explicit annotation

- Status: Accepted
- Date: 2026-05-29

**Context.** Every error type must map to HTTP status, gRPC codes, CLI exit codes, etc. before any protocol derive can handle Result<T,E>. Doing this by hand is boilerplate on every variant.

**Decision.** #[derive(ServerlessError)] infers the ErrorCode from each variant name via ErrorCode::infer_from_name, checking the lowercased name for known substrings in priority order; explicit #[error(code = ...)] (named or numeric HTTP status) is available only for unusual names. The single protocol-agnostic ErrorCode is then mapped per-protocol.

**Alternatives rejected.**
- *Explicit-only: a required trait with no inference where every variant must be annotated with #[error(code = ...)]* — It is consistent and never surprising, but tedious for the common case where the variant name is self-documenting; inference handles that case without ceremony, and the cases where inference is wrong are exactly the unusual names where you'd reach for the explicit override anyway.

**Consequences.** Error codes are inferred broadly (UserNotFound, FileNotFound, ResourceMissing all -> NotFound); unmatched names fall back to Internal/500. The inference substring table is now a contract authors rely on. ErrorCode stays protocol-agnostic; each protocol derive converts it (http_status, grpc_code, exit_code). Mined from: /home/me/git/rhizone/server-less/docs/design/error-mapping.md (164), /home/me/git/rhizone/server-less/docs/design/error-mapping.md (179), /home/me/git/rhizone/server-less/docs/design/error-mapping.md (185).
