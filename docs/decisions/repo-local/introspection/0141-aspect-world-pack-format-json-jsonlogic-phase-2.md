# ADR-0141: Aspect world pack format is JSON with JSONLogic for the Phase 2 predicate language

- Status: Accepted
- Date: 2026-05-29

**Context.** Aspect needed a serialization format for world packs and a predicate language for pack logic (validation/conditions) in Phase 2.

**Decision.** World packs use JSON as the format; JSONLogic is chosen as the predicate language for Phase 2.

**Alternatives rejected.**
- *Non-JSON pack format alternatives* — JSON was chosen over the alternatives considered (the log states 'JSON chosen over alternatives'), favoring a document-native, broadly tooled format.

**Consequences.** Pack tooling (export/import, pack validation, pack format/UI) targets JSON; Phase 2 predicate evaluation standardizes on JSONLogic. Future pack logic must express predicates in JSONLogic rather than a bespoke language. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-01-29.md (70).
