# The Decision Stream

**See also:** [Deterministic Simulation Testing](/deterministic-simulation-testing) (the first half of this arc — antithesis → oracle → lever), [Vision](/vision), [Prior Art](/prior-art), [Ecosystem Design Principles](/decisions/throughlines). The engineering form of this essay's destination lives in the crescent repo as `docs/foundations/pedagogy-and-the-reader.md`.

The companion essay started at a deterministic-simulation-testing platform and, through repeated adversarial self-critique, walked itself to a precise claim: **novelty is search times a cheap, dense, exact oracle.** It ended there, on the lever. This essay is what happens when you keep pulling that lever and ask where it points. It points, surprisingly, at a typechecker — and then at something larger that crescent is built to be.

This is one continuous argument. Each section is the place the previous one broke under pressure. The order is the content.

## Where the first half left off

Three results carry over and are not re-derived here:

- **The oracle is the frontier**, not the engine or the attacker. Antithesis open-sourced *Bombadil* (its DOM explorer) because the DOM is a free managed seam, and kept the deterministic hypervisor proprietary. XBOW, the agentic offensive-security system that topped HackerOne, is a genuine reasoning adversary — but it is *overtuned to known bug classes*, because a bug class **is** an oracle, and you can only reinforcement-learn toward *measurable* (already-named) wrongness. Novel bugs need taxonomy-free oracles: differential (two implementations disagree — a bug with no name, self-justifying), metamorphic, liveness.
- **The lever.** Novelty = search × a cheap exact oracle. The generator can be dumb; *selection* does the inventing. Evolution, AlphaGo's move 37, FunSearch / AlphaEvolve extracting genuinely new mathematics from an LLM — all are an ordinary prior wrapped in an evolutionary loop with an exact evaluator. The LLM is demoted from author to *prior whose buried tail the oracle mines*.
- **The underflow resolution.** The probability of a whole novel sequence underflows — it is the product of per-token probabilities, and that product vanishes. So the lever cannot be one-shot. It must be **short, individually-probable, individually-verified steps**, with the verifier *resetting the probability budget* at each step — particle-filter resampling. You **hop** to the tail; you never sample it whole. The antidote that falls out is **oracle density: bits per query.** A dense, incremental oracle that prunes at every step beats a terminal one that only judges the finished artifact. And the densest oracle of all is a typechecker, which rejects an ill-typed subterm the instant it is written.

That last sentence is the hinge. The companion treated the typechecker as an *example* of a dense oracle. The rest of this essay takes it seriously as *the* one — and discovers that doing so forces a complete theory of what code is.

## Shannon, made load-bearing

If novelty is bits, the right foundation is information theory, and it makes the whole "LLMs can't be truly novel" debate precise instead of vibes.

Novelty is **surprisal** — bits relative to a model of the expected. The rigorous form of the skeptic's claim is the **Data Processing Inequality**: no amount of processing can increase the information a signal carries about the truth. An LLM is a processing stage. It therefore cannot manufacture new *information* about the world; its only fresh bits are sampling **entropy** — randomness — not **information**. New *meaningful* bits enter a system only from the oracle, which is to say from the world.

This reframes the lever exactly. Density is bits-per-query because each query is the only channel through which world-information enters. Total findable novelty is **bounded above by the oracle's information content** — you cannot discover more truth than your oracle can certify. And "structured randomness beats uniform randomness" gets a precise meaning: put the sampling entropy *where the oracle can extract bits from it*. Aimless entropy is wasted; entropy aimed at a discriminating oracle becomes discovery.

This is satisfying, but Shannon is the wrong rigorous home for *code*. Shannon entropy is about a distribution over messages. A codebase is one specific artifact, not a sample from a distribution. The correct home is **Kolmogorov complexity / algorithmic information theory** — the information content of *this object*, not of an ensemble.

## The codebase ⇄ Shannon isomorphism

Here is the move that makes everything click. **A codebase is a code** — an encoding — of intended behavior. Run the dictionary:

- **Essential complexity = the Kolmogorov complexity of the behavior.** It is the irreducible floor: the source-coding theorem says you cannot encode the behavior in fewer bits than its own information content. (And it lives partly in uncomputable territory — K is not computable, which is the honest reason "just minimize complexity" is not a mechanical procedure.)
- **Accidental complexity = L − H.** The excess of the encoding's length over the entropy of what it encodes. Every bit of accidental complexity is a bit the codebase spends saying something the behavior did not require it to say.
- **Architecture = the shared codebook.** This is the load-bearing identification. In a good encoding, you factor a small dictionary of shared structure (abstractions, invariants, conventions) and then describe each part cheaply *given* that dictionary. Architecture **is** the mutual-information structure of the codebase: a small shared core, plus parts that are individually cheap-to-describe and conditionally independent *given the core*. "State the invariants" = "build the codebook." Refactoring = lossless re-encoding toward the minimum description length.

And the consequence for the dense oracle: **a typechecker's power is upper-bounded by the codebase's mutual information.** A typechecker can only certify structure that is *legibly there* — relationships the codebook has actually expressed. **Oracle power ≤ legibility of substrate.** A codebase with no shared structure gives a typechecker nothing to check; a codebase whose invariants are explicit hands it leverage. The oracle and the architecture are the same quantity seen from two directions.

## Decision-accounting, and the spike pit

Push on "what does the oracle certify" and a sharper unit appears. **Every AST node is a decision** — a point where the author chose this construct over the alternatives. Cyclomatic complexity is a *lower* bound on the count of decisions, not the count itself; it only counts branches, and most decisions are not branches. A typechecker certifies only a thin band of these decisions — the ones expressible as types. So, stated precisely: **almost all software is, strictly, not accounted for.** The decisions were made and then their justification evaporated.

