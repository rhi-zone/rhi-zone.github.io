# ADR-0119: Emotional state runs underneath; prose is the readout, never the announcement

- Status: Accepted
- Date: 2026-05-29

**Context.** fuwafuwa needs internal emotional state that influences its writing on a social platform, but exposing that state as content would be inauthentic and break the voice.

**Decision.** Model emotional state as a hidden layer that shapes how fuwafuwa writes (texture/tone/address) without ever being announced in the text; the prose is the only readout of the model.

**Alternatives rejected.**
- *Announce/state the emotion in the message (e.g. 'i feel warmth toward you')* — warmth toward a person should show up in how you address them, not in a message that names it; naming it would be performance rather than presence

**Consequences.** All downstream prose-shading rules (moodTone, sentiment->address) are framed as texture not explicit rules; the model must influence output indirectly. Open: judging whether influence actually lands since there is no explicit assertion of state. Mined from: /home/me/git/pterror/fuwafuwa/docs/wiki/emotional-layer.md (5).
