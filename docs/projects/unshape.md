# Unshape

**Constructive media generation in Rust.**

Unshape provides composable primitives for procedural generation of meshes, audio, textures, vector graphics, and skeletal animation.

## Key Features

- **Meshes** - Procedural 3D geometry with primitives, deformation, and indexed mesh representation
- **Audio** - Synthesis oscillators (sine, saw, square, triangle) with anti-aliasing
- **Textures & Noise** - Lazy Field trait with Perlin, Simplex, fBm and composable combinators
- **2D Vector** - SVG-like paths with bezier curves, shapes, and boolean operations
- **Rigging** - Skeletal animation with bones, poses, and GPU-friendly skinning weights
- **Node Graphs** - Dynamic evaluation with type-safe connections and topological execution

## Philosophy

Unshape treats media as data structures that can be composed, transformed, and evaluated lazily. Rather than imperative drawing commands, you build up descriptions that are rendered on demand.

## Links

- [GitHub](https://github.com/rhi-zone/unshape)
- [Documentation](https://rhi.zone/unshape/)
