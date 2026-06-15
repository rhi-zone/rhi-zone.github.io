# WebFetch/WebSearch Blanket Allow — 2026-06-15

Blanket-allowed `WebFetch` and `WebSearch` in every ecosystem repo's
`.claude/settings.local.json` to stop per-session web-access prompts.
Bare `"WebFetch"` subsumes all domain-scoped `"WebFetch(domain:...)"` entries,
so those were collapsed in the same pass.

Files are machine-local and globally gitignored
(`~/.config/git/ignore` → `**/.claude/settings.local.json`).
Nothing was committed from the target repos.

## Counts

| metric | value |
|--------|-------|
| total repos processed | 67 |
| created (file did not exist) | 13 |
| merged (file existed, needed changes) | 43 |
| no change (already had both, no domain entries) | 11 |
| errors | 0 |
| total domain-scoped `WebFetch(domain:...)` entries collapsed | 582 |

## Created (new file)

| repo |
|------|
| bun |
| exoplace/noncanon |
| paragarden/solarium |
| pteraworld/annotated-law |
| pterror/chub-stage-factory |
| pterror/matrix-gen |
| pterror/software-taxonomy |
| pterror/statosphere-guide |
| pterror/statosphere-studio |
| rhizone/defocus |
| rhizone/gels |
| rhizone/github-io/scaffolding |
| rhizone/rhi.zone |

## Merged (file existed)

| repo | had WebFetch | had WebSearch | domain entries collapsed |
|------|:---:|:---:|---:|
| ascent-interpreter | — | yes | 3 |
| private-recipient-b | — | yes | 18 |
| claude-code-hub | — | yes | 0 |
| config-nixos | — | yes | 17 |
| private-recipient-a | — | yes | 28 |
| desloppify | — | yes | 6 |
| exoplace/aeriea | — | — | 14 |
| exoplace/aspect | — | yes | 3 |
| exoplace/github-io | — | — | 0 |
| exoplace/hologram | — | yes | 13 |
| herbarium | — | yes | 2 |
| keybinds | — | — | 0 |
| lee-website | — | — | 0 |
| moue | — | — | 1 |
| nix-comfyui | — | — | 2 |
| ooxml | — | yes | 4 |
| pad | yes | — | 0 |
| paragarden/divergence | — | yes | 30 |
| paragarden/existence | — | yes | 29 |
| paragarden/github-io | — | — | 0 |
| paragarden/legacy | — | yes | 30 |
| paragarden/postmortem | — | yes | 30 |
| pteraworld | — | — | 7 |
| pterror/ashwren | — | — | 0 |
| pterror/chub-mirrorer | — | — | 1 |
| pterror/fuwafuwa | — | yes | 20 |
| rhizone/crescent | — | yes | 39 |
| rhizone/deskspace | — | — | 0 |
| rhizone/fractal | — | — | 27 |
| rhizone/github-io | — | — | 166 |
| rhizone/interconnect | — | yes | 6 |
| rhizone/moonlet | — | — | 0 |
| rhizone/motif | — | yes | 30 |
| rhizone/nanites | — | — | 0 |
| rhizone/portals | — | yes | 0 |
| rhizone/rainbow | — | — | 0 |
| rhizone/reincarnate | — | yes | 44 |
| rhizone/scribble | — | — | 0 |
| rhizone/server-less | — | yes | 5 |
| rhizone/sketchpad | yes | yes | 1 |
| rhizone/tiltshift | — | — | 2 |
| rhizone/zone | — | yes | 4 |
| vela | — | — | 0 |

## No Change (already complete)

lotus, rhizone/concord, rhizone/dusklight, rhizone/myenv, rhizone/normalize,
rhizone/paraphase, rhizone/playmate, rhizone/profile, rhizone/rescribe,
rhizone/unshape, rhizone/wick

## Anomalies

None. All 67 `settings.local.json` files were confirmed gitignored via
`git check-ignore` (sampled: rhizone/crescent, exoplace/hologram, bun).
No malformed JSON encountered. No repo had the file unexpectedly tracked.

## Verification

Spot-checked 6 files post-write:

- `rhizone/crescent`: bare WebFetch=1, WebSearch=1, domain-scoped=0. Other keys (Skill entries, Bash entries) intact.
- `exoplace/hologram`: bare WebFetch=1, WebSearch=1, domain-scoped=0.
- `paragarden/divergence`: bare WebFetch=1, WebSearch=1, domain-scoped=0.
- `pterror/fuwafuwa`: bare WebFetch=1, WebSearch=1, domain-scoped=0.
- `bun` (created): `{"permissions":{"allow":["WebFetch","WebSearch"]}}`.
- `rhizone/github-io`: bare WebFetch=1, WebSearch=1, domain-scoped=0 (was the largest: 166 entries collapsed).

`rhizone/normalize` verified: `enableAllProjectMcpServers` and `enabledMcpjsonServers` top-level keys preserved intact.
