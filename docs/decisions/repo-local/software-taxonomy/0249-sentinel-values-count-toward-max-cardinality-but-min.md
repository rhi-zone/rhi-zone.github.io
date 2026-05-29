# ADR-0249: Sentinel values count toward MAX cardinality but NOT MIN

- Status: Accepted
- Date: 2026-05-29

**Context.** When a property applies but its value is unknown (or known not to apply), the statement still needs to exist for completeness, but it must not falsely satisfy required-field constraints.

**Decision.** `{"unknown":true}` and `{"novalue":true}` sentinel statements count toward MAX cardinality but NOT MIN. A `1..1` required predicate whose only value is a sentinel is a cardinality error (0 real values, 1 required). Sentinels assert presence, not content.

**Alternatives rejected.**
- *Count sentinels toward both MIN and MAX (treat a sentinel as satisfying a required field)* — Would let a 'known unknown' falsely satisfy a required predicate; sentinels assert presence not content, so they must not satisfy MIN
- *Omit the statement entirely when value is unknown* — Loses the assertion that the property applies; sentinels are used instead of omitting

**Consequences.** Validator distinguishes real values from sentinels in cardinality_violation_min vs _max checks. Required predicates cannot be satisfied by a placeholder. Mined from: /home/me/git/pterror/software-taxonomy/CLAUDE.md (75).
