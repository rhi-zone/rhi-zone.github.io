# ADR-0097: Refs are attenuable capabilities, not bare ID strings

- Status: Accepted
- Date: 2026-05-29

**Context.** Objects need to reference other objects. The simplest representation is a bare identity string. But defocus is a multi-object substrate where one object holding a reference to another should be able to grant only partial access (e.g. share read without write).

**Decision.** A Ref is a capability pointer (`Value::Ref { id, verbs }`, serialized as `{ "$ref": id, "$verbs": [...] }`) that may be attenuated to a subset of allowed verbs. Attenuation narrows a Ref and cannot be upgraded by the recipient. A Ref is therefore not a bare Identity string — it carries access permissions.

**Alternatives rejected.**
- *Bare ID strings as references* — A bare string carries no access permissions, so any holder gets full access to the target; it cannot express attenuated/least-privilege sharing, defeating capability-based security.

**Consequences.** Refs enable capability-based security: an object can hand out a verb-restricted reference that the recipient cannot widen. References and bare identity strings are distinct value kinds that must be handled separately throughout the evaluator and serializer. Mined from: /home/me/git/rhizone/defocus/CONTEXT.md (67-68), /home/me/git/rhizone/defocus/CONTEXT.md (73).
