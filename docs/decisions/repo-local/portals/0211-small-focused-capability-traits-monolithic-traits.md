# ADR-0211: Small focused capability traits over monolithic traits

- Status: Accepted
- Date: 2026-05-29

**Context.** A store-like interface could be one big trait with all operations, or several small traits split by capability (since not all backends support all operations, e.g. atomic CAS).

**Decision.** Prefer small, focused traits split by capability rather than by object; use supertraits (extension traits) for enhanced versions (e.g. AtomicKeyValue: KeyValue).

**Alternatives rejected.**
- *Monolithic trait bundling all operations (e.g. a Store with get/set/atomic_cas together)* — Not all stores support every operation (e.g. atomic compare-and-swap), so a monolithic trait forces implementors to support capabilities they lack.

**Consequences.** Capabilities are separable and composed via supertraits; backends implement only the traits matching their real capabilities. Constrains how future interfaces are decomposed. Mined from: /home/me/git/rhizone/portals/DESIGN.md (201), /home/me/git/rhizone/portals/DESIGN.md (212).
