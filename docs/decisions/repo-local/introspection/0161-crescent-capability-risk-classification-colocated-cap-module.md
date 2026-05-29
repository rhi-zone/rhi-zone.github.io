# ADR-0161: Crescent: capability risk classification colocated in per-cap modules, with ancestor-aware filesystem path classification

- Status: Accepted
- Date: 2026-05-29

**Context.** Crescent's capability (cap) system was too coarse to support system_dashboard work: a centralized `cap_risks.lua` held risk descriptions, caps were declared as flat labels like `caps = { 'shell' }`, the platform could only echo declared paths, and multi-cap/attenuation did not exist. The user pushed back that labels can lie and risk metadata must be structured and per-cap. Apr 26's design discussion crystallized a refactor.

**Decision.** Relocate risk classification out of the centralized `cap_risks.lua` and into the individual capability modules themselves, deleting `cap_risks.lua` entirely to enforce colocation, with a new `cap_dispatch.lua` as the single index mapping `decl.type` to module. Add ancestor-aware filesystem path classification that detects paths that ARE sensitive directories and paths that are ANCESTORS of sensitive directories, escalating severity accordingly (root_fs critical, keys high, user_home high-read/critical-write) — a parent path encompasses and inherits the severity of its descendants (e.g. a declared `/home/alice` encompasses `~/.ssh`).

**Alternatives rejected.**
- *Keep risk descriptions centralized in cap_risks.lua and surface only available/declared caps as flat labels* — Centralization was the design gap blocking system_dashboard; too coarse to express multi-cap, attenuation, and per-module risk. Labels can lie; risk metadata must be structured and per-cap, and the platform must warn about risks of all dangerous caps, not just surface available ones.
- *Classify filesystem caps by echoing only the literally-declared path* — Misses that a declared parent path (e.g. /home/alice) encompasses sensitive children like ~/.ssh; needs ancestor-aware detection to assign correct severity.

**Consequences.** Each cap module owns its own risk classification; `cap_dispatch.lua` is the single type-to-module index; path classification is ancestor-aware. system_dashboard and registry-action work depend on this. Multi-cap support and attenuation remained open at decision time. Note: the cap work was later set aside ('caps are off the table') for typechecker soundness, but the relocation decision itself was implemented, not reversed. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-26-2026-05-09.md (11), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-04-27.md (13), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-04-27.md (15), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-04-26.md (50).
