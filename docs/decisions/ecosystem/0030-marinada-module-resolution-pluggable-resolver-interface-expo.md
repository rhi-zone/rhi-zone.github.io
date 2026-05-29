# ADR-0030: Marinada module resolution: pluggable resolver interface, exported by Marinada, implemented by hosts

- Status: Accepted
- Date: 2026-05-29

**Context.** May 5 needed to pin module-resolution architecture for Marinada across module boundaries (let/letrec peeling for export-type extraction), and decide who owns resolution.

**Decision.** Pin module resolution as a pluggable interface — `(path: string) => Module | null` resolver with composable defaults and protocol-based dispatch. Marinada exports the interface; hosts (e.g. Aspect) provide the implementations.

**Alternatives rejected.**
- *Marinada owns/bundles a fixed module-resolution implementation* — A pluggable, protocol-based resolver with composable defaults was chosen instead so hosts provide implementations; a fixed built-in resolver would prevent host-specific resolution.

**Consequences.** Establishes a cross-repo contract: Aspect and other hosts implement the resolver interface Marinada defines. Resolution strategy is host-pluggable rather than baked into Marinada. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-26-2026-05-09.md (49).
