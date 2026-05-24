# Worldbuilding namespace: universe-keyed, not genre-keyed

**Project(s) touched:** software-taxonomy (primary); potentially exo-place biomes, paragarden universes

**Status:** Open — convention agreed, no in-corpus instance yet

**Surfaced in:** software-taxonomy `TODO.md`, "Open questions from the founding session" (commit `3287805`)

---

## The question

How should the `worldbuilding` lens namespace be structured in software-taxonomy?

## Working answer

One lens per *named universe* — `worldbuilding.<universe-name>`. Genre and aesthetic (scifi, fantasy, grimdark, space-opera, solarpunk, …) is a *property* of a universe, not the namespace key. One universe can mix multiple genres.

## Why not genre-keyed

`worldbuilding.scifi` would imply a single canonical scifi universe shared across the whole corpus, which is the opposite of the multi-universe intent.

## What's still open

- No canonical universe name exists inside the software-taxonomy corpus yet. The first in-corpus universe needs a name before the lens can be seeded.
- The paragarden projects (existence, legacy, divergence, postmortem) are separate worldbuilding artifacts; they are not lenses in this corpus.
- The genre/aesthetic predicate needs a definition — what shape does it take, and where does it live relative to the universe lens?

## Cross-project angle

If paragarden universes or any other knowledge-graph project ever export into the software-taxonomy corpus, the universe-keyed convention should be reused consistently. That reuse requirement is why this thread lives here rather than solely in software-taxonomy's `TODO.md`.
