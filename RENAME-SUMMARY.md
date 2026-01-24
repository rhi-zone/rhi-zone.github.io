# Ecosystem Rename Summary

Complete documentation update for the rhi ecosystem rename.

## Organization Changes

- `rhizome-lab` → `rhi-zone`
- `rhizome-lab.github.io` → `rhi.zone`
- `Rhizome ecosystem` → `rhi ecosystem`
- `Rhizome` → `rhi`

## Project Renames

| Old Name | New Name | Category |
|----------|----------|----------|
| moss | normalize | Code Intelligence |
| resin | unshape | Generation |
| frond | playmate | Games & Worlds |
| hypha | interconnect | Games & Worlds |
| cambium | paraphase | Data Transformation |
| liana | concord | Data Transformation |
| siphon | resurrect | Data Transformation |
| spore | moonlet | Runtime & Interface |
| canopy | dusklight | Runtime & Interface |
| nursery | myenv | Infrastructure |
| pith | portals | Infrastructure |
| flora | zone | Infrastructure |
| trellis | server-less | Infrastructure |
| burn-models | sketchpad | External |

**Unchanged**: dew, rescribe, ooxml, claude-code-hub

## Configuration Changes

- `rhizome.toml` → `rhi.toml`
- Crate prefix: `rhizome-` → no prefix (we don't publish to crates.io)
  - Example: `rhizome-moss-core` → `normalize-core`

## Files Updated

### Root Documentation
- ✓ README.md - Project tables, links, descriptions
- ✓ CLAUDE.md - Project paths, tool references, crate naming
- ✓ TODO.md - Project references
- ✓ WORLDBUILDING.md - All ecosystem references
- ✓ NAMING.md - Naming rationale doc
- ✓ NAMING-SUMMARY.md - Naming summary
- ✓ RHI-RENAME.md - Rename tracking doc
- ✓ PRE-RENAME-SNAPSHOT.md - Snapshot doc
- ✓ scaffolding/README.md - Example project name

### VitePress Documentation
- ✓ docs/index.md - Hero section, features
- ✓ docs/about.md - All project references, philosophy section
- ✓ docs/architecture.md - Architecture diagrams, project names
- ✓ docs/contributing.md - Contribution guidelines
- ✓ docs/integration.md - Integration examples, mermaid diagrams
- ✓ docs/problems.md - Problem statements
- ✓ docs/use-cases.md - Use case examples
- ✓ docs/vision.md - Vision statements
- ✓ docs/.vitepress/config.ts - Navigation, sidebar, project links

### Project Pages (Renamed Files)
- ✓ docs/projects/moss.md → normalize.md
- ✓ docs/projects/resin.md → unshape.md
- ✓ docs/projects/frond.md → playmate.md
- ✓ docs/projects/hypha.md → interconnect.md
- ✓ docs/projects/cambium.md → paraphase.md
- ✓ docs/projects/liana.md → concord.md
- ✓ docs/projects/siphon.md → resurrect.md
- ✓ docs/projects/spore.md → moonlet.md
- ✓ docs/projects/canopy.md → dusklight.md
- ✓ docs/projects/nursery.md → myenv.md
- ✓ docs/projects/pith.md → portals.md
- ✓ docs/projects/flora.md → zone.md
- ✓ docs/projects/trellis.md → server-less.md
- ✓ docs/projects/dew.md (unchanged name, content updated)
- ✓ docs/projects/index.md - Project listing and badges

## Verification

All files checked for remaining old references:
```bash
grep -riE "moss|resin|frond|hypha|cambium|liana|siphon|spore|canopy|nursery|pith|flora|trellis|burn-models" \
  --include="*.md" --include="*.ts" --exclude-dir=node_modules --exclude-dir=.git
```

Result: No remaining old names found (excluding NAMING/TODO tracking docs).

## Git Statistics

```
33 files changed, 425 insertions(+), 944 deletions(-)
```

- 13 project files renamed
- All documentation files updated with new naming
- VitePress config updated with new navigation structure
- All URLs updated to rhi.zone domain

## Next Steps

1. Commit these changes to the rhi-zone-github-io repository
2. Update GitHub repository settings (name, description, topics)
3. Configure custom domain rhi.zone for GitHub Pages
4. Update all individual project repositories with new names
5. Update GitHub organization name from rhizome-lab to rhi-zone
6. Archive or redirect old repository URLs
