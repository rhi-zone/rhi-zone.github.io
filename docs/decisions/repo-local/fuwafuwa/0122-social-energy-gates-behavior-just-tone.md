# ADR-0122: Social energy gates behavior, not just tone

- Status: Accepted
- Date: 2026-05-29

**Context.** The model needs a way to make fuwafuwa pull back when over-extended rather than always engaging at full capacity.

**Decision.** Track a 0-100 social_energy that depletes per action and recovers between sessions (introversion-scaled); when depleted, fuwafuwa actually does less (less initiation, shorter engagements, more reading) rather than merely sounding tired.

**Alternatives rejected.**
- *Make energy affect only how fuwafuwa sounds (tone), as an explicit rule to follow* — energy must affect what fuwafuwa does, not just how it sounds; and it is explicitly not a rule to follow but the model's implicit way of saying 'not right now'

**Consequences.** Behavioral selection (post vs read, initiate vs reply) is driven by a quantitative energy budget with introversion-derived rates. Constrains action-selection logic to consult social_energy tiers. Mined from: /home/me/git/pterror/fuwafuwa/docs/wiki/emotional-layer.md (199).
