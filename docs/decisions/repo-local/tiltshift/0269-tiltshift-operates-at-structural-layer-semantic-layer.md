# ADR-0269: tiltshift operates at the structural layer, not the semantic layer

- Status: Accepted
- Date: 2026-05-29

**Context.** A binary analysis tool could attempt to recover meaning (what data means, application logic, disassembly/decompilation). The team had to decide how far up the abstraction stack tiltshift reaches, given that disassembly is already served by mature tooling.

**Decision.** Bound tiltshift to the structural layer: field boundaries, encoding detection, chunk structure, anomaly detection, embedded format detection. Semantic concerns (meaning, application logic, disassembly/decompilation, cryptographic analysis, stego payload solving) are explicitly out of scope.

**Alternatives rejected.**
- *Include disassembly / decompilation* — "that's a well-solved problem with mature tools (Ghidra, Binary Ninja, IDA)" — no value in re-solving it
- *Solve steganography payloads* — solving stego "requires decoding the container format first — that's a different layer"; detection is kept as a byproduct but solving is excluded

**Consequences.** tiltshift's API surface, signal taxonomy, and integration points (paraphase, reincarnate, rescribe) are all framed as structure-only. Semantic interpretation is delegated to downstream tools. The boundary forecloses feature creep toward disassembly. Mined from: /home/me/git/rhizone/tiltshift/DESIGN.md (23), /home/me/git/rhizone/tiltshift/DESIGN.md (35), /home/me/git/rhizone/tiltshift/DESIGN.md (33).