The naive fix is "verifiably rationalize every decision." But that walks straight into a wall. Verifiably rationalizing every decision is *program-as-proof* — Curry–Howard — and "every decision proved" is maximal dependent types. Which means it inherits the **exact same undecidability and expressiveness wall** every full dependent type system hits. You do not escape the pit of spikes by demanding more proof; you *are* the pit.

The escape is a reframe that took the whole conversation to find: **don't VERIFY every decision — FORCE most of them.**

A typechecker's real job is not to prove things. It is to **remove degrees of freedom.** A decision that is *forced* by the surrounding structure needs no proof — it is rationalized-by-determination. If the codebook leaves you only one legal move, the move requires no note; the codebook already explains it. From this angle the whole vocabulary re-derives cleanly:

- **Accidental complexity = free decisions the codebook failed to force.** Every place the author had latitude the architecture should have removed.
- **Expressiveness = forcing-power per annotation.** A more expressive system forces more decisions per bit of annotation you write.
- **The irreducible residual = the essential free decisions** — the choices the behavior genuinely leaves open, the author-rationalized tail. This residual is exactly **H(behavior)**, the entropy floor from the isomorphism above.

So the goal is not a proof of everything. It is to *force* the accidental decisions to zero and *capture* the essential ones — and to know, by construction, which is which.

## The destination

Strip it to the bottom and here is what code actually is. **Code is a lossy encoding of the design process.** It records the *what* — the node that was chosen — and erases the *why* — the decision itself: the alternatives that were rejected, the constraint that selected, the rationale. The artifact we ship is the lossy projection; the thing that mattered, the **decision stream**, is thrown away at write time and then expensively reverse-engineered forever after, by every future reader and every future model.

The whole game is to **stop erasing it.** Capture the why as first-class, verifiable, recoverable structure, rather than reconstructing it from the what for the rest of the codebase's life. That is the destination the arc was walking toward the entire time — and when it was stated this plainly in the conversation, the author's answer was *"YES EXACTLY."*

## Crescent as the materialization

Crescent is what this theory looks like when you actually build it. Its author describes it, naively, as "a typechecker + package manager + batteries-included stdlib + a capability-based sandboxed app-hosting platform" — an *OS* not in the literal-kernel sense but in the sense of *"I hate modern computer userspace and want to make computer interaction not suck."* The decision-stream theory is the spine under that ambition. The goal, stated sharply: **every single decision recoverable and explained.**

The mechanism is a **decision engine**.

- It encodes the **base set** — taste, convention, architecture: the codebook — and ideally *composed from primitives* rather than accreted ad hoc. Decisions the engine **forces** cost ≈0 bits and get no note; the engine already explains them.
- The **minimal residual** — the essential choices, the deliberate deviations, the things that violate the house style on purpose — get **dedicated notes**.
- A **tool recovers the rationale for every decision point** from this metadata. Every node is either forced-by-the-engine (explained by construction) or noted (explained explicitly). Nothing is unaccounted for.

Two methods were on the table and the lever resolved their tension. One: a *model* heuristically finds and encodes decisions, Huffman-style, so encoding length tracks entropy. Two: a *manually authored, primitive-composed engine* plus hand-written notes. The resolution is the lever from the first half, applied to the engine itself: **the LLM proposes a convention → MDL ratifies it (accept it into the codebook only if it actually compresses the corpus) → the author ratifies → the engine grows → the note-burden shrinks.** The model is the dumb generator at the leaf; minimum-description-length is the cheap exact oracle; the author is the final gate. Search × dense oracle, one more time.

The consequences are exact, and they are what make this more than documentation discipline:

- **Total note-burden = H(decisions | engine) = KL(your taste ‖ the engine).** The amount you have to write down is precisely the divergence between your taste and what the engine already encodes. Close the gap and the writing vanishes.
- **A note that "should have been a rule" is a missing primitive.** It is a *signal*, not a chore — a measured place where the codebook is incomplete.
- Therefore crescent is **not a documentation system. It is an architecture-forcing function.** The note-burden is a live **accidental-complexity meter**, and the way you drive it down is not by writing more notes — it is by *architecting*: by finding the missing primitive that forces the decision so the note is no longer needed. The meter turns "improve the architecture" from a taste judgment into a measured quantity you reduce.

## The honest spikes

The arc earned its conclusions by breaking its own claims, so it ends by naming the two places this one can break.

**The engine is a typechecker for taste — and can inherit the same wall.** Push expressiveness on the decision engine and it drifts toward the same undecidability / expressiveness pit that swallowed "verify every decision." The only defense is the same one the dense-oracle result demanded: the engine must stay **cheap, dense, and executable.** Conventions have to *self-check* — a convention that cannot be mechanically evaluated rots into a lying comment, an assertion no one re-runs, drifting out of sync with the code while still claiming to describe it. Executability is not a nicety here; it is the line between a codebook and a graveyard of stale prose.

**Crescent must eat itself.** The engine has to be the *first* artifact that passes its own bar — its own decisions forced-or-noted, its own why recoverable. And at the scope of an OS this sharpens into the hardest version of the problem: you are **bootstrapping the property through the very layer that enforces it.** It is not enough to account for source lines; an OS is live, and you must account for **state and transitions** — the running system's decisions, not just the static ones. The thing that certifies that every decision is explained must itself be a thing every decision of which is explained, while it is running. That is the spike crescent is built on, eyes open.

---

The first half of this arc asked how you find something genuinely new and answered: search past a dense, exact oracle. This half asked what that oracle should be pointed at, and answered: the decision stream we throw away every time we write code. Crescent is the bet that you can stop throwing it away — that "why" can be made to survive, forced where it can be and captured where it cannot, with the leftover writing serving as the meter that tells you where your architecture is still incomplete.
