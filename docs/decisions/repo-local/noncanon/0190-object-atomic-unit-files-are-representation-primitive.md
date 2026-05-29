# ADR-0190: Object is the atomic unit; files are representation, not the primitive

- Status: Accepted
- Date: 2026-05-29

**Context.** Because noncanon wraps git, the on-filesystem unit (a file) is the obvious candidate for the atomic unit of canon. The design had to decide whether the file IS the primitive or merely how a more abstract unit is stored.

**Decision.** The atomic unit is the object; files are the on-filesystem representation of objects, not the primitive itself.

**Alternatives rejected.**
- *Treat the file as the atomic primitive* — It would conflate the on-disk serialization with the conceptual unit of canon; the design instead keeps the object as the primitive so files are just its representation.

**Consequences.** The core data model is defined in terms of world and object; file layout is an implementation detail that can change without changing the primitive. Pulling, referencing, and divergence operate over objects. Mined from: /home/me/git/exoplace/noncanon/TODO.md (5).
