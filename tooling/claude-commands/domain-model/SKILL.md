---
name: domain-model
description: Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates CONTEXT.md inline as decisions crystallise. Use when user wants to stress-test a plan against their project's language and documented decisions.
disable-model-invocation: true
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

## Domain awareness

Read `CONTEXT.md` at the repo root before the interview begins. If it doesn't exist, create it now — don't wait.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code does X, but you just said Y — which is right?" Note: a contradiction between the stated design and the code requires the user to decide which is authoritative — don't silently patch the docs to match the code.

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch — capture while the decision is live. Format:

```markdown
## TermName
_Avoid:_ synonym or related term easily confused with this one

One-sentence definition capturing what makes this term precise.

What goes wrong when it's confused with the avoided term.
```

Don't couple `CONTEXT.md` to implementation details. Only include terms meaningful to someone reasoning about the design, not the code.
