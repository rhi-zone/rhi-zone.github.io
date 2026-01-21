# Ecosystem TODO

Tracking issues for cross-project work.

## Nursery Integration: `--schema` Support

Add `--schema` flag to CLI tools for Nursery integration per [tool-integration.md](https://github.com/rhizome-lab/nursery/blob/master/docs/tool-integration.md).

When invoked with `--schema`, the tool prints a JSON Schema describing its configuration and exits.

### Projects with CLIs

- [x] **moss** - Code intelligence CLI
- [ ] **lotus** - World runtime CLI
- [ ] **cambium** - Pipeline orchestrator (no CLI yet)
- [ ] **dew** - Expression language (no CLI yet)
- [ ] **nursery** - Ecosystem orchestrator (has CLI, needs schema)

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
