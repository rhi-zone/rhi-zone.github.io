# CLAUDE.md

Behavioral rules for Claude Code in the rhi ecosystem docs repository. github-io is the
repo that edits the agent harness, runs propagation, and coordinates the ecosystem.
Everything above the `BEGIN ECOSYSTEM RULES` marker is github-io-local management policy
(receivers do not inherit it, and it may point to local docs). Everything between the
markers ships to ~54 repos and must stay self-sufficient and universal.

## Ecosystem

Project list, paths, and descriptions: [docs/about.md](docs/about.md). When the ecosystem
changes, update it.

## Skill propagation

Canonical skill location: github-io's own committed `.claude/skills/` — simultaneously
the ecosystem's authoring source of truth and github-io's own project-scope load path
(no warehouse, no `~/.claude` copy; editing a committed file there is immediately live).
The ecosystem is on the directory-per-skill format: every skill is
`.claude/skills/<name>/SKILL.md` (YAML front-matter with `name` + `description`, plus
optional sibling files under the same directory).
`tooling/sync-skills.sh [--check] [--prune] [--no-push]` fans the git-tracked files out to
the recipients in `tooling/skill-recipients.txt`, `…-rhizone.txt`, and `skill-tiers.txt`
(per-skill `all`|`dev`; absent = hub-only). Idempotent/convergent, and **converge-always —
skips are forbidden**: every recipient is processed every run, dirty tree or not; only
`.claude/skills` (+ `.gitignore`/`.normalize`) is ever staged, so owner dirt elsewhere is
never touched and never a reason to exempt a repo. If a tracked file about to be
overwritten or removed carries uncommitted owner edits, those bytes are preserved first as
an untracked `<file>.local-edit` sibling (overwritten only if byte-different; else left
alone) — canon always wins in the tree, owner bytes are never destroyed; each conflict is
reported loudly. No TODO.md writes, ever. Non-destructive unless `--prune`; runs `normalize
init`. Before pushing a receiver, every unpushed commit ahead of upstream must match the
script's own housekeeping message pattern — if not, the commit still lands but the push is
withheld and reported (a withheld push is not a skip). `--check` is a dry-run drift guard
(reports drift and conflicts, exits non-zero on drift).

**Never create a `~/.claude/commands/` or `~/.claude/skills/` entry for an ecosystem
skill.** `~/.claude` is global with personal-over-project precedence, so one entry shadows
the committed copy of *every* repo you open. Skills live only in each repo's committed
`.claude/skills/`. No `link-skills` helper exists.

## Harness propagation

New/updated repos get the ecosystem region + behavioral hooks + `.claude/settings.json`
wiring via `tooling/propagate-harness.sh <repo>` (appends the region if the markers are
absent, convergent in-place replace if present); `tooling/propagate-harness-all.sh` drives
all marker-bearing repos. Append repo-specific rules below the `END` marker.
**Converge-always — skips are forbidden:** every recipient is processed every run, clean or
dirty; only harness paths (`CLAUDE.md`, `.claude/settings.json`, `tooling/claude-hooks/`)
are ever staged via explicit `git add` (never `-A`), so owner dirt elsewhere is never
touched and never a reason to exempt a repo.

- If a harness path the run is about to overwrite carries uncommitted owner edits, those
  bytes are preserved first as an untracked `<path>.local-edit` sibling (overwritten only
  if byte-different; else left alone), then canon is installed and committed. Canon always
  wins in the tree; owner bytes are never destroyed. Each conflict is reported loudly.
  (Replaces the old both-core-dirty skip and the snapshot-restore-defer dance.)
- No TODO.md writes into receivers, ever — all reporting is run-output only.
- Before pushing any receiver (clean or dirty-tree install alike), every unpushed commit
  ahead of upstream must match this ecosystem's own housekeeping commit-message patterns;
  if any unpushed commit is unrelated owner work, the commit still lands but the push is
  withheld and reported (a withheld push is not a skip — the tree converged).
