# Incubating

Early-stage concepts that haven't been scaffolded yet. Notes from the conversation where they emerged.

---

## Fear of the Unknown (worldbuilding — three worlds)

Three distinct flavors that probably deserve separate treatment:

### The Uncanny

Small wrongness, intimate scale. Dread that comes from *wrongness* rather than danger. Not the monster — the door that wasn't there. The person who answers correctly but slightly too fast. Requires restraint in execution. Eldritch horror does this badly (too loud, too explicit); Twilight Zone and classic Doctor Who are closer.

### The Annihilating Unknown

Cognitively overwhelming. The thing that can't be looked at directly — not because it's dangerous but because it cannot be processed. Trauma-adjacent: the mind wants to block it out. The horror is less "this is dangerous" and more "this cannot be witnessed."

Key formal insight: **the medium can enact the content**. A video where the bad thing was sloppily censored — the redaction *became* the thing. The gap your mind fills is worse than anything they could have shown. The censorship is load-bearing. A game could use this: the thing isn't hidden for atmosphere, it's hidden because showing it would break the frame.

### The Illegible

Fully present, fully visible, just *unresolvable*. Not hidden (annihilating) or subtly wrong (uncanny) — simply illegible. Non-euclidean, unrecognizable, geometry that refuses to be a space. Your navigation sense runs, finds nothing, keeps running. You can stand in it indefinitely and never get purchase.

The distinction: the uncanny makes you uneasy, the annihilating destroys you, the illegible just *refuses*. It doesn't threaten. It doesn't overwhelm. It withholds resolution indefinitely.

Prior art: **the Backrooms** — not just the original yellow rooms (liminal horror, familiar-but-empty) but the full extended canon. Each floor is a different kind of wrongness: impossible scale, broken causality, spaces that don't navigate consistently. A taxonomy of how a space can fail to be a space. The variety is the point.

### The Gaslit

Mostly normal — but breaks the player's expectations and memory when they least suspect it. Not "haha gotcha" trolling; the broken memory is the content.

The goal: make the player feel that conventional logic doesn't apply. The mechanic that achieves this best is attacking memory, because memory is how you build a model of anything. Break memory, break model-building itself. You can't learn the rules if you can't trust what you remember about what happened.

**The screenshot system:** the game has built-in screenshotting that feels like an external anchor. Screenshots change after the fact — not obviously, just enough off that you can't tell if the game changed or you misremembered. The game got to your receipts.

**The notes system:** in-game note-taking, also feels like an anchor. LLM-backed corruption: notes are rewritten subtly over time — same general meaning, details shifted. Plausible deniability (maybe you just phrased it differently). This also opens the door to *responses* — the notes become a conversation you didn't know you were having. Delayed, not immediate. You write something, nothing happens. Come back later and your words have shifted, or there's a reply. The timing is on its own schedule, not reactive. You can never tell.

**How little game do we need?** Possibly zero. No UI, no levels, no "game" in any conventional sense — just files that appear, move, change. You open a folder and something is there. You come back and it's different. The question is how deeply it can reach.

**The filesystem contract:** every executable you run already has full system access — this is no different, it just uses that access honestly as the medium. Requires upfront informed consent: not buried in a EULA, the actual premise of the thing. "This will mess with your files. That's the experience." And then: the installer disappears after you accept. No entry in installed programs, no uninstaller, no trace it was ever there. Just whatever it left behind, which is also moving around. "You agreed to this." "Did you? Can you find where it said that?"

Prior art: *A Pet Shop After Dark* (npckc) — horror point-and-click that uses intentional crashes and filesystem interaction as mechanics. Subtle, not announced. Worth studying before going further.

---

## God Game (two perspectives, possibly two games)

### The God

Existing god games are too impersonal — technically accurate but probably wrong. A god who is *present*, who has relationships, who can be wrong about things. The specific problem: power without proximity. You can unmake something but you never sit with what that meant. Distance is the failure mode.

A god game where consequences come back to you. You can't poof from a clean altitude.

### The Small Thing

The complement: play the thing that gets poofed at. Not survival (dodge the god, outlast the god) — *experience the incomprehensibility of it*. Exist in a world where existence is contingent on something that doesn't notice you.

Formal reference: a video where architecture just *disappeared from existence* during gameplay — not destroyed, just absent. No rubble, no wound, a hole in what was. The space is being unwritten while you're mid-flight. You can't plan, can't read the environment, can't trust the ground.

---

## Humans as Cosmic Horror (worldbuilding — sci-fi/space opera)

Space opera where humans are the threat — but the recognition is deliberately delayed. The world is genuinely alien: non-Earth, non-human species (beastkin, reptilians, whatever), no genetic relation. The humans are obscured enough — armor, bioengineering, whatever — that neither the other characters nor the audience immediately clocks them as human.

The horror lands before the recognition does. If the recognition ever comes at all.

