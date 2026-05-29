# ADR-0265: Known formats are training/validation data, not a configured analysis mode

- Status: Accepted
- Date: 2026-05-29

**Context.** A binary analysis tool could branch its behavior on whether the input format is known (e.g., a 'parse as PNG' mode vs an 'explore unknown' mode). tiltshift had to decide whether known-format handling is a separate code path.

**Decision.** tiltshift is agnostic of whether the input format is known and runs the same signal analysis regardless. Known formats serve as training data and validation set: running on PNG/ZIP/ELF validates that signals find the right structure, and those results become reference fragment models for detecting fragments in unknown data.

**Alternatives rejected.**
- *Branch behavior on known vs unknown format (dedicated known-format parse mode)* — Rejected in favor of one agnostic analysis path: "tiltshift is agnostic of whether the input format is known. It runs its signal analysis regardless." Known formats are repurposed as validation rather than a privileged mode, keeping a single algorithm honest.

**Consequences.** One analysis pipeline serves unknown-format discovery, known-format validation, anomaly diffing, and multi-file correlation. The corpus of known formats becomes a reference library rather than a set of hardcoded parsers, reinforcing the no-format-knowledge law. Mined from: /home/me/git/rhizone/tiltshift/DESIGN.md (39), /home/me/git/rhizone/tiltshift/DESIGN.md (46).