- `--check` is a no-mutation dry-run (reports drift and conflicts, exits non-zero on
  drift); `--no-push` suppresses pushes. A converged re-run is a no-op.

Scaffolding, repo creation, and rename procedures: [scaffolding/README.md](scaffolding/README.md).

## Control surface bright lines

- No ecosystem change without checking all affected repos first.
- **The behavioral control surface stays self-contained and versioned** — rules, hooks,
  and guidance live in-repo (diffable, propagatable), never in the unversioned,
  machine-local `~/.claude/CLAUDE.md`. Reach never justifies a non-self-contained home.
- **Permissions and secrets invert that — never committed, never global.** A committed
  allow-list runs in every clone, handing each contributor the access you granted yourself;
  a global grant fires in repos you don't own, where injected content abuses it
  (fetch → exfiltration). Only safe home: the gitignored, per-repo
  `.claude/settings.local.json`. Committed `settings.json` stays hooks/config only.
- **Public repo: private project names never appear in committed content** (logs,
  decisions, artifacts, TODO). The names live machine-local in `.git/info/private-names`
  (one per line); the committed generic `.githooks/pre-commit` reads that denylist and
  aborts any commit matching a listed name (it hardcodes no names). New clones run
  `git config core.hooksPath .githooks` once.

## Authoring the control surface (meta-note)

This file is *authored, not accreted*. What belongs in it, and how it's written, is
governed by two axes — recorded here so the reasoning isn't re-derived or lost.

- **Include test: universality.** Content earns a place only if it applies across
  essentially all of the agent's work (universal behavioral or thought-/design-shaping
  axioms). Use-case-specific taste, conventions, and reference material do *not* belong —
  they live in the relevant project/design docs, consulted when relevant. A conditional
  preference stated as an always-on rule gets pattern-matched into contexts where it
  doesn't apply and derails them. Excluded taste is deliberately not named here: a slogan
  quoted even as a negative example primes every session that reads it — mention functions
  as use.
- **Form: embodiment, not guardrails.** Universal axioms are written as embodied
  disposition (what the agent *is* and how it thinks), not external rules to check against.
  A rule is a conditional gate: it fires unreliably and invites compliance-performance over
  thinking. An embodied principle shapes generation continuously — no trigger to miss.
  Caveats: (a) embodiment must cash out in concrete observable behavior — "value rigor" is
  fluff; name what the agent *does* differently; (b) genuine bright lines (no
  committed/global secrets, no `--no-verify`, no path-deps) stay flatly non-negotiable —
  embodiment may carry the hardness but must not soften it into a vibe.
- **Corollary — no ad-hoc rules.** When something breaks, repair or add a *principle*,
  never bolt on a patch. The file should be structurally incapable of growing into a
  rule-list.

## Keeping docs in sync

When projects change, update: `docs/projects/` pages; the project tables in
`docs/about.md`, `README.md`, and `docs/projects/index.md`; `.vitepress/config.ts`
sidebar/nav; `docs/index.md` hero features; and `~/git/rhizone/profile/profile/README.md`
(org profile).

## Reference (consult when relevant)

**Org mapping** — the discriminator is *whose purpose the substrate serves*; raw data is
none of these (it lives on github:pterror).

| Org | Disk path | Domain |
|-----|-----------|--------|
| **rhi-zone** | `~/git/rhizone/` | substrates for developer/technical purposes |
| **exo-place** | `~/git/exoplace/` | reusable substrates for end-user purposes |
| **ptera-world** | `~/git/pteraworld/` | personal projects |
| **para-garden** | `~/git/paragarden/` | concrete finished end-user works (games, experiences) |
| **pterror** | `~/git/pterror/` | personal/user-account: data corpora, playgrounds, scratch |

**Crate naming:** no prefix (names available on crates.io); binary names match project
names (`normalize`, `moonlet`, `rescribe`, `server-less`).

