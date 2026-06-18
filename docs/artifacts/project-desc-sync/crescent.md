# Project Description Sync — crescent

Read-only grounded assessment. Reconciles github-io docs against the actual `crescent` codebase. Assessment only — no doc surfaces edited.

## (a) Repo path + activity summary

- **Path:** `~/git/rhizone/crescent` (rhi-zone org). Found on first guess; no ambiguity.
- **Activity:** Highly active and mature.
  - `git rev-list --count HEAD` = **3355 commits**
  - First commit `2024-03-13`; latest commit `2026-06-17` (the day before this assessment).
  - Recent `git log --oneline -25` is dominated by deep typechecker soundness work (e.g. `cdc5b2a6 fix(analysis): close covariant write-through unsoundness…`, `750295e9 docs: typechecker design thesis — sound coverage-gradual modular typing`, multiple "slice v2 increment N" feature commits, adversarial design/critique rounds) plus ecosystem-harness sync chores. This is sustained, current engineering, not a dormant repo.

## (b) What the codebase ACTUALLY is (cited evidence)

Crescent is a **pure-Lua / LuaJIT software ecosystem** — a very large collection of independent, vendorable libraries plus first-class tooling (a static typechecker, test runner, package manager, CLI). No top-level `Cargo.toml` or `package.json` for the project itself (the only `package.json` is `docs/package.json` for the VitePress docs site); it is not a Rust or Node project. Manifest is `pkg.lua` (`name = "crescent"`, with typecheck rule config).

Evidence of scale (measured, not claimed):
- **416 library directories** under `lib/` (`ls lib | wc -l`).
- **1503 Lua files** under `lib/` alone; **3216 `.lua` files** repo-wide excluding `.crescentcache`/`docs/node_modules` (`find … -name '*.lua' | wc -l`).
- `lib/` is **24M**, `bin/` 3.7M (vendored LuaJIT binaries for multiple platforms — `bin/luajit`, `luajit-aarch64`, `luajit.exe`, `luajit-macos-aarch64`, etc.), `dep/` 18M (vendored C deps).

Tooling is real and substantial, not stubbed:
- **Typechecker** — `lib/type/` contains **200 Lua files**, with `analysis/`, `check.lua`, `static/`, `static-v4/`, `search/`, `framework/`, `init.lua`. Recent commits show active soundness work (variance, narrowing, mutual alias families via Bekić elaboration). `CONTEXT.md` documents a rich type vocabulary (TypeSlot FFI structs, constraint-based inference via `solve.lua`, narrowing in `narrow.lua`, opaques/newtypes/row polymorphism). A "design thesis" arc on sound coverage-gradual modular typing is in progress.
- **Test runner** — `lib/test/` has `arb.lua`, `prop.lua`, `fuzz.lua`, `gen.lua`, `coverage.lua`, `fixture.lua`, `assert.lua`, `cli.lua` (property + fuzz + snapshot testing, all with `_test.lua` companions).
- **Package manager** — `lib/pkg/` is complete: `semver.lua`, `manifest.lua`, `lock.lua`, `install.lua`, `publish.lua`, `workspace.lua`, `config.lua`, `check.lua`, `cli.lua` — each with `_test.lua`.
- **HTTP** — `lib/http/` has `server.lua`, `client.lua`, `server_ws.lua`, `server_tls_test.lua`, `server_fork.lua`, `stream.lua`, `router/`, `format/`, `status.lua` — matches the README's "server + client, mature" claim.
- **CLI entry** — `bin/cr` plus `cr-check.lua`, `cr-test.lua`, `cr-daemon.lua` (LSP daemon), `cr-doc.lua`, `cr-publish.lua`, `cr-install.lua`, etc.
- **Tier architecture is pervasive:** `grep -rl '_tier' lib | wc -l` = **469** files reference the `_tier` introspection field — confirming the `system > ffi > pure` three-tier model documented in CONTEXT.md is actually wired throughout, not aspirational.

WIP items the README honestly flags (TLS, QR codes) match reality: `lib/qrencode/init.lua` contains WIP/TODO markers.

**Inferred real purpose (from code):** "the ecosystem LuaJIT never had" — fill LuaJIT's near-empty stdlib with the entire surface area of software as composable, copy-paste-ownable pure-Lua libraries, distributed by inspection rather than a registry, with the typechecker/test-runner/pkg-manager making it self-contained. The codebase strongly substantiates the README's framing.

## (c) GAP vs current docs

Crescent **is** documented on every github-io surface:
- `docs/projects/crescent.md` (full page)
- `docs/about.md:45` (Lua-ecosystem problem row) and `:139` (project table)
- `README.md:49` (project table)
- `docs/projects/index.md:24` (project table)
- `docs/index.md:64` (hero feature card)
- `docs/.vitepress/config.ts:43` (nav link to docs.rhi.zone/crescent) and `:157` (sidebar)

The framing/voice is **accurate and well-aligned**. The one material defect is a **stale status line in `docs/projects/crescent.md`**:

> `docs/projects/crescent.md:5-6`: "Status: Fleshed Out ◐ — **44 commits, 287 Lua files.** Type inference engine with structural operator dispatch…"

Reality: **3355 commits** (vs 44 — off by ~75×) and **1503 lib Lua files / 3216 total** (vs 287 — off by ~5–11×). The qualitative description ("Type inference engine…, Test infrastructure in place, Active development on type system features") is still directionally true, but the hard numbers badly understate maturity. Everything else (table blurbs, hero card, problem-table row) is short enough to remain accurate; no other surface carries stale metrics.

Classification: **documented, but the project-page status metrics are stale (severely undercounted).** Not undocumented; not aspirational-beyond-reality (if anything the opposite — docs undersell the codebase).

Uncertainties / flags:
- Commit count `3355` is on the current `master`/HEAD as cloned locally; assumes no large rebase that would change the count on the canonical remote. Verified locally only.
- I did not run the test suite or the typechecker; "mature/complete" for http/pkg/test is inferred from file structure + presence of `_test.lua` companions + recent commit activity, not from a green test run.
- The README's per-category breadth claims (crypto, codecs, compression, etc.) were spot-checked against `ls lib` (libraries like `argon2`, `ed25519`, `curve25519`, `brotli`, `cbor`, `bson`, `datalog` all present) but not exhaustively verified library-by-library.

## (d) Proposed description

The doc already exists and the voice is good — the recommendation is a **targeted refresh of the stale status line**, not a rewrite. Proposed replacements matching existing voice/format:

**One-line table blurb** (already in use, keep as-is — accurate):
> Comprehensive LuaJIT ecosystem — stdlib, typechecker, package manager.

**Status line for `docs/projects/crescent.md`** (replacing the stale "44 commits, 287 Lua files…"):
> ::: info Status: Mature ◐
> 416 vendorable libraries, 1500+ Lua files, 3000+ commits since 2024. Constraint-based static typechecker with LSP daemon (sound coverage-gradual typing, active), property/fuzz test runner, vendor-first package manager, mature HTTP server+client. TLS and QR codes WIP.
> :::

(If the docs prefer not to hard-code numbers that will drift again, an alternative is to drop exact counts: "400+ vendorable libraries with a static typechecker (LSP), test runner, and vendor-first package manager.")

**Longer body** — the existing body of `docs/projects/crescent.md` (key-features list, prior-art, links) remains accurate and can stand; only the status callout needs updating. Optionally add HTTP/WebSocket maturity and the three-tier `system > ffi > pure` model to "Key features" to reflect the codebase's actual organizing principle.
