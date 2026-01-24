# Vision

## What rhi Actually Is

rhi isn't a master plan, or a city, or THE solution, or a polished product.

It's "I made some stuff." Hacky prototypes. Experiments that might fail. Things built to see what happens, based on conversations (some with LLMs giving questionable ideas).

ARPANET energy: "This technically works, we don't know if it scales, it's held together with duct tape and enthusiasm."

The original hacker spirit, actually. Before it got stolen. Just making things because you can. No grand claims. See what sticks. Maybe some of it will be useful. Maybe it won't. But the making is the point.

## The "What If?" Question

The real, fundamental goal: **subsuming virtually all interaction with a computer.**

- Of course it'll never happen
- Of course it won't take off
- Of course there's tradeoffs
- **But what if? What would it look like?**

This is the "what if?" question carried to its logical extreme. Not "this will win" but "if it did, what would it be?"

Everything else in rhi is in service of this question. Structure for agents, so computers understand themselves. Tags not hierarchies, so everything's findable. Hyper-modularity, so you compose what you need. The exploration itself is valuable, even if the destination is unreachable.

## Questioning Accepted Tradeoffs

Lots of software makes tradeoffs. Some do things well. But in general:

| Pain point | Why do we accept this? |
|-----------|------------------------|
| Multi-app workflows | Use X then Y then Z for one task. Why not integrated? |
| Settings sprawl | Dialog after dialog after dialog. It's just data! |
| Notes apps | Paper skeuomorphism on a $2000 interactive machine |
| Chat history as AI context | Linear conversation = amnesia. Why not world state? |
| Different stdlib per language | Everyone reinvents the same things |
| Format conversion | Hunt for exotic tools, pray they exist |
| Fragmented context | Working at your desk, want to continue on your phone. The "solution" is a vendor VM - but you already have tailscale to your home machine. Everything's there. You don't want their infrastructure, you want a mobile interface to yours. Tools should compose with what you have, not replace it. |
| Finding things later | Download an image, want to find it in 6 months. Options: folder hierarchy (which one?), hack tags into filename, hope search works. Windows had tags decades ago. macOS has tags. And yet the actual workflow is... rename the file. The pragmatic fix: tags in a database (SQLite), not file metadata. Metadata doesn't survive transfers, isn't indexed, has patchy app support. DB just works. |

These are all "accepted" tradeoffs that maybe shouldn't be accepted. The question isn't "can we make software" - it's "can we make software that doesn't make these tradeoffs?" Or at least makes different ones.

## Objects, Not Documents

Hot take: notes apps are paper skeuomorphism on the most interactive medium ever created.

Paper affordances: static, linear, you write and it sits there, you have to remember it exists, organization is manual.

What computers can do: execute, respond, connect, trigger, compute views on the fly, come to you instead of waiting.

We have the most interactive medium ever created and use it to simulate sheets of paper with text. Then we add "features" like backlinks and tags, which are just compensating for the base metaphor being wrong.

The right question isn't "how do I organize my notes?" It's "why am I taking notes at all when I have a computer?"

The thesis, clarified:
- Objects > Documents
- Things that live > things that sit
- Active > passive
- Comes to you > you go to it

Not a second brain. A living system.

## Substrate, Not Platform

Don't try to be the destination. Be the infrastructure. Let others build the destinations on top.

- Minecraft isn't a platform - it's a substrate. Servers are the destinations.
- SCP wiki isn't a platform - the wiki software is substrate, the content is destination.
- AO3 isn't trying to be a social network - it's an archive. Infrastructure for fic.

If you build good substrate, others build the communities. You don't have to do the social labor.

But you have to build high enough up the stack. Too low ("here's a VM bytecode spec") and nobody uses it. Too high and you're running a community - which is fine, but its reach is fundamentally limited to that community. The sweet spot: usable + demonstrable + extensible. Reference implementations that show what's possible, but aren't *the* destination.

The hope: someone uses the tools to build something. The realistic version: we build things ourselves, use them ourselves, and if others find them useful, great. If not, we still have tools we use.

**Why some things work at scale without being platforms:** Minecraft, SCP, AO3, Terraria - massive successes that aren't traditional platforms. What they share: not ad-driven (no incentive to maximize engagement), creation is the point (not consumption with a "post" button), ownership (you own what you make), no algorithmic feed (you find things by exploring), community not audience (you're *with* people, not performing *for* them), persistence (things you build stay).

The pattern: **they have specific creative outputs**. Minecraft has builds. SCP has articles. AO3 has fics. "General social" has no artifact - just ephemeral engagement. Platforms won general social because there's nothing to *build*. The alternatives that work are ones where you're building something together.

## Prior Art

### Systems That Dared To Be Different

