# Project description sync: normalize

Read-only grounded reconciliation of the github-io docs for **normalize** against the
actual state of its codebase. Evidence-cited; aspirations are not restated as fact.

Assessment date: 2026-06-18. Assessor model: Opus 4.8.

---

## (a) Repo path + activity summary

- **Path:** `/home/me/git/rhizone/normalize` (rhi-zone org, as expected for a developer substrate).
- **Last commit:** `2026-06-18 10:11:27 +1000` (today) — `dafdcf7d chore(todo): record --schema hack retirement task`.
- **Total commits:** `3441` (via `git rev-list --count HEAD`).
- **Cadence:** `283` commits in the last 60 days — very active, daily-scale development.
- **Version:** `0.3.2` (`Cargo.toml` `[workspace.package]`).
- **Recent work themes (from `git log --oneline -25`):** `rank` output house-style/formatting
  migration (waves 1–3, many commits), ecosystem CLAUDE.md/hook propagation, CLI argv[0] fix.

## (b) What the codebase ACTUALLY is (with cited evidence)

A large, mature Rust workspace for structural code intelligence. Implemented and substantial,
not stubbed.

- **Scale:** `45` member crates (`ls -d crates/*/ | wc -l` → 45; workspace `members` list in
  `Cargo.toml` enumerates 44 crates + `xtask` + `benches`). `257,421` lines of Rust under
  `crates/` (`find crates -name '*.rs' | xargs wc -l` total). `2169` test functions
  (`#[test]`/`#[tokio::test]` count across `crates`). Release binary builds and is present
  (`target/release/normalize`, ~58 MB; also a Nix `result/bin/normalize`).

- **Three primitives — ALL real, implemented as command modules:**
  - `view` — `crates/normalize/src/commands/view/` (mod.rs, file.rs, symbol.rs, tree.rs,
    search.rs, lines.rs, chunked.rs, history.rs, report.rs). Confirmed.
  - `edit` — `crates/normalize/src/commands/edit.rs` (+ `crates/normalize/src/edit.rs`,
    `crates/normalize-edit/`). Operates on AST symbols: `find_symbols_matching` →
    `path_resolve::resolve_symbol_glob`. Confirmed AST-based.
  - `analyze` — `crates/normalize/src/commands/analyze/` — a large dir of analyzers
    (complexity, coupling, density, duplicates, test_ratio, budget, clusters, hotspots,
    layering, imports, contributors, architecture, etc., per `output.rs` report imports).
  - CLI is dispatched through the `server-less` framework (`main.rs` `cli_run_with_async`),
    consistent with the ecosystem "library-first / projection-from-one-definition" principle,
    not hand-rolled per surface.

- **"AST-based edit with fuzzy matching" claim — GROUNDED.** Fuzzy matching is real and lives
  in `crates/normalize-path-resolve/src/lib.rs` (module doc: "Path resolution utilities: fuzzy
  matching, sigil expansion…"; uses `nucleo_matcher` — `Pattern`, `Matcher`, `Config`; strategy
  comments at lines ~209/235/367 "try fuzzy matching"). `edit.rs` resolves targets via
  `resolve_symbol_glob` (AST symbol paths). So: AST-symbol targeting + fuzzy path resolution.
  *Caveat:* I did not run a live `normalize edit` to confirm end-to-end behavior; the claim is
  verified at the code/module level, not by execution.

- **98 languages — EXACT and accurate.** `crates/normalize-languages/src/` contains exactly
  `98` language modules (excluding infra files lib/traits/registry/parsers/grammar_loader/
  query*/ffi/body/docstring/component/ast_grep). The `registry.rs` has ~101 register-like
  lines (a few aliases/variants). README.md line 310 also states "98 languages via tree-sitter
  grammars." Feature-gated (`langs-all` default, `langs-core`, per-`lang-*`). Confirmed.

