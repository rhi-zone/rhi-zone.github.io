# ADR-0260: Single recipe-instance canvas replaces the tabbed layout (v2)

- Status: Accepted
- Date: 2026-05-29

**Context.** The v1 editor exposed the five Statosphere schema arrays through a tabbed layout. That layout did not capture reusable, parameterized configuration patterns; v2 reframed the editor around composable recipes.

**Decision.** The studio is organized as a single canvas of recipe instances. Each recipe encapsulates a reusable, parameterized configuration pattern and materializes into the five Statosphere schema arrays (variables / classifiers / generators / contentRules / functions), which is the artifact pasted into Chub. The canvas is a stream of recipe instances rather than per-array tabs.

**Alternatives rejected.**
- *The old tabbed layout (one tab per schema array, raw JSON-ish editing)* — It exposed the five arrays directly but could not represent reusable parameterized patterns; the canvas model materializes recipe instances into those arrays instead.

**Consequences.** All editing flows through recipe instances that materialize into schema arrays; the materialize pipeline (src/recipes/materialize.ts) is now the central contract. The TODO notes a possible future IA redo, but the recipe-instance-on-canvas model itself is in force. Mined from: /home/me/git/pterror/statosphere-studio/README.md (7).
