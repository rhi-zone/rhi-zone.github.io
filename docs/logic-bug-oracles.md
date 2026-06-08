# Oracles for Logic Bugs in Existing Code

**See also:** [Finding Bugs in Existing Code](/finding-bugs-in-existing-code) (the direct predecessor — the open question this essay answers), [Deterministic Simulation Testing](/deterministic-simulation-testing), [The Decision Stream](/decision-stream), [Vision](/vision), [Ecosystem Design Principles](/decisions/throughlines).

The prior essay in this arc established the lever — **novelty = search × a cheap, exact oracle** — and walked through a concrete attempt to operationalize it against rsync. It ended with a wall and an open question, recorded carefully: *is there a useful, incomplete, order-independent, non-enumerating finder for logic bugs in existing code?* This essay records the answer-shape that emerged from a four-branch literature probe. It inherits the same epistemic convention: claims are tagged **settled**, **open**, or **retracted**, and nothing the inquiry did not reach has been manufactured into a resolution.

## The framing (settled)

Memory-safety oracles are solved. ASan, UBSan, MSan, and crash detection cover an entire bug class comprehensively and cheaply; the toolchain ships them. The open problem is *logic/semantic* bugs — wrong-but-not-crashing behavior. The six rsync CVEs from January 2025 illustrate the stakes: four of the six are logic failures (path traversal, `--safe-links` bypass, symlink race), not memory corruption. Centering the oracle on the logic class is correct.

**(settled)** The lever for bug-finding is the oracle. The oracle is the only source of new bits — the only way the search learns that a state is interesting. Without a cheap, dense oracle for the logic class, every search degenerates: you run inputs, nothing fires, and you have learned nothing. The prior essay's eliminations of fuzzing, coverage-guidance, and chosen-target search were not eliminations of *finding* — they were eliminations of search strategies that assume the oracle is free (crash) or that substitute a proxy fitness (coverage) that isn't the thing you care about. The open question was specifically about oracle design.

**(settled — the organizing principle)** A logic bug is a *violated relation* that must hold. You do not need a ground-truth oracle — a full formal specification of what the program is supposed to do. You need relations that the correct program cannot violate. This reframes the problem from "write a spec" to "enumerate cheap checkable properties." The prior essay identified four law-shaped predicates for rsync (confinement, faithfulness, atomicity-under-fault, no-leak). This essay goes one level deeper: what *families* of relation are actually checkable online, without a spec, and what prior art proves they catch logic — not just crash — bugs?

