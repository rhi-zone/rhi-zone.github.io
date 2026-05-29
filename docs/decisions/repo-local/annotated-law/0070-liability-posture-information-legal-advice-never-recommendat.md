# ADR-0070: Liability posture: information not legal advice, never recommendation, on every surface

- Status: Accepted
- Date: 2026-05-29

**Context.** A product that summarizes statutes and case law for laypeople risks being construed as giving individualized legal advice, with the attendant liability. The project is non-commercial with no legal entity, so the liability surface must be controlled by product design rather than by counsel or insurance.

**Decision.** Carry an aggressive 'information, not legal advice' posture through every surface: never phrase output as a recommendation ('the law says X' / 'courts have held Y', never 'you should Z'), persistent disclaimers, always link to source nodes, and no personalization that resembles individualized legal advice (jurisdiction selection is filtering, not counsel).

**Alternatives rejected.**
- *Recommendation- or advice-style output (e.g. 'what should you do', personalized counsel like a navigator that advises action)* — Rejected for liability: output must never be phrased as a recommendation and there must be no personalization resembling individualized legal advice; jurisdiction selection is explicitly defined as filtering rather than counsel.

**Consequences.** All four views must render verdicts as descriptive statements with persistent disclaimers and drill-to-source links; the navigator view cannot output actionable advice. Constrains copy, UX, and the summary-generation prompt across every surface. Mined from: /home/me/.claude/plans/snuggly-wobbling-melody.md (67), /home/me/.claude/plans/snuggly-wobbling-melody.md (69), /home/me/.claude/plans/snuggly-wobbling-melody.md (14).