- **Background indexing daemon — implemented.** `crates/normalize/src/daemon.rs`: "Global
  daemon for watching multiple codebases and keeping indexes fresh… watches file changes…
  incrementally refreshes their indexes. Index queries go directly to SQLite files… Unix
  domain sockets for IPC… only supported on Unix." Confirmed (Unix-only is a real constraint
  the docs omit).

- **Shadow Git — implemented, but the docs' PATH is WRONG.** `crates/normalize-shadow/src/lib.rs`:
  "Maintains a hidden git repository (`.normalize/shadow/`)"; code joins `.normalize/shadow`
  (line 75) and `.normalize/shadow/worktree/`. The doc says "Hunk-level edit tracking in
  `.normalize/.git`" — the actual path is `.normalize/shadow/`, not `.normalize/.git`.
  *Caveat:* "hunk-level" is the doc's word; I confirmed the shadow-git mechanism exists but did
  not separately verify hunk-level granularity in the source.

- **Session analysis — implemented and broader than the headline.** `crates/normalize-chat-sessions/`
  parses Claude Code (JSONL), Gemini CLI (JSON), and OpenAI Codex CLI (JSONL) — see
  `src/lib.rs` lines 4–6. `crates/normalize-session-analysis/` adds cost/model pricing
  (`Claude Sonnet 4.5`, etc., "Anthropic Claude pricing (as of Feb 2026)").

- **Crates the docs DON'T mention (underclaim).** The doc lists 14 crates; the workspace has
  44. Undocumented substantial crates include: `normalize-analyze`, `normalize-architecture`,
  `normalize-budget`, `normalize-cfg` (control-flow), `normalize-deps`, `normalize-graph`,
  `normalize-knowledge-graph`, `normalize-semantic`, `normalize-scope`, `normalize-shadow`,
  `normalize-edit`, `normalize-refactor`, `normalize-metrics`, `normalize-facts*` (a Datalog/
  ascent fact-rules subsystem), `normalize-code-similarity`, `normalize-context`,
  `normalize-module-resolve`, `normalize-path-resolve`, `normalize-ratchet`,
  `normalize-native-rules`, `normalize-syntax-rules`, `normalize-output`,
  `normalize-package-index`, `normalize-ecosystems`, `normalize-local-deps`,
  `normalize-manifest`, `normalize-grammars`, `normalize-language-meta`,
  `normalize-rules-config`, `normalize-session-analysis`. (The doc's `normalize-sessions` and
  `normalize-jsonschema` names do not match current crate names — see gap below.)

## (c) GAP vs current docs

Doc surface analyzed: `docs/projects/normalize.md` (full), plus `docs/about.md` (rows at
lines 25–29, 59, 104), `README.md` (line 13), `docs/projects/index.md` (line 7),
`docs/index.md` (lines 15–18), `docs/.vitepress/config.ts` (lines 20, 118).

**Net verdict: the docs are largely ACCURATE on the headline pitch and on the 98-languages and
three-primitives claims, but the status block's metrics are STALE (undercount), and there are
two factual errors plus a couple of stale crate names.**

