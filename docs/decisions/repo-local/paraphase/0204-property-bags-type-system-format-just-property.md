# ADR-0204: Property bags as the type system (format is just a property)

- Status: Accepted
- Date: 2026-05-29

**Context.** Paraphase needs to represent 'what kind of data is this' to route conversions. Five models were weighed from flat strings up to bags-plus-schema, trading expressiveness against whether a 'type' is privileged.

**Decision.** Pure property bags: data is an untyped Properties map (HashMap<String, Value>), converters declare requires/produces/removes PropertyPatterns, and routing is A* state-space planning with superset goal matching. Format is just another property; schemas are an optional plugin layer.

**Alternatives rejected.**
- *Type + params (e.g. video[pixfmt=yuv411])* — The base type is privileged over its parameters; property bags treat format change, resize, and transcode uniformly as property transformations
- *Hierarchical MIME-style types (image/png)* — Only expresses grouping, cannot express parameters like width/colorspace
- *Bags + mandatory schema validation* — Validation is made an opt-in plugin instead of core, keeping the core maximally general and domain-agnostic

**Consequences.** Core knows nothing about images/video/etc. and plugins add properties without core changes; same model handles all transformations. Cost: no built-in validation without a schema plugin, conventions need discipline, and the search space can be large (mitigated by heuristics). Mined from: /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (357), /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (361), /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (410).
