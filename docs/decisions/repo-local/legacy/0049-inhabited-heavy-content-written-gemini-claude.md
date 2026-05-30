# ADR-0049: Inhabited heavy content is written via Gemini, not Claude

- Status: Accepted
- Date: 2026-05-29

**Context.** The voice rule demands not sanitizing heavy/traumatic content — matching the actual fragmented cognitive state. In practice Claude's safety training sanitizes such content despite the rule, producing the cleaned-up version the rule rejects.

**Decision.** For inhabited heavy content the workflow is: build the character card in this repo (via /character), then write the actual content via Gemini rather than Claude. Claude is used to author the card/system-prompt but not the inhabited heavy writing itself.

**Alternatives rejected.**
- *Have Claude write the inhabited heavy content directly under the character card* — 'Claude's safety training still sanitizes despite this rule' — the output is composed and tastefully distanced, which minimizes trauma by making it look manageable, the opposite of the intended 'least distance possible.'

**Consequences.** A model-selection contract for a class of content: Gemini is the writing tool for inhabited heavy material; Claude's role is bounded to card construction. Ties the legacy workflow to an external model. Mined from: /home/me/git/paragarden/legacy/CLAUDE.md (135).
