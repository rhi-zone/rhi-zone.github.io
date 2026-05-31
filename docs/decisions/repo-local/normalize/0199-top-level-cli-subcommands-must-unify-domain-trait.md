# ADR-0199: Top-level CLI subcommands must unify a domain via a trait; analyze dissolves into rank/view

- Status: Accepted
- Date: 2026-05-29

**Context.** normalize analyze had accumulated ~42 subcommands with no guiding principle. An audit found every other top-level subcommand unifies a domain via a trait with multiple implementations (rules->RuleEngine, tools->Tool, syntax->Language), while analyze had no such trait — it was a grab-bag.

**Decision.** A top-level subcommand must unify a domain via a trait (the test: is there a trait where each subcommand variant is an implementation?). Introduce normalize rank backed by the Rankable trait (~80% of analyze commands answer 'rank by metric X'). Move graph/history navigation into target-first `normalize view <target> <subcommand>`. analyze dissolves toward zero rather than being given a new identity; remaining non-ranking commands are deferred until the right primitive appears.

**Alternatives rejected.**
- *Reorganize analyze into sub-services (graph, quality, structure)* — Reorganizing a grab-bag produces a smaller grab-bag; the root cause was no unifying trait, not bad grouping.
- *Arbitrary graph query interface (Datalog, Cypher, jq)* — Every tool achieving this either embedded a full query engine or exposed facts to an external tool; neither is lightweight. Canned view subcommands give the closure property without a query language.
- *analyze run --pass <...> modeled on rules run --engine* — rank already provides the right abstraction for orchestration; the rules model works only because all engines share input/output shape, which analysis passes don't.

**Consequences.** rank, `view <target> <subcommand>`, and trend/syntax absorbed most of analyze; ViewOutput's 9 variants dissolved into ViewReport + view list. grep stays top-level because its output shape differs fundamentally. Future top-level commands must pass the trait-unification test. Mined from: /home/me/git/rhizone/normalize/docs/architecture-decisions.md (452-453), /home/me/git/rhizone/normalize/docs/architecture-decisions.md (486), /home/me/git/rhizone/normalize/docs/architecture-decisions.md (503-504).
