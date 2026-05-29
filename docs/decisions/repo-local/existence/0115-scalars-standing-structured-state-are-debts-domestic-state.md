# ADR-0115: Scalars standing in for structured state are debts; domestic state is modeled as objects with histories

- Status: Accepted
- Date: 2026-05-29

**Context.** The apartment's messiness was represented by an aggregate scalar (apartment_mess: 67). Prose needed to say specific things ('the shirt you've worn three days') that a single number cannot support.

**Decision.** A scalar that stands in for something with more structure is a named debt, not a design choice. apartment_mess is removed as a primary variable; mess becomes emergent from real objects (dishes, linens, clothing) with independent states and histories. messTier() becomes derived or goes away. Genuinely-fungible scalars (money, financial anxiety) are explicitly NOT debts.

**Alternatives rejected.**
- *Keep aggregate scalars like apartment_mess as the state model* — A single scalar implies the apartment has one mess level when it actually has independent things in independent states; it forces prose to pretend at specificity it can't support, and doing the dishes shouldn't move the jeans.

**Consequences.** Domestic objects are tracked individually with state and history; mess is computed from them. A residual light scalar may remain only for untracked entropy (dust/mail) and must be labeled as residual. Old saves predating object systems get neutral legacy stubs. The test 'real quantity vs. stand-in for structure' governs all future scalar choices. Mined from: /home/me/git/paragarden/existence/docs/design/objects.md (3), /home/me/git/paragarden/existence/docs/design/philosophy.md (37), /home/me/git/paragarden/existence/docs/design/objects.md (13).
