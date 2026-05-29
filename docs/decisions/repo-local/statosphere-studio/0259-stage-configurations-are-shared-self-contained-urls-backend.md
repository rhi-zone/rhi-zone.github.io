# ADR-0259: Stage configurations are shared as self-contained URLs with no backend

- Status: Accepted
- Date: 2026-05-29

**Context.** A stage configuration needs to be shareable between users. The studio could have stored/served configs from a backend service.

**Decision.** Sharing is implemented by encoding the full studio state (instances + custom library) into the URL `#cfg=` hash via gzip + base64url, so a configuration can be shared as a link with no backend. The v2.5 wire format carries a studio sidecar so shared URLs restore the full recipe structure.

**Alternatives rejected.**
- *A backend service to persist and serve shared configurations* — Explicitly avoided so a stage configuration can be shared as a link with no backend, keeping the studio a pure client-side SPA.

**Consequences.** Share payloads are bounded by URL length and must be self-contained; encode/hydrate logic (src/share/encode.ts, hydrate.ts) carries a versioned wire format. No server infrastructure is required to deploy or operate sharing. Mined from: /home/me/git/pterror/statosphere-studio/CLAUDE.md (13), /home/me/git/pterror/statosphere-studio/README.md (13).
