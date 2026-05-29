# Dusklight Binding & Gap Closure — Design

Designs (A) closing the four Dusklight config-driven gaps in rhi-zone substrate, and
(B) the corpus↔Dusklight binding with "domain reader = config/data" built on top.

- Master plan: `design-overview.md` (Architecture / Engine).
- Annotation schema (explainer / `@medium:*` / `@core:explains` / cardinalities): `annotation-schema.md`.
- Chosen path: **close the four gaps FIRST** (front-load substrate work) so "reader = config" is actually delivered, not aspirational.

## 0. Verified ground truth (read 2026-05-29)

Dusklight is **clean** at HEAD `bbec487`. Marinada is a **separate repo** (`github:rhi-zone/marinada`, vendored as `@dusklight/marinada`); its edits land there, Dusklight stays in rhi-zone. Implementer **must re-check `git status` of both `~/git/rhizone/dusklight` and `~/git/rhizone/marinada` before editing** — clean→edit directly, dirty→append to that repo's `TODO.md`. State of both at design time is otherwise UNKNOWN to this doc.

Confirmed from source (not docs):

- `compile(expr: Expr, opts?): JitFn` and `JitFn = (env: Record<string, unknown>) => unknown` — **synchronous JIT**, exported from `@dusklight/marinada`. This is the cache target: compile once, call per data item.
- `evaluate(expr, env: Env): EvalResult` — tree-walking interpreter (alternative to JIT).
- `compileReactive(expr): ReactiveFn`, `ReactiveEnv = Record<string, ReactiveSignal>`, `ReactiveSignal = { get(); subscribe(fn) }`. Layout already uses this with `env = { _: lens.signal }` (`app/src/layout.ts` `renderLayout`).
- `Expr = null | boolean | number | string | Expr[]` (JSON s-expressions). So layout JSON and Expr JSON are the **same** serialization — A2 is mostly a validator, not a parser.
- Core evaluator ops (in `evaluate.ts` switch): `get`, `get-in`, `record-get`, `array-get`, `keys`, `vals`, `merge`, `if`, `cond`, `let`, `fn`, `call`, `match`, `count`, comparison/arith, `cap` (capability call), `perform`/`handle` (effects). Field access is `["get", obj, "key"]`; nested is `["get-in", obj, ["array","a","b"]]`.
- `lib:std` (called as `["call", "filter", lambda, arr]` after importing `filter` etc.): `map`, `filter`, `reduce`, `find`, `includes`, `any`/`every`, `count`, `index-of`, `flat-map`, … Confirmed `filter` + `includes` exist (B2 depends only on these).
- **NO optic ops in Marinada.** `lens.field` / `traversal.each` / `lens.compose` do NOT exist in `evaluate.ts`/`std.ts` (design-doc-only). `optics.ts` Lens/Traversal/`composeLensTraversal`/`each`/`field` exist in `@dusklight/core` as TS values only.
- `PluginRegistry.getSourceFactory(id)` exists and works; `Pipeline` (`app/src/pipeline.ts`) has `parseStream` + `matchPatterns` but **no `runSource`**. App uses hardwired `fetchAsStream()` (`App.ts`).
- `Pattern.match(data, ctx: MatchContext): number | null`; `MatchContext = { schema?; contentType?; metadata? }`. Renderer/medium preference is an **in-memory `signal` only** (`App.ts` `selectedRenderer`); not persisted.
- `ForEach` (`app/src/layout.ts`) **ignores `node.optic`** — iterates `lens.signal.get()` as a raw array directly (comment in `main.ts` admits this).

Correction to the briefing: `get`/`get-in` are **core evaluator ops, not `lib:std`** (briefing listed them under std). Immaterial to the design; noted for accuracy.

---

# PART A — Gap closures

## A1. Patterns-as-Marinada (THE enabler for medium-selection-as-config)

**Keep `Pattern` unchanged** (backward-compat with TS-function patterns in `main.ts`). Add a **factory** in `@dusklight/core` that produces a `Pattern` whose `match()` runs a compiled Marinada `Expr`:

