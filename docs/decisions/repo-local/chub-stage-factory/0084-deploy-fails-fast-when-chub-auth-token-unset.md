# ADR-0084: Deploy fails fast when CHUB_AUTH_TOKEN is unset, rather than gracefully skipping

- Status: Accepted
- Date: 2026-05-29

**Context.** The deploy.yml workflow runs on every push to main but requires the CHUB_AUTH_TOKEN secret. The audit considered adding a graceful-skip guard so deploy would no-op when the token is absent.

**Decision.** Keep the hard-fail: the 'Confirm CHUB_AUTH_TOKEN is set' step exits with code 1 when the secret is absent. Deploy is opt-in; the job fails on every push until the owner sets the secret. No graceful-skip guard is added.

**Alternatives rejected.**
- *Add a graceful-skip guard so the deploy job no-ops when the token is missing* — Explicitly rejected by the user; fail-fast on a missing token is intentional so a missing deploy credential is loud rather than silently skipped.

**Consequences.** Repos cloned from the factory show a failing deploy job until CHUB_AUTH_TOKEN (and optionally STAGE_ID) is configured; this is by design, not a bug to fix. Mined from: /home/me/git/pterror/chub-stage-factory/docs/CICD-AUDIT-2026-05-27.md (41), /home/me/git/pterror/chub-stage-factory/docs/CICD-AUDIT-2026-05-27.md (62).
