# ADR-0074: Semantic-neutral core; all meaning lives in declarative world packs

- Status: Accepted
- Date: 2026-05-29

**Context.** Aspect needs to support many different worlds (rooms-and-items, social, survival) from the same graph primitives. If the core engine knew about 'room', 'item', or 'wear', every new world genre would require core code changes, and the engine would be coupled to one game's vocabulary.

**Decision.** Core stores only cards, edges, patches, and events and never hardcodes any semantic category. All semantics (kinds, edge types, actions, rules, UI hints) are supplied by portable declarative world packs loaded and interpreted at runtime. Different world packs produce different experiences from the same graph.

**Alternatives rejected.**
- *Bake semantic categories (room, item, wear) into the core engine* — Couples the substrate to one interpretation; the doc states semantic neutrality is 'a design constraint, not an accident' and that core 'provides structure without imposing interpretation', so a fixed vocabulary in core is explicitly disallowed

**Consequences.** Core code may never reference 'room', 'item', or 'wear'. New world genres ship as data, not code. World packs become the unit of distribution. Constrains all future feature work to respect the layering: lower layers never depend on upper ones. Mined from: /home/me/git/exoplace/aspect/docs/design/architecture.md (9), /home/me/git/exoplace/aspect/docs/design/architecture.md (87).
