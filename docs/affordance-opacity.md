# Affordance Opacity

**See also:** [Why software is hard](/why-software-is-hard) (accessible version), [Interaction graph](/interaction-graph) (the diagnostic lens), [Explorations](/explorations) (related hypotheses), [Prior art](/prior-art) (things that got it right), [Problems](/problems) (broader context)

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

**The tutorial dependency.** Software so opaque that tutorials are mandatory. Not for complex tasks - for basic usage. The tutorial isn't teaching you a skill, it's revealing secrets the UI hides. See also: [todepond's "Just"](https://www.todepond.com/wikiblogarden/better-computing/just/) on how "just do X" hides enormous assumed knowledge.

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

**Toolkits locked it in.** Win32 gives you `CreateMenu()` but not `CreateRadialMenu()`. So 99% of developers use linear menus - not because they're better, but because they're *there*. Radial menus are faster (Fitts's Law: all options equidistant from cursor) and more memorable (direction vs position), but the toolkit didn't provide them. The paradigm calcified around what happened to be implemented.

**Complexity as moat.** Cynically: hard to learn = hard to leave. If you've invested in mastering the hiding places, switching costs are high. Some companies benefit from this. Not a conspiracy, just misaligned incentives.

**Features ship, organization doesn't.** Adding a feature is one PR. Reorganizing the entire menu structure is a project. Features accumulate. Organization debt compounds. The result: software that grew without a plan.

**Interaction design isn't valued.** In FOSS especially, clever code and features get praise. "The UX is confusing" is seen as a user problem. Interaction design is dismissed as "not real engineering." So it doesn't get engineering effort.

## Partial solutions that exist

**Command palettes.** Ctrl+K (or Cmd+Shift+P, or whatever) opens a searchable list of commands. Revolutionary when VSCode popularized it. You can *search* for what you want. The interaction graph becomes queryable - at least by text search.

But command palettes are also a crutch: "we don't have a proper place for this, so put it in the giant bag of every other action." The best affordances don't require searching - things are where you expect them. A command palette that contains everything is admitting the UI failed to organize.

Limitations: still app-specific (each has its own palette), usually flat (no context, no relationships), not composable (can't chain commands), discovery requires knowing what to search for.

**Keyboard shortcut viewers.** Help → Keyboard Shortcuts. Or a cheat sheet PDF. Better than nothing. But it's a separate mode - you leave your work to look up how to do work. And it's static - doesn't show context-specific shortcuts.

**Tooltips on hover.** Hover over a button, see what it does (maybe). Inconsistent - some apps do it, some don't. Some tooltips are helpful ("Rotate selection 90° clockwise"), some are useless ("Rotate"). And you have to hover over everything to discover what's there.

**Discoverability hints.** Some apps surface random tips. "Did you know? Press Shift while dragging to constrain proportions." Better than nothing. Still random - you might never see the tip you need.

**Tutorials and onboarding.** Walk new users through features. A bandaid. The app is so opaque it needs a guided tour. And the tour is one-time - six months later, you've forgotten, and the tour won't re-run.

**Documentation.** Read the manual. Separate from the app, out of context, often outdated. The answer to "how do I X?" shouldn't be "leave the app and search the docs."

## What transparency would require

The [interaction graph](/interaction-graph) lens suggests what explicit affordances would look like - whether this is achievable at scale is an open question.

**Actions as data.** Every command, every capability would exist as a queryable entity. Not buried in UI code - structured, introspectable.

**Context-aware filtering.** The system would know what's relevant: current mode, selection, state, recent actions. Show 5-10 relevant actions, not 500 in a menu hierarchy.

**Intelligent surfacing.** Frecency (frequency + recency), relevance to current task, likelihood of intent. The command palette, but smarter - ordered by what you probably want, not alphabetically.

**Relationships visible.** Not just "these commands exist" but "this leads to that." The graph of possibilities, navigable.

**Shareable context.** "Here's what I can do right now" as data you can show someone else. The interaction state is data, not just pixels on a screen.

**Learnable by inspection.** Explore the capability space directly. Not through trial and error - through a map of what exists.

VSCode approximates some of this: commands are first-class, context-aware (Git commands appear in repos, language commands appear for that language), frecency-ordered. It proves the approach is tractable. Most software just doesn't bother.

## Agents have the same problem

Everything above is about humans. But consider what happens when an AI agent sits in front of a computer.

It faces the exact same opacity. Menus are hidden. Capabilities are implicit. There's no way to ask "what can I do here?" - the same question humans can't answer, agents can't answer either.

The difference is smaller than it seems. Humans muddle through by accumulating tribal knowledge - memorizing the maze, building muscle memory, years of "oh right, it's under *that* menu." Agents do the same thing, just differently. They absorb general knowledge from training data, and build project-specific knowledge through session after session of exploration and correction. The ramp-up time is roughly the same. There's no shortcut to "I've worked with this codebase for months."

One key difference: human tribal knowledge persists automatically - it's in your head. Agent knowledge evaporates at the end of a session unless explicitly saved to memory files, project docs, or configuration. The persistence is deliberate, not automatic. Without it, every session starts from scratch. With it, the knowledge is arguably more durable than human knowledge - it survives indefinitely, transfers to any human or agent that reads the same files, and doesn't degrade when someone leaves the team. But it has to be written down, which means someone (human or agent) has to recognize what's worth keeping.

But both are workarounds. Human tribal knowledge and agent context accumulation are both compensating for the same thing: software that won't tell you what it can do. The knowledge shouldn't need to be accumulated at all. An opaque interface that requires months of tribal knowledge - human or agent - is an interface that's failing at its job.

MCP (Model Context Protocol) is one attempt to solve this: expose tool schemas so agents know what's available. But it often manifests as the agent equivalent of settings sprawl - hundreds of tool definitions dumped into context, thousands of tokens of schema, no sense of what's relevant. It's the menu problem in a different costume: the capabilities are technically enumerated, but not organized, not filtered, not contextual. "Here are 400 tools" is barely more useful than "here are 400 menu items."

The interesting implication: solving affordance opacity for humans would also solve it for agents. Not as a side effect - as the same solution. Actions as data, context-aware filtering, relationships visible - these are exactly what agents need. The [interaction graph](/interaction-graph) isn't just a UX concept. It's the interface that both humans and agents are missing.

The problems were always the same problems. Software hides what it can do, and it doesn't matter whether the user is a person or a process.

## The deeper point

Affordance opacity isn't just a UX problem. It's about who software is *for*.

Opaque software is for experts who already know, or for users who accept the floor. Transparent software would be for everyone - experts move faster, beginners can actually learn, the middle ground doesn't require years of tribal knowledge. And agents - who can build tribal knowledge but at the same human cost of time and exploration - wouldn't need to.

The [interaction graph](/interaction-graph) lens helps diagnose *why* software feels opaque. Whether making affordances fully explicit is achievable - or even desirable at scale - remains an open question. But recognizing the problem is the first step.
