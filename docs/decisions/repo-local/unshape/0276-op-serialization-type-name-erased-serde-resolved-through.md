# ADR-0276: Op serialization via type_name + erased_serde, resolved through a registry

- Status: Accepted
- Date: 2026-05-29

**Context.** Graph nodes hold ops as Box<dyn MeshOp> (and similar), which erases concrete type information. To serialize and deserialize a graph the concrete op type must be recoverable from data.

**Decision.** Each op trait requires a type_name() returning a unique string identifier (e.g. "unshape::mesh::Subdivide") and uses erased_serde for serialization. Graph nodes serialize as { type, params }. Deserialization goes through an OpRegistry that maps type names to deserialize functions; an unregistered type name fails with a clear UnknownOp error.

**Alternatives rejected.**
- *Rely on Box<dyn MeshOp> alone* — Box<dyn MeshOp> loses concrete type info, so there is no way to recover the type name needed for serialization

**Consequences.** Ops are round-trippable to JSON/MessagePack; graphs reference ops by stable string type names. Adding an op requires registering it. Static linking can use typetag; dynamic hosts register explicitly. Type name strings become a stable contract that serialized graphs depend on. Mined from: /home/me/git/rhizone/unshape/docs/design/plugin-architecture.md (48), /home/me/git/rhizone/unshape/docs/design/plugin-architecture.md (50).
