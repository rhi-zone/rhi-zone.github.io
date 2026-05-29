# ADR-0250: source_required is checked per-statement against the owning lens, with an interpretive escape hatch

- Status: Accepted
- Date: 2026-05-29

**Context.** A biology overlay lens (source_required:false) contributes statements to a core entity (source_required:true). It must be clear which lens's policy governs and whether a sourced sibling exempts an unsourced statement.

**Decision.** source_required is evaluated against the OWNING lens's policy, per-statement: a biology overlay (source_required:false) extending a core entity (source_required:true) must source every statement it adds. A sourced sibling at the same rank does NOT exempt an unsourced one. Interpretive/analytical claims may use `kind:"interpretive"` sources (requiring last_verified) to satisfy the requirement without an external citation.

**Alternatives rejected.**
- *Evaluate source_required against the extending lens's own policy* — Would let a permissive overlay inject unsourced claims into a strict core entity; owning-lens policy is enforced instead
- *Let a sourced sibling statement exempt unsourced ones at the same rank* — Source-required is per-statement; a sourced sibling does not exempt an unsourced one, so each claim stands on its own evidence

**Consequences.** Cross-lens statements coexist in one entity file but each is checked under the core policy. Interpretive authors get an explicit non-weakening escape hatch (kind:interpretive). Open TODO: whether to upgrade source_required_violation from warning to error after sourceless triage. Mined from: /home/me/git/pterror/software-taxonomy/CLAUDE.md (192), /home/me/git/pterror/software-taxonomy/CLAUDE.md (121).
