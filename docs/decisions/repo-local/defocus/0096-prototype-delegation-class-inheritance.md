# ADR-0096: Prototype delegation, not class inheritance

- Status: Accepted
- Date: 2026-05-29

**Context.** defocus objects need to share behavior. The conventional OO mechanism is class inheritance with base/supertype relationships, but defocus is a runtime object-message substrate where objects are created and modified dynamically.

**Decision.** Objects delegate to an optional prototype object: when the target has no handler for a verb, resolution walks the prototype's handler table. Crucially, state modifications still apply to the target object, not the prototype. This is dynamic delegation, explicitly not inheritance and not a parent/base class relationship.

**Alternatives rejected.**
- *Class inheritance (parent class / base class / supertype)* — Inheritance binds structure statically and would apply state to the wrong entity; defocus needs runtime-dynamic behavior sharing where only handler resolution is delegated while state stays on the target object.

**Consequences.** Handler resolution walks the prototype chain at dispatch time; objects can be re-prototyped at runtime. State always belongs to the concrete object, so prototypes carry behavior only, never shared mutable state. Mined from: /home/me/git/rhizone/defocus/CONTEXT.md (43), /home/me/git/rhizone/defocus/README.md (77).
