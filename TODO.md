# Ecosystem TODO

Tracking issues for cross-project work.

## Branding Migration: rhizome → rhi

**Status:** Blocked - do this AFTER namespace audit and project name finalization

Migrate from "rhizome" branding to "rhi" to match rhi.zone domain:
1. **Namespace audit**: Check crates.io availability for all project names
   - Identify which projects need prefixes (namespace collision)
   - Decide: rescribe-style (no prefix) vs normalize-style (needs prefix)
2. **GitHub org rename**: rhi-zone → rhi-zone
   - Note: `rhi` org is taken on GitHub, so we'd use `rhi-zone`
   - Update all git remotes across ecosystem repos
   - Can script with gh cli + git remote set-url
3. **Crate prefix migration**: rhi-* → rhi-*
   - Update all Cargo.toml workspace members
   - Update all internal crate references
   - Update imports in all projects
4. **Documentation updates**:
   - CLAUDE.md in all repos
   - README.md in all repos
   - docs/about.md, docs/projects/*
   - Update branding/philosophy to explain "rhi" as shorthand
5. **Domain configuration**: See rhi.zone planning section below

**Prerequisites:**
- [ ] Complete project name audit (which need botanical renames?)
- [ ] Finalize rescribe integration
- [ ] Finalize server-less rename
- [ ] Test GitHub org rename on a dummy org first

## rhi.zone Domain Planning

**Status:** Ideas phase - needs refinement before implementation

### Subdomain Structure

**Project-specific docs:**
- `normalize.rhi.zone` → Normalize documentation
- `moonlet.rhi.zone` → Moonlet documentation
- `unshape.rhi.zone` → Unshape documentation
- etc. (makes each project feel independent under unified brand)

**Functional subdomains:**
- `docs.rhi.zone` → Main ecosystem docs (what's currently at root)
- `api.rhi.zone` → Unified API gateway (if built)
- `play.rhi.zone` → Interactive playground/demos
- `pkg.rhi.zone` → Package index/search (like docs.rs but for rhi)

### Root Domain (rhi.zone)

Landing page options:
- Interactive project switcher with ecosystem visualization
- Live demos of each project in action
- Playground: Try Dew expressions, Normalize queries, Unshape generation in-browser
- Status dashboard: Build status, release versions across projects

### Short URLs

Pattern: `rhi.zone/{project-initial}/{topic}`
- `rhi.zone/m/view` → Normalize view command docs
- `rhi.zone/s/plugin` → Moonlet plugin docs
- `rhi.zone/r/audio` → Unshape audio docs
- Short, memorable links for common docs pages

### TODO

- [ ] Design landing page mockup
- [ ] Decide on subdomain strategy (project subdomains vs all under docs.rhi.zone)
- [ ] Plan short URL scheme and routing
- [ ] Implement DNS configuration
- [ ] Set up subdomain deployments
- [ ] Build landing page
- [ ] Create playground infrastructure

## Session Analysis: Sessions to Investigate

Identified via `normalize sessions show --analyze`. These sessions have high rework, context pressure, or unusual patterns worth deeper analysis (especially once `show --analyze` is improved).

### High-Rework Sessions

- **dew** `28d418c3` - 455 turns, 6 corrections, 8 build failures, 20 touches on a single Cargo.toml. Peak context 141.7K. The poster child for file thrashing.
- **normalize** `6b847726` - 283 turns, 4 corrections, 17 command failures, 217 parallelizable API calls. Context hit 131K. Shows sequential Bash chain waste at scale.
- **normalize** `bc20cfe9` - Second-most-recent normalize session, likely similar patterns.

### High-Cost-Per-Session Repos

These repos have the highest $/session and deserve per-session deep dives:

- **sketchpad** - $7.78/session avg, 96.8K avg context. Any recent session worth analyzing.
- **ooxml** - $5.01/session avg, 92K avg context.
- **rescribe** - $4.58/session avg, 89.5K avg context.

### Agent Sessions (hub-spawned)

- **server-less** `agent-af3501f`, `agent-aefeb60`, `agent-acbd5a3` - Hub-spawned agents; compare efficiency to interactive sessions.
- **dew** `agent-a904a54`, `agent-a92d4e2` - Same.
- **parents** `agent-a82a79f`, `agent-aa8010c` - Same.

### TODO

- [ ] Re-run analysis after `show --analyze` improvements land in normalize
- [ ] Compare agent-spawned vs interactive session efficiency
- [ ] Track per-repo $/session trends over time
- [ ] Identify which CLAUDE.md changes actually reduce Bash chain length

## Myenv Integration: `--schema` Support

Add `--schema` flag to CLI tools for Myenv integration per [tool-integration.md](https://github.com/rhi-zone/myenv/blob/master/docs/tool-integration.md).

When invoked with `--schema`, the tool prints a JSON Schema describing its configuration and exits.

### Projects with CLIs

- [x] **normalize** - Code intelligence CLI
- [ ] **lotus** - World runtime CLI
- [ ] **paraphase** - Pipeline orchestrator (no CLI yet)
- [ ] **dew** - Expression language (no CLI yet)
- [ ] **myenv** - Ecosystem orchestrator (has CLI, needs schema)

### Implementation

Use `schemars` crate to derive JSON Schema from config structs:

```rust
use schemars::JsonSchema;

#[derive(JsonSchema)]
struct Config { ... }

if args.get(1) == Some(&"--schema".to_string()) {
    let schema = schemars::schema_for!(Config);
    println!("{}", serde_json::to_string_pretty(&schema).unwrap());
    return;
}
```
