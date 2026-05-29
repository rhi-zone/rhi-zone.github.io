# ADR-0232: commonmark-fmt wraps pulldown-cmark; superseding it is a non-goal

- Status: Accepted
- Date: 2026-05-29

**Context.** CommonMark could be implemented as a native hand-rolled parser like the other formats, or by wrapping the de facto Rust CommonMark library pulldown-cmark.

**Decision.** commonmark-fmt wraps pulldown-cmark for the events()/parse() paths; its StreamingParser buffers all chunks and runs pulldown on the complete input, and explicitly does not aim to supersede pulldown-cmark — callers needing true chunked CommonMark streaming should use pulldown-cmark directly or wait for a future native parser.

**Alternatives rejected.**
- *Write a native hand-rolled CommonMark parser matching the full three-API streaming architecture now* — pulldown-cmark has 77M+ weekly downloads and is the de facto ecosystem parser; the crate's value is a consistent API surface, spans, diagnostics, and ecosystem compatibility, not beating pulldown on streaming performance.

**Consequences.** commonmark-fmt's StreamingParser is not at max performance and this is documented in the crate doc comment; true chunked CommonMark streaming remains a future-native-parser option. Accepts a known limitation rather than reimplementing a mature parser. Mined from: /home/me/git/rhizone/rescribe/docs/format-library-design.md (234), /home/me/git/rhizone/rescribe/docs/format-library-design.md (225-226).
