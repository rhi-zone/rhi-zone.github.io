# ADR-0246: bf16 as default inference precision; f16 rejected for UNet overflow

- Status: Accepted
- Date: 2026-05-29

**Context.** Stable Diffusion UNet inference produces large intermediate values (attention Q@K^T matmul, GroupNorm variance accumulation, Linear outputs) that exceed f16's ~65504 ceiling, turning into Inf/NaN. A precision contract had to be chosen for the inference pipeline that balances memory, speed, and numerical stability.

**Decision.** bf16 is the default inference precision. f16 is supported but not default because it overflows in UNet operations without extra upcasting work that is not yet implemented; bf16 is chosen because its 8 exponent bits give it f32's dynamic range, avoiding overflow while still halving memory and matching f16 speed on Ampere+ (RTX 30xx/40xx).

**Alternatives rejected.**
- *f16 (standard float16) as the default precision* — f16's 5 exponent bits cap range at ~65504; UNet attention/GroupNorm/Linear intermediates exceed this and become Inf/NaN. Doc status table marks plain f16 and f16+flash as 'NaN issues' / overflow, and notes upcast-attention (the fix) is 'Not implemented'.
- *f32 (full precision) everywhere* — 100% memory, slowest; reserved as the 'quality' preset rather than the default because bf16 delivers near-f32 stability at 50% memory and faster speed.

**Consequences.** bf16 is the wired-up default backend (CubeBackend<CudaRuntime, bf16, i32, u32>); presets (quality/balanced/fast/memory) and cargo feature flags (precision-f32/f16/bf16, preset-fast, preset-quality) are organized around this. Making f16 viable remains open work, gated on implementing upcast-attention and upcast-matmul phases. Mined from: /home/me/git/rhizone/sketchpad/docs/precision-strategies.md (31), /home/me/git/rhizone/sketchpad/docs/precision-strategies.md (121), /home/me/git/rhizone/sketchpad/docs/precision-strategies.md (123).
