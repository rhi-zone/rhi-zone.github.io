# ADR-0051: Invisible manifest: tools read generated native configs, never myenv.toml

- Status: Accepted
- Date: 2026-05-29

**Context.** A central manifest (myenv.toml) defines configuration for many ecosystem tools. The design had to decide whether tools read the central manifest directly or whether myenv compiles it down to per-tool native config files that tools read as usual.

**Decision.** myenv generates per-tool native config files; tools never read myenv.toml directly and require no special runtime behavior. The manifest is invisible to tools and myenv itself is optional.

**Alternatives rejected.**
- *Tools read the central myenv.toml manifest directly at runtime* — Would require every tool to understand the central manifest format and add special runtime behavior; the design holds 'Tools stay dumb' and that tools 'work standalone, myenv is optional', so coupling tools to the manifest was rejected.

**Consequences.** Every ecosystem tool can be used standalone with its own native config, and myenv is an optional generation layer on top. Tools must continue to read only their own config files. myenv must be able to write each tool's native format. Mined from: /home/me/git/rhizone/myenv/docs/design.md (8), /home/me/git/rhizone/myenv/docs/design.md (9), /home/me/git/rhizone/myenv/docs/design.md (150).
