# ADR-0087: Confidence-scored generation with flagging, rather than refusing hard cases

- Status: Accepted
- Date: 2026-05-29

**Context.** Some bindings (especially complex FFI) cannot be generated with certainty. The design had to decide whether to refuse generation on ambiguous/complex cases or to generate them anyway with a quality signal.

**Decision.** Score confidence per binding during codegen; generate-and-trust high-confidence bindings, and still generate low-confidence ones but flag them for review (via comments/metadata). The Metadata type carries a confidence field for this purpose.

**Alternatives rejected.**
- *Refuse to generate complex/ambiguous cases* — Explicitly judged worse — "Better than refusing to generate complex cases" — because the hard part is 90% to 99%, and refusing leaves the user with nothing rather than a flagged starting point.

**Consequences.** Output always includes a best-effort binding plus a confidence signal; consumers must triage flagged bindings. The exact confidence scoring scheme is deferred until ambiguous parsing cases are hit. Mined from: /home/me/git/rhizone/concord/TODO.md (69), /home/me/git/rhizone/concord/TODO.md (70).
