# ADR-0218: Identity is explicit in the data model; rainbow omits Unicorn's `dynamic` combinator

- Status: Accepted
- Date: 2026-05-29

**Context.** Rainbow is grounded in Unicorn, an OCaml UI library with 7 combinators whose most powerful is `dynamic` (a widget that renders a widget, putting widget instances into application state to solve the identity-vs-position problem). The port had to decide whether to replicate `dynamic`.

**Decision.** Rainbow does not include `dynamic`. Identity is made explicit in the domain model (stable IDs on records); local UI state is keyed by ID via `Signal<Map<Id, LocalState>>` composed with a lens. No widget-instance-in-state combinator exists.

**Alternatives rejected.**
- *Port Unicorn's `dynamic` combinator (widget instances as first-class state)* — Rainbow has no widget layer, so there is nothing for a `Signal<Signal<A>>` to be the way `('a t * 'a) t` is in Unicorn; and `dynamic` is a fix for implicit identity carried by widget object references, which does not arise when identity is explicit in the data model.

**Consequences.** Keyed list reordering, swapping stateful widgets, and duplication with independent state all collapse into 'make identity explicit in the domain model.' No new combinator is needed. Constrains how consumers model local state: by ID lookup, not by tree position. Mined from: /home/me/git/rhizone/rainbow/docs/design/dynamic.md (39), /home/me/git/rhizone/rainbow/docs/design/dynamic.md (27).
