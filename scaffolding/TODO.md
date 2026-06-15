# TODO
## Seed `design-it-twice` skill (deferred — repo was dirty 2026-06-15)

A new ecosystem skill `design-it-twice.md` was added (canonical: `~/git/rhizone/github-io/tooling/claude-commands/design-it-twice.md`). `propagate-skill.sh` only updates repos that already carry a skill, so brand-new skills are seeded by hand. This repo was dirty during the seeding pass, so it was skipped per the ecosystem-wide refactor rules. Once clean, run:

```sh
cp ~/.claude/commands/design-it-twice.md "$(git rev-parse --show-toplevel)/.claude/commands/design-it-twice.md"
~/git/rhizone/normalize/target/debug/normalize init
git add .claude/commands/design-it-twice.md .gitignore .normalize/
direnv exec . git commit -m "feat(skills): add design-it-twice"
git push
```

(`direnv exec` puts the nix toolchain on PATH so the pre-commit hook passes; never use `--no-verify`.)
