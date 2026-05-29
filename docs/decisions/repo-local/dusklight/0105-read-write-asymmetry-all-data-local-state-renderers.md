# ADR-0105: No read/write asymmetry: all data is local state, renderers receive a ReactiveLens

- Status: Accepted
- Date: 2026-05-29

**Context.** A UI client for arbitrary sources must decide how renderers relate to data. The conventional split treats remote/source data as read-only and mutations as a separate write path with its own asymmetry.

**Decision.** Everything is data and functions over data; there is no fundamental read/write asymmetry. All source data becomes local state — always locally owned and always writable. Every renderer receives a ReactiveLens<S, A> with a valid write side (read-only = no-op write). Lens writes update local state; actions via capability propagate changes to the world. These are distinct paths.

**Alternatives rejected.**
- *Read-only renderers for source data with a separate, asymmetric mutation/write path* — Rejected as a false dichotomy — treating all data as local writable state removes the read/write asymmetry; the source merely synchronizes, while in memory data is always writable

**Consequences.** A form input writes through a lens; a POST button invokes a Marinada action via capability. Read-only renderers simply get a no-op write side. The reactive lens at a leaf is the composition of all optics from the layout-tree root down. Mined from: /home/me/git/rhizone/dusklight/docs/architecture.md (101), /home/me/git/rhizone/dusklight/docs/architecture.md (11).
