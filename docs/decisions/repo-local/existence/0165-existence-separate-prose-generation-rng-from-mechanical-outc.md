# ADR-0165: Existence: separate prose-generation RNG from mechanical-outcome RNG

- Status: Accepted
- Date: 2026-05-29

**Context.** In existence, randomness was conflated between 'what words appear' (prose generation) and 'what happens' (mechanical outcomes), drawing from a shared RNG stream. This made cosmetic and mechanical determinism inseparable.

**Decision.** Migrate 535 call sites from the shared RNG to a dedicated cosmeticWeightedPick(), structurally separating prose generation from mechanical outcomes.

**Alternatives rejected.**
- *Keep a single shared RNG stream for both prose and mechanical outcomes* — It conflated 'what words appear' with 'what happens,' so cosmetic prose draws and mechanical outcomes could not be reasoned about or reproduced independently

**Consequences.** Prose generation and mechanical outcomes now draw from separate RNG paths across 535 call sites, enabling independent reasoning/reproducibility. Future code must route cosmetic randomness through cosmeticWeightedPick() rather than the mechanical stream. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar17-mar19.md (65).