```ts
// @dusklight/core — new: marinada-pattern.ts
import { compile, type Expr, type JitFn } from "@dusklight/marinada";
import type { Pattern, MatchContext } from "./types.ts";

export type MarinadaPatternSpec = {
  id: string;
  rendererId: string;
  /** Expr evaluating to a number in [0,1] or null. Bindings: `_` = data, `ctx` = MatchContext. */
  expr: Expr;
};

export function marinadaPattern(spec: MarinadaPatternSpec): Pattern {
  const fn: JitFn = compile(spec.expr);            // compiled ONCE (uses the JIT, no per-call recompile)
  return {
    id: spec.id,
    rendererId: spec.rendererId,
    match(data: unknown, ctx: MatchContext): number | null {
      const r = fn({ _: data, ctx });              // ctx carries ctx.metadata (medium preference)
      if (r === null || r === undefined) return null;
      if (typeof r === "number") return Math.max(0, Math.min(1, r));
      if (typeof r === "bigint") return Math.max(0, Math.min(1, Number(r)));
      return null;                                  // non-numeric → no match (defensive)
    },
  };
}
```

Decisions / justifications:
- **Factory, not a `Pattern` type variant.** The runtime (`registry.matchPatterns`) already calls `pattern.match()` uniformly; a variant would force a dispatch edit everywhere. The factory yields a normal `Pattern`, so `PluginRegistry` and `Pipeline.matchPatterns` need **zero changes**.
- **Compile once at factory call** (module-load / registration time), reuse the closure-captured `JitFn` per call. This is "use the JIT, don't recompile per call." If patterns are built from JSON at load (B3), compilation is amortized across every data item.
- **Bindings exposed:** `_` = the data being matched; `ctx` = the whole `MatchContext`. The learner's medium preference rides in `ctx.metadata` (A5 puts it there). A pattern reads it as `["get", ["get", "ctx", "metadata"], "preferredMedium"]`. **Requires** the pipeline to thread the real `MatchContext` into `matchPatterns` (today `App.ts` calls `pipeline.matchPatterns(d)` with default `{}` — see A5 / B4 for populating `metadata`).
- Edit needed in `@dusklight/core/index.ts`: export `marinadaPattern`. No `types.ts` change.

## A2. Layout JSON loader

Because `Expr = JSON`, every `Expr`-valued field (`spacing`, `columns`, `optic`, `keyExpr`, `minLength`) is **already valid JSON** and passes through untouched. A2 is a **validating identity function over the node tree**, not an Expr parser.

```ts
// @dusklight/core — new: layout-loader.ts
import type { LayoutNode } from "./types.ts";

export class LayoutParseError extends Error {
  constructor(msg: string, readonly path: string) { super(`${path}: ${msg}`); }
}

const STACK = new Set(["HStack", "VStack", "ZStack", "Grid"]);

export function parseLayoutNode(json: unknown, path = "$"): LayoutNode {
  if (typeof json !== "object" || json === null || Array.isArray(json))
    throw new LayoutParseError("expected object", path);
  const o = json as Record<string, unknown>;
  const t = o.type;
  switch (t) {
    case "HStack": case "VStack": case "ZStack": case "Grid": {
      const children = o.children;
      if (!Array.isArray(children))
        throw new LayoutParseError(`${t} requires children array`, path);
      if (t === "Grid" && o.columns === undefined)
        throw new LayoutParseError("Grid requires columns", path);
      return {
        ...o,                                   // Expr fields (spacing/columns/rows/alignment) pass through
        type: t,
        children: children.map((c, i) => parseLayoutNode(c, `${path}.children[${i}]`)),
      } as LayoutNode;
    }
    case "Spacer":
      return { type: "Spacer", ...(o.minLength !== undefined ? { minLength: o.minLength } : {}) };
    case "ForEach": {
      if (o.optic === undefined)
        throw new LayoutParseError("ForEach requires optic", path);
      if (o.child === undefined)
        throw new LayoutParseError("ForEach requires child", path);
      return {
        type: "ForEach",
        optic: o.optic,                          // LayoutOptic = Expr, passes through
        child: parseLayoutNode(o.child, `${path}.child`),
        ...(o.keyExpr !== undefined ? { keyExpr: o.keyExpr } : {}),
      };
    }
    case "Renderer": {
      if (typeof o.rendererId !== "string")
        throw new LayoutParseError("Renderer requires string rendererId", path);
      return {
        type: "Renderer", rendererId: o.rendererId,
        ...(o.optic !== undefined ? { optic: o.optic } : {}),
        ...(Array.isArray(o.caps) ? { caps: o.caps as string[] } : {}),
      };
    }
    default:
      throw new LayoutParseError(`unknown node type ${JSON.stringify(t)}`, path);
  }
}
```

- Validation: unknown `type` → error with JSON-path; missing required structural fields (`children`, `Grid.columns`, `ForEach.optic`/`child`, `Renderer.rendererId`) → error; `Expr` fields are **not** validated here (Marinada validates/typechecks them at compile time). Recurses children/child.
- Export from `index.ts`. No `types.ts` change.

## A3. ForEach.optic + Marinada optic ops

Two parts: (a) make `ForEach` evaluate `node.optic`; (b) add the missing Marinada optic ops that return existing `optics.ts` values.

**(b) Optic ops in Marinada.** Add to the **evaluator core** (not `lib:std`), because they must produce host `Lens`/`Traversal` objects, which the evaluator already does for capabilities (`cap` op returns host objects). New ops, returning `@dusklight/core` `optics.ts` values wrapped as opaque host values:

| Op | s-expr | Returns |
|---|---|---|
| `lens.field` | `["lens.field", "name"]` | `Lens<S, S["name"]>` (← `field("name")`) |
| `lens.index` | `["lens.index", 0]` | `Lens<A[], A>` (← `index(0)`) |
| `traversal.each` | `["traversal.each"]` | `Traversal<A[], A>` (← `each()`) |
| `lens.compose` | `["lens.compose", a, b]` | composed lens, or lens∘traversal → traversal (← `composeLenses`/`composeLensTraversal`) |

`lens.compose` dispatches on whether the second arg is a Lens or Traversal (presence of `getAll`) and calls `composeLenses` or `composeLensTraversal` from `optics.ts`. These live in **marinada repo** (`evaluate.ts` + JIT codegen in `jit.ts`); they import the optic constructors from `@dusklight/core/optics`. **Wrinkle (W1):** this makes `marinada` depend on `@dusklight/core`, but `@dusklight/core` already depends on `@dusklight/marinada` (for `Expr` in `types.ts`) → **dependency cycle**. Resolution: optic *values* are plain structural objects (`{ get, set }` / `{ getAll, modify }`); define the optic constructors in marinada itself (or in a tiny shared `@dusklight/optics` leaf package) rather than importing `@dusklight/core`. **Recommend the leaf package** so both depend on it and the cycle is broken. This is the one non-trivial structural change in Part A.

**(a) ForEach evaluation** (`app/src/layout.ts`, `ForEach` case). Replace the raw-array path:

```ts
case "ForEach": {
  // optic: Expr evaluating to a Traversal (or Lens, treated as 1-element).
  const opticFn = compile(node.optic);            // JIT, compiled once per node
  const getItems = (whole: unknown): unknown[] => {
    const optic = opticFn({ _: whole }) as Traversal<unknown, unknown> | Lens<unknown, unknown>;
    return "getAll" in optic ? optic.getAll(whole) : [optic.get(whole)];
  };
  // per item i: focus a Lens<whole, item> derived from the optic + index,
  // composed onto the parent reactive lens via lens.focus(...).
  // For a `traversal.each` optic the per-item lens is index(i); for a composed
  // lens∘each it is composeLenses(prefixLens, index(i)).
  ...
}
```

- **Per-item focus.** The traversal enumerates; rendering each item needs a *settable* `Lens<whole, item>`. For `traversal.each` over an array at the root, that is `index(i)` (already what the current code hand-rolls). For a composed optic `lens.compose(lens.field("xs"), traversal.each())`, the per-item lens is `composeLenses(field("xs"), index(i))`. Design: the optic-eval returns, alongside `getAll`, an **`itemLens(i)`** helper; the simplest concrete shape is to have `traversal.each`/`lens.compose` also expose a `focus(i): Lens` (a thin extension of `Traversal`), or — minimal — keep ForEach's existing `index(i)`-based focus and only generalize the *enumeration* via the optic, deferring deep-path settable focus to when a config needs it. **Recommend: generalize enumeration now (unblocks B), keep `index(i)` focus, document deep-path-settable as a follow-up.** Reads (the corpus reader is read-mostly) work fully; writes through deep ForEach paths are the deferred edge.
- Cite: `app/src/layout.ts` `ForEach` case; `@dusklight/core/optics.ts` `each`/`field`/`composeLenses`/`composeLensTraversal`.

## A4. Source-factory wiring

Add `runSource` to `Pipeline` (`app/src/pipeline.ts`), composing the existing `parseStream`:

```ts
// app/src/pipeline.ts — new method on Pipeline
async *runSource(
  cfg: { sourceId: string; config: SourceConfig; caps?: Record<string, Cap<unknown>> },
): AsyncIterable<ParseResult> {
  const factory = this.registry.getSourceFactory(cfg.sourceId);
  if (!factory) throw new Error(`Unknown source factory: ${cfg.sourceId}`);
  const result: SourceResult = factory.create(cfg.config, cfg.caps ?? {});
  yield* this.parseStream(result.data, result.contentType);   // existing parser routing
}
```

