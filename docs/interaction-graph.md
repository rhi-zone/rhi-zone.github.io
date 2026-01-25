# Interaction graph

**See also:** [Why software is hard](/why-software-is-hard) (the problem, accessible), [Affordance opacity](/affordance-opacity) (the problem, technical), [Explorations](/explorations) (related hypotheses), [Prior art](/prior-art) (things that got it right), [Problems](/problems) (broader context), [Zone Brainstorm](https://rhi.zone/zone/design/servers-brainstorm) (source conversation)

**Every affordance is an edge in the graph.**

| UI element | → Edge |
|------------|--------|
| Button | edge |
| Tab | edge |
| Context menu item | edge |
| Keybind | edge |
| Link | edge |
| Drag target | edge |
| Hover tooltip action | edge |

The interaction graph is **affordance structure**: what can you DO at any moment, and what does it lead to. This lens answers the fundamental question: **what can you do, and how do you know?**

## Not data graphs

This is explicitly *not* what Obsidian or Dendron show:

| Obsidian graph | Interaction graph |
|----------------|-------------------|
| Data relationships | Affordance structure |
| "Your notes connect like this" | "From here, you can DO these things" |
| Static visualization | Navigational/action structure |
| Pretty but not actionable | Useful for filtering/discovery |

Obsidian rendered a graph. And? Visual noise, not insight. "Look, your notes are connected" - but what do you *do* with that?

The interaction graph is about the UI itself. What's available NOW. What's contextually relevant. What should be surfaced vs hidden.

## The problem it reveals

Most software hides its interaction graph. Commands live in menus you have to hunt through. Features hide behind modifier keys you'll never discover. The graph is implicit - buried in UI code, not queryable, not shareable.

This framing explains why software feels hard: decision paralysis (too many unlabeled options), steep learning curves (figure out what's even possible), expertise as tribal knowledge ("did you know Ctrl+Shift+K does...?"), collaboration friction (can't share context about what actions exist).

See [Why software is hard](/why-software-is-hard) for an accessible take, or [Affordance opacity](/affordance-opacity) for the technical deep dive.

## Why it matters

WIMP hides commands in menus. You hunt through File → Edit → View hoping to find what you need. The commands exist, but they're implicit - buried in UI code, not queryable.

Command palettes are a partial fix: they make the interaction graph *searchable*. Ctrl+K surfaces available actions. VSCode goes further - commands are first-class, bindable, scriptable.

But command palettes are still typically:
- App-specific (each app has its own palette)
- Flat (no context, no history)
- Not composable (can't chain commands)
- Not introspectable (can't ask "what commands exist that operate on X?")

VSCode is a notable exception - commands filter by active editor type, extension context, current mode. Git commands appear when you're in a repo. Language-specific commands appear for that language. Plus frecency. This shows context-awareness is tractable; most implementations just don't bother.

## Discoverability at scale

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

## The lens applied

When you look at software through the interaction graph lens, frontends become projections:

| Frontend | Projection of affordances |
|----------|--------------------------|
| Web | Buttons, forms, clicks |
| CLI | Commands, flags, args |
| TUI | Keys, menus, prompts |
| Discord | Slash commands, reactions |
| Voice | Utterances, intents |

Same underlying graph, different rendering. The "paradigm" is the graph, not the pixels.

This reframes questions:
- "Why is this app hard to use?" → "Where is the interaction graph hidden or tangled?"
- "Why do experts seem magical?" → "They've internalized a graph that isn't visible to newcomers"
- "Why do multi-app workflows feel clunky?" → "Each app has its own isolated graph with no shared structure"

Software that makes its interaction graph explicit would have different properties: pluggable views, user-controlled layout, inspectable actions. Whether that's achievable at scale is an open question - but the lens helps diagnose why current software often feels opaque.

## What the lens reveals

Applying this lens to existing software reveals patterns:

**WIMP is paper skeuomorphism.** Windows are pieces of paper. Scrolling is long paper. Menus are hidden paper. Tabs are stacked paper. The entire GUI paradigm is "what if paper, but screen." We built the most interactive medium in history and made it cosplay as an office supply store. Paper's limitations (static, linear, waiting to be found) carry over.

**Modality works when it matches task.** Blender modes, vim modes, VSCode's different contexts - task-based modality reduces clutter by showing only relevant tools. The bad modality is "which dialog is active?" The good modality is "I'm sculpting, so I see sculpt tools."

**Command palettes are a crutch.** They're "discoverable" in that you can search for anything. But they're also a dumping ground: "we don't have a place for this, so put it in the giant bag of every other action." The best affordances don't require searching - things are where you expect them.

**The hierarchy of discoverability:**

| Tier | What it looks like |
|------|-------------------|
| Best | Affordances so clear you don't need to search |
| Good | Contextual actions (right-click, hover reveals) |
| Okay | Organized menus (at least categorized) |
| Crutch | Command palette (find it *if* you know what to search) |
| Bad | Hidden (keyboard shortcuts with no hint) |

**Toolkits shape paradigms.** Win32 gives you `CreateMenu()` but not `CreateRadialMenu()`. So 99% of developers use linear menus - not because they're better, but because they're *there*. Radial menus are faster (Fitts's Law) and more memorable (direction vs position), but the toolkit didn't provide them. The paradigm calcified around what happened to be implemented in 1990.

**Spatial interfaces existed and were abandoned.** The original Mac Finder was spatial - each folder was its own window, always in the same position. You knew where things were. Changed to browser model because "too many windows." The spatial memory was a feature, not a bug, and we threw it away.

**Linear feeds control thought sequence.** If creativity is connection-making, and the platform chooses what sequence you see things in, the platform shapes which connections you make. Graph/spatial navigation gives you agency over your input stream. This reframes "platforms are bad for attention" into "platforms are bad for cognition."

## Failure modes

When an interaction graph is broken, it manifests in predictable ways:

| Failure mode | What it looks like |
|--------------|-------------------|
| **Hidden features** | Capabilities exist but are only discoverable via docs, forums, or accident. "Did you know you can Shift+drag to..." Worse when docs are online-only |
| **Modal confusion** | Current mode unclear. Actions do unexpected things because you're in the wrong state. Vim's modes done badly |
| **Actions far from targets** | The thing you want to affect and the action that affects it are distant. Menu bar commands for canvas objects |
| **Inconsistent patterns** | Same gesture does different things in different contexts. Right-click behavior varies arbitrarily |
| **Invisible state** | System state that affects behavior but isn't shown. Why did that command fail? What mode am I in? |
| **No undo** | Actions are irreversible, or undo is partial/broken. Fear of exploration |
| **Destructive defaults** | Dangerous actions are easy to trigger, safe actions require confirmation |
| **Search as only navigation** | The only way to find features is search. No spatial/structural navigation. Command palette as entire UI |
| **Orphaned affordances** | Features that exist but connect to nothing. Dead ends in the graph |
| **Circular dependencies** | To do A you need B, to do B you need A. Onboarding traps |

Graph topology problems:

| Shape problem | What it means |
|---------------|---------------|
| **Over-connected nodes** | One state has too many outgoing edges. Decision paralysis. The 50-item menu |
| **Sparse regions** | Areas with few affordances. "You can get here but there's nothing to do" |
| **Bottleneck nodes** | Everything routes through one point. Single point of navigation failure |
| **Unbalanced depth** | Some features 1 click away, others buried 7 levels deep. Arbitrary hierarchy |
| **Missing shortcuts** | Common operations require too many hops. No direct edges for frequent paths |
| **Disconnected subgraphs** | Features that don't connect to the rest of the system. Siloed functionality |

These aren't just UX complaints. They're structural problems in the interaction graph: missing edges, hidden nodes, broken connections, unclear state. The lens helps diagnose *what's actually wrong* rather than just "it feels bad."

## Graph visualization (separately)

Graph *visualization* is worth exploring - but for different reasons:
- Navigate by relationship
- Show what's relevant NOW
- Connect to actions
- Filter by context

Not "here's all your notes as dots" (useless), but "from here, what's related, and what can I do about it?"

## Clean graphs, not filtered messy graphs

If the interaction graph is too connected, the problem isn't filtering. It's architecture.

A well-designed system has a clean graph:
- Not because you filtered a messy one
- Because the affordances are thoughtfully designed
- Clear what you can do, clear where it leads

Context filtering isn't a solution for bad design - it's a coping mechanism. The real solution: design a graph that doesn't need heroic filtering. Keep connections meaningful. Keep complexity appropriate.

**Case study:** Normalize (code intelligence) started with dozens of specialized commands - discoverability wasn't the problem, there was just too much to discover. The fix wasn't better surfacing. It was collapsing them into three primitives: `view`, `edit`, `analyze`. Now there's less to discover in the first place.

This is "generalize, don't multiply" - fewer concepts that compose beats many specialized concepts that don't. See also: [100 Rabbits / Uxn](https://100r.co/site/uxn.html) - a VM you can hold in your head. Comprehensible systems are possible when simplicity is the goal.

Structure informs design. The interaction graph isn't "render the relationship data." It's "use relationship data to determine importance, placement, affordances."