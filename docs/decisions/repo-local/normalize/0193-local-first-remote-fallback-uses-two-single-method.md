# ADR-0193: Local-first/remote-fallback uses two single-method traits + coordinator, not one trait with a local_only flag

- Status: Accepted
- Date: 2026-05-29

**Context.** Features like doc fetching need both a local path (cargo source, node_modules, git, SQLite index, KG cache) and a network fallback. This could be modeled as one trait whose implementations sometimes hit the network depending on a flag, or as two separate traits joined by a coordinator.

**Decision.** Split into two single-method traits (e.g. LocalDocsExtractor::extract_docs and RemoteDocsFetcher::fetch_docs) coordinated by a get_with_fallback function (reference: fetch_symbol_docs_with_fallback). Local is always preferred; network is only the fallback path. The two traits are intentionally not collapsed.

**Alternatives rejected.**
- *A single DocsExtractor trait with a bool local_only flag whose impls sometimes hit the network* — Conflating the paths loses independent test surfaces, independent cache policies (local 'fresh as disk' vs remote TTL), independent error taxonomies (a network error from local is a bug; a 'not in lockfile' from remote is a bug), and independent impl sites (a new ecosystem can land remote-only or local-only first). Named explicitly as an anti-pattern: 'Do not do this.'

**Consequences.** New ecosystems can implement one half independently; mocking and caching are per-path. Establishes the broader local-first principle (network call when local data exists is an anti-pattern). The current CargoLocalDocsExtractor placement is a known violation being repaid, but the two-trait coordinator shape itself is endorsed as correct. Mined from: /home/me/git/rhizone/normalize/ARCHITECTURE.md (541), /home/me/git/rhizone/normalize/ARCHITECTURE.md (551-553).
