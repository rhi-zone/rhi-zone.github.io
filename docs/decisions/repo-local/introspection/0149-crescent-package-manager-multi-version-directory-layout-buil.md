# ADR-0149: Crescent package manager: multi-version directory layout with no build step, ever

- Status: Accepted
- Date: 2026-05-29

**Context.** Crescent's package-manager design sprint (Mar 25-26) had to settle how dependencies are installed, consumed, and how version conflicts are resolved across an ecosystem the manager does not fully control, while avoiding the complexity costs npm pays. A build/compile step is the conventional way package managers prepare dependencies, but it imposes tooling and latency on every consumer.

**Decision.** Install packages under a multi-version directory layout — lib/<name>/v1/, lib/<name>/v2/ — with an auto-generated lib/<name>/init.lua redirect shim pointing to the current major version; resolve version conflicts via multi-version install (npm-like) while avoiding npm's multi-version complexity and maintaining semver discipline. The manager only touches versioned directories under a fixed lib/ default. Require a lockfile with hashes for reproducibility, support phantom-dependency linting, and support vendoring with diff support. Dependencies are consumed directly from already-usable source — no compilation/build phase, ever.

**Alternatives rejected.**
- *Include a build/compile step in the dependency pipeline (the conventional package-manager approach)* — Explicitly rejected as a permanent constraint: 'I don't want a build step, ever' — build steps add tooling and friction the design refuses to take on.
- *npm-style flat/nested multi-version resolution* — Positioned to avoid npm's multi-version complexity while maintaining semver discipline.
- *Configurable install location instead of a fixed lib/* — Settled on lib/ as default with redirect shims rather than configurable placement.

**Consequences.** Future crescent PM implementation is constrained to a versioned-directory layout with init.lua redirect shims, lockfile hashing, and phantom-dependency linting; consumers can pick package subsets but phantom-dep linting is required. No build pipeline is permitted, so the PM and any consumer must operate on already-usable source — making the serialization-layer choice load-bearing instead (JSON benchmarking showed Node.js beats pure Lua, suggesting the API itself may be the constraint rather than LuaJIT speed). Performance/platform constraints (Alpine/Windows/macOS, minimal external deps) carry forward. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-26.md (11), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-26.md (16), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-26.md (19), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-20-2026-03-27.md (62), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-03-20-2026-03-27.md (65).
