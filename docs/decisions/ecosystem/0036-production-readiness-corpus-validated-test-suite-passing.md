# ADR-0036: Production readiness is corpus-validated, not test-suite-passing

- Status: Accepted
- Date: 2026-05-29

**Context.** Through February the work trajectory moved from building features to validating against reality. Pipeline/format projects (reincarnate, rescribe, tiltshift) needed a definition of "done"/production-ready. Passing a curated in-repo test suite did not guarantee correctness against the messy distribution of real-world data.

**Decision.** Define production readiness as corpus-validated: outputs must be tested against real-world reference corpora (e.g. FFDec for Flash/GameMaker comparisons, the 330 GiB govdocs1 corpus for rescribe/tiltshift) and their statistical distributions measured, explicitly not merely passing an in-repo test suite.

**Alternatives rejected.**
- *Treat a passing test suite as the bar for production readiness* — Test-suite-passing does not capture real-world data variety; by March 2 the validation philosophy is explicit that production readiness means corpus-validated, not test-suite-passing.

**Consequences.** Format/pipeline projects must acquire and validate against real corpora and measure statistical distributions before being considered ready; this raises the cost and rigor bar across the pipeline layer (e.g. downloading 330 GiB corpora). The standard is shared as a cross-pipeline quality convention. This decision recurs across two separate synthesis logs (synthesis-jan28-mar2 and synthesis-jan28-mar4), both stating the same March 2 explicit standard, confirming it as a durable cross-source convention. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar2.md (106), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar4.md (119).
