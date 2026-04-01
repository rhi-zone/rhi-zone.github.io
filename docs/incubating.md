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

## Fractal World Explorer (Infinite Craft, done right)

Infinite Craft had something: an open-ended, unmapped discovery space. Everything else about it was wrong.

The failure: `a + b = c` is the whole game. No state, no history, no structure — just a lookup table that happens to be infinite. The operation is the content. You're not charting territory, you're filling a spreadsheet.

What it needs: **structure**. Not "the combinations have internal logic" (still too narrow) — the world has to have *bones*. Rules that exist independent of you, so when you discover something you're discovering something about the world, not about the generator.

The architecture: **scale-invariant generation**. Generate structure top-down for coherence, explore bottom-up as a player. The same generator runs at every level of detail, parameterized by constraints from above — so fine structure is always consistent with coarse structure. Lazy: materialize nodes only when needed, but deterministically (same constraints → same result). The tree exists implicitly; exploration makes it explicit.

The result: discovery feels earned. The territory was already there. You're excavating, not generating.
