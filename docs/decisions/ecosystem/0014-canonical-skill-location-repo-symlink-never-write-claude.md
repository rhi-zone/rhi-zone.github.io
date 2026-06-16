# ADR-0014: Canonical skill location is in-repo with symlink; never write to ~/.claude directly

- Status: Superseded by ADR-0287
- Date: 2026-05-29

> *Superseded by ADR-0287: the `~/.claude` symlink was found defective — a global skill entry shadows every repo's committed copy. The decision below is retained verbatim as history.*

**Context.** Claude Code skills/commands live in `~/.claude/commands/`. A decision was needed about the source of truth for skills shared across repos: edit them in the home dir, or keep them version-controlled in the repo.

**Decision.** The canonical skill location is `tooling/claude-commands/` in this repo, with `~/.claude/commands/` symlinked to it. Skills must not be written to `.claude/` directly; they propagate from the repo via the propagator script.

**Alternatives rejected.**
- *Treat `~/.claude/commands/` as the editable source of truth for skills* — It is unversioned and per-machine; keeping the canonical copy in-repo makes skills version-controlled and propagatable across every repo that has them.

**Consequences.** Skill edits go to the in-repo location and propagate via `propagate-skill.sh`; the home dir is a symlink, not a source. Adds a propagation step but gains versioning and consistency. Mined from: /home/me/git/rhizone/github-io/CLAUDE.md (26).
