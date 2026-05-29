# ADR-0054: Nanites is general orchestration, not LLM/AI-specific

- Status: Accepted
- Date: 2026-05-29

**Context.** The obvious framing for an LLM-orchestration substrate is 'AI orchestration', which would bake LLM concepts into the core.

**Decision.** Nanites orchestrates the whole rhi ecosystem; LLMs are one backend among many (normalize, tiltshift, paraphase, rescribe, unshape, moonlet, etc.). 'AI orchestration' is rejected as the wrong framing — it's just orchestration. Ctx carries only runtime concerns, nothing LLM-specific.

**Alternatives rejected.**
- *Make nanites LLM-aware (LLM-specific Ctx, AI-orchestration framing)* — The thesis is that LLMs fall away at the leaves as problems become well-defined; the ecosystem's deterministic tools ARE the well-defined leaves. Putting LLM context in Ctx would contradict that LLM calls are one node type among many.

**Consequences.** Core types stay LLM-agnostic; every rhi tool is a potential executor; LLM-specific concerns live in task data or executor config (e.g. nanites-rig), not the substrate. Mined from: /home/me/git/rhizone/nanites/docs/design/decisions.md (139), /home/me/git/rhizone/nanites/docs/design/decisions.md (141), /home/me/git/rhizone/nanites/docs/design/decisions.md (51).
