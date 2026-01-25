# Prior art

Things worth knowing about, learning from, or appreciating. This isn't comprehensive - it's what's informed the thinking here.

**See also:** [Why software is hard](/why-software-is-hard) (the diagnosis), [Interaction graph](/interaction-graph) (making affordances explicit), [Affordance opacity](/affordance-opacity) (why software hides), [Explorations](/explorations) (related hypotheses), [Problems](/problems) (broader context)

---

## Accessible creation

| Name | What it is | Why it matters |
|------|-----------|----------------|
| [HyperCard](https://en.wikipedia.org/wiki/HyperCard) | Apple, 1987-2004 | "Anyone can build interactive things." We had this and lost it |
| [Snap!](https://snap.berkeley.edu/) | Scratch + macros, first-class functions | Visual programming with a high ceiling |
| [Scratch](https://scratch.mit.edu/) | MIT, kids visual programming | Proof low floor works. Ceiling too low though |
| [Mario Maker](https://supermariomaker.nintendo.com/) | Nintendo level editor | Immediate creation → playable. Real ownership |
| [Dreams](https://www.playstation.com/en-us/games/dreams/) | Media Molecule, PS4/5 | Create games/music/art. Genuinely accessible |

HyperCard is the canonical "we had it and threw it away" - anyone could build interactive stacks, and many did. The barrier was low, the ceiling was high enough, and it shipped on every Mac. Then Apple neglected it to death.

---

## Creative constraints

| Name | What it is | Why it matters |
|------|-----------|----------------|
| [PICO-8](https://www.lexaloffle.com/pico-8.php) | Fantasy console | Intentional limits (128x128, 16 colors) → focused creativity |
| [TIC-80](https://tic80.com/) | Open source fantasy console | Same energy, different tradeoffs |
| [Shadertoy](https://www.shadertoy.com/) | Shader art community | GPU programming accessible, instant feedback |
| [Dwitter](https://www.dwitter.net/) | JS art in 140 characters | Extreme constraint breeds creativity |
| [Bytebeat](http://canonical.org/~kragen/bytebeat/) | Music from math expressions | One-line formulas → sound |
| [TidalCycles](https://tidalcycles.org/) / [Strudel](https://strudel.cc/) | Live coding music | Pattern-based, immediate feedback |
| Demoscene | Real-time graphics art | Decades of constraint-driven innovation |

These prove that constraints aren't limitations - they're focusing functions. PICO-8's 128x128 resolution means you can't bikeshed on asset quality. Dwitter's 140 characters means you ship or you don't. The creativity happens *because* of the limits, not despite them.

See: [8-item forcing function](/explorations#_8-item-forcing-function)

---

## Transparent systems

| Name | What it is | Why it matters |
|------|-----------|----------------|
| [100 Rabbits / Uxn](https://100r.co/site/uxn.html) | Minimal VM, personal computing | Intentionally comprehensible. You can understand the whole thing |
| [Plan 9](https://9p.io/plan9/) | Bell Labs OS | Everything is files. Radical consistency |
| [Oberon](https://en.wikipedia.org/wiki/Oberon_(operating_system)) | Wirth's OS | Simple, integrated, inspectable |
| [Lua](https://www.lua.org/) | Minimal scripting language | Small, readable, embeddable |

100 Rabbits is the existence proof that comprehensible systems are possible. Uxn is a VM you can hold in your head. This is the opposite of "47 dependencies to run hello world" - it's intentional simplicity as a design goal.

See: [Clean graphs, not filtered messy graphs](/interaction-graph#clean-graphs-not-filtered-messy-graphs)

---

## Programmable worlds

| Name | What it is | Why it matters |
|------|-----------|----------------|
| [LambdaMOO](https://en.wikipedia.org/wiki/LambdaMOO) | Text-based virtual world (1990) | Fully programmable in user-space. Simple core, infinite possibility |
| [ChatMUD](https://www.chatmud.com/) | Modern MUD, social focus | Proof the form still works |
| [Resonite](https://resonite.com/) | VR social platform, programmable | Closest to "programmable VR world" today |
| [Second Life](https://secondlife.com/) | 3D virtual world | User-created everything. Walled garden but proves the model |

LambdaMOO's insight: minimal core (objects, verbs, properties) + user-space programming = emergent complexity. The world becomes what users make it. 35 years later, this is still rare.

---

## Collaborative worldbuilding

| Name | What it is | Why it matters |
|------|-----------|----------------|
| [SCP Foundation](https://scp-wiki.wikidot.com/) | Collaborative horror fiction wiki | Massively successful collaborative worldbuilding |
| [Orion's Arm](https://www.orionsarm.com/) | Hard SF collaborative universe | 25+ years of accumulated lore |
| [AO3](https://archiveofourown.org/) | Fanfiction archive | Community-owned, thriving, proves scale possible |
| [Minecraft](https://minecraft.net) | Block-based survival/building | Collaborative worldbuilding at scale. Builds persist |
| [nightfall.city](https://nightfall.city/) | Text city via telnet | Community as narrative structure |

The energy for collaborative creation exists. SCP Foundation has thousands of contributors building a shared fictional universe. The question is why this energy is mostly in wikis and game servers rather than programmable systems.

---

## Interactive fiction

| Name | What it is | Why it matters |
|------|-----------|----------------|
| [Counterfeit Monkey](https://ifdb.org/viewgame?id=aearuuxv83plclpl) | Emily Short, 2012 | Wordplay as world mechanic. Text can be deep |
| [Galatea](https://ifdb.org/viewgame?id=urxrv27t7qtu52lb) | Emily Short, 2000 | Conversation as gameplay. Mood modeling |
| [Versu](https://emshort.blog/2013/02/26/versu/) | Emily Short + Richard Evans | Social simulation engine |
| IF community generally | IFComp, IFDB, etc. | Kept producing excellent work through the platform era |

The IF community proves that text-based interaction can be rich, deep, and rewarding. They kept making things while the rest of the industry chased graphics.

---

## Philosophy / writing

| Name | What it is | Why it matters |
|------|-----------|----------------|
| [todepond's "Just"](https://www.todepond.com/wikiblogarden/better-computing/just/) | Essay | Critiques "just do X" as hidden complexity |
| [todepond generally](https://www.todepond.com/) | Blog/videos | Thoughtful takes on computing, accessibility, creation |
| [Neocities](https://neocities.org/) | Free web hosting | The GeoCities spirit survived |
| [Small web / Indieweb](https://indieweb.org/) | Movement | People trying to reclaim personal web |

todepond's "Just" essay is essential reading on hidden complexity. "Just use React" or "just learn Vim" hides enormous assumed knowledge. The word "just" is a complexity-hiding mechanism.

See: [Affordance opacity](/affordance-opacity)

---

## Worth watching

| Name | What it is | Status |
|------|-----------|--------|
| [Resonite](https://resonite.com/) | VR social platform, programmable | Active development |
| Federation (ActivityPub, AT Protocol) | Decentralized social | Trying to solve the platform problem |
| Local-first software | CRDTs, sync engines | Ownership + collaboration |
| [Hazel](https://hazel.org/) | Typed holes, structure editing | Research, active |

---

This list is incomplete. The goal isn't comprehensiveness - it's pointing at things that inform the diagnosis of [why software is hard](/why-software-is-hard).
