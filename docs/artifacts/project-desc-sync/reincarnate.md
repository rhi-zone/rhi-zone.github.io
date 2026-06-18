# Project-Description Sync — reincarnate

Read-only grounded reconciliation of github-io docs vs. the actual `reincarnate` codebase.
Date: 2026-06-18. Assessment only; no doc surfaces edited.

## (a) Repo path + activity

- **Path:** `/home/me/git/rhizone/reincarnate` (found on first try; rhi-zone root). Working tree clean.
- **Activity:** Highly active. `git rev-list --count HEAD` = **2013 commits**. Recent log (top 25)
  is dominated by type-inference work on the GameMaker frontend (`feat(infer): …`,
  `fix(infer): …`, `fix(gamemaker): …`), TypeScript-backend codegen fixes (`fix(ts): …`),
  and harness/CLAUDE.md syncs. Most recent functional commit:
  `4de16db9 feat(infer): resolve param types to the post-fixpoint join of all callers`.
  This is an actively-developed project, not a dormant one.

## (b) What the codebase ACTUALLY is (cited evidence)

A **Rust multi-crate workspace** that lifts legacy bytecode/script applications to a modern
web runtime by decompiling to an SSA-like IR, running transform passes, and re-emitting
TypeScript alongside a swappable replacement runtime. This matches the README framing closely.

Evidence:
- **Workspace members** (`/home/me/git/rhizone/reincarnate/Cargo.toml`): `reincarnate-core`,
  `reincarnate-cli`, frontends `reincarnate-frontend-flash` / `-gamemaker` / `-twine`,
  backend `reincarnate-backend-typescript`, format `datawin`, checker
  `reincarnate-checker-typescript`, tool `gen-gml-builtins`.
- **All listed crate dirs physically exist** under `crates/{frontends,backends,formats,checkers}`
  plus `crates/reincarnate-core` and `crates/reincarnate-cli` (verified via `ls`).
- **Source size (LOC, `*.rs`, target excluded):** reincarnate-core **37,604**;
  frontend-gamemaker **50,154** (the largest, consistent with the inference-heavy recent log);
  backend-typescript **24,899**; frontend-twine **15,409**; datawin **9,114**;
  frontend-flash **4,557**; cli **3,398**; checker-typescript **216** (thin).
  Total **192** `.rs` files (target excluded).
- **Runtimes present** (`runtime/`): `flash/ts/`, `gamemaker/ts/`, `twine/ts/` — TypeScript
  per-engine runtimes (e.g. `runtime/flash/ts/flash/display.ts`, `events.ts`, `geom.ts`, …),
  matching the README "replacement runtime" claim.
- **Domain model** (`CONTEXT.md`): IR is SSA-like with block arguments (not phi nodes);
  strict Frontend (source-aware, target-blind) / Backend (target-aware, source-blind) split;
  `Transform`/`TransformPipeline` with declarative `requires()`/`invalidates()`; `PureIrPass`
  marker enforcing pipeline-stage isolation. This is a real, documented architecture.
