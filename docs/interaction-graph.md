# Interaction Graph

**See also:** [Affordance Opacity](/affordance-opacity) (the problem this solves), [Problems](/problems) (broader context), [Vision](/vision) (what we're exploring), [Zone Brainstorm](https://rhi.zone/zone/design/servers-brainstorm) (source conversation)

The interaction graph is a core design concept in rhi: **affordances as explicit, queryable data**.

## The Problem It Solves

Software hides what you can do. Commands live in menus you have to hunt through. Features hide behind modifier keys you'll never discover. The interaction is implicit - buried in UI code, not queryable, not shareable.

This creates real problems: decision paralysis (too many unlabeled options), steep learning curves (figure out what's even possible), expertise as tribal knowledge ("did you know Ctrl+Shift+K does...?"), collaboration friction (can't share context about what actions exist).

See [Affordance Opacity](/affordance-opacity) for the full problem statement.

## What It Is

Every affordance is an edge in the graph:

| UI Element | → Edge |
|------------|--------|
| Button | edge |
| Tab | edge |
| Context menu item | edge |
| Keybind | edge |
| Link | edge |
| Drag target | edge |
| Hover tooltip action | edge |

The interaction graph is **affordance structure**: what can you DO at any moment, and what does it lead to.

## Not Data Graphs

This is explicitly *not* what Obsidian or Dendron show:

| Obsidian graph | Interaction graph |
|----------------|-------------------|
| Data relationships | Affordance structure |
| "Your notes connect like this" | "From here, you can DO these things" |
| Static visualization | Navigational/action structure |
| Pretty but not actionable | Actually useful for filtering/discovery |

Obsidian rendered a graph. And? Visual noise, not insight. "Look, your notes are connected" - but what do you *do* with that?

The interaction graph is about the UI itself. What's available NOW. What's contextually relevant. What should be surfaced vs hidden.

## Why It Matters

WIMP hides commands in menus. You hunt through File → Edit → View hoping to find what you need. The commands exist, but they're implicit - buried in UI code, not queryable.

Command palettes are a partial fix: they make the interaction graph *searchable*. Ctrl+K surfaces available actions. VSCode goes further - commands are first-class, bindable, scriptable.

But command palettes are still typically:
- App-specific (each app has its own palette)
- Flat (no context, no history)
- Not composable (can't chain commands)
- Not introspectable (can't ask "what commands exist that operate on X?")

## Discoverability at Scale

"Discoverability doesn't scale" is wrong. The problem isn't having thousands of actions. It's *showing* thousands of actions.

If you have:
1. **Interaction graph** - all actions exist as structured, queryable data
2. **Mode filtering** - current task/mode determines which slice is relevant
3. **Context filtering** - selection, state, recent actions narrow further
4. **Intelligent ordering** - frecency, relevance, likelihood

Then:
- Total actions: thousands
- Visible at any moment: 5-10
- Full graph available via search when needed

This is what Blender modes *almost* do. Edit mode shows edit tools, sculpt mode shows sculpt tools. But it's coarse - still dozens per mode. Finer-grained context filtering could narrow to what's actually relevant *right now*.

## First-Class Citizen

The insight: **interaction graph as first-class citizen**. Not just "UI has actions" but actions-as-data, queryable, composable.

What this enables:
- Views are projections of the graph (not the source of truth)
- Different frontends render the same graph differently
- The graph IS the system; UI is just one projection
- Actions become inspectable, programmable, composable

| Frontend | Projection of affordances |
|----------|--------------------------|
| Web | Buttons, forms, clicks |
| CLI | Commands, flags, args |
| TUI | Keys, menus, prompts |
| Discord | Slash commands, reactions |
| Voice | Utterances, intents |

Same graph, different rendering. The "paradigm" is the graph, not the pixels.

## Architecture Implications

If the interaction graph is explicit:
- Object sources are pluggable (not hardcoded integrations)
- Views are ALSO pluggable (swap renderers without changing logic)
- Layout is user-controlled (not app-dictated)
- The backend owns the affordances; frontends just render them

This is why rhi projects are designed as headless cores with frontend-agnostic interfaces. The interaction graph lives in the server (MOO verbs, entity affordances, command capabilities). Frontends just project it.

## Graph Visualization (Separately)

Graph *visualization* is worth exploring - but for different reasons:
- Navigate by relationship
- Show what's relevant NOW
- Connect to actions
- Filter by context

Not "here's all your notes as dots" (useless), but "from here, what's related, and what can I do about it?"

## Clean Graphs, Not Filtered Messy Graphs

If the interaction graph is too connected, the problem isn't filtering. It's architecture.

A well-designed system has a clean graph:
- Not because you filtered a messy one
- Because the affordances are thoughtfully designed
- Clear what you can do, clear where it leads

Structure informs design. The interaction graph isn't "render the relationship data." It's "use relationship data to determine importance, placement, affordances."

