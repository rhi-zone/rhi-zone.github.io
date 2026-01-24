# Pre-Rename Snapshot

Snapshot taken before rhi ecosystem rename on 2026-01-24.

## Ecosystem Repos

### Code Intelligence
- **normalize** → normalize

### Generation
- **unshape** → unshape
- **dew** → dew (unchanged)

### Games & Worlds
- **playmate** → playmate
- **interconnect** → interconnect

### Data Transformation
- **paraphase** → paraphase
- **rescribe** → rescribe (unchanged)
- **concord** → concord
- **resurrect** → resurrect

### Runtime & Interface
- **moonlet** → moonlet
- **dusklight** → dusklight

### Infrastructure
- **myenv** → myenv
- **portals** → portals
- **zone** → zone
- **server-less** → server-less (unchanged - but will check if this is correct)

### Org Resources
- **rhi-zone-github** → rhi-zone-github (or similar)
- **rhi-zone-github-io** → rhi-docs (or similar)

### External (to be transferred in)
- **sketchpad** → sketchpad (currently under pterror org)

### External (remain external)
- **ooxml** (infrastructure dependency)
- **claude-code-hub** (external orchestration tool)

## Current Org Status

- **rhi-zone**: normalize, unshape, dew, playmate, interconnect, paraphase, rescribe, concord, resurrect, moonlet, dusklight, myenv, portals, zone, server-less, rhi-zone-github, rhi-zone-github-io
- **pterror**: sketchpad (will be transferred)

## Org Migration

- **rhi-zone** org → **rhi-zone** org

## Crate Naming

All crates will use `rhi-` prefix:
- `rhi-normalize-core` → `rhi-normalize-core`
- `rhi-moonlet-core` → `rhi-moonlet-core`
- etc.

## Git Tags

All repos tagged with `pre-rhi-rename` for rollback safety.
