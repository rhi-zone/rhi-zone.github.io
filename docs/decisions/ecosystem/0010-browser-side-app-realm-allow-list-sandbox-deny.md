# ADR-0010: Browser-side app realm is an allow-list sandbox, not deny-list/SES, with no daemon-side JS parser validation

- Status: Accepted
- Date: 2026-05-29

**Context.** Apps shipping browser UI run author JS with ambient page authority, which is unacceptable once third-party app code shares an origin. A sandbox model and a security boundary had to be chosen, plus whether to enforce a JS source subset at app-load via a parser.

**Decision.** Resolved to an in-house allow-list realm lockdown: the iframe realm starts with JS language primitives only and structurally deletes everything else; new TC39 features are absent by construction. The runtime sandbox (lib/js_realm_sandbox/) is THE security boundary. The daemon enforces NO parser-side rules; language-level constraints are handled at runtime (patched non-constructable bind, forced strict mode, CSP) or become optional author hygiene via lib/js_pack_validator/. SES is reference material, not a runtime dependency.

**Alternatives rejected.**
- *Deny-list lockdown (SES) enumerating dangerous intrinsics* — Deny-lists rot as the browser ships new APIs (the 'TC39 catch-up gap'); allow-list inverts the framing so new features are absent by construction. SES's deny-list framing exists for backwards-compat crescent doesn't need.
- *WASM-based isolation* — Once the allow-list realm is structurally tight, the prototype-chain escape class is already closed; WASM's ~500kb bundle no longer earns its keep.
- *Daemon-side parse-and-validate of app JS at load using a vendored JS parser (acorn/equivalent)* — Bundling bun/any JS interpreter violates zero-dependency; a Lua-native JS parser is multi-week effort and a maintenance burden; acorn-as-WASM has no clean off-the-shelf path.

**Consequences.** Security rests entirely on the runtime realm lockdown plus an enumerated escape-test corpus that the implementation must defeat; the daemon serves whatever the author ships; a SIZE_CAP and bounded-method patches handle DoS. The pack_validator is dev/CI hygiene only, never in the daemon critical path. Mined from: /home/me/git/rhizone/crescent/docs/platform_isolation.md (316-318), /home/me/git/rhizone/crescent/docs/platform_isolation.md (400-404), /home/me/git/rhizone/crescent/docs/platform_isolation.md (595-596).
