# Statosphere Studio

**Best-in-class editor for Statosphere stage configurations.**

::: info Status: Active ●
Embeddable Vue 3 component with built-in help, templates, shareable URL hashes, and runtime-gotcha lints. Ships as both a standalone SPA and an importable library.
:::

**Repository:** [github.com/pterror/statosphere-studio](https://github.com/pterror/statosphere-studio)
**Site:** [pterror.github.io/statosphere-studio/](https://pterror.github.io/statosphere-studio/)

## Overview

[Statosphere](https://github.com/Lord-Raven/statosphere) is a Chub.ai stage extension that lets authors attach rich configuration — classifiers, generators, content rules, variables — to any stage. Writing that configuration by hand is error-prone: the schema is complex, gotchas are numerous, and the feedback loop is slow.

Statosphere Studio collapses the edit-test cycle. The editor knows the schema, surfaces contextual help inline, and catches known runtime gotchas before deployment. Configurations can be shared as URL hashes — no server, no account.

## Key features

- **Embeddable** — ships as a Vue 3 component (`StatosphereStudio`) importable from `statosphere-studio`; Vue is externalized
- **Built-in help** — contextual documentation surfaced at the field level, not in a separate tab
- **Templates** — starter configurations for common patterns
- **Shareable URL hashes** — full config encoded in the URL fragment; no backend required
- **Runtime-gotcha lints** — static checks for known Statosphere edge cases that fail silently at runtime

## Embedding

```ts
import { StatosphereStudio } from 'statosphere-studio'
```

Vue must be a peer dependency (not bundled). The component accepts the config as a prop and emits change events.

## Related

- [statosphere-guide](https://github.com/pterror/statosphere-guide) — comprehensive unofficial reference for Statosphere: variables, functions, classifiers, generators, stage lifecycle, and JSON schema

## Links

- [GitHub](https://github.com/pterror/statosphere-studio)
- [Live editor](https://pterror.github.io/statosphere-studio/)