Prior art not because they're all good or relevant, but because they tried something other than the mainstream.

| System | What's Different | Status |
|--------|-----------------|--------|
| **Plan 9** | Everything is a file, network-transparent FS | Influential but niche |
| **Oberon** | Tiled text UI, no hidden state, everything visible | Academic, preserved |
| **Smalltalk/Pharo** | Live object system, image-based | Active (Pharo), influential |
| **Arcan** | Rethinking display server from scratch | Active, ambitious |
| **Uxn/Varvara** | Minimal VM, personal computing, off-grid capable | Active, intentionally constrained |
| **Lisp Machines** | Hardware + OS built around one paradigm | Dead, influential |
| **HyperCard** | Anyone can build interactive things, low floor | Dead, mourned |

Common threads: coherence (one paradigm carried through), simplicity (fewer concepts, more orthogonal), introspection (system can examine/modify itself), different tradeoffs (sacrificed mainstream compatibility for internal consistency).

Why they didn't win: network effects, ecosystem ("where are the apps?"), "good enough" incumbents, sometimes genuinely worse at common tasks. But they proved *alternatives exist*. The current way isn't the only way.

### Where Did HyperCard Go?

HyperCard (1987) - "Anyone can make interactive things." It worked. Regular people made things. Then Apple killed it.

And in almost 40 years, where did its paradigm go? Nowhere useful.

Flash is dead. Scratch has a ceiling too low ("for kids"). No-code tools are vendor-locked. Notion is close but not programmable. Excel is everyone's accidental programming environment but doesn't produce interactive artifacts.

We've had decades to reinvent it. To stand on shoulders of giants. To make something *better*. Instead: professional developers vs everyone else. The gap widened, not narrowed.

### The Early Web Spirit

What the early web had:
- **Ownership** - your space, your rules
- **Tinkering** - view source → learn → make your own
- **Low floor** - HTML in notepad was enough to start
- **Weird creativity** - personal, messy, no brand consistency required
- **Connection** - links to other weird pages, webrings, discovery
- **No gatekeepers** - no algorithm, no platform approval

What killed it wasn't technology - it was incentives. Platforms centralized attention (easier to post *on* something than *make* something). Mobile shifted to apps. The attention economy rewards feeds, not exploration. "Your site looks amateur" became an insult, not a badge of authenticity.

The spirit never fully died - nightfall.city, the IF community, Neocities, the small web movement. But the *path* to finding these corners got paved over. Algorithms surface what optimizes engagement. The weird creative stuff doesn't optimize for engagement. So it stays invisible.

**Deeper problem: feeds control cognition.** If creativity is making connections between things, and connections depend on what's adjacent in your mind, then the platform controls which connections you make by controlling what you see, in what order. Linear feeds are the most controlled - you scroll down, one thing after another, no choice in sequence. The "doomscroll trance" isn't just addiction - it's surrendering cognitive agency to an algorithm.

Non-linear tools (wikis, MOO, spatial interfaces) give you agency. You choose what to look at next. You make your own paths. The connections are *yours*.

### Learning From Failure

It's 2026. We have all the prior art in the world. Not just research - all shipped software, all the code ever written, all tutorials, blog posts, Stack Overflow answers, all hacky weekend projects and abandoned repos.

But prior art includes the status quo. Which often doesn't work.

The current broken landscape is itself evidence: "this approach was tried and didn't scale," "this pattern became standard despite being broken," "this decision calcified before anyone questioned it."

WIMP is prior art. Lesson: accidental, calcified, not a solution. React churn is prior art. Lesson: state management is unsolved. The current mess is data. Learning from prior art means learning from failures as much as successes. We're swimming in documented failure.

### People

**Creative track inspirations** - people keeping the "programming as play" spirit alive:

