# ADR-0089: Specialcases as version-controlled override files, not hand-edits to generated code

- Status: Accepted
- Date: 2026-05-29

**Context.** Generated bindings will sometimes be wrong or need manual fixes (type overrides, signature fixes, doc comments, added/removed bindings). The design had to decide how those manual corrections survive regeneration.

**Decision.** Manual corrections live in version-controlled, auditable override files (`schemas/<api>/specialcases.toml`) applied on top of generated code — modeled on Nix/portage patches. Regeneration preserves and reapplies the specialcases.

**Alternatives rejected.**
- *Edit the generated code directly* — Direct edits are clobbered on regeneration and are not auditable; the override-file model keeps corrections version-controlled and reapplied automatically across regenerations.

**Consequences.** Manual fixes are durable across regeneration and reviewable in version control. Requires building a patch/override application mechanism into codegen. Overrides become part of each API's checked-in artifacts. Mined from: /home/me/git/rhizone/concord/TODO.md (73), /home/me/git/rhizone/concord/TODO.md (74), /home/me/git/rhizone/concord/TODO.md (76).
