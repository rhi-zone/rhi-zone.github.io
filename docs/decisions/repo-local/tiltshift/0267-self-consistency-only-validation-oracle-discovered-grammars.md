# ADR-0267: Self-consistency is the only validation oracle for discovered grammars

- Status: Accepted
- Date: 2026-05-29

**Context.** To confirm a discovered bytecode grammar is correct, one could compare against a reference disassembler or known-format ground truth. But that would reintroduce format dependence and external tooling. The design needed a validation criterion compatible with the from-scratch constraint.

**Decision.** Validate grammars only via two format-agnostic, data-internal metrics: decode coverage (fraction of bytes decoding as valid instructions) and jump target validity (fraction of branch operands landing on instruction boundaries). Both require only the data and the candidate grammar, no external reference. These metrics drive the confidence formula.

**Alternatives rejected.**
- *Validate against an external reference disassembler / known-format ground truth* — Would reintroduce format knowledge and break the from-scratch law; the design explicitly requires metrics that "require only the data and the candidate grammar — no external reference."
- *Use entropy as a standalone signal* — entropy is "weak as a standalone signal"; chi-square and compression ratio are more honest proxies for randomness

**Consequences.** Confidence scoring is grounded in self-consistency (base = decode_coverage x 0.70, jump bonus = jump_validity x 0.20). The tool can claim correctness without any oracle, which is what makes unknown-format discovery tractable. Validation can never appeal to an authoritative external decoder. Mined from: /home/me/git/rhizone/tiltshift/DESIGN.md (146), /home/me/git/rhizone/tiltshift/DESIGN.md (149).
