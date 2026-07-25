# github-io

The rhi ecosystem hub: docs site source and the shared agent harness for ~54 repos.

This repo is two things in one place:

- **Docs site** — the VitePress source for [docs.rhi.zone](https://docs.rhi.zone), covering
  rhi's philosophy, the full project catalog, and per-project pages under `docs/projects/`.
- **Harness authority** — the canonical source for the Claude Code behavioral control
  surface (`CLAUDE.md` region, hooks, skills) that's propagated out to every other repo in
  the ecosystem via `tooling/propagate-harness.sh` and `tooling/sync-skills.sh`.

Skills live in `.claude/skills/` (directory-per-skill, `SKILL.md` plus optional sibling
files) and fan out to recipient repos listed in `tooling/skill-recipients.txt`. Harness
rules live in `CLAUDE.md` between the `BEGIN ECOSYSTEM RULES` / `END` markers and propagate
the same way. Both propagation scripts are idempotent and converge every recipient on every
run.

See [docs/about.md](docs/about.md) for the ecosystem's philosophy and full project list,
and [scaffolding/README.md](scaffolding/README.md) for the new-repo scaffolding templates
this repo also hosts.

## License

Licensed under MIT OR Apache-2.0.
