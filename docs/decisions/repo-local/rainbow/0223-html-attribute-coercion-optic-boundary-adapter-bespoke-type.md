# ADR-0223: HTML attribute coercion is an Optic boundary adapter, not a bespoke type-tag system

- Status: Accepted
- Date: 2026-05-29

**Context.** The original `defineElement` design coerced attributes via string tags ("string", "number", "boolean", "json"). This was revised in April 2026.

**Decision.** Attributes are a boundary adapter modeled as `Optic<string | null, T[K]>` (view = parse, review = serialize). The bespoke string-tag type system is replaced. `AttrSchema<T>` is a record of such optics; `attrsFrom(defaults)` auto-derives them for primitive fields.

**Alternatives rejected.**
- *String type-tags for attribute coercion ("string", "number", "boolean", "json")* — They are a bespoke type system that doesn't compose with the rest of the optics toolkit; the Optic framing generalizes to URL search params, localStorage, and form submissions (stringly-typed external world -> typed internal signal).

**Consequences.** Attribute coercion now composes with the optics toolkit and the framing reaches across URL params, localStorage, form submissions. Standard attribute optics (attrString/attrNumber/attrBoolean/attrJson) live in `@rhi-zone/rainbow-ui/elements`. All `T` fields get JS property accessors regardless of `attrs`; `attrs` only controls HTML-attribute observability. Mined from: /home/me/git/rhizone/rainbow/docs/design/ui-elements.md (18-19), /home/me/git/rhizone/rainbow/docs/design/ui-elements.md (22).