- **Implemented vs. planned frontends:** Implemented = **Flash, GameMaker, Twine** (these are
  the only frontend crates that exist; README marks exactly these three "✅ Active"). Everything
  else in the README target table (Director, VB6, Silverlight, Java applets, HyperCard, RPG Maker,
  Ren'Py, WolfRPG, SRPG Studio, Inform 7, Ink, RAGS, QSP, PuzzleScript) is **Planned** — no crates
  exist for them (`ls crates/frontends` shows only flash/gamemaker/twine).
- **Backend:** TypeScript only (`reincarnate-backend-typescript`); README mentions Rust as a
  possible target but no Rust backend crate exists.

## (c) GAP vs. current docs

The project IS documented across all surfaces:
- `docs/projects/reincarnate.md` (full body page)
- `docs/about.md:43` (problem-space row), `:132` (project table), `:198` (keybinds note)
- `README.md:41` (table), `docs/projects/index.md:27`, `docs/index.md:54` (hero feature),
  `.vitepress/config.ts:38,148` (nav/sidebar)

The one-line blurbs are accurate and need no change:
- about.md/index hero/projects-index all say variants of "Lift legacy software to modern web
  runtimes" / "Legacy software lifting framework" — **correct**.

**The body page `docs/projects/reincarnate.md` is STALE / partly fabricated.** Specific gaps:

1. **Invented component names.** The "Key features" list cites **"Explant"** (bytecode
   extraction) and **"Hypha"** (game translation with UI overlay). `grep -rli explant|hypha`
   over all `.rs`/`.md`/`.toml` (target excluded) returns **zero hits**. These names do not exist
   anywhere in the codebase — they appear to be hallucinated or from an abandoned design.
2. **"Multi-tier approach — Native patching for hard targets."** The README explicitly scopes
   the project to "bytecode and script-based runtimes — engines where user logic can be
   extracted" and "not native binaries." No native-patching code exists. The doc's own
   Philosophy section even contradicts its own feature bullet ("works on bytecode and script,
   not native binaries").
3. **Stale status metrics.** Status box says "1096 commits, 195 Rust files." Actual:
   **2013 commits** (≈1.8× off), **192 `.rs` files**. Roughly six months stale.
4. **Twine omitted; planned targets listed as if equal.** The "Supported targets" list names
   Flash, Director, Authorware, VB6, Silverlight, Java, HyperCard, ToolBook, RPG Maker, Ren'Py,
   GameMaker — but **omits Twine entirely**, which is one of only three actually-implemented
   frontends (Flash, GameMaker, **Twine**), and lists many never-started targets without
   distinguishing planned from active. The README's status table is the accurate source.
5. Status icon ◐ ("Fleshed Out") is reasonable and consistent with index.md ("reincarnate ◐").

Net: the project is correctly *placed* and the short blurbs are fine; the **body page needs a
rewrite** to (a) drop the nonexistent Explant/Hypha/native-patching claims, (b) refresh metrics,
(c) reflect the real implemented set (Flash + GameMaker + Twine, TypeScript backend, IR pipeline),
and (d) mark the rest as planned.

## (d) PROPOSED description

Matches existing voice/format (compare `docs/projects/normalize.md`). Metrics below are verified
against the repo as of 2026-06-18.

### One-line table blurb (already accurate — keep as-is)

> Legacy software lifting framework — lift legacy software to modern web runtimes

(No change needed to about.md:132 / README.md:41 / projects/index.md:27 / index.md:54.)

### Proposed body for `docs/projects/reincarnate.md` (replaces stale content)

```markdown
# Reincarnate

**Legacy software lifting framework in Rust.**

::: info Status: Fleshed Out ◐
~2000 commits, 192 Rust files across a multi-crate workspace (core IR + CLI, three frontends,
a TypeScript backend, a TS type-checker, and the GameMaker data.win parser). Active lifting for
Flash (AVM2), GameMaker (GMS1/GMS2), and Twine (SugarCube + Harlowe), emitting compiled
TypeScript over per-engine replacement runtimes. IR-level transform passes including type
inference/narrowing, mem2reg, coroutine lowering, and const folding. Validated against
production games (e.g. Dead Estate). Remaining work: additional frontends and format coverage.
:::

Reincarnate extracts application logic from obsolete bytecode/script runtimes and re-emits it as
modern web code. It decompiles to an SSA-like intermediate representation, runs transform passes,
then emits compiled TypeScript alongside a swappable replacement runtime — not an interpreter
bundle. The original runtime is fully replaced.

## Pipeline

**Frontend** (extract + decompile, source-aware) → **IR** (SSA-like, block arguments) →
**Transform passes** (declarative requires/invalidates ordering) → **Backend** (emit target
code, target-aware). Frontend and backend are strictly isolated: a frontend never knows the
target language, a backend never knows the source engine.

## Implemented today

| Stage | Targets | Status |
|-------|---------|--------|
| Frontend | Flash (AVM2 / ABC bytecode) | Active |
| Frontend | GameMaker (GMS1/GMS2, data.win) | Active |
| Frontend | Twine (SugarCube + Harlowe) | Active |
| Backend | TypeScript | Active |
| Runtimes | flash / gamemaker / twine (TS, swappable platform layer) | Active |

## Planned

Director/Shockwave, Visual Basic 6, Silverlight, Java applets, HyperCard/ToolBook,
RPG Maker, Ren'Py, WolfRPG, SRPG Studio, Inform 7, Ink, RAGS, QSP, PuzzleScript.
(See the repo README's target table for format/status detail.)

## Crates

| Crate | Description |
|-------|-------------|
| `reincarnate-core` | Core IR, transform pipeline, type inference |
| `reincarnate-cli` | CLI binary (extract / emit / print-ir / info) |
| `reincarnate-frontend-flash` | Flash/SWF frontend (ABC bytecode) |
| `reincarnate-frontend-gamemaker` | GameMaker frontend (GMS1/GMS2) |
| `reincarnate-frontend-twine` | Twine frontend (SugarCube + Harlowe) |
| `reincarnate-backend-typescript` | TypeScript code emitter |
| `reincarnate-checker-typescript` | Emitted-TypeScript type checker |
| `datawin` | GameMaker data.win format parser |

## Philosophy

Reincarnate works on **bytecode and script**, not native binaries. The goal is accurate
preservation, not improvement — make the old thing work as it was, in a modern runtime.

## Links

- [GitHub](https://github.com/rhi-zone/reincarnate)
- [Documentation](https://rhi.zone/reincarnate/)
```

## Uncertainties / things NOT independently verified

- Transform-pass names cited in the proposed status box (mem2reg, coroutine lowering, const
  folding, type inference) are drawn from `CONTEXT.md` examples (`Mem2Reg`, `CoroutineLowering`,
  `ConstraintSolveHM`) and the recent git log; I did not enumerate the full registered pass list
  from source. Safe but worth a glance before publishing.
- "Dead Estate" production-game validation is carried over from the existing doc and corroborated
  by a TODO.md commit referencing the "Dead Estate corpus"; I did not locate the corpus itself.
- README target-table statuses (which planned targets are partially started vs. untouched) were
  taken from the README; only the three crate-backed frontends were verified as actually present.
- "keybinds used in reincarnate" (about.md:198): `Cargo.toml` files contain no `keybinds`
  dependency. That claim refers to the *TypeScript* runtime layer (not Rust crates) or is stale —
  flagged, not resolved. Out of scope for this body rewrite but noted.
