# ADR-0093: Unified IR superset: express HTTP and FFI as types, no dedicated protocol layers

- Status: Accepted
- Date: 2026-05-29

**Context.** Concord must represent multiple API surfaces (OpenAPI HTTP APIs, C-header FFI, and future sources) in one intermediate representation. The design had to decide whether each surface gets its own special-cased layer or whether all surfaces collapse into a single shared type/function model.

**Decision.** One IR that is a superset of all surfaces, preserving all information. HTTP and FFI semantics are expressed as ordinary types, functions, and annotations (e.g. http_method/http_path/calling_convention annotations) rather than as a special HTTP or FFI layer in the model.

**Alternatives rejected.**
- *Special-cased HTTP and FFI layers/type kinds in the IR* — Would multiply special cases and fragment the model; the design instead unifies via types so the same patterns apply at every level (Uniform structure / Unify via types principles), keeping the core types unchanged as new sources are added.

**Consequences.** New sources (GraphQL, gRPC, FFI) are intended to be accommodated without changes to the core types. Surface-specific behavior must be encoded as annotations rather than new structures. Generators must interpret these annotations. Open: how/when to validate annotation kinds; how to represent streaming/async. Mined from: /home/me/git/rhizone/concord/docs/design/ir.md (3), /home/me/git/rhizone/concord/docs/design/ir.md (173), /home/me/git/rhizone/concord/docs/design/ir.md (9).
