# ADR-0109: Optimizer is a name-agnostic tree-automaton rule engine running once before backends

- Status: Accepted
- Date: 2026-05-29

**Context.** Standard-library functions (map/filter/reduce) are defined as ordinary recursive Marinada code, not builtins. To make them as fast as native loops, the system must optimize them — either by recognizing them by name, or by recognizing their structure.

**Decision.** The optimizer is a tree automaton rule engine indexed by root op, applied bottom-up to a fixed point. Rules fire on structural patterns with no privileged names; a user-written recursive function structurally matching a known pattern is optimized identically to the lib:std version. It runs once at load time, before any backend, producing one normalized AST all backends execute.

**Alternatives rejected.**
- *Recognize standard functions by name / special-case lib:std* — Rejected — there are no privileged names; structural matching means user-defined functions get the same optimizations and no special-casing leaks into the core
- *Per-backend pattern recognition (each JIT/interpreter optimizes itself)* — Rejected — the optimizer is backend-agnostic and runs once; backends do not perform pattern recognition, so interpreter backends benefit equally

**Consequences.** Interpreter and JIT backends share optimization work. TCO normalization to __loop is the key step that gives all loops one canonical form for pattern recognition into __native nodes. Optimization cost is paid once at load, not per call. Mined from: /home/me/git/rhizone/dusklight/docs/marinada.md (326), /home/me/git/rhizone/dusklight/docs/marinada.md (338).
