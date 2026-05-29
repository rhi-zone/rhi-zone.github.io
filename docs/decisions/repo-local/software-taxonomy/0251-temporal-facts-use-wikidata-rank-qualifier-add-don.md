# ADR-0251: Temporal facts use Wikidata rank+qualifier (ADD don't replace), not flattened or split predicates

- Status: Accepted
- Date: 2026-05-29

**Context.** Facts like developer history change over time (nginx: Sysoev original, F5 current). Both are true at different times; a flat single-valued schema loses history.

**Decision.** Multi-valued historical facts are modeled with Wikidata's rank (preferred/normal/deprecated) + qualifier (start_time/end_time) pattern, each historical value its own statement. When a fact changes, ADD a new statement; never remove the old one (it is historically true). At most one `preferred` per predicate per entity (validator errors on multi-preferred).

**Alternatives rejected.**
- *Flatten to a single current value* — Today's schema flattens original vs current developer; loses historically-true facts
- *Time-bounded predicate variants or a separate `originally_developed_by` predicate* — Considered for the nginx case but the rank+qualifier (ADD-don't-replace) pattern was adopted instead as the general discipline

**Consequences.** Validator enforces multi-preferred-rank (error), no-preferred-rank, deprecated-no-end-time, end-without-start. expect_preferred:false marks predicates where parallel current values are normal. Open question remains for fully time-bounded predicate semantics at scale. Mined from: /home/me/git/pterror/software-taxonomy/CLAUDE.md (216), /home/me/git/pterror/software-taxonomy/CLAUDE.md (196-197).
