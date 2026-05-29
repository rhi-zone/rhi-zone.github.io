# ADR-0202: Named ports with per-port cardinality (cardinality orthogonal to property patterns)

- Status: Accepted
- Date: 2026-05-29

**Context.** Paraphase must handle 1→1, 1→N, N→1, and N→M conversions. Early designs encoded cardinality inside PropertyPattern (a $each syntax or a separate Cardinality enum), which coupled 'what kind of data' with 'how many' and felt awkward.

**Decision.** Converters declare named input/output ports, each a PortDecl { pattern, list: bool }, inspired by ComfyUI. Cardinality lives on the port (list flag), orthogonal to the property pattern; planning infers cardinality from source (glob vs file) and target and tracks it through the graph via fixed transformation rules.

**Alternatives rejected.**
- *Encoding cardinality inside PropertyPattern ($each syntax / separate Cardinality enum)* — It coupled the orthogonal concerns of data-kind and count and felt awkward; named ports separate patterns (what) from cardinality (how many)

**Consequences.** Multi-output converters expose named ports referenced unambiguously in workflows (step.output_name); sidecars/manifests/spritesheets need no special cases. Cost: slightly more verbose converter declarations and workflow wiring must use port references for multi-output. Mined from: /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (508), /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (504), /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (525).