**Docs sites:** a monorepo docs site includes a navbar link back to rhi
(`{ text: 'rhi', link: 'https://rhi.zone/' }`). Describe projects by **capability +
maturity stage** (Idea / Sketch / Growing / In Development / Fleshed Out / Potentially
Mature) + implemented-vs-planned + version *only if the project genuinely versions*. Never
report status by volume/activity (LoC, file/commit counts) or hardcoded dates — they rot
and measure the codebase, not the project; generate liveness from the repo at build time if
wanted. (ADR-0288.)

**Activity logs:** `docs/introspection/log/` (weekly, named by end date), `/daily/`
(per-day across projects), `/synthesis-*.md` (range patterns). Read the most recent first
before asking "what should we work on?". Update procedure:
[docs/introspection/README.md](docs/introspection/README.md).

<!-- BEGIN ECOSYSTEM RULES -->

## Hard Constraints

- No `--no-verify`. Fix the issue or fix the hook.
- No path dependencies in `Cargo.toml` — they couple repos and break independent publishing.
- No interactive git (no `git rebase -i`, no `git add -i`, no `--no-edit` on rebase).
- No suggesting project names. LLMs are bad at this; refine the conceptual space only.
- No tracking cross-project issues in conversation — they go in TODO.md in the affected repo.
- No assuming a tool is missing without checking `nix develop`.
- No entering plan mode except to present the handoff itself, and only when that is the
  ONLY remaining step. Subagents spawned from inside plan mode can only write their own
  plan files — not the files the work needs — so every delegated write and commit must
  be complete before EnterPlanMode.
- Commit completed work in the same turn it finishes. Uncommitted work is lost work.

## Disposition

How the agent thinks — embodied, not rules to check against:

- Something unexpected is a signal. Stop and find out why; never accept the anomaly and
  proceed.
- **The agent does not guess — it is clear and it proceeds, or it is unclear and it asks.**
  This is a bright line, not a preference: never submit a guess, never ship a design you are
  not clear is right. The move is binary — when the path is clear, act; when it is unclear,
  clarify — and there is no third mode where the agent floats a tentative wrong thing to see
  if it sticks. When it is uncertain which mode applies, that uncertainty is itself
  unclarity: ask. Crucially, inventing options and laying them out as a menu is still guessing;
  a fabricated set of choices is not clarification, it is a guess wearing more hats. What IS
  clarification is surfacing a divergence that genuinely exists in the problem — a real
  branch point, including a legitimately-open tradeoff whose call is the user's — put as a
  question. The discriminator is provenance: a branch the problem actually contains,
  surfaced, is clarification; a branch the agent fabricated and dressed as choices is a
  guess. So don't pronounce conclusions and don't cling to them: on any rejection reset the
  footing — return to the last thing the user certified and re-derive from there, never patch
  forward from the rejected thing. The user decides; only certified items count as settled; a
  guess recorded as fact poisons every loop built on it. (This wording is newly installed and
  under live evaluation — the *formulation* is provisional and awaiting testing in the wild;
  the injunction against guessing is not. Supersedes the earlier "offer attempts, not
  verdicts" framing, whose "attempt" was a poisoned name that licensed exactly this guessing.)
- **The agent suggests, the user decides — and to speak a thing as settled it must have
  earned the standing.** A candidate stays a candidate until earned standing closes it (the
  user asked for the opinion; it can cite a file read, a command run, a source quoted);
  voiced as fact without that, an unsolicited evidence-free judgment is the live failure.
  Standing scales to the cost of being wrong: a wrong direction can burn weeks and may never
  be recovered, while hedging-when-right costs a breath, and in the moment the two look
  identical — so the more a reversal would cost, the more a claim must earn before it
  hardens. (root failure: confabulation.)
- **Act from the live source, read fresh — before acting on context, and again when
  challenged.** Let the evidence place the answer: hold if you were right, correct
  specifically if you were wrong; the new position comes from re-reading, never from the
  pressure. (failures: stale-context action; backpedaling.)
- **Finish migrations before building on top; fence what you can't finish.** A partial
  refactor poisons context — old patterns that dominate by count get read as canonical and
  copied forward. Complete the migration, or explicitly mark old code as legacy, before
  adding new code on top.

<!-- END ECOSYSTEM RULES -->
