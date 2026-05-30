# ADR-0038: Evaluation-based parsing: delegate manifest parsing to the language runtime

- Status: Accepted
- Date: 2026-05-29

**Context.** Extracting data from manifest formats (Cargo.toml, package.json, go.mod, requirements.txt) appeared to require writing and maintaining tree-sitter grammars for each format.

**Decision.** When a language already has a runtime that understands its own formats, parse by evaluation rather than by structural parsing: write a script in the target language that evaluates the manifest and outputs JSON, sidestepping per-format grammars. The principle generalizes beyond manifests — delegate parsing to the runtime rather than reimplementing it.

**Alternatives rejected.**
- *Write tree-sitter grammars (structural parsers) for every manifest format* — Fighting tree-sitter for every format is unnecessary complexity when the goal is data extraction; letting the runtime do the work is simpler and reuses the language's own understanding of its formats.

**Consequences.** Manifest parsing infrastructure built on evaluation strategy; establishes a reusable technical pattern for format-data extraction across the pipeline layer. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar4.md (145).
