# ADR-0004: Prompts are assembled by ContextAssembler from ContextContributors; string-concatenation is not an exposed mode

- Status: Accepted
- Date: 2026-05-29

**Context.** Stages contribute many things to a prompt (observations, Timeline, chat window, prose-register). The decision was how prompt text gets built and whether the author ever concatenates strings.

**Decision.** Every primitive that contributes to prompts implements ContextContributor. Prompts are assembled by ContextAssembler from a registered set of contributors with explicit priority + token-budget + drop-on-overflow ordering. The author composes contributors; the assembler emits final text. There is no string-concatenate mode in the library.

**Alternatives rejected.**
- *Stage author does `string +` to build the prompt (string-concatenate-everything)* — Makes naive chat-append trivially writable and bypasses priority/budget/overflow ordering; the assembler deliberately does not expose that mode so it is 'literally not a thing one writes'.

**Consequences.** Forecloses ad-hoc prompt string building; every prompt-contributing primitive must declare priority and budget and participate as a contributor. Enforces north star 5 mechanically. Mined from: /home/me/git/pterror/chub-stage-factory/CLAUDE.md (41), /home/me/git/pterror/chub-stage-factory/CLAUDE.md (41).
