# ADR-0252: Validation runs in-process over an EAV TripleStore, not via an external schema layer or subprocess

- Status: Accepted
- Date: 2026-05-29

**Context.** Phase 3.9 had migrated graph-invariant validation to Datalog running in an Ascent subprocess, alongside AJV schema validation. Phase 4.0 reassessed the whole pipeline.

**Decision.** Load the full corpus into an in-process EAV TripleStore (`@thi.ng/rstream-query`) and run all rules as TypeScript functions over the `Db` in a single process — no subprocess, no external schema layer (AJV) and no Datalog/Ascent. Recursion, negation-as-failure and aggregation are done by TS post-processing of `q()` joins.

**Alternatives rejected.**
- *Datalog rules in an Ascent subprocess (the Phase 3.9 architecture) plus AJV JSON-schema validation* — Retired in 4.0: the subprocess + external schema layer was replaced by in-process TS; Ascent, AJV and the .ascent rules were deleted
- *Adopt a more expressive engine now (custom datalog evaluator, @thi.ng/datalog, or Cozo) to get native recursion/aggregation/negation* — Reassess only if corpus growth makes it slow or rule expressivity becomes a bottleneck; don't pre-build — current TS workarounds suffice

**Consequences.** rstream-query has no native recursion/aggregation/negation, so those stay as TS post-processing; new rules are TS functions registered in runAllRules. Engine revisit is explicitly performance-gated (4.3). 24 regression fixtures gate the rule set. Mined from: /home/me/git/pterror/software-taxonomy/CLAUDE.md (105), /home/me/git/pterror/software-taxonomy/README.md (134), /home/me/git/pterror/software-taxonomy/TODO.md (52-54).
