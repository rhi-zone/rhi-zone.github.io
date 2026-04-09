# Affordance Types

**See also:** [Interaction Graph](/interaction-graph), [Affordance Surfaces](/affordance-surfaces), [Affordance Opacity](/affordance-opacity)

The word "affordance" is frequently conflated with "command" — a labeled, executable, keyboard-shortcuttable action that appears in a palette or menu. This conflation impoverishes the design space. Commands are one affordance type. There are several others, and they behave very differently.

## The spectrum

**Commands** are labeled, executable, addressable. They have an ID, a human-readable name, optionally a keyboard shortcut. They appear in command palettes, menus, toolbars. They're the affordance type that software developers think of first, because they're the easiest to represent as data.

**Gestural affordances** are spatial and physical. Drag handles, resize edges, reorder handles, pinch-to-zoom targets. They don't have labels. They're discovered through hover states, cursor changes, or experimentation. They operate on position and direction, not selection-and-execute.

**Ambient affordances** inform rather than act. Hover tooltips, status indicators, progress states, focus rings. They communicate the current state of the system and signal what's possible without requiring an action. Removing them doesn't remove a capability — it removes the signal that the capability exists.

**Navigational affordances** change context without transforming content. Tabs, breadcrumbs, back buttons, links, focus regions. They traverse the interaction graph rather than executing a transformation at a node. The distinction matters: a "Save" command transforms content; a "Close" button navigates to a different state.

**Directional affordances** operate on vectors. Swipe gestures, scroll, pan, rotate. They're continuous rather than discrete. They have no natural "undo" semantics and often map to direct manipulation of a spatial model.

**Data-entry affordances** are two-way channels. Text inputs, sliders, color pickers, date pickers. They're not actions — they're bindings between UI and state. They're affordances in the sense that they enable the user to *do* something (change a value), but their grammar is different from commands.

## Why the distinction matters

Each affordance type has different properties along several axes:

| Type | Labelled | Discoverable | Undoable | Composable |
|------|----------|--------------|----------|------------|
| Command | Yes | Yes | Usually | Yes |
| Gestural | Rarely | Low | Sometimes | Rarely |
| Ambient | N/A | High | N/A | N/A |
| Navigational | Usually | Medium | Via back | No |
| Directional | No | Low | Sometimes | No |
| Data-entry | Via label | Medium | Via reset | No |

Commands are highly composable and discoverable but require deliberate invocation. Gestural affordances are fast but hidden. A good system has the right mix for its context — not "everything as commands" or "everything as gestures."

## Different surfaces render different types

The same underlying affordance set renders differently depending on which types are relevant to a given surface:

A **command palette** renders commands only. Gestural and ambient affordances don't translate to a search box.

A **toolbar** renders commands (as buttons) and data-entry affordances (as inline inputs). Gestural affordances don't belong here.

A **context menu** renders commands and navigational affordances. It appears spatially near a target, making gestural affordances redundant.

A **canvas** renders gestural, directional, and ambient affordances. Commands appear as overlay toolbars or radial menus, not inline.

The mistake is designing a single affordance surface that tries to present all types uniformly. Menus full of gestural affordances are confusing (what does "drag" mean in a menu?). Canvases full of explicit command buttons are cluttered.

## Affordance discovery by type

Different types have different discovery mechanisms, and ignoring this is a major source of learnability problems.

Commands benefit from explicit enumeration: menus, palettes, tooltips with keyboard shortcut hints. Users can browse.

Gestural affordances are mostly discovered through exploration or instruction. The cursor change on hover is the primary signal. This is fragile — users who don't move the cursor over every pixel never discover them. Tutorials and animated hints partially compensate.

Ambient affordances are always visible by definition — the challenge is not discovery but attention. Status bars and indicators that no one watches are ambient affordances that have failed.

Navigational affordances rely on spatial consistency. If breadcrumbs always appear in the same place, users learn to look there. If they move contextually, users miss them.

## Implications for an interaction graph model

A data model that only represents commands will produce a system biased toward commands. The interaction graph should be typed by affordance type — not because types change the graph structure (every affordance is still an edge), but because they inform how edges are rendered, how they're discovered, and what constraints apply.

A resize handle and a "Resize" menu item are the same semantic operation — "resize this thing" — but they're different affordance types with different appropriate surfaces, different discovery mechanisms, and different UX constraints. A model that conflates them will surface them inappropriately.

The richer framing: the interaction graph encodes what can be done, and the affordance type encodes how it should be presented and discovered. Both are necessary. The type system for affordances is at least as important as the data model for the graph itself.
