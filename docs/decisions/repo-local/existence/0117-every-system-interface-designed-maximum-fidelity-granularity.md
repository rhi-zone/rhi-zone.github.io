# ADR-0117: Every system is an interface designed for maximum fidelity; granularity is fixed per-run

- Status: Accepted
- Date: 2026-05-29

**Context.** Subsystems (neurochemistry, clothing, finances) get built at varying fidelity over time, and runs created at different points must keep loading. Coupling content/prose to a current implementation would make every fidelity upgrade a breaking change.

**Decision.** Each system exposes a stable interface designed for the fullest possible fidelity; simpler implementations only approximate within that contract and never constrain it downward. Implementation fidelity is fixed at run creation (stored per-subsystem in the RunRecord) and never changes mid-run; the engine hotswaps implementations between saves. A simpler implementation is a legitimate permanent choice for a run.

**Alternatives rejected.**
- *Design interfaces to current/coarse fidelity and let implementations evolve freely* — You can write a fuller implementation behind a high-fidelity interface, but you can never add fidelity to a coarse interface without breaking everything that talks to it; coarse-first interfaces foreclose deepening.
- *Let granularity change mid-run as systems improve* — Mid-run granularity changes would break load/replay correctness across saves; fixing fidelity at run creation keeps every run reproducible forever.

**Consequences.** New systems must be interface-designed for full fidelity before any implementation is written. RunRecord stores subsystem versions; old saves get legacy stubs. Coarse implementations are permanent run choices, not placeholders to be force-upgraded. Mined from: /home/me/git/paragarden/existence/docs/design/philosophy.md (19), /home/me/git/paragarden/existence/docs/design/philosophy.md (29).
