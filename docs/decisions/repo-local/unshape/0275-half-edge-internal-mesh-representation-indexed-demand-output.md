# ADR-0275: Half-edge as internal mesh representation, indexed on demand for output

- Status: Accepted
- Date: 2026-05-29

**Context.** The engine needed a single internal mesh data structure. Indexed meshes are compact and match GPU/file-format expectations but make topology queries O(n); half-edge gives O(1) adjacency but costs ~3-4x memory and must be converted for GPU upload. Subdivision, bevel, and other topology operations are core to a procedural-generation engine.

**Decision.** Use half-edge as the internal representation (assuming manifold), accept the ~3-4x memory cost for topology benefits, and convert to indexed on demand for export/GPU. Keep ngons internally and triangulate only on export. Detect non-manifold geometry on import and apply an explicit NonManifoldFix strategy; maintain the manifold invariant during operations.

**Alternatives rejected.**
- *Indexed mesh as the internal structure* — Topology queries (which faces share this edge, walk around vertex) are O(n) and require rebuilding adjacency each time, which is unacceptable for core topology ops like subdivision and bevel

**Consequences.** Topology operations are natural and O(1); memory use is higher and many-mesh / high-poly / WASM-mobile scenarios pay for it. Conversion to indexed is required at every export/GPU boundary. Incremental indexed update is explicitly not done (full rebuild). Open: half-edge compression, parallel construction, attribute storage location, boundary representation. Mined from: /home/me/git/rhizone/unshape/docs/design/mesh-representation.md (106), /home/me/git/rhizone/unshape/docs/design/mesh-representation.md (319), /home/me/git/rhizone/unshape/docs/design/mesh-representation.md (323).
