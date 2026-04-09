# Affordance Surfaces

**See also:** [Interaction Graph](/interaction-graph), [Affordance Types](/affordance-types), [Affordance Opacity](/affordance-opacity)

An affordance surface is any UI element that renders a set of available actions: a toolbar, a context menu, a command palette, a ribbon, a radial menu. The same underlying affordance set can be rendered as any of these — the surface is the presentation, not the data.

How a surface performs depends almost entirely on one constraint.

## Miller's Law is not a guideline

Humans can hold 7±2 items in working memory simultaneously. This is not a soft UX recommendation — it's a hard limit on human cognitive architecture. Any affordance surface that presents more than ~7 items at once crosses a threshold: it stops being a *scanning* surface and becomes a *searching* surface.

Below the threshold, users glance and act. Above it, users hunt. The surface has failed its primary job regardless of how well-organized it is.

This threshold applies at every level of a hierarchy, not just the top. A ribbon that has 6 tabs (within limit) but 40 commands per tab (way over) still fails — because you see all commands simultaneously, not just the tabs. The chunking benefit collapses when multiple levels are visible at once.

The implication is stark: **showing "everything available" is almost never the right answer**, even after filtering. The goal is to show ~5–7 things that are relevant *right now*.

## The ribbon

Microsoft Office's ribbon is the most-studied large-scale affordance surface. It got some things right.

**What it got right:** Contextual tabs are a genuine insight — when you select an image, Picture Format appears; when you select a table, Table Design appears. The interaction graph becomes visible in response to selection state. Semantic grouping (commands clustered into named groups like Font, Paragraph, Styles) is also right in principle.

**What it got wrong:** A single ribbon tab — Home in Word — contains roughly 40–50 individual controls. This is 5–6× over the working memory limit. Users cannot scan it. They have to search it, which defeats the purpose of a visual affordance layout.

The ribbon uses groups to chunk commands into ~5–6 groups per tab. That's Miller-aware at the group level. But it displays all groups and all commands within all groups simultaneously. The hierarchical chunking benefit is negated by simultaneous display. You see 6 groups × 8 commands = ~48 things at once. The chunking is structural but not perceptual.

The uniform visual weighting compounds this. Cut/Copy/Paste and Subscript sit at the same visual level. The surface has no sense of frequency, recency, or current intent — it can't tell you that Bold is used 100× more often than Format Painter. Everything gets equal screen real estate.

Contextual tabs, for all their cleverness, are also too coarse. They appear based on selected *object type*, not on the user's current *intent*. Selecting any image shows Picture Format — but the system doesn't know whether you're doing layout, color correction, or cropping. Object type is a rough proxy for intent, not intent itself.

The eventual addition of "Tell me what you want to do" — a command palette retrofitted onto the ribbon in 2016 — is the admission that the ribbon didn't solve discoverability. A surface that requires a search escape hatch for common operations has failed at its primary job.

## Context menus

Context menus carry the same failure mode in vertical form. A context menu with 20 items is a vertical ribbon. Separator lines help marginally but don't solve the Miller's Law problem — you're still presenting 20 items to a human who can process 7.

Submenus don't fix this either. They push the problem one level deeper while adding navigation cost: the user must now hover to reveal, then scan a second surface. The total cognitive load increases even though each individual surface is smaller.

A context menu should have ~7 items. This is only achievable if the system genuinely knows what's irrelevant for the specific cursor position in the specific state. Not broad category filtering — precise contextual awareness.

## Filtering vs. prioritization

There's a common instinct to solve overloaded surfaces through prioritization: show important things bigger, dimmer for less-important things, add visual hierarchy. This doesn't work because the items are still there, still occupying working memory slots.

The gain from context-aware affordance modeling is not prioritization — it's **removal**. Irrelevant affordances aren't demoted; they're absent. The surface shrinks to only what's real for this moment.

This reframes the design question. It's not "how do we make 40 commands easier to scan?" but "what are the 5–7 things this user most likely wants to do right now, and how do we show only those?"

The answer requires genuine knowledge of user intent — not just object type, not just current mode, but something closer to: what have they been doing, what are they looking at, what's the next natural step in this workflow?

## Spatial semantics and muscle memory

Affordance surfaces have spatial semantics. A button in the bottom-right corner of a dialog carries different meaning than the same button label in a toolbar. Users don't just learn "there's a Save action" — they learn "Save is in the bottom-right, Cancel is next to it, Delete is on the left, and that's always where they are."

This spatial memory is not a nice-to-have. It's how affordance surfaces become fast. Muscle memory is the goal — users stop reading labels and start navigating by position. Destroying spatial consistency destroys muscle memory. Every time affordances move, users must re-read everything.