- **Config shape** (the thing a reader names — used by B):
  ```json
  { "sourceId": "@dusklight/source-http",
    "config": { "url": "https://..." },
    "caps": ["network:rhi.zone"] }
  ```
  `config` is the factory's `SourceConfig` blob (its `configSchema` describes it); `caps` is a list of capability grant strings that the host resolves to `Cap` objects before calling `create`.
- **Replace** `App.ts`'s `fetchAsStream`/`fetchFirstResult` with a call through `pipeline.runSource({ sourceId: "@dusklight/source-http", config: { url }, caps })`. The existing `transport-http` package already exposes an HTTP `SourceFactory` (registered via its manifest) — wire it instead of the inline fetch. This removes the only hardwired source path.
- `matchPatterns` should be invoked with a real `MatchContext` populated from the `SourceResult.metadata` + the persisted preference (A5), not the current `{}`.

## A5. Preference persistence (deterministic)

Today: in-memory `signal<string | null>` (`App.ts` `selectedRenderer`). The plan references a "config file system" + "local agent" (not built). **Minimal persistence slot now, full local-agent later.**

- Define a **capability-backed key-value store** `PrefStore` as a `Cap`:
  ```ts
  type PrefStore = Cap<unknown> & {
    methods: {
      get(key: string): string | null;
      set(key: string, value: string): void;
    };
  };
  ```
  Default host implementation: `localStorage`-backed (browser) keyed `dusklight.pref.<name>`. Pluggable: the local-agent later supplies a different `PrefStore` cap with identical interface — **no consumer change**.
