# ADR-0160: Unshape reframed from CAD-parity tool to a toolkit for any X to X operation on arbitrary media

- Status: Accepted
- Date: 2026-05-29

**Context.** Unshape entered a design-exploration phase surveying 3D CAD/NURBS prior art (Plasticity, Rhino Grasshopper, MOI, XNurbs) and was implicitly positioned as chasing CAD-parity (matching the feature set of existing CAD tools). That framing left the implementation scope open-ended and non-enumerable, and the project was stalled at exploration rather than implementation. A decision was forced on what success means for the project relative to existing CAD tools.

**Decision.** Reframe unshape as "a toolkit for any X → X operation on arbitrary media" and explicitly reject computational/feature parity with commercial CAD tools as a goal. Under this frame every capability gap is just another op, making the implementation queue enumerable and letting the parallel-delegation pattern (from Crescent's stdlib sprint) transfer directly. The graph I/O work (ConstantNode, GraphInput, GraphOutput, introspection) is the composition substrate that lets these ops compose; every other op is a leaf on that tree.

**Alternatives rejected.**
- *Target computational/feature parity with commercial CAD tools (match the feature set of existing CAD software)* — CAD-parity left scope open-ended and kept the project in design-exploration mode; unshape is positioned as a general medium-agnostic X→X transformation toolkit rather than a CAD competitor. The X→X-on-arbitrary-media frame made the implementation queue enumerable (every gap is just another op), unlocking a 20-task parallel-delegation day.

**Consequences.** Unshape's implementation surface is now defined as a set of composable X→X ops over a graph I/O substrate; capability additions are enumerable op-additions rather than CAD-feature-matching, and the roadmap is not benchmarked against commercial CAD feature sets. This drove an 18+ hour parallel session landing ~20 op subsystems and hundreds of tests in a day. Open: which ops are in scope long-term and how the graph composition model bounds them. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-01-2026-04-20.md (93), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-21-2026-04-25.md (11), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-21-2026-04-25.md (11).
