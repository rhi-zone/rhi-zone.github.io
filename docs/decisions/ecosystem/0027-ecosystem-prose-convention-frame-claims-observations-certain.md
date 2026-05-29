# ADR-0027: Ecosystem prose convention: frame claims as observations, not certainties

- Status: Accepted
- Date: 2026-05-29

**Context.** A reader called the pteraworld intent essays 'schizoposting'; investigation found the prose sounded too prescriptive and LLM-generated (universal claims stated as neurological fact, observations immediately over-explained). The ecosystem had to decide whether this was a copy-edit fix or a standing principle.

**Decision.** Adopt a prose design principle — human-sounding prose frames claims as observations rather than certainties — and apply audit-and-fix discipline to prose: mass-rewrite existing instances (44+ essays, 5 parallel batches, softening universal claims, removing authorial self-consciousness and hedging-as-softener) then automate prevention via a pre-commit hook detecting bold heading patterns.

**Alternatives rejected.**
- *Treat it as one-off copy-editing, or 'unschizo' the prose by flattening the voice entirely* — The reader's 'please don't unschizo it' validated that the voice should be preserved; the issue was a structural design failure mode (LLM artifacts, claims outrunning evidence), warranting a principle and automated prevention rather than a single cleanup.

**Consequences.** Establishes an ecosystem-wide prose convention plus a bold-heading pre-commit hook and a see-also-preservation feature for rewrites. Expected to propagate to any project with significant prose (legacy, motif docs, existence narrative). Open: how broadly the hook/convention is enforced across repos. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-20-2026-03-27.md (27), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-20-2026-03-27.md (33), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-20-2026-03-27.md (31).
