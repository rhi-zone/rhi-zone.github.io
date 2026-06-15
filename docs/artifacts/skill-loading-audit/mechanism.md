# Skill Loading Audit — Mechanism Ground Truth

Audited: 2026-06-16. Read-only; no changes made.

---

## 1. `propagate-skill.sh` and `propagate-claude-md.sh` Behavior

### `tooling/propagate-skill.sh`

**Canonical source it reads from:**
```
SOURCE=~/.claude/commands/"$SKILL_FILE"
```
Comment at top: `# Source of truth: ~/.claude/commands/<skill-file>`. The script does NOT read from `tooling/claude-commands/` directly; it reads from the machine-local `~/.claude/commands/` path. Because `~/.claude/commands/` entries are symlinks into `tooling/claude-commands/`, this resolves to the same bytes — but the declared source of truth is the machine-local path, not the versioned one.

**Note on CLAUDE.md vs script:** CLAUDE.md says "Updates `~/.claude/commands/<skill-file>` first, then copies to every repo that has it" — but the script has no step that updates `~/.claude/commands/<skill-file>`. The update-first step is a manual prerequisite the operator must perform; the script starts from whatever is already at `$SOURCE`. CLAUDE.md overstates the script's autonomy here.

**Repo discovery rule (the find pattern):**
```bash
REPOS=$(find ~/git -name "$SKILL_FILE" -path "*/.claude/commands/*" 2>/dev/null \
  | awk -F'/.claude/' '{print $1}' | sort -u)
```
A repo is included if and only if a file with that exact name already exists under `<repo>/.claude/commands/`. Opt-in by presence; there is no registry. If a repo doesn't already have the file, it is silently excluded.

**What it writes and commits:**
```bash
cp "$SOURCE" ".claude/commands/$SKILL_FILE"
# ...
git add ".claude/commands/$SKILL_FILE" .gitignore .normalize/ 2>/dev/null || true
# ...
git commit -m ...
git push ...
```
Copies the skill file into each receiver repo's `.claude/commands/`, stages only that file plus `.gitignore` and `.normalize/`, commits, and pushes if the working tree is clean.

### `tooling/propagate-claude-md.sh`

Reads from `$(dirname "$0")/../CLAUDE.md` (i.e., `github-io/CLAUDE.md`). Extracts the region between `<!-- BEGIN ECOSYSTEM RULES -->` and `<!-- END ECOSYSTEM RULES -->` and either replaces that region in the target file (if both markers exist) or appends it (if no markers). Does not touch `.claude/commands/` at all. Operates only on CLAUDE.md propagation.

---

## 2. Canonical vs Deployed Layout in github-io

### `tooling/claude-commands/` — what's committed (via `git ls-files tooling/claude-commands/`)

```
tooling/claude-commands/design-an-interface/SKILL.md
tooling/claude-commands/design-it-twice.md
tooling/claude-commands/domain-model/SKILL.md
tooling/claude-commands/improve-codebase-architecture/DEEPENING.md
tooling/claude-commands/improve-codebase-architecture/INTERFACE-DESIGN.md
tooling/claude-commands/improve-codebase-architecture/LANGUAGE.md
tooling/claude-commands/improve-codebase-architecture/SKILL.md
tooling/claude-commands/polish.md
tooling/claude-commands/survey-open-threads.md
```

`think-with-the-engineering-taste.md` is **present in `tooling/claude-commands/`** as a real file but is **NOT listed by `git ls-files`** — meaning it is **not committed** in `tooling/claude-commands/` either.

Wait — `ls` showed it there; git ls-files did not. Rechecking:

`ls /home/me/git/rhizone/github-io/tooling/claude-commands/` showed `think-with-the-engineering-taste.md` as a real file (size 8145, Jun 4). But `git ls-files tooling/claude-commands/` did NOT return it. This means `think-with-the-engineering-taste.md` in `tooling/claude-commands/` is an **untracked real file**, not committed to git.

### `.claude/commands/` in github-io

The entire `.claude/commands/` directory is **untracked** (`git status` shows `?? .claude/commands/`). No entries from `.claude/commands/` appear in `git ls-files`. `settings.json` is the only committed file under `.claude/` in github-io.

### Per-Skill Table (github-io)

