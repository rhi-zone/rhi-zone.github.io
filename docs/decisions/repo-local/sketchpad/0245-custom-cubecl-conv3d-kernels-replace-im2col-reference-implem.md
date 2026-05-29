# ADR-0245: Custom CubeCL Conv3d kernels replace im2col reference implementation

- Status: Accepted
- Date: 2026-05-29

**Context.** Video model inference (3D VAE, temporal layers) needs 3D convolution. The available reference path was im2col-based, which is O(n^3) in spatial dimensions and becomes unusably slow as tensors grow (measured 39,800x slower than the custom kernel on a small config).

**Decision.** Provide purpose-built CubeCL GPU kernels for Conv3d (a simple NCTHW kernel and an optimized vectorized NTHWC kernel) instead of relying on the im2col reference. Both are dramatically faster than im2col; the optimized NTHWC kernel is the speed-priority path (1.5-2.6x over the simple kernel) and the simple kernel is the memory-priority / non-contiguous path.

**Alternatives rejected.**
- *im2col-based reference convolution* — O(n^3) in spatial dimensions, prohibitively slow for larger tensors (e.g. 2.54s vs 63.8us on the 'small' config, ~39,800x). Unworkable for video-scale 3D conv.

**Consequences.** rhi-sketchpad-cubecl ships two kernels with a documented selection rule (layout, tensor size, speed-vs-memory). A speed/memory trade-off persists: the optimized kernel requires contiguous channels and copies (+~8MB on a sample tensor) if data is NCTHW, so memory-constrained runs use the simple kernel. Recommendation to store tensors NTHWC end-to-end to avoid conversion is an open pipeline-design lever. Mined from: /home/me/git/rhizone/sketchpad/docs/cubecl-conv3d.md (13), /home/me/git/rhizone/sketchpad/docs/cubecl-conv3d.md (45).
