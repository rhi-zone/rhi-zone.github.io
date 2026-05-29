# ADR-0064: Snippet (verbatim source excerpt) as the anti-confabulation primitive

- Status: Accepted
- Date: 2026-05-29

**Context.** The LLM doing corpus construction hallucinates software history (release dates, authors, lineage). A source id alone does not prove the cited source actually supports the claim.

**Decision.** Every sourced factual statement must carry a verbatim `snippet` copied from the cited source that supports the claim; the acceptance gate refuses snippets not present in the fetched revision. Snippet is a first-class, validator-checked field, not optional provenance.

**Alternatives rejected.**
- *Reference a source by id only, trusting the LLM's claim that the source supports the statement* — The model hallucinates history; a bare source id does not bind the claim to evidence, so confabulation passes silently
- *Trust LLM-extracted facts without a citable record* — Do not invent release dates/authors/lineage without a citable source; unknown sentinel is used instead when no source exists

**Consequences.** Snippet is the trust primitive that carries across federation boundaries (the original reason 4.0 made it first-class). 921 statements still need snippets (local drain). verify-snippets and snippet-todo tooling exist; acceptance gate must refuse mis-quoted snippets. Mined from: /home/me/git/pterror/software-taxonomy/CLAUDE.md (30), /home/me/git/pterror/software-taxonomy/TODO.md (95-97).