| Who | What | Why it matters |
|-----|------|----------------|
| **Lu Wilson** (todepond) | Experimental interfaces, creative coding, [tldraw](https://tldraw.com) | Proves you can explore weird ideas publicly, playfully |
| **Inigo Quilez** | [Shadertoy](https://shadertoy.com), procedural graphics | Demoscene spirit in 2026, math as art, approachable mastery |
| **100 Rabbits** (Devine Lu Linvega) | Uxn/Varvara, off-grid computing | Intentional constraints, comprehensible systems, living differently |
| **letoram** | Arcan display server | One person rethinking the entire display stack |

**Infrastructure legends** - more aspirational than achievable, but proof of what's possible:

| Who | What | Pattern |
|-----|------|---------|
| **Linus Torvalds** | Linux, Git | Scratched own itch, became essential infrastructure |
| **Fabrice Bellard** | QEMU, TCC, FFmpeg | Single genius filling infrastructure niches |
| **Mike Pall** | LuaJIT | Insane performance from one person |
| **Georgi Gerganov** | ggml, llama.cpp | Recent proof this is still possible |

Common threads: infrastructure not end-user apps, filled genuine gaps (not "slightly better" but "didn't exist"), became dependencies, technically extraordinary ("how did one person do this?").

The question isn't "why hasn't someone built X" but "who specifically would have built X, and why didn't they?" These people are rare, busy, or working on other things. Maybe things don't exist because the people who could build them are occupied elsewhere.

## Why Things Don't Exist

### Bridge Problems

Most missing tools are bridge problems - they require crossing between specializations, and specialists rarely cross.

Building something ambitious needs multiple disciplines: systems programming, interaction design, domain knowledge, product sense, distribution. The Venn diagram of "can build it" + "will build it" + "has time" is nearly empty.

Plus incentives work against it: open source maintainers burn out, companies optimize for features not polish, academia rewards novelty not accessibility.

### Taste and Drive

LLMs collapse the skill barrier. You don't need to *be* a proc macro expert if you can collaborate with one. The bridge becomes walkable.

But motivation is still the bottleneck. Who *sees* that it should exist? Who cares enough to start? Who follows through past the prototype?

LLMs help with execution, not vision. The person still needs to notice the gap, believe it's worth filling, and sustain effort through the unglamorous parts. **The new scarcity isn't skill - it's taste and drive.** Knowing what's worth building, and actually shipping it.

The bottleneck isn't time either. 100k Discord messages prove time exists. It's the allocation that doesn't.

### Incumbents Won By Showing Up

The uncomfortable truth: incumbents often won by showing up first, not by being good.

So the bar is actually low - but it *looks* high because incumbents seem authoritative. In reality, "finished and marketed" beats "better but obscure." The real filter is: showing up, finishing, telling people. Most projects fail at step 2 or 3, not step 1.

The median software experience is buggy, bloated, half-finished, user-hostile, fragile. We've just normalized it. "Good enough" captures the market and then coasts. 2026 and we still can't copy-paste reliably between apps.

Good software exists - SQLite, ffmpeg, Linux kernel - because the right person happened to care. Most problems don't get their Hipp or their obsessive. They get abandoned side projects and half-baked enterprise solutions. Pockets of excellence in a sea of mediocrity.

### Ideas Aren't Rare, Completion Is

The intuitions behind most "missing" software are years old. Thousands of people probably had the same ideas. Where did they go?

- Gave up (too hard)
- Got practical (needed a job)
- Built it, nobody noticed
- Wrote papers nobody read
- Burned out
- Life happened
- Still going, somewhere, quietly

Ideas aren't the bottleneck. Completion is rare. Good completion is rarer. The sadness isn't "someone might steal my idea." The sadness is: nobody built it, so if you want it, you might have to do it yourself. Years of work. Might never matter to anyone else.

But also: **the dream is still available.** Nobody's claimed it yet.

### The Stolen Word

There's no "doodling" for programming. No word that means "I make little programs for fun, not for work, don't ask about my career."

"I draw" → hobby until proven otherwise. "I program" → "for work? a startup? why?"

Except we *had* a word. **Hacker.** MIT hacker culture - tinkering with computers for fun, clever solutions, joy of building. "I'm a hacker" used to mean "I make things because I love it."

Then it got stolen. Media turned it into "criminal who breaks into systems." Bootcamps gave us "growth hacker" and "hackathon" (career-ified).

1980: "I'm a hacker" = I make things with computers for fun.
2026: "I'm a hacker" = I break into systems / I do 24-hour startup sprints.

We lost the word. And with it, the framing.

**The crochet comparison:** Nobody asks a crocheter "but why though." The answer "because I enjoy it" is sufficient. Same time investment as programming. Same skill-building. But when a programmer says "I make software for fun" it's "but why? Is it for work? A startup? What's the point?"

The point is the same: because I like doing it. Society just decided one is a valid hobby and one is weird.

## Who Might Care

You might find rhi useful if you:

- Build tools and want structural primitives (ASTs, specs, pipelines)
- Work with multiple languages/platforms and want codegen from specs
- Care about preserving meaning during transformation (not just "it compiles")
- Want procedural generation that's deterministic and portable
- Think notes apps are solving the wrong problem
- Escaped the attention economy into deep work and want tools that match

You probably won't care if you want polished, production-ready software today, or need stability over experimentation, or are looking for a product rather than a toolkit.

## See Also

- [Philosophy](/about#philosophy) - Design principles shared across projects
- [Projects](/projects/) - What exists today
- [Zone Design Brainstorm](https://rhi.zone/zone/design/servers-brainstorm) - The 5000-line conversation this page was distilled from
