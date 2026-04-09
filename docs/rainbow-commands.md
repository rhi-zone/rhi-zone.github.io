# Rainbow Commands

**See also:** [Interaction Graph](/interaction-graph), [Affordance Types](/affordance-types), [Affordance Surfaces](/affordance-surfaces)

Design notes for `@rhi-zone/rainbow-commands` — the affordance model layer for rainbow apps. This document captures what has been decided, what is strongly leaning one way, and what remains genuinely open. It is intentionally not a specification: the design has not been validated against real UI code and should not be treated as settled.

---

## What this layer does (and doesn't do)

`@rhi-zone/rainbow-commands` is the **affordance model**: a registry of what actions exist, which are currently available, and how they should be ordered. It does not handle keyboard routing, key binding storage, or UI components — that is the keybinds library's job. The two connect via a thin bridge.

```
App state (Signal<S>)
    ↓
rainbow-commands: registry → active command set
    ↓
keybindsContext (rainbow-ui): bridges to keybinds library
    ↓
keybinds: key routing, BindingsStore, CommandPalette, ContextMenu, RadialMenu
```

Each layer is independently useful. An app can use the keybinds library without rainbow-commands. An app can use rainbow-commands without the full keybinds component suite.

---

## Starting point: commands only

The [full affordance spectrum](/affordance-types) includes commands, gestural, ambient, navigational, directional, and data-entry types. Commands are the tractable subset: labeled, executable, keyboard-shortcuttable, palette-searchable.

The initial design covers commands only. If affordance type becomes relevant, it slots in as a discriminated field (`type: 'command' | 'gestural' | ...`) without breaking the command-only case.

---

## The Command type

```ts
type Command = {
  id: string
  label: string
  shortcut?: string
  icon?: string
  group?: string
  priority?: number        // explicit hint for scorer, default 0
  available: ReadonlySignal<boolean>
  execute(): void | Promise<void>
}
```

**No type parameter.** Commands close over the signals and setters they need. `execute` is `() => void`, not `(s: S) => S` — state transitions happen inside `execute` via `signal.set(...)`. This composes naturally across scope boundaries that would otherwise have incompatible state types.

**`available` is a `ReadonlySignal<boolean>`.** This fits the rainbow reactive model and enables the registry to maintain a reactive `active` signal without polling. Simple cases: `signal(true)` (always available) or `panel.map(p => p.mode === 'viewing')` (contextual).

> **Open question — available as function vs signal.** `available: () => boolean` is more familiar to developers coming from plain JS, and it's what the keybinds library uses (`when: (ctx) => boolean`). The signal form requires knowing rainbow's signal API at command-definition time, which is a coupling cost. The signal form is necessary for a reactive `active` signal in the registry; the function form would require either polling or making `active` non-reactive (computed on demand). Not settled.

---

## CommandRegistry

```ts
type CommandRegistry = {
  push(scope: CommandScope): () => void   // returns pop
  readonly active: ReadonlySignal<ReadonlyArray<Command>>
  record(id: string): void                // called after execute, for frecency
  readonly history: ReadonlyArray<{ id: string; at: number }>
}

type CommandScope = {
  readonly id: string   // for debugging
  readonly commands: ReadonlyArray<Command>
}

function createCommandRegistry(): CommandRegistry
```

`active` is the flattened, deduplicated, availability-filtered command set from all pushed scopes. Deduplication by `id` follows stack order — the top scope wins. This means a modal can shadow a page-level command with the same `id`.

`record` + `history` exist for frecency scoring. The registry tracks execution history; scorers consume it.

> **Open question — dynamic subscription management.** `active` needs to recompute when any `available` signal changes. With N commands across all scopes, the registry must dynamically subscribe to N signals — and update those subscriptions as scopes are pushed and popped. This is a tractable but non-trivial dependency tracking problem. Whether this warrants a custom mechanism or fits cleanly onto existing signal infrastructure is unresolved.

> **Open question — scope model for non-linear UIs.** Push/pop is clear for modal flows (open → push, close → pop). It is less clear for tab-based or panel-based UIs where multiple views are simultaneously mounted and each has its own command set. Is a stack the right model, or should scopes be a set with explicit priority ordering? Not tested against real cases.

> **Open question — frecency and shadowed commands.** If a modal shadows a page command with the same `id`, does executing the modal version count against the page command in frecency history? They share an `id` but may have different semantics. This may not matter in practice but the model doesn't have an answer yet.

---

## Scoring

The scorer is always injectable. Commands in `active` are sorted by score; ties preserve declaration order.

```ts
type Scorer = (command: Command, history: ReadonlyArray<{ id: string; at: number }>) => number

function defaultScorer(): Scorer
```

`defaultScorer` combines two signals:

- **Priority** — `command.priority ?? 0`. Explicit author hint. Higher = more relevant.
- **Frecency** — `+3` if executed in last 60s, `+2` in last 5min, `+1` in last 30min.

**Context specificity** (commands that are rarely available score higher when they are available) is the more interesting signal — see [Interaction Graph § what does the user most likely want to do next](/interaction-graph#what-does-the-user-most-likely-want-to-do-next). It requires runtime observation of how often `available` is true. Not in v1; `priority` is the explicit proxy for now.

---

## Convenience API

```ts
// Push a set of commands, return cleanup
function useCommands(registry: CommandRegistry, commands: Command[]): () => void

// Create a command — shorthand to avoid repeating the type
function command(def: Command): Command
```

---

## Bridge to keybinds

`keybindsContext` (in `@rhi-zone/rainbow-ui`) connects the registry to the keybinds library:

```ts
// packages/ui/src/keybinds.ts
function keybindsContext<S>(
  keybindsFn: KeybindsFn,
  commands: Command[],
  state: Signal<S> | ReadonlySignal<S>,
  buildContext: (s: S) => Record<string, unknown>,
): () => void
```

With rainbow-commands, the pattern becomes: push a scope to the registry, and derive the keybinds `when` predicates from `command.available.get()` rather than from a manual context object:

```ts
const registry = createCommandRegistry()

const commands: Command[] = [
  {
    id: 'contact.edit',
    label: 'Edit Contact',
    shortcut: 'e',
    available: panel.map(p => p.mode === 'viewing'),
    execute: () => startEdit(panel.get().contactId),
  },
  {
    id: 'contact.delete',
    label: 'Delete Contact',
    shortcut: 'Delete',
    available: panel.map(p => p.mode === 'viewing'),
    execute: () => deleteContact(panel.get().contactId),
  },
]

useCommands(registry, commands)
```

The `active` signal feeds the keybinds component suite. The ContextMenu receives `registry.active.get()` as its command list.

---

## What this has not been tested against

- **Real multi-action surfaces** — the contacts example app (the closest thing to real UI) doesn't exercise commands at all. Its buttons are plain click handlers. The command model would add keyboard shortcuts and a palette, but those weren't needed for the example's scope.
- **A scheduling app UI** — the natural first real consumer (lesson scheduling, billing actions, context menus per item) doesn't have a UI layer yet.
- **Modal scope stacking** — the push/pop scope model is theoretically sound for linear modal flows but hasn't been exercised in code.
- **Tab/panel UIs** — unresolved at the model level.

The design is internally consistent but unvalidated. It should be treated as a starting hypothesis, not a specification. The first real app to use it will break something.