Stale / undercount (status block, `normalize.md` lines 5–7):
- "~128K lines of Rust" — STALE. Actual `crates/` Rust = **257K lines** (roughly 2x).
- "14 crates" — STALE/undercount. Actual = **44 member crates** (3x).
- "2281 commits" — STALE. Actual = **3441 commits**.
- These three are all undercounts pointing the same direction: the project has grown
  substantially since the status block was written. The qualitative status ("Potentially
  Mature ●", "core functionality is solid") remains a fair characterization.

Factual errors:
- Shadow Git path "`.normalize/.git`" is WRONG — code uses `.normalize/shadow/`
  (`normalize-shadow/src/lib.rs`).
- Crate name `normalize-sessions` (line 69) does not exist; the actual crates are
  `normalize-chat-sessions` (parsing) and `normalize-session-analysis` (cost/metrics).
- Crate name `normalize-jsonschema` (line 56) — NOT a member crate; JSON Schema handling
  appears folded into `normalize-typegen` / the `jsonschema` dep. *Caveat:* I did not exhaustively
  confirm no such crate exists anywhere; it is simply absent from the workspace `members` list.

Underclaim:
- The "Crates" tables document 14 of 44 crates and omit major subsystems (control-flow graphs,
  dependency/knowledge graphs, semantic analysis, facts/Datalog rules, refactor, metrics,
  shadow, code-similarity). Not wrong, just a small slice of what's there.

Accurate (verified true):
- "98 Languages via tree-sitter" — exact.
- Three primitives `view`/`edit`/`analyze` — all present as real command modules.
- "AST-based code modifications with fuzzy matching" — grounded (AST-symbol targeting +
  `nucleo` fuzzy path resolution).
- Background indexing daemon — present (note: Unix-only, undocumented).
- Session analysis across Claude Code/Gemini/Codex — present and broader than stated.
- `about.md` rows (98 languages, session formats, package ecosystems, tool interface,
  skeleton views) — all consistent with code.

Unverified / cannot assert:
- "12+ ecosystems" for `normalize-packages` — the doc's crate is actually `normalize-package-index`
  / `normalize-ecosystems`; I did not count the ecosystems, so I cannot confirm the "12+" figure.
- End-to-end runtime behavior of `view`/`edit`/`analyze` — verified at source/module level
  only; not executed.
- "Hunk-level" granularity of shadow git — mechanism confirmed, granularity not separately
  checked.
- Moonlet plugin/relationship claim (lines 89–91) — out of scope; not checked against either
  codebase.

## (d) PROPOSED corrected description

Voice/format matches the existing `docs/projects/normalize.md`. Clearly separates shipped
reality from stated direction. Numbers below are the verified current ones.

### One-line table blurb (for about.md line 104 / README / projects/index.md)

> AST-aware code navigation, editing, and analysis across 98 languages

(Current blurbs — "Structural code intelligence for humans and AI agents" / "Structural code
intelligence across 98 languages" — are accurate and need no change. The above is an
interchangeable tightening, not a correction.)

### Longer projects/normalize.md status block (replacement for lines 5–7)

> ::: info Status: Potentially Mature ●
> ~257K lines of Rust across 44 crates, 3400+ commits (v0.3.2). Core functionality is solid:
> the three primitives (`view`/`edit`/`analyze`) ship, with extensive language support
> (98 languages via tree-sitter), a background indexing daemon (Unix), shadow-git edit
> tracking, and AI-session analysis. Active development is on the analysis surface
> (budget, test-ratio, coupling clusters, output formatting). Remaining work is capability
> expansion rather than foundation building.
> :::

### Corrections to the body of projects/normalize.md

- "Shadow Git — Hunk-level edit tracking in `.normalize/.git`" → "Shadow Git — automatic edit
  history tracking in `.normalize/shadow/`".
- Crate table: rename `normalize-sessions` → `normalize-chat-sessions` (session-log parsing:
  Claude Code, Gemini CLI, OpenAI Codex), and consider adding `normalize-session-analysis`
  (cost/usage/model metrics).
- Crate table: drop or relabel `normalize-jsonschema` (not a current member crate; JSON Schema
  codegen lives under `normalize-typegen`) — verify against current `normalize-typegen` before
  rewording.
- Package-management row: the crate is `normalize-package-index` (+ `normalize-ecosystems`),
  not `normalize-packages`; re-confirm the "12+ ecosystems" figure before keeping it.
- Optionally note the daemon is Unix-only (uses Unix domain sockets), per `daemon.rs`.
- Optionally surface the larger crate set (control-flow, graphs, semantic, facts/Datalog,
  refactor, metrics) as the workspace has 3x the documented crates.

> Note: these are PROPOSED edits recorded in this artifact only. No doc surface was modified.
