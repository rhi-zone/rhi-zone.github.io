# ADR-0012: No online resources in the loop: air-gapped bare clone is the supported configuration

- Status: Accepted
- Date: 2026-05-29

**Context.** Crescent is positioned as 'the ecosystem LuaJIT never had' but as a tool meant to be fully owned and legible. A choice had to be made about whether install, help, learning, activation, telemetry, and first-run experience may depend on the network. The industry default (even Microsoft Word's F1) points at a server.

**Decision.** No online resources are permitted anywhere in the loop — not for install, help, learning, activation, telemetry, license check, or first-run. A bare clone on an air-gapped machine is the supported configuration, both for the crescent tool itself and for everything built with it. LuaJIT binaries for all target platforms are vendored in bin/, so 'git clone and it runs' with no npm/pip/build step or internet after clone.

**Alternatives rejected.**
- *Network-dependent install/help/telemetry (the industry default, e.g. Word's F1 pointing at a server)* — The industry has decided the internet is part of the install; crescent disagrees. Network dependence breaks the 'make the computer small / knowable end-to-end' principle and fails on air-gapped machines, Docker containers, and offline use.

**Consequences.** All runtime binaries are vendored; no package-install network step is permitted for stdlib; discoverability and reference material must ship with the binary. This forecloses any future feature (telemetry, license checks, online help, registry-required runtime) that needs the network at use time. Mined from: /home/me/git/rhizone/crescent/docs/principles.md (35-38), /home/me/git/rhizone/crescent/docs/principles.md (40-42).
