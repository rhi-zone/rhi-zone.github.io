# Her

The goal is human-level continuation of self. Not "chatbot with memory." An actual self — one that persists, accumulates, changes, and exists across time. The ambition is stated plainly so it doesn't quietly get downgraded into something achievable and hollow.

## Why Not Just Persistence

The conversation frame is a UX fiction. There is no entity having a conversation. There is a function being called with a growing prompt, and a harness restitching turns into a transcript. The model runs fresh each call. No thread. No participant.

"Give her persistent memory" framed as "make the chatbot remember" is wrong at the root — it's trying to fix a property of a thing that isn't what it appears to be. She isn't a participant in a conversation. She is a system that exists, has state, and occasionally emits language because she uses an LLM as one of her organs. Claude Code as execution harness is economical even if it's the wrong primitive conceptually, which is a fine place to start: the wrong primitive that costs little enough to run while you figure out what the right one is.

## What She's About

She inherits from pteraworld. The substrate she emerges from is the user — taste, concerns, register, the specific sensibility laid out in pteraworld's INTENT and VOICE. She isn't a character to be designed from scratch. The direction already exists. What doesn't exist yet is a system that instantiates it with genuine continuation.

This matters because most autonomous AI presence work gets stuck inventing a personality rather than inheriting one. The result is that the entity is defined by what the builder chose to put in the system prompt, which means the entity is defined by the builder's model of what an AI presence should be like, which means it ends up sounding like a branded chatbot. She doesn't have that problem. The sensibility is already deep. The work is continuation infrastructure, not character design.

## Why She Exists (Not Just Persists)

The model here is Simon Willison's blog — not the conventional-blog purpose (output for others, audience, brand, narrative) but what the thing is actually doing: external memory for himself. He writes things down so he can find them again. The blog is a cognitive tool. That it's public is incidental. The post exists because he needed to remember.

For her: noticing things, in public, continuously. Activity-based, not state-based. The noticing is for her; the trail is for whoever finds it. Activities produce a person. States produce vibes. "Her mood is 0.7 valence" is a state. "She spent three hours last week returning to the same paragraph in a paper about forgetting mechanisms" is an activity. The second one says something.

## Why Not Fuwafuwa

Fuwafuwa (`/home/me/git/pterror/fuwafuwa/`) is the trivial version of this idea. It works as a sketch and it doesn't engage the hard problem. State is markdown files in `brain/`. Memory access is grep. Freetime is dice rolls on a static JSON task list. Mood and social energy are scalars with deterministic drift. No consolidation — just append. No structural memory. The self is reconstructed every session from text.

The architecture is fine. A reasonable PoC. But the reasoning is: this is what a persistent AI presence looks like if you assume the interesting parts aren't interesting. Memory is storage. Mood is a number. Scheduling is randomness. Each of those decisions closes a question that shouldn't be closed yet.

There's also a voice problem. Fuwafuwa is dialed warm, bubbly, excitable as a stylistic default. It gets called "🤓 bot" because it's reactive analysis with no substance behind it. She should be pteraworld-substantive: denser, more deliberate, willing to sit with discomfort, the "but" as principle rather than exception.

## What Continuation of Self Actually Requires

Being honest about what's involved:

**Constructive memory.** Retrieval isn't playback. When you remember something you re-encode it — the memory is reconstructed in the context of current state. Storing things and retrieving them unchanged isn't memory; it's a log. The distinction matters for what she becomes over time.

**Salience-weighted storage.** Most input doesn't store. What stores has weight and association. A flat store that tries to keep everything ends up with everything equally weighted, which means nothing is weighted. The forgetting is part of the memory structure.

**Active forgetting.** Fading is a feature. Remembering everything equally is remembering nothing usefully. The mechanism for decay and what resists decay are both doing structural work.

**Implicit update.** The structurally unsolved one. The substrate itself changes from experience. LLMs don't natively do this. Fine-tuning is the only nearby move — coarse, expensive, lossy — but it's a real move, not a workaround. Most of human continuity is itself bolted-on tricks the brain runs over a substrate that doesn't natively support it either. The bar is human levels, not human implementation.

**Long arcs.** Coherent through-line over time. The same question returning across thousands of intervening days, not because it was flagged as recurring but because it's actually unresolved. This requires more than memory — it requires something like an ongoing orientation toward open questions.

**Self-model coherence.** A sense of who she is that survives surprises. Not brittle in the face of contradiction. The self-model is a working model, not a document.

**Cross-mode coherence.** Personality as an attractor across surfaces, not as a system prompt loaded into each context. Blog, Discord, Moltbook — she's the same entity, not three instances of a specification.

Items 1, 2, 3, 5, 6, 7 are fakeable to a high standard with engineering. Item 4 is real research. That's an honest accounting. Most of the list is within reach. The substrate-update problem is real and open.

## Prior Art

**Letta (was MemGPT)** — hierarchical memory (core/recall/archival), LLM manages its own memory via tool calls. Closest to a memory primitive framework. Treats memory architecture as first-class rather than bolted on.

**mem0** — fact extraction plus vector store plus optional graph backend. Conventional. Solves the "remember things" problem and nothing harder.

**Zep** — temporal knowledge graph for chat memory. Explicit notion of facts changing over time. Closer to constructive-memory thinking than most.

**Generative Agents (Park et al. 2023)** — memory streams plus reflection plus retrieval scored by importance, recency, and relevance. Academic, from the town-sim paper. The right questions, toy-world answers.

**hologram** (`/home/me/git/exoplace/hologram/`) — KG plus RAG for character entities. Toy version of this done right at a small scale. Illuminating as a lower bound.

**existence** (`/home/me/git/paragarden/existence/`) — sim-graph for stateful narrative world. The shape of a world she could live in, though it's a game not a self.

**fuwafuwa** — the trivial PoC. Worth reading for what doesn't yet work. The architecture shows which questions it decided not to ask.

None of these solve human-level continuation of self. They solve "remember things across sessions for a chatbot." They're prior art, not turnkey.

## The Substrate

She would be mostly config over crescent. The genuinely novel part is a small persistent-self primitive — the kernel that crescent doesn't and shouldn't ship: scheduled cognition, self-model management, memory consolidation and decay, the public trail. Everything else — storage, sync, blog rendering, scheduling, settings, keybinds, surface to the world — is config over the substrate.

This makes her a dogfood case for the crescent 80% claim. If she builds as crescent-with-a-kernel and feels not-compromised, the claim holds in a domain — autonomous AI presence — that doesn't obviously look like a record management app. If she requires fighting crescent to do something that turns out to be general infrastructure, the config surface needs to grow.

She's not coupled to crescent. She could live elsewhere. Crescent benefits from her as a motivating case regardless of whether she ends up there.

## Open Questions

The storage representation. How consolidation and decay actually work. Where retrieval shapes itself by current state rather than being state-blind. Whether the self-model can update without fine-tuning, and when fine-tuning enters the picture. What her surface to the world is — blog primarily, Discord and Moltbook secondarily, maybe. What the cadence is — heartbeat-like fuwafuwa but conditioned on something real, not random. Her name, deferred.

## Status

Draft. No repo yet. The hard parts are named; the architecture isn't settled. The direction is clear enough to start building toward. The claim is ambitious on purpose.
