# ADR-0005: Implementation tiers are independent complete implementations selected at load time, not runtime fallbacks

- Status: Accepted
- Date: 2026-05-29

**Context.** Many libraries can be implemented at multiple levels (system library > FFI > pure Lua) with different performance. A model was needed for how these coexist: whether they wrap each other, switch at runtime, and which is canonical.

**Decision.** When multiple tiers exist, the best available tier is selected once at load time via pcall (no runtime switching). Each tier is a real, independent, standalone implementation — not a wrapper around a lower tier. The pure Lua tier must exist before any FFI tier is added and is the correctness reference. Parity tests assert byte-for-byte identical output across tiers. M._tier exposes the selected tier for introspection. The term 'tier' is mandated over 'fallback' precisely because lower tiers are complete, not incomplete approximations.

**Alternatives rejected.**
- *Treat lower levels as 'fallbacks' — wrappers/approximations around a faster tier, possibly switched at runtime* — Confusing 'tier' with 'fallback' implies lower tiers are incomplete approximations; they are not. Wrapping one tier around another and runtime switching are explicitly forbidden.

**Consequences.** Every tiered library must ship a complete pure-Lua reference before adding FFI; parity tests are mandatory; no runtime tier-switching code paths. Adds implementation cost (full reimplementation per tier) in exchange for a guaranteed correctness reference and air-gap-safe degradation. Mined from: /home/me/git/rhizone/crescent/docs/conventions.md (67-68), /home/me/git/rhizone/crescent/docs/conventions.md (71-72), /home/me/git/rhizone/crescent/CONTEXT.md (10).
