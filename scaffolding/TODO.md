# TODO
## Seed `design-it-twice` skill (deferred — repo was dirty 2026-06-15)

Superseded by the skill-loading redesign (2026-06-16). Skills are no longer seeded by
hand or from `~/.claude/commands/`. Canonical source is github-io's committed
`.claude/commands/`; distribution is convergent via `tooling/sync-skills.sh`, which seeds
any missing skill (including `design-it-twice`) into every listed recipient when it is
clean. Once this repo is clean it will be picked up by the next `sync-skills.sh` run; no
manual `cp` step. See github-io CLAUDE.md → Ecosystem-Wide Refactors.
