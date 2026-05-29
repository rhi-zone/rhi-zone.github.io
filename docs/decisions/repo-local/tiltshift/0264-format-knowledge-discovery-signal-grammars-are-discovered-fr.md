# ADR-0264: No format knowledge in the discovery signal; grammars are discovered from first principles

- Status: Accepted
- Date: 2026-05-29

**Context.** Bytecode grammar discovery must handle WASM, .pyc, JVM, x86, and unknown custom VMs. The natural shortcut is to special-case known formats so the algorithm recognizes them quickly. The design had to choose between baking in format knowledge versus deriving structure with zero priors.

**Decision.** The discovery algorithm contains zero special cases for any named bytecode format. Named-format grammar files (data/opcodes/<format>.toml) are outputs of verified discovery, never inputs; the signal never reads them. Discovery must derive each format from scratch every time, or the tool has failed.

**Alternatives rejected.**
- *Let discovery read named-format grammar files / special-case known formats* — Would make the algorithm format-aware rather than general; "If it cannot [derive from first principles], the tool has failed." Special-casing defeats the core purpose of handling unknown custom VMs.

**Consequences.** Grammar files are strictly persistence for display/validation (the `decode` command), not analysis inputs. The discovery path must remain general and is testable against any format. Forecloses optimizing accuracy by hardcoding known opcodes. Mined from: /home/me/git/rhizone/tiltshift/DESIGN.md (144), /home/me/git/rhizone/tiltshift/DESIGN.md (140), /home/me/git/rhizone/tiltshift/DESIGN.md (155).
