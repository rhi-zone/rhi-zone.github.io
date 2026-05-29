# ADR-0154: Connector architecture: Transport trait, fixed to the Discord pattern

- Status: Accepted
- Date: 2026-05-29

**Context.** Interconnect needed to add Listmonk, Slack, and Zulip connectors. The choice was whether each connector defines its own shape or conforms to an established pattern.

**Decision.** All new connectors follow the Discord connector pattern exactly: a Transport trait where send() handles SendMessage, recv() polls and filters, and Connection::established() establishes the link. Three parallel implementations independently converged on this identical structure, confirming it as the stable connector contract.

**Alternatives rejected.**
- *Let each connector define a bespoke structure suited to its platform* — Independent convergence on the identical Transport-trait structure confirmed the shared pattern is stable; bespoke shapes would block embarrassingly-parallel implementation and cross-platform room synchronization.

**Consequences.** New connectors are structurally identical and parallel-implementable without merge conflicts; the stable pattern is the precondition for cross-platform room synchronization, the next horizon. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-28-2026-03-31.md (45).
