# ADR-0237: Format roundtrip guarantee is tiered, not uniform

- Status: Accepted
- Date: 2026-05-29

**Context.** A document conversion library could promise uniform lossless roundtrip for every supported format. But document programming languages (Typst, LaTeX) and extract-only formats (PDF, XLSX, bibliographic) cannot honestly meet that promise.

**Decision.** Classify formats into three tiers — Tier 1 (full bidirectional roundtrip), Tier 2 (write-primary, reader extracts static authored content only and must fire fidelity warnings for skipped programmatic constructs), Tier 3 (read/extract-only, no roundtrip guarantee) — with each crate declaring its tier in lib.rs and the tier determining the required fixture suite.

**Alternatives rejected.**
- *A single uniform roundtrip guarantee across all formats* — Document programming languages cannot recover programmatically generated content without executing their runtime, and extract-only/structurally-lossy formats make a roundtrip guarantee meaningless; a uniform promise would be dishonest.

**Consequences.** Tier dictates fixture requirements: Tier 1 proves bidirectional roundtrip, Tier 2 proves static-subset coverage plus fidelity-warning assertions, Tier 3 proves extraction only. Full execution of Typst/LaTeX is explicitly out of scope. Mined from: /home/me/git/rhizone/rescribe/docs/format-tiers.md (3-4), /home/me/git/rhizone/rescribe/docs/format-tiers.md (58).
