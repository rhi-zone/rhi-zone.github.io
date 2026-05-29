# ADR-0106: Renderer dispatch is heuristic/multi-valued, distinct from Marinada's exact match

- Status: Accepted
- Date: 2026-05-29

**Context.** Dusklight must pick a renderer for recognized data. It could reuse Marinada's exact, exhaustive, deterministic match mechanism, or treat renderer selection as a separate, fuzzier concern.

**Decision.** Patterns are Marinada predicates returning a confidence score (float 0–1 or null). The dispatch layer ranks all results and presents a ranked candidate list the user can switch between, with persisted preferences. This is deliberately distinct from Marinada's match, which is exact, exhaustive, and deterministic.

**Alternatives rejected.**
- *Use Marinada's exact/exhaustive/deterministic match for renderer selection* — Rejected — UI renderer selection is inherently heuristic and multi-valued (e.g. Milkdown, Prosemirror, and raw JSON are all valid for markdown), so a single deterministic answer is wrong for this layer

**Consequences.** Multiple renderers can be valid for the same data; the user chooses and preferences persist. Patterns may be structural, heuristic, semantic, or schema-derived. The deterministic match remains reserved for DU dispatch and exhaustiveness checking. Mined from: /home/me/git/rhizone/dusklight/docs/architecture.md (83).