The misanthropy is the point. Humans aren't redeemed, aren't scrappy underdogs, aren't secretly the most empathetic. They're just genuinely bad news — and the story doesn't explain or justify that.

**What makes them horrifying to the other species:** mundane human behavioral traits, which are completely incomprehensible from outside:
- Territorial, hierarchical, resource-hoarding
- Infighting — destroys itself and keeps going anyway
- Us-vs-them pattern-matching on everything
- Treats its own individuals as disposable while breeding fast enough that it doesn't matter

To the other species: *why would anything behave like this?* To us: extremely recognizable.

Prior art: "humans are space orcs" is a known trope, but usually framed as a compliment (surprisingly tough, endearingly chaotic). This is the misanthropic inversion — no redemption arc, recognition deliberately withheld.

---

## Programmable LLM Interaction Substrate (ST/Talemate/Claude Code replacement)

A platform generic enough to replace SillyTavern, Talemate, and Claude Code — not by being all three, but by being the substrate all three are programs on top of.

**Core thesis (from nanites):** the LLM is a stateless oracle. Conversation is context poisoning. The right unit is a function call. The orchestrator is a program, not an agent. ST, Talemate, and Claude Code are just different programs that call LLMs — the platform gives you the primitives and requires you to write the loop.

**Distribution format:** programs embedded in PNG metadata. A "character" or "scenario" is a Lua/Crescent script in a PNG tEXt chunk — the image is the distributable. Visual representation and executable loop in one file, zero dependencies (fully vendorable LuaJIT binaries).

**CCv2 and friends:** lossless import (CCv2 is just text fields; a program can represent all of them faithfully), lossy export (anything beyond what CCv2 fields can express gets dropped). CCv1/v2/v3/charx I/O via plugins.

**What this fixes about ST:**
- No database — state as a database, not loose JSON files; search is instant, tags are joins, filtering is free
- Conversation-as-foundation — loop is yours to write; accumulation is a choice, not the default
- LLM-derived worldstate (Talemate) — real worldstate is written by the program, read by the LLM, never held by it
- Entity isolation — each character is a function call with explicit inputs; cross-contamination is impossible by construction, not by careful prompting
- Lorebook trigger system = fields pretending to be a language — predicates are code
- Discovery-by-accident UX — affordance opacity failure; power users know things, everyone else stays stuck; the platform fixes this structurally
- Character browser freezes (23k cards, no index, full CCv2 JSON blob, no virtualization, no thumbnails) — real index, server-side search, virtualized grid, thumbnails generated on import via stb (compiled into binary, zero runtime deps)
- 500-card pages with full-size PNGs — virtual scroll, thumbnails, never more than a viewport in the DOM

**UX model (from [affordance surfaces](/affordance-surfaces) and [affordance opacity](/affordance-opacity)):**
- Command palette as *primary navigation*, not escape hatch — context-aware, ordered by frecency and intent, not alphabetically
- Actions as data — if the interaction loop is a Lua program and actions are first-class objects, the palette gets them for free
- Miller's Law enforced at every level: ≤7 items visible at any hierarchy level, achieved by removal not prioritization
- Pinning model for the character browser: frequently-used characters earn stable positions; everything else flows around them
- Radial menus for spatial/repeated affordances (canvas tools, mode switching); linear menus only where direction carries no semantic meaning

**Stack:** Crescent (includes its own function call substrate; scripting the loop) + PNG as distribution format. Image processing (thumbnail generation) via stb_image_resize compiled into the binary — no runtime dependency.

---

## Defocus Seed Worlds

Six starter worlds for the defocus substrate — each independently authored, each a fork point. The body state schema is deliberately deferred: good worlds come first, shared grammar emerges from them. Seed worlds are forkable, not unified.

### The Intimacy (cyberpunk)

Vulnerability, closeness, trust. Flesh as canvas. Modification as intimacy — the trust of letting someone change you. Body-mod clinics as the interface layer for transformation mechanics.

NPC model: every corpo, fixer, bartender, street kid is a defocus object. LLMs read their state, generate a response, the platform writes back what changed. NPCs remember. Rumors spread through the message graph. A deal made three sessions ago has consequences because the object still holds it.

Not action/thriller cyberpunk. The emotional register is vulnerability and closeness.

### The Insignificance (brutalist)

Scale, weight, being dwarfed. Massive inhuman architecture that makes the individual feel small. Not horror, not beauty — specifically the feeling of being dwarfed and the weight of scale.

Transformation axis: scale (size, proportion, being made smaller or larger relative to environment).

### The Uncanny Valley (backrooms)

Wrongness, liminality. Environments that don't describe themselves cleanly. You wander somewhere you shouldn't be and come out different.

The LLM's tendency toward slight mis-description becomes a feature: descriptions that are *almost* right, wrongness seeping into how the world narrates itself. Transformation as environmental contamination — you emerge different, but the nature of the difference is liminal and not fully nameable.

### The TF (TiTS/LT/Flexible Survival inspired)

