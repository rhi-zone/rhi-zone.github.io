# Affordance Opacity

**See also:** [Why software is hard](/why-software-is-hard) (accessible version), [Interaction graph](/interaction-graph) (the solution), [Problems](/problems) (broader context)

The hidden commands problem. Why software feels like it's keeping secrets from you.

## The core problem

Software hides what you can do.

Commands live in menus you have to hunt through. Features hide behind modifier keys you'll never discover by accident. Right-click and hope. Hover and wait for a tooltip that may or may not appear. Open settings and scroll through dialogs looking for the thing you vaguely remember existing.

The interaction is *implicit*. It's buried in UI code, tangled with presentation logic. There's no way to ask "what can I do here?" - you hunt. You guess. You Google. You watch tutorials for software you've used for years, still discovering features.

This isn't a minor UX annoyance. It's a fundamental architectural choice that shapes how people experience software.

## Manifestations

**Menu hunting.** File → Edit → View → Tools → Help. Which one has the thing you want? Is it under Edit or Tools? Is it a submenu? Every app organizes differently. The answer is "memorize the arbitrary structure" or "hunt every time."

**Modifier key mystery.** Ctrl+K does something. Ctrl+Shift+K does something else. Ctrl+Alt+Shift+K might exist. How would you know? Some apps show hints in menus. Some have a keyboard shortcut viewer buried in Help. Most just... don't tell you. Power users discover features by accident or word of mouth.

**Context menu roulette.** Right-click and see what appears. Different on different elements. Different in different modes. Discoverable only by trying everywhere.

**Settings sprawl.** Preferences → General → Advanced → (scroll) → (scroll) → is it here? Software accumulates options over years. Nobody reorganizes. The answer to "can it do X?" is often "probably, somewhere in settings."

**Feature discovery by accident.** "Wait, you can do that?" "Yeah, just hold Shift while dragging." "How was I supposed to know that?" "I don't know, I found it on Reddit."

**The tutorial dependency.** Software so opaque that tutorials are mandatory. Not for complex tasks - for basic usage. The tutorial isn't teaching you a skill, it's revealing secrets the UI hides.

## Consequences

**Decision paralysis.** Too many options, none of them labeled with what they actually do. The paradox: more features, but harder to use any of them because you can't find them or evaluate them.

**Steep learning curves.** Not because the concepts are hard. Because the *interface* is hard. You're not learning the domain - you're learning the arbitrary hiding places of one particular app.

**Expertise as tribal knowledge.** Power users know things. They learned from other power users, from forums, from years of accident and discovery. The knowledge doesn't transfer - each app has its own secrets. You can be an expert in one tool and a beginner in another that does the same thing, because the expertise is about the hiding places, not the capabilities.

**Collaboration friction.** "How do I do X?" "Oh, go to View → Panels → Secondary Sidebar → Extensions → Settings → ..." You can't share context about what's possible. Helping someone means navigating them through menus verbally. Screen share becomes remote-piloting: "click the... no, the other thing."

**Power user vs everyone else.** The gap widens. Those who invested time discovering features get multiplicative returns. Those who didn't stay stuck in beginner mode forever, using 10% of the tool. Not because they can't learn - because the tool won't teach them.

**Software feels adversarial.** Like it's keeping secrets. Like there's a club of people who know, and you're not in it. The UI is a wall, not a guide.

## Why it happens

**UI code mixes concerns.** In most codebases, the button that does a thing and the logic for the thing are intertwined. The action isn't data - it's code. You can't query "what actions exist?" because they're not stored anywhere queryable. They're scattered across components, defined alongside rendering.

**No standard for introspection.** There's no protocol for "what can this application do?" Applications expose APIs (sometimes), but not self-descriptions of their capabilities. Compare to: web servers have `/robots.txt`, APIs have OpenAPI specs. UIs have... nothing.

**Historical accident.** WIMP (Windows, Icons, Menus, Pointer) emerged in the 1970s-80s. It was revolutionary then. It calcified into "how software works" before anyone questioned whether menus were the right abstraction. We inherited the paradigm, not the reasoning.

**Complexity as moat.** Cynically: hard to learn = hard to leave. If you've invested in mastering the hiding places, switching costs are high. Some companies benefit from this. Not a conspiracy, just misaligned incentives.

**Features ship, organization doesn't.** Adding a feature is one PR. Reorganizing the entire menu structure is a project. Features accumulate. Organization debt compounds. The result: software that grew without a plan.

**Interaction design isn't valued.** In FOSS especially, clever code and features get praise. "The UX is confusing" is seen as a user problem. Interaction design is dismissed as "not real engineering." So it doesn't get engineering effort.

## Partial solutions that exist

**Command palettes.** Ctrl+K (or Cmd+Shift+P, or whatever) opens a searchable list of commands. Revolutionary when VSCode popularized it. You can *search* for what you want. The interaction graph becomes queryable - at least by text search.

Limitations: still app-specific (each has its own palette), usually flat (no context, no relationships), not composable (can't chain commands), discovery requires knowing what to search for.

**Keyboard shortcut viewers.** Help → Keyboard Shortcuts. Or a cheat sheet PDF. Better than nothing. But it's a separate mode - you leave your work to look up how to do work. And it's static - doesn't show context-specific shortcuts.

**Tooltips on hover.** Hover over a button, see what it does (maybe). Inconsistent - some apps do it, some don't. Some tooltips are helpful ("Rotate selection 90° clockwise"), some are useless ("Rotate"). And you have to hover over everything to discover what's there.

**Discoverability hints.** Some apps surface random tips. "Did you know? Press Shift while dragging to constrain proportions." Better than nothing. Still random - you might never see the tip you need.

**Tutorials and onboarding.** Walk new users through features. A bandaid. The app is so opaque it needs a guided tour. And the tour is one-time - six months later, you've forgotten, and the tour won't re-run.

**Documentation.** Read the manual. Separate from the app, out of context, often outdated. The answer to "how do I X?" shouldn't be "leave the app and search the docs."

## What full transparency would look like

The [interaction graph](/interaction-graph) makes affordances explicit.

**Actions are data.** Every command, every capability exists as a queryable entity. Not buried in UI code - structured, introspectable.

**Context-aware filtering.** At any moment, the system knows what's relevant: current mode, selection, state, recent actions. Show 5-10 relevant actions, not 500 in a menu hierarchy.

**Intelligent surfacing.** Frecency (frequency + recency), relevance to current task, likelihood of intent. The command palette, but smarter - ordered by what you probably want, not alphabetically.

**Relationships are visible.** Not just "these commands exist" but "this leads to that." The graph of possibilities, navigable.

**Shareable context.** "Here's what I can do right now" is something you can show someone else. The interaction state is data, not just pixels on a screen.

**Learnable by inspection.** You can explore the capability space directly. Not through trial and error - through a map of what exists.

## The deeper point

Affordance opacity isn't just a UX problem. It's about who software is *for*.

Opaque software is for experts who already know, or for users who accept the floor. Transparent software is for everyone - experts move faster, beginners can actually learn, the middle ground doesn't require years of tribal knowledge.

The interaction graph isn't just a design pattern. It's a statement: software should be honest about what it can do.

