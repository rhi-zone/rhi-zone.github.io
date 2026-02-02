# Unshape

**Constructive media generation in Rust.**

::: info Status: Potentially Mature ●
~144K lines of Rust across 44 crates covering 13+ media generation domains (meshes, audio, textures, noise, physics, fluid sim, animation, voxels, point clouds). 750+ tests, comprehensive documentation. Production-grade for offline generation; GPU compute backend partially designed but not yet integrated.
:::

Unshape provides composable primitives for procedural generation of meshes, audio, textures, vector graphics, and skeletal animation.

## Domains

| Domain | Crates | Capabilities |
|--------|--------|--------------|
| **3D Geometry** | mesh, gltf, pointcloud, voxel, spline, curve, surface | Primitives, booleans, subdivision, LOD, NURBS |
| **Audio** | audio, spectral | FM/wavetable/granular synthesis, FFT, 3D HRTF, time-stretch |
| **2D Vector** | vector | SVG paths, bezier, boolean ops, gradients, hatching |
| **Image** | image, color | Convolution, color grading, normal maps, pyramids |
| **Animation** | rig, motion, motion-fn, easing | Skeleton IK, motion graphics, 31 easing functions |
| **Physics** | physics, spring, particle, fluid | Rigid/soft body, cloth, SPH fluids |
| **Procgen** | noise, automata, procgen, lsystem, rd, space-colonization | Noise, WFC, mazes, L-systems, reaction-diffusion |
| **Core** | core, op, field, geometry, transform, spatial | Node graphs, lazy fields, 9 spatial structures |

## Philosophy

Unshape treats media as data structures that can be composed, transformed, and evaluated lazily. Rather than imperative drawing commands, you build up descriptions that are rendered on demand.

**Ops as values** - Every operation is a serializable struct first, enabling project files, undo/redo, and node graphs.

## Related projects

- [Wick](/projects/wick) - Expression language for shader and procedural expressions

## Links

- [GitHub](https://github.com/rhi-zone/unshape)
- [Documentation](https://rhi.zone/unshape/)
