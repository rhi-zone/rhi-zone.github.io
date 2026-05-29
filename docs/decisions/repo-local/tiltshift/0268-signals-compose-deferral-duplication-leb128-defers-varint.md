# ADR-0268: Signals compose by deferral, not duplication (LEB128 defers to VarInt)

- Status: Accepted
- Date: 2026-05-29

**Context.** The BytecodeStream signal needs to handle LEB128-encoded operands. It could re-implement variable-length integer decoding internally, but a separate VarInt signal already detects that encoding.

**Decision.** When the VarInt signal fires in the same region, BytecodeStream treats it as an encoding hint and adjusts operand-width estimation, rather than re-implementing LEB128 decoding. Signals defer to one another instead of duplicating capability.

**Alternatives rejected.**
- *Re-implement LEB128 decoding inside BytecodeStream* — "It does not re-implement LEB128 decoding." Duplicating the VarInt capability would diverge and bloat the signal; deferral keeps each signal single-responsibility.

**Consequences.** Establishes a composition pattern where signals consume each other's outputs as hints. New signals should check for and defer to existing ones rather than duplicating detection logic. Mined from: /home/me/git/rhizone/tiltshift/DESIGN.md (153).
