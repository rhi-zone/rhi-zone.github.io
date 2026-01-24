# Pre-Rename Snapshot

Snapshot taken before rhi ecosystem rename on 2026-01-24.

## Ecosystem Repos

### Code Intelligence
- **moss** → normalize

### Generation
- **resin** → unshape
- **dew** → dew (unchanged)

### Games & Worlds
- **frond** → playmate
- **hypha** → interconnect

### Data Transformation
- **cambium** → paraphase
- **rescribe** → rescribe (unchanged)
- **liana** → concord
- **siphon** → resurrect

### Runtime & Interface
- **spore** → moonlet
- **canopy** → dusklight

### Infrastructure
- **nursery** → myenv
- **pith** → portals
- **flora** → zone
- **trellis** → server-less (unchanged - but will check if this is correct)

### Org Resources
- **rhizome-lab-github** → rhi-zone-github (or similar)
- **rhizome-lab-github-io** → rhi-docs (or similar)

### External (to be transferred in)
- **burn-models** → sketchpad (currently under pterror org)

### External (remain external)
- **ooxml** (infrastructure dependency)
- **claude-code-hub** (external orchestration tool)

## Current Org Status

- **rhizome-lab**: moss, resin, dew, frond, hypha, cambium, rescribe, liana, siphon, spore, canopy, nursery, pith, flora, trellis, rhizome-lab-github, rhizome-lab-github-io
- **pterror**: burn-models (will be transferred)

## Org Migration

- **rhizome-lab** org → **rhi-zone** org

## Crate Naming

All crates will use `rhi-` prefix:
- `rhizome-moss-core` → `rhi-normalize-core`
- `rhizome-spore-core` → `rhi-moonlet-core`
- etc.

## Git Tags

All repos tagged with `pre-rhi-rename` for rollback safety.
