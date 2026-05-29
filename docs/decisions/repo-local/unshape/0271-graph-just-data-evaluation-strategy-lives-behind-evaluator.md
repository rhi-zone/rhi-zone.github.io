# ADR-0271: Graph is just data; evaluation strategy lives behind an Evaluator trait

- Status: Accepted
- Date: 2026-05-29

**Context.** The same graph needs different execution strategies in different contexts: pull+lazy for texture/mesh generation and offline render, push+eager/streaming for real-time audio and live preview, push-invalidate+pull for interactive editing. Baking one strategy into the graph would foreclose the others.

**Decision.** Separate graph structure from evaluation. Graph is a plain data structure (nodes + wires, no evaluation logic). An Evaluator trait determines execution; built-in evaluators (Lazy, Eager, Streaming, Incremental) share common utilities. The default is LazyEvaluator (pull + lazy). Users can implement custom evaluators.

**Alternatives rejected.**
- *Bake a single evaluation strategy into the graph* — The same graph may need different strategies in different contexts (offline render vs live preview vs real-time audio), so a fixed strategy would not fit all use cases

**Consequences.** Evaluators are independent and separately testable against shared fixtures; new strategies add ~100-300 LOC without touching the graph. Cache policy and parallelism are also pluggable traits (KeepAll / sequential defaults). EagerEvaluator may never be needed since lazy covers most cases. Mined from: /home/me/git/rhizone/unshape/docs/design/evaluation-strategy.md (40), /home/me/git/rhizone/unshape/docs/design/evaluation-strategy.md (37), /home/me/git/rhizone/unshape/docs/design/evaluation-strategy.md (660).
