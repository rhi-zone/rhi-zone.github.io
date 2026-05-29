# ADR-0059: Cost/scoring expressions use Dew (rhizome shared expression language)

- Status: Accepted
- Date: 2026-05-29

**Context.** When multiple conversion paths exist, converters declare costs as properties and users provide scoring expressions to pick a path. The expression syntax should be consistent across the rhizome ecosystem rather than bespoke to paraphase.

**Decision.** Adopt Dew (the rhizome minimal expression language for procedural generation) for cost/scoring expressions, likely depending only on dew-core + dew-scalar; each domain crate carries self-contained wgsl/lua/cranelift backends as features. For the MVP, expression evaluation is deferred in favor of --optimize quality|speed|size.

**Alternatives rejected.**
- *A paraphase-specific bespoke expression syntax* — The syntax should be consistent across the rhizome ecosystem, so the shared Dew language is reused instead of inventing a new one

**Consequences.** Cost-scoring syntax is shared with the rest of the rhizome ecosystem via Dew; paraphase takes a dependency on dew-core/dew-scalar when expressions land. Full expression support is post-MVP; MVP ships fixed --optimize presets. Mined from: /home/me/git/rhizone/paraphase/docs/open-questions.md (140), /home/me/git/rhizone/paraphase/docs/open-questions.md (138).
