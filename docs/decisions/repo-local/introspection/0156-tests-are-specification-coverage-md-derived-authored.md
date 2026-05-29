# ADR-0156: Tests are the specification; COVERAGE.md is derived, not authored

- Status: Accepted
- Date: 2026-05-29

**Context.** Rescribe's fixture coverage expansion needed a model for how format support is documented and tracked across 24 formats. The conventional approach would be to hand-author documentation describing what each format parser supports.

**Decision.** Invert documentation: tests (fixtures) are the specification, and COVERAGE.md is derived from fixture existence rather than hand-written. Parser limitations (e.g. RST: no tables, dropped footnote refs) are made explicit and testable rather than silently broken.

**Alternatives rejected.**
- *Hand-author documentation as the source of truth describing each parser's supported features* — Hand-written docs drift from reality and let limitations be silently broken; deriving coverage from fixtures keeps the spec grounded in what is actually tested.

**Consequences.** Coverage docs cannot claim support that lacks a fixture; format limitations become explicit and testable. The 24-format coverage audit is reproducible via parallel agent dispatch over fixtures. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-28-2026-03-31.md (43).