- Two preferences persist: `dusklight.pref.medium` (learner's preferred `@medium:*`, e.g. `"@medium:video"`) and `dusklight.pref.renderer.<entityKind>` (explicit per-kind renderer override).
- **Determinism:** selection is a pure function of (data, persisted prefs, registry pattern set). Given the same persisted `medium` and the same corpus, the ranked pick is identical across sessions/machines. The store is read into `MatchContext.metadata.preferredMedium` before `matchPatterns`; nothing in the scoring path is time- or random-dependent.
- This is an **app-level** addition (`app/src`), plus the `Cap` interface in `@dusklight/core`. Not a Marinada change.

---

# PART B — Corpus binding & domain-reader-as-config

## B1. Corpus as a SourceFactory

```ts
// new package: @dusklight/source-corpus — manifest registers this factory
const corpusSource: SourceFactory = {
  id: "@dusklight/source-corpus",
  configSchema: { /* JSON Schema: { location, lens, query? } */ },
  create(config, caps) {
    // config = { location: string; lens?: string; query?: Expr }
    // emits the selected entities as a JSONL stream → existing parser-json (JSONL mode) consumes it
    return { data: /* AsyncIterable<Uint8Array> of newline-delimited entity JSON */, contentType: "application/jsonl" };
  },
};
```

- **Unit that streams: per-entity JSONL** (one entity object per line). Rationale: (1) reuses the existing JSON/JSONL parser with zero new parser; (2) streamable/incremental; (3) the reader's Marinada query (B3) filters/projects the resulting array — keeping "what entities" in config, not in the source. Whole-corpus is the default emission; the `query`/`lens` in config can pre-narrow at the source for large corpora (optional optimization, same result as query-time filter).
- The corpus location resolution (filesystem path, bundled asset, or HTTP) is a capability concern (`caps`), out of scope of the binding shape.

## B2. Build-time closure flattening (bank regardless)

The corpus validator already computes `subclass_of` / `subtopic_of` / `instance` transitive closures. **Materialize them as flattened arrays on each entity at construction time** so Dusklight queries use only flat `filter` + `includes` (which exist) and need **no recursive Marinada and no query-time graph walk**:

Flattened fields written onto each entity at build (regenerated every build):
- `subclass_closure: string[]` — all transitive superclasses (incl. self) by `@ns:slug`.
- `subtopic_closure: string[]` — on `@topic:*` entities: all transitive super-topics (incl. self).
- `about_topic_closure: string[]` — on concept entities: union of each `about_topic` value's `subtopic_closure`. So "is this concept under `@topic:personal-finance` (transitively)?" is `includes(about_topic_closure, "@topic:personal-finance")`.
- `instance_closure: string[]` — transitive `instance_of` metaclass chain (lets patterns key on `@meta:explainer` cheaply).

This keeps every reader query deterministic, O(n) flat scans, no recursion. The fields are **derived build artifacts**, never hand-authored; the corpus build step writes them; the validator may assert they match the live closures.

## B3. Domain-reader config shape (DATA)

A domain reader is a single JSON artifact: a named source + config (A4/B1), a Marinada selection query (B2 closures), a layout tree (A2 JSON), medium-scoring patterns (A1), and renderer refs. Worked minimal **personal-finance reader**:

```json
{
  "id": "reader:personal-finance",
  "source": {
    "sourceId": "@dusklight/source-corpus",
    "config": { "location": "corpus://finance", "lens": "finance" },
    "caps": ["corpus:read"]
  },
  "select": ["call", "filter",
    ["fn", ["e"],
      ["includes", ["get", "e", "about_topic_closure"], "@topic:personal-finance"]],
    "_"],
  "layout": {
    "type": "VStack", "spacing": 8,
    "children": [
      { "type": "ForEach",
        "optic": ["traversal.each"],
        "child": { "type": "Renderer", "rendererId": "@finance/renderer-concept" } }
    ]
  },
  "mediumPatterns": [
    { "id": "explainer-medium-match", "rendererId": "@dusklight/renderer-explainer",
      "expr": [ /* see B4 */ ] }
  ],
  "renderers": ["@finance/renderer-concept", "@dusklight/renderer-explainer"]
}
```

- `select` runs over the streamed entity array (`_`), returning the finance concepts under `@topic:personal-finance` via the B2 flattened closure — **deterministic, no LLM, no graph walk**.
- `layout` is parsed by `parseLayoutNode` (A2); its `ForEach` enumerates the selected array via the A3 `traversal.each` optic.
- For a selected concept, the explainer renderer is chosen by `mediumPatterns` (A1) read against the persisted preference (A5) — see B4.
- A host loader (`app/src`) consumes this artifact: registers `mediumPatterns` via `marinadaPattern()`, runs `source` via `pipeline.runSource()`, applies `select`, mounts `layout`. The reader artifact itself contains **no code**.

## B4. Deterministic medium selection — end to end

Per the annotation schema, a concept's `explained_by` yields explainers, each with `@core:medium` values (`1..*`) and one `@explainer:` slug ending `-<NN>`. The reader presents a concept; for each candidate explainer, a medium-scoring Marinada pattern scores its renderer by matching the explainer's media against the persisted preference.

**Scoring expression** (the `expr` for the B3 `mediumPatterns` entry). `_` = an explainer entity; `ctx.metadata.preferredMedium` = persisted pref (A5). Returns confidence or null:

```json
["let", ["pref", ["get", ["get", "ctx", "metadata"], "preferredMedium"]],
  ["let", ["media", ["get", "_", "medium"]],
    ["if", ["includes", "media", "pref"],
      ["-", 1.0, ["*", 0.01, ["count", "media"]]],
      null]]]
```

- **Any-medium match** (per schema §3): an explainer matches if ANY of its `medium` values equals the preference → `includes(media, pref)`.
- **Tie-break is folded into the score, deterministically** (schema §3 fixed order): base `1.0` minus a small penalty proportional to media-set size (`0.01 * count(media)`) implements "smallest superset wins" — a single-medium explainer (`count 1` → `0.99`) outranks a 3-medium one (`0.97`). The remaining tie-breaks (lowest `<NN>` ordinal, then lexicographic id) are **not expressible as a confidence number alone** — see W2.
- The registry's existing `matchPatterns` ranking (dedup by `rendererId`, highest confidence, sort desc) then picks the winning renderer. User can switch via the existing renderer-bar mechanism (`App.ts`); the chosen renderer/medium persists via A5; next session re-derives the same default.

**Wrinkle (W2): the schema's full tie-break needs entity identity, but patterns rank by `rendererId`.** `registry.matchPatterns` dedups by `rendererId` keeping the highest confidence — it does **not** carry which *explainer entity* won, only which renderer. If all explainers of a concept use the same `@dusklight/renderer-explainer`, the registry collapses them to one renderer with the max score and loses the per-explainer ordinal/id tie-break. **Resolution options:** (a) the `select`/ForEach layer pre-picks the single winning explainer per concept *before* renderer dispatch — i.e. medium selection happens as a **Marinada `select`/sort over explainers** (deterministic, all three tie-break keys available: `count(media)`, parsed `<NN>`, id), and the renderer just renders the chosen one; or (b) extend `PatternResult` to carry an opaque `subject` id. **Recommend (a)** — it keeps `Pattern`/registry untouched and puts the full deterministic tie-break in the reader's Marinada query where entity id/ordinal are in scope. Under (a), A1 medium-patterns become an *optional* convenience for the renderer-switch UI rather than the primary selection path; the primary selection is a sort in `select`. This is the most important design judgment in Part B.

## B5. What stays code vs data

- **Code (Dusklight plugins, in rhi-zone or a finance plugin package):** the actual display components — `@dusklight/renderer-explainer`, `@finance/renderer-concept`, a `medium:video` player, a `medium:interactive` host. Renderers are TS that mount DOM; they remain code.
- **Data (the READER artifact):** source config + selection query + layout tree + medium-scoring patterns + renderer references. No per-domain app code. A "law reader" vs a "finance reader" differ only in this JSON.
- **Boundary statement:** *how a medium is displayed* is code (a renderer plugin); *which entities, which layout, which renderer for which medium-preference* is data. The corpus contributes only data and renderer **references**; it ships no Dusklight code.

---

## Implementation sequencing (which gap unblocks which binding piece)

1. **A2 (layout loader)** — independent, smallest, no deps. Do first; unblocks B3's `layout`.
2. **A4 (runSource) + B1 (corpus SourceFactory)** — A4 first, then B1 rides it. Unblocks loading any corpus data at all.
3. **B2 (closure flattening)** — corpus-side build step, **independent of Dusklight**; can proceed in parallel. Unblocks B3 `select` and B4 tie-break.
4. **A3 (ForEach optic + Marinada optic ops)** — needs the `@dusklight/optics` leaf-package extraction (W1) first. Unblocks B3's `ForEach`/`traversal.each`. The enumeration-only subset is enough for B; deep-settable focus deferred.
5. **A5 (preference persistence)** — independent app-level; unblocks the *deterministic* half of B4.
6. **A1 (patterns-as-Marinada)** — needs A5's `MatchContext.metadata` threading to be useful. Unblocks B4's renderer-switch UI; **not** on the critical path for primary selection if B4 option (a) is taken.
7. **B3 + B4** — assemble last, on top of all above. B4 primary selection (sort in `select`) depends on A3 + B2; the A1 pattern path is the optional secondary.

Critical path: A2 → (A4+B1) → A3(via W1) + B2 → B3/B4. A1/A5 parallel-track the renderer-switch convenience.

## Assumptions & unresolved uncertainties

- **U1 — Marinada repo state unknown.** Could not check `~/git/rhizone/marinada` git status (it's the separate repo holding A1/A3 edits). Implementer must check before editing; dirty → its `TODO.md`.
- **U2 — optics dependency cycle (W1).** Recommended a `@dusklight/optics` leaf package to break the marinada↔core cycle for A3. Did not verify whether marinada already vendors any optic primitive; if it does, reuse it instead of a new package.
- **U3 — pattern→entity identity (W2).** `registry.matchPatterns` dedups by `rendererId` and cannot return *which explainer* won; the full schema tie-break (ordinal, id) is therefore not expressible in the A1 pattern path. Recommended doing primary medium selection as a Marinada sort in `select` (option a). Not validated against a built reader.
- **U4 — `lib:std` `sort`/`sort-by`.** B4 option (a) needs a stable sort with a custom key. Confirmed `filter`/`includes`/`map`/`reduce`/`find`; did **not** confirm a `sort`/`sort-by` op in `std.ts`. If absent, either add it to marinada std or fold the tie-break into a `reduce`-based argmin. **Verify before implementing B4(a).**
- **U5 — `<NN>` ordinal parsing.** The tie-break "lowest `<NN>`" requires parsing the trailing 2-digit ordinal from an `@explainer:` slug in Marinada (`str-slice`/`parse-int` exist as core ops, so feasible) — not prototyped.
- **U6 — corpus location capability.** `corpus://` scheme resolution (filesystem vs bundled vs HTTP) is assumed to be a host capability; the concrete cap shape is out of scope and undesigned here.
- **U7 — `MatchContext.metadata` typing.** `metadata` is `unknown`; reading `metadata.preferredMedium` in Marinada assumes the host writes that exact shape. No type guards it — convention only.
- **Out of scope (seam, not solved):** interactive-component embedding (`medium:interactive` renderer). The renderer is a Dusklight plugin (code); how its component/manifest loads (WASM / Web Component / iframe) is the separate open task — the binding only references the renderer id.