The right primitive for spatial consistency is **semantic groups with stable identity across rendering contexts**. Not hardcoded coordinates, but a grammar of groups (primary action, secondary action, destructive action, navigation) that render consistently wherever they appear — in dialogs, in toolbars, in context menus. The position changes; the spatial relationships within the group do not.

## Adaptive layout: stability earned per-item

The spatial semantics model above describes a static ideal — groups with stable identity. But for a real user interacting with a real surface over time, the question is more dynamic: how does the layout get *to* that stable state, and what happens when usage patterns change?

The key is that **stability is earned per-item, not assumed globally.**

For a new user, nothing has spatial meaning yet. No muscle memory has formed. The initial layout can be optimized freely — for learnability, for relevance, for whatever the system estimates is most useful. Position carries no cost to change because no position has been learned.

As a user interacts, individual items accumulate use. An item used frequently from a consistent position builds spatial memory for that item at that position. This is the unit of stability: not "the surface is stable" but "this specific item, at this specific position, has been used enough that moving it now has a real cost."

When an item falls out of use, its slot becomes a vacancy. The question is what fills it. The answer: other items that don't yet have spatial memory — items that are candidates for the user's attention but haven't locked in yet. These flow into available slots. Stable items don't move to fill gaps; they stay pinned.

This is a **pinning model, not a sorting model.** Stable items are pinned at their positions as hard constraints. Unstable items flow around the pinned ones, filling remaining slots by relevance and recency.

Implications:

- A power user's surface progressively converges on a fully pinned layout — all 7 slots have spatial meaning, nothing moves, every position is where they expect it.
- A surface mid-transition might have 3 pinned slots and 4 fluid ones. The 4 fluid slots can vary by context; the 3 pinned slots are fixed.
- The end state for a power user isn't "context filtering selects 7 from thousands at runtime." It's "this surface has 7 stable items for this context, and the filtering already happened when usage patterns crystallized." Context filtering and layout stability work together: filtering keeps the candidate pool small; stability locks the result into muscle memory.
- A gap left by a departed item doesn't shift neighboring stable items. It waits for a new candidate. Each item's stability is independent.

The practical design question this surfaces: what signal earns stability? Raw use-count is the simplest proxy. Better proxies involve consistency of position across sessions (if the user always reaches for item X at position 3, position 3 is stable regardless of raw count). The ideal metric is something like: "how much would moving this item degrade the user's performance?" — which is approximable but never perfectly measurable.

## The command palette as escape hatch

Command palettes solve a different problem than other affordance surfaces. They're not for the things you want to do right now — they're for things you occasionally need but can't find. They're escape hatches, not primary navigation.

The hierarchy of discoverability runs from "affordances so obvious you never think about them" down to "keyboard shortcut with no hint." The command palette sits somewhere in the middle: better than nothing, worse than contextual affordances. A well-designed surface makes the palette rarely necessary.

The pathological case is a surface where the palette *is* the primary navigation — where the toolbar and menus are vestigial and everyone just Ctrl+Ks their way through the app. This is a sign that the contextual affordance model has failed, not that palettes are a good design.

## Radial menus and Fitts's Law

Fitts's Law says the time to acquire a target is a function of its distance and size. A linear context menu penalizes items at the bottom — they're farther from the cursor and require precise vertical movement. A radial menu places all items equidistant from the cursor, eliminating the distance penalty entirely. Every item is equally fast to reach.

Eight segments maps onto Miller's Law cleanly. Direction becomes muscle memory faster than position — "bold is up-right" is more durable than "bold is the fourth item down." Blender's radial menus and game weapon-select wheels demonstrate this: experienced users stop reading and navigate by direction alone.

The reason radial menus haven't displaced linear menus is labeling. Text labels are hard to lay out in a circle — they curve awkwardly, truncate, or require narrow columns that are hard to read. A bilateral layout solves this:

```
     AAAA    BBBB
  CCCC          DDDD
  EEEE          FFFF
     GGGG    HHHH
```

Four labels on each side, flush to their respective edges, fully readable, with direction still clearly encoded. Eight items, Miller-compliant, Fitts-optimal.

This works well for spatial and gestural affordances where direction carries semantic meaning — canvas tools, sculpting modes, game actions. It works poorly for arbitrary command sets where direction carries no meaning and users must read every label every time. The muscle memory benefit only accrues when the mapping is stable and semantically motivated.

A radial menu is not a general replacement for context menus. It's the right surface for a specific affordance type — spatial, repeated, direction-meaningful — and the wrong surface for everything else.

## What a good surface looks like

A good affordance surface:

- Shows ≤7 items at any moment, at any level of the hierarchy
- Achieves this through removal, not prioritization
- Has stable spatial semantics that survive across contexts
- Adapts to intent, not just object type
- Has a clear escape hatch (search/palette) for the rare case
- Is one rendering of an underlying affordance model, not the model itself
