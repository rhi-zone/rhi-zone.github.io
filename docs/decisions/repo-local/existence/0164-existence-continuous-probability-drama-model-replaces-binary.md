# ADR-0164: Existence: continuous-probability drama model replaces binary cooldown gate

- Status: Accepted
- Date: 2026-05-29

**Context.** Existence's drama mechanic used a binary cooldown timer (a gate that is either open or closed). This forced discrete on/off behavior rather than graded likelihood, limiting emergent behavior.

**Decision.** Replace the drama cooldown binary gate with a continuous probability function (tau=480min), tagged with explicit approximation debt for future experimental validation.

**Alternatives rejected.**
- *Keep the binary cooldown-timer gate for drama events* — A binary gate cannot express graded likelihood; the continuous probability model better supports the move toward emergent behavior matching expectations

**Consequences.** Drama events are now governed by a continuous probability model (tau=480min) carrying explicit approximation debt for later experimental validation. Marks existence's transition from 'does the code work?' to 'does the model produce expected emergent behavior?' Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar17-mar19.md (63), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar17-mar19.md (67).