Transformation as the primary thing. No grinding — authored encounters that change based on accumulated body state. The same scene revisited produces different text based on who you've become.

The critical design gap in prior art: TiTS/DoL/LT/Flexible Survival all rebuilt body state from scratch, incompatibly. This seed world demonstrates the shared body state schema — NPCs react correctly to character state because everyone uses the same vocabulary. Same authoring model as Twine (write scenes, write choices), but the world remembers.

Scope is deliberately unconstrained (anthro, feral, gender, body type, species — all of it).

### Pregnancy-focused world

Transformation that's also becoming — transformation with a direction and an endpoint, distinct from other TF which is more about state change without inherent trajectory. No setting details yet.

### The Becoming (aspect-inspired)

Transformation as the primary *mechanic*, not just content. Collect/save presets, create TF direction macros. Card-as-macro: collect transformation directions, combine them, apply them.

**Negative friction:** most TF games use friction as core tension (resist or succumb). Frictionless = no resistance. Negative friction = the world actively pulls you toward transformation, making it feel like relief rather than loss.

A TF macro is just a defocus object with an `apply` verb. Composition builds a new object that calls both. Composable TFs are the platform working correctly — shareable, forkable objects. Closest prior art: Resonite/NeosVR's avatar economy, but in text form.

---

## Cross-Media Hybrids (combinations people didn't think to make)

X + Y where people just didn't think to combine them. The combination is load-bearing — the hybrid is the meaning, not a delivery mechanism for it.

**Interactive images** — hover states, click states, behavior without being a "game." The image has behavior. Not animation, not a UI component — an image that responds.

**Modulated art** — media parameterized by something external. Wwise solved this for audio: music that responds to game state, layered, reactive. Nobody solved the visual layer on top. The music video that changes based on track state. The illustration that shifts with the beat. The visual equivalent of wwise, extended to other media forms.

These don't have to be interactive. The category is: an artifact that exists in two registers simultaneously, neither one pretending. The Lumen changelog that's genuinely readable as a changelog. The character card that's a real in-world document. The combination is the point.

---

## Hyper-Immersion

A subgenre of unfiction where the membrane genuinely disappears rather than just thins. Not "designed to feel real" — the artifact *is* real, which also happens to be fiction. You find it, it just exists, and you're inside before you notice there's an inside.

The test: could someone encounter it without knowing it's fiction and simply not know? Not "could mistake it" — genuinely indeterminate.

**The neocities angle**: one domain, subdirectories that each feel like their own site — different aesthetics, different eras of web design, different levels of maintenance. Some updated recently. Some abandoned mid-thought in years past. Each one is a person's site with no announcement. You find one, follow a link, you're in it. The personal web made real by building enough texture that the question of whether anyone's home becomes unanswerable.

Prior art: nightfall.city (community that functions as a place), corru.observer (system degradation that's real degradation) — but both still have frames. Hyper-immersion has no frame.

---

## Unrecognizable Alienness

Not horror. Not uncanny valley. Genuinely orthogonal — no dread, just *huh*.

The uncanny is defined against the familiar. The annihilating overwhelms. This one does neither — it's fully present, visible, and just refuses to map onto anything. Your navigation sense runs, finds nothing, keeps running. You can engage with it indefinitely and never get purchase. Not because it's hostile, not because it's incomprehensible in principle — but because humans have no reference point, no vocabulary, no adjacent category.

The thing isn't hiding from you. You're just not equipped. And the experience of being unequipped isn't threatening — it's just exposure to the size of what exists outside the frame.

**The formal challenge**: consistent nonhuman symbolic language with grammar that doesn't map to human grammar. UI sensibilities that reflect how the species actually thinks, not alien aesthetic as style. An actual system with rules you can't immediately reverse-engineer, where someone encountering it finds themselves taking notes trying to crack it.

Corru.observer is adjacent but still routes through horror — the uncanny is still defined against the familiar, the Obesk are still humanoid enough to fall into the valley. This is further out. No valley to fall into.

---

## Fractal World Explorer (Infinite Craft, done right)

Infinite Craft had something: an open-ended, unmapped discovery space. Everything else about it was wrong.

The failure: `a + b = c` is the whole game. No state, no history, no structure — just a lookup table that happens to be infinite. The operation is the content. You're not charting territory, you're filling a spreadsheet.

What it needs: **structure**. Not "the combinations have internal logic" (still too narrow) — the world has to have *bones*. Rules that exist independent of you, so when you discover something you're discovering something about the world, not about the generator.

The architecture: **scale-invariant generation**. Generate structure top-down for coherence, explore bottom-up as a player. The same generator runs at every level of detail, parameterized by constraints from above — so fine structure is always consistent with coarse structure. Lazy: materialize nodes only when needed, but deterministically (same constraints → same result). The tree exists implicitly; exploration makes it explicit.

The result: discovery feels earned. The territory was already there. You're excavating, not generating.