| Skill | In `tooling/claude-commands/` committed? | `~/.claude/commands/` state | `.claude/commands/` in github-io |
|-------|------------------------------------------|-----------------------------|----------------------------------|
| `design-an-interface` | Yes (dir, `SKILL.md`) | Symlink → `tooling/claude-commands/design-an-interface` | Absent |
| `design-it-twice.md` | Yes | Symlink → `tooling/claude-commands/design-it-twice.md` | Absent |
| `domain-model` | Yes (dir, `SKILL.md`) | Symlink → `tooling/claude-commands/domain-model` | Absent |
| `improve-codebase-architecture` | Yes (dir, 4 files) | Symlink → `tooling/claude-commands/improve-codebase-architecture` | Absent |
| `polish.md` | Yes | Real file (not symlink) | Absent |
| `survey-open-threads.md` | Yes | Symlink → `tooling/claude-commands/survey-open-threads.md` | Absent |
| `think-with-the-engineering-taste.md` | **No — untracked real file** | Symlink → `tooling/claude-commands/think-with-the-engineering-taste.md` | Real file, **untracked** |
| `handoff.md` | **Not present in tooling/claude-commands/** | Real file (not symlink) | Absent |

**`think-with-the-engineering-taste.md` is not an exception — it is part of a consistent pattern for recently-added skills:** the tooling copy exists on disk but is not committed. `handoff.md` is the opposite anomaly: it exists in `~/.claude/commands/` as a real file but has no counterpart in `tooling/claude-commands/` at all.

---

## 3. `~/.claude/commands/` Symlink Topology

Full listing with resolved targets:

| Entry | Type | Resolves to |
|-------|------|-------------|
| `design-an-interface` | Symlink | `/home/me/git/rhizone/github-io/tooling/claude-commands/design-an-interface` |
| `design-it-twice.md` | Symlink | `/home/me/git/rhizone/github-io/tooling/claude-commands/design-it-twice.md` |
| `domain-model` | Symlink | `/home/me/git/rhizone/github-io/tooling/claude-commands/domain-model` |
| `handoff.md` | **Real file** | (no target — standalone file, not symlinked) |
| `improve-codebase-architecture` | Symlink | `/home/me/git/rhizone/github-io/tooling/claude-commands/improve-codebase-architecture` |
| `polish.md` | **Real file** | (no target — standalone file, not symlinked) |
| `survey-open-threads.md` | Symlink | `/home/me/git/rhizone/github-io/tooling/claude-commands/survey-open-threads.md` |
| `think-with-the-engineering-taste.md` | Symlink | `/home/me/git/rhizone/github-io/tooling/claude-commands/think-with-the-engineering-taste.md` |

Six of eight entries are symlinks into `tooling/claude-commands/`. Two (`handoff.md`, `polish.md`) are real files with no symlink relationship to `tooling/claude-commands/`.

**Consequence for propagation:** When `propagate-skill.sh` runs with `handoff.md` or `polish.md`, it reads from `~/.claude/commands/<file>` — a real file that is not versioned anywhere in the repo tree. Edits to these skill files made in-place at `~/.claude/commands/` are unversioned and invisible to git.

---

## 4. Cross-Repo Self-Containment (Receiver Repos)

Sample set checked via `git ls-files .claude/commands/`:

| Repo | Committed skill files |
|------|-----------------------|
| `rhizone/normalize` | `design-it-twice.md`, `handoff.md`, `polish.md`, `SUMMARY.md` |
| `rhizone/concord` | `design-it-twice.md`, `handoff.md`, `polish.md` |
| `rhizone/crescent` | `design-it-twice.md`, `handoff.md`, `polish.md` |
| `rhizone/moonlet` | `design-it-twice.md`, `handoff.md`, `polish.md` |
| `exoplace/aspect` | `design-it-twice.md`, `handoff.md`, `polish.md` |
| `exoplace/noncanon` | `design-it-twice.md`, `handoff.md`, `polish.md` |
| `paragarden/existence` | `design-it-twice.md`, `handoff.md`, `polish.md` |

**Finding: receiver repos ARE self-contained.** Their `.claude/commands/` files are committed real files — not symlinks. The asymmetry is confirmed:

- **github-io (source):** skills load from `~/.claude/commands/` which is either a machine-local symlink into `tooling/claude-commands/` or an unversioned real file; `.claude/commands/` is entirely untracked.
- **Receiver repos:** skills are committed real files in `.claude/commands/`, loaded directly from the repo tree.

**What receiver repos are missing:** No receiver repo has `survey-open-threads.md`, `think-with-the-engineering-taste.md`, `design-an-interface`, `domain-model`, or `improve-codebase-architecture` — these skills were never propagated (no existing receiver file means the find rule excludes them).

---

## 5. CLAUDE.md and Docs — Verbatim Quotes and Tensions

From `CLAUDE.md` (lines 18–26):

> Propagate `.claude/commands/` skills across all repos:
>
> ```bash
> ~/git/rhizone/github-io/tooling/propagate-skill.sh <skill-file> "<commit message>"
> ```
>
> Updates `~/.claude/commands/<skill-file>` first, then copies to every repo that has it, runs `normalize init`, commits, and pushes where clean.
>
> Canonical skill location: `tooling/claude-commands/` in this repo. Symlink from `~/.claude/commands/` to `tooling/claude-commands/`. Do not write skills to `.claude/` directly.

From `CLAUDE.md` (Control Surface & Harness Management, line 50):

> **Control surface stays self-contained and versioned.** Behavioral rules, hooks, and guidance live in-repo — versioned, diffable, propagatable. Never put them in the unversioned, machine-local `~/.claude/CLAUDE.md`; reach never justifies a non-self-contained home.

### Internal Tensions

1. **"Canonical skill location: `tooling/claude-commands/`" vs. script source of truth `~/.claude/commands/`**: The script comment says `# Source of truth: ~/.claude/commands/<skill-file>` and `SOURCE=~/.claude/commands/"$SKILL_FILE"`. CLAUDE.md says the canonical location is `tooling/claude-commands/`. These conflict. The script doesn't read from `tooling/claude-commands/` at all.

2. **"Symlink from `~/.claude/commands/` to `tooling/claude-commands/`" vs. reality**: The symlink direction described in CLAUDE.md is correct (entries in `~/.claude/commands/` pointing into `tooling/claude-commands/`), but two entries (`handoff.md`, `polish.md`) are real files, not symlinks — they have drifted outside the described topology.

3. **"Do not write skills to `.claude/` directly"** vs. `think-with-the-engineering-taste.md` in `.claude/commands/`: The file exists at `.claude/commands/think-with-the-engineering-taste.md` in github-io as a real file, untracked. This directly violates the stated rule.

4. **"Control surface stays self-contained and versioned"** vs. github-io's own skill loading: github-io's `.claude/commands/` is entirely untracked. Its skills reach the harness only through `~/.claude/commands/`, which is machine-local. If you clone github-io on a different machine, the skills do not load. Receiver repos (by contrast) are genuinely self-contained for the skills they have.

5. **"Updates `~/.claude/commands/<skill-file>` first"** vs. script reality: The script has no step that updates `~/.claude/commands/`. This sentence describes a manual prerequisite, not a script behavior. Because `~/.claude/commands/` symlinks to `tooling/claude-commands/`, editing a file in `tooling/claude-commands/` IS the update (via the symlink) — but only for symlinked entries; `handoff.md` and `polish.md` have no such path.

---

## 6. gitignore and settings.json

### `.gitignore` in github-io
No entries matching `claude`, `commands`, or `.claude`. The entire `.claude/commands/` directory is untracked purely because it was never added (not because it is ignored).

### `.claude/settings.json` in github-io (committed)
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {"type": "command", "command": "/home/me/git/rhizone/github-io/tooling/claude-hooks/post-history.sh"}
        ]
      }
    ]
  }
}
```
References only hooks; no skill/commands configuration.

### `.claude/settings.json` in receiver repos (committed)
Same structure — hooks only, referencing each repo's own `tooling/claude-hooks/post-history.sh`. No skill references.

### `.claude/settings.local.json` in github-io (gitignored by convention, not .gitignore)
Present on disk, not committed (per the self-containment rule on permissions).

---

## Summary of Key Findings

**github-io's skills do NOT load from committed in-repo files.** They load from `~/.claude/commands/`, which is a machine-local directory. Most entries there are symlinks into `tooling/claude-commands/` (which IS versioned), but the link exists only on this machine. Two skills (`handoff.md`, `polish.md`) are real files in `~/.claude/commands/` with no versioned backing at all.

**The self-containment gap is asymmetric:** receiver repos have committed real files in `.claude/commands/` and are self-contained for the skills they carry. github-io (the source and propagation hub) is the one repo that is NOT self-contained — its skills only load on this machine via the `~/.claude/commands/` symlink topology.

**Unversioned skills:** `think-with-the-engineering-taste.md` is present in `tooling/claude-commands/` but not committed. `handoff.md` has no presence in `tooling/claude-commands/` at all. These skills exist only on this machine.

**Propagation gap:** Skills added to `tooling/claude-commands/` after the ecosystem was established (`survey-open-threads`, `think-with-the-engineering-taste`, `design-an-interface`, `domain-model`, `improve-codebase-architecture`) have never been propagated to any receiver repo. The find-by-presence rule means they can never self-propagate until they're seeded into receiver repos manually.
