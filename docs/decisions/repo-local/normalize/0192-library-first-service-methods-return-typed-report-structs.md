# ADR-0192: Library-first: service methods return typed Report structs, never String; CLI/JSON/MCP/HTTP are generated

- Status: Accepted
- Date: 2026-05-29

**Context.** Every command needs output across multiple surfaces (text, JSON, JSONL, jq, MCP, HTTP, JSON Schema). The data layer could either emit ad-hoc strings/print-loops per command, or return a typed structure from which all surfaces are derived.

**Decision.** normalize is 'an API that happens to have a CLI'. Every command flows: data extraction layer -> typed Report struct (deriving Serialize + JsonSchema) -> OutputFormatter / server-less. Service methods return Result<SomeReport, String>; --json/--jsonl/--jq come from serde and the generated #[cli] layer for free. Design the Report struct before designing CLI flags.

**Alternatives rejected.**
- *Return String / let the print loop define the output* — Returning String from a service method is almost always wrong; if the underlying data is 'whatever the print loop emits', you lose free JSON, JSONL, jq filtering, and JSON Schema introspection, and the MCP/HTTP surfaces can't be generated. Listed explicitly as an anti-pattern.

**Consequences.** All public output structs end in Report (ViewReport, DocsReport, CiReport), implement OutputFormatter, and are compile-time checked via assert_output_formatter. JSON/jq support must never be added ad-hoc. The main normalize crate owns no domain logic; it only mounts sub-services. Mined from: /home/me/git/rhizone/normalize/ARCHITECTURE.md (56), /home/me/git/rhizone/normalize/ARCHITECTURE.md (68-69), /home/me/git/rhizone/normalize/ARCHITECTURE.md (64-65).
