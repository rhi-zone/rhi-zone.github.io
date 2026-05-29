# ADR-0180: Capability security via host injection; scripts cannot construct capabilities

- Status: Accepted
- Date: 2026-05-29

**Context.** The require/constructor model lets any script call fs.capability({path="/",mode="rw"}), which is namespacing not security; needed a real capability-security model.

**Decision.** Capabilities must be injected by the trusted host (created from a policy file) and passed to scripts as arguments; the plugin module constructors are not exposed to the script sandbox, so scripts cannot forge capabilities and can only attenuate received ones.

**Alternatives rejected.**
- *Let scripts construct capabilities directly via the plugin module (e.g. fs.capability(...))* — That is only namespacing, not security; any script could request root access and escalate.

**Consequences.** require("moonlet.fs") is host-only and removed from the script environment; host builds caps from policy.toml and injects them; attenuation is a plugin-implemented method that can only narrow; revocation remains an open question. Mined from: /home/me/git/rhizone/moonlet/docs/design/plugin-architecture.md (600), /home/me/git/rhizone/moonlet/docs/design/plugin-architecture.md (650).