**(settled — the key insight from prior art)** The relations do not have to be automatically inferred. [Antithesis](https://antithesis.com/docs/properties_assertions/assertions/)'s `always`/`sometimes`/`reachable` assertions are hand-written by users. The tool's job is not to invent the oracle; it is to drive execution into the rare states where a cheap hand-written relation trips. This is what rescues the design from the weakest branch of the literature — automated invariant mining — which is addressed below and dropped.

## Three relation families that catch logic bugs

### 1. Conservation and metamorphic relations

A metamorphic relation is a property that must hold *across* two or more executions with related inputs — without knowing the correct output of either. The canonical form: if you transform the input in a known way, the output must transform correspondingly (or be invariant). These are hand-writable in a few lines each.

**(settled)** For rsync as the running target:

- **Post-transfer content checksum (conservation):** after `rsync src/ dst/`, the SHA-256 of every transferred file at the destination must match the source. This catches rsync's v3.2.4 cross-architecture `rollsum` delta-transfer corruption ([GitHub issue #317](https://github.com/RsyncProject/rsync/issues/317)): the block-rolling checksum produced different values on big-endian and little-endian architectures, silently writing wrong data. The relation is five lines of shell; the bug was invisible to any crash oracle.

- **Spatial monotonicity under `--safe-links`:** the set of paths written outside the destination prefix must be empty when `--safe-links` is active. This catches CVE-2024-12088, the `--safe-links` bypass: rsync failed to correctly reject a symlink whose target, after normalization, escaped the transfer root. The confinement relation fires; a crash oracle does not.

- **Idempotence:** `rsync A→B` run twice should leave the second run a no-op (zero bytes transferred, zero files changed). This catches filter/delete-interaction bugs, where a second sync corrects something the first run corrupted or omitted — the program's own inconsistency becomes the witness.

Additional metamorphic relations applicable here: commutativity (the order of files in a transfer set should not affect the destination), composition (syncing A→B then B→C should produce the same result as A→C directly). These cost 2–3× in execution time (you run the same transfer twice) and are CI-grade — cheap enough to run on every commit.

**(settled — the prior art that proves this catches logic bugs, not just crashes):** EMI (Equivalence Modulo Inputs / Orion, Le Goues & Regehr et al., PLDI 2014) found 147 confirmed GCC/LLVM bugs, approximately 95 of which were miscompilations — wrong-but-not-crashing behavior — using exactly this pattern: compile the same program with and without dead-code insertions, check that the outputs agree. SQLancer's TLP and NoREC techniques (Rigger & Su, OOPSLA 2020) found 175+ database logic bugs using metamorphic relations over SQL query results. MarMot (arXiv:2310.07414) applies online metamorphic monitoring to autonomous-driving systems at 0–10% false-positive rates. The evidence base is solid.

**(settled — the ceiling)** Metamorphic relations cannot catch bugs that are uniform across all exercised paths (a systematic error the relation never distinguishes), or semantically-consistent-but-wrong behavior where the relation itself is too weak. Without a true reference, you are bounded by the strength of the relations you write.

### 2. Differential testing

A differential oracle requires no spec and no ground truth: run the same input through two executions that *should* agree, and treat disagreement as the witness. Each side is the other's reference.

**(settled)** Sub-types, ordered by strength:

- **Version-differential (commit N vs N−1):** run the same transfer through two adjacent versions of rsync and compare the destination trees. This directly fits rsync's documented history of at least three regressions across approximately forty commits — each regression is, by definition, a disagreement between versions. This is the regression oracle; it is blind to bugs that predate the comparison baseline, but it is the cheapest continuous safety net.

- **Implementation-differential (rsync vs openrsync):** openrsync is a clean-room reimplementation targeting compatibility with rsync. A disagreement between the two is strong evidence of a bug in one of them — the two sides share the intended protocol spec but not the code, so a shared systematic error is much less likely. This is the strongest pairing available for rsync. (rsync vs rclone diverges too much in semantics to be useful here — rclone is a different product.)

- **Configuration-differential:** `--archive` must produce the same result as its explicit expansion `-rlptgoD`. This is the cheapest sub-type — one binary, zero reference implementation — and it is almost entirely unexploited. The equivalence-spec is the flag documentation.

- **Build-variant differential (`-O0` vs `-O3`):** zero false positives but weak — it only catches UB-sensitive bugs that happen to manifest under optimization. Not a primary oracle.

**(settled — the prior art)** Csmith + compiler differential found hundreds of GCC/LLVM miscompilations using exactly this pattern: generate a random C program, compile it with multiple compilers/flags, compare outputs. Frankencerts / NEZHA (SSL/TLS validation logic bugs across implementations) used N-way divergence scoring to rank candidate bugs by the number of implementations that agreed against the outlier — a signal quality improvement over pairwise comparison.

**(settled — the central problem, stated honestly)** The intended-difference false positive: the two sides legitimately differ. A flag legitimately changes behavior; a version intentionally changed a default. This is the wall that makes naive differential testing dense with noise.

**(settled — the mitigations)** Output canonicalization: compare the destination tree as a set of (path, content-hash, mode, owner) tuples, not raw bytes — cheap, kills format-level noise. Scope restriction via an equivalence-spec: the spec declares which flag-sets are "pure sync" (the two sides must agree) versus legitimately side-effecting (permitted to differ). Commit/test-delta annotation: flag version pairs where the changelog documents an intentional behavior change. Minimization-based triage: a shrinker that reduces the disagreeing input to its minimal form makes human review fast. NEZHA-style N-way scoring with rsync + openrsync + a version pin gives 2–3 voters; unanimous agreement that side A is wrong is strong signal.

**(settled — the ceiling)** Differential testing is blind to bugs both sides share — a systematic error predating the comparison baseline is invisible to every variant of this oracle.

### 3. Fault-injection-amplified relations

**(settled — why this family is non-optional)** Plain metamorphic and differential oracles only exercise the happy path. The error-handling code — where the class of "swallow the error and continue with corrupt state" bugs live — is structurally unreachable without injected faults. ALICE (OSDI 2014) found 60 such bugs across 11 well-tested applications. CrashMonkey found 10 in btrfs. Both classes of bug were invisible to crash-free testing. The happy path is not where the worst logic bugs hide.

**(settled)** Fault injection alone is not an oracle. libfiu's exact weakness: it has a fault-injection mechanism but no checker. Injecting a fault and watching rsync exit non-zero tells you nothing — that may be correct behavior. The productive pattern is injection *cross* relation-oracle: run families 1 and 2 *under* injected I/O faults. The crash-consistency checkers (ALICE, CrashMonkey, Hydra/SOSP 2019) and Jepsen implement exactly this: a nemesis that injects failures, an oracle (Elle/Knossos linearizability) that checks the result.

**(settled — a concrete rsync bug in this class)** `rsync -u --inplace --partial` interrupted mid-transfer leaves a partial file at the destination with a newer mtime (from the partial write) than the source. On resume, rsync's timestamp-based update check sees "destination is newer" and silently skips the file. rsync exits 0 with a wrong result ([GitHub issue #236 class](https://github.com/RsyncProject/rsync/issues/236)). A metamorphic oracle — post-transfer checksum, run under a fault that interrupts mid-file and then allows resume — catches this. A crash oracle does not: rsync never crashes.

## The discriminator that makes it usable (settled)

Condition the oracle on exit code.

- **Non-zero exit:** rsync correctly aborted. The destination may differ from the source — that is the expected outcome of an abort. The pre-existing destination file must survive intact (no destruction before completion, unless `--inplace` was specified, which the equivalence-spec records as a permitted side-effect).
- **Zero exit:** rsync claimed success. The destination *must* equal the source, or it is silent corruption. Any deviation from the conservation relation under zero exit is a bug.

This single rule separates "rsync correctly bailed" from "rsync claimed success and lied." It is the clean discriminator against the intended-difference false-positive wall: the dense oracle-trips that plagued the confinement-shim spike were dense because the spike was configuration-blind and had no notion of "was this outcome permitted." Exit-code conditioning is the missing piece from that dead end. It is not a complete solution to the config-blindness problem — a full equivalence-spec is still needed for flags that change intended behavior — but it eliminates the largest single source of false positives cheaply.

## What the tool actually is (settled)

**(settled — the reusable / hand-written split)** Two halves, clearly separated:

**The reusable library (the product):** the fault-injection seam (LD_PRELOAD over I/O and other mediated decisions); a differential runner with tree canonicalization; the exit-code-conditioned comparator; deterministic replay and input minimization. The prior essay established that determinism is not the hard part — Antithesis itself stated that "ensuring determinism is the easiest part… the hard part is actually finding the bugs." Value goes into the oracle machinery and the injection seam, not into gold-plating determinism infrastructure.

**The hand-written per-target layer (cheap, à la Antithesis assertions):** the relation catalog (which conservation, monotonicity, and differential checks apply) and the equivalence-spec (which flag-sets are "pure sync" versus legitimately side-effecting). This is what the library makes cheap to write and run.

**(settled — honest caveat)** "Spec-free" is marketing. This is *spec-light*. You replace a full formal specification with a small, concrete, maintained equivalence-spec — the set of behavioral contracts you are willing to assert. The Antithesis model is why this is acceptable: humans write the `always`/`sometimes` assertions; the tool drives execution into the states where they trip. The spec shrinks from "describe the entire program" to "describe which output equivalences you care about." That is a tractable engineering task, not a research problem.

## The dropped branch: automated invariant mining (settled)

The fourth branch of the literature probe was automated invariant mining — tools like Daikon that instrument a program's execution, observe variable values, and infer likely invariants from the observations.

**(settled)** Daikon is approximately 25 years old, has roughly 1,000 citations, and has not become a standard bug-finding tool. The reasons are structural, not fixable with engineering effort:

- **Instrumentation friction:** `-O0`, 10–20× Valgrind-level overhead, incompatible with production workloads.
- **Spurious invariant flood:** hundreds to thousands of candidate invariants per run, with no reliable automated triage between "always true because of this code path" and "always true because of this test suite."
- **Corpus dependence:** the invariants reflect what the test suite exercises, which is exactly what you already tested. Mining "what the program does" from the test suite and then checking "what the program does" is circular — it validates the test suite's assumptions, not the program's correctness.
- **The fatal circularity:** Daikon mines "what the program does," not "what it should do." A bug that is consistent across all tests produces an invariant that encodes the bug as a law.

**(settled — the narrow surviving niche)** Automated mining is useful in exactly one configuration: hand-written scalar rep-invariants on accounting structs (rsync's `stats`: `total_bytes = Σ file_lengths`, `num_transferred ≤ num_files`) and protocol-sequence invariants (Perracotta-style FSM mining over the wire protocol — what message sequences the protocol actually produces, as a sanity check against the spec). These are the cases where the invariant is structurally simple, the corpus is comprehensive, and the human can read and validate the mined output.

**(settled — conclusion)** With hand-written oracles as the spine — the Antithesis model — automated mining drops from "load-bearing" to "optional enrichment." This is a feature: it removes the shakiest leg. The design does not depend on Daikon working.

## The ceilings (stated plainly)

**(settled)** These ceilings are not engineering gaps. They are structural limits of the approach.

**None of these generate the triggering input.** Every relation-oracle is: *if you run the input that exposes the bug, the relation catches it.* Input and decision generation — the search half — is the separate, unsolved-here problem. It is precisely the job of the injection engine and the search strategy (to be addressed separately). Oracle and search are both necessary; neither substitutes for the other.

**"Spec-free" is really spec-light.** You replace a full formal spec with a bounded, hand-written, maintained equivalence-spec. The spec is smaller and more tractable, but it is not zero. A bug whose correct behavior you did not specify is a bug the oracle cannot catch.

**Blind to bugs both sides share.** Differential testing cannot catch a systematic error that predates the comparison baseline. Metamorphic relations cannot catch behaviors that are semantically consistent but wrong — where the relation you chose is not strong enough to discriminate.

**The online half only.** This essay covers online relation-oracles: relations that fire during execution and return a verdict at the end of a run. Separately, execution can emit a recorded coloring of the decision tree for offline, human-driven corpus analysis — that coloring must never feed back to steer the search (doing so biases away from indirectly-relevant regions, poisoning the search). The online oracles here and the offline coloring are independent; this essay is the online half only.

## The minimum viable build (settled)

Exit-code-conditioned differential under fault injection, plus a three-item hand-written relation catalog: the post-transfer content checksum (conservation); the `--safe-links` spatial bound (monotonicity); and idempotence (run twice = second run is a no-op). Add version-differential as the regression net. Three families, each backed by a real rsync bug documented above, all hand-authored oracles, all riding on the search and injection engine.

This is the Antithesis division of labor: the tool makes the rare states; the human writes the cheap relation the rare state violates.

## Sources

- Metamorphic testing survey — Segura et al., IEEE TSE 2016
- EMI / Equivalence Modulo Inputs (Orion) — Le Goues & Regehr et al., PLDI 2014: https://dl.acm.org/doi/10.1145/2594291.2594334
- SQLancer / TLP / NoREC — Rigger & Su: https://github.com/sqlancer/sqlancer
- MarMot — metamorphic runtime monitoring: https://arxiv.org/abs/2310.07414
- Csmith — compiler differential testing: https://embed.cs.utah.edu/csmith/
- frankencerts / NEZHA — SSL/TLS differential testing
- Daikon — Ernst et al.: https://plse.cs.washington.edu/daikon/
- Perracotta — temporal API spec mining, ICSE 2006
- ALICE — file-system fault injection, OSDI 2014
- CrashMonkey + ACE — OSDI 2018
- Hydra — SOSP 2019
- Jepsen + Elle: https://github.com/jepsen-io/jepsen
- Antithesis assertions: https://antithesis.com/docs/properties_assertions/assertions/
- rsync issue #317 (delta corruption): https://github.com/RsyncProject/rsync/issues/317
- rsync issue #236 (--inplace/--partial resume): https://github.com/RsyncProject/rsync/issues/236
- CVE-2024-12088 (--safe-links bypass)
