# Nanites

**Flexible orchestration. Stateless functions all the way down.**

::: info Status: In Development ◑
~5K lines across 3 crates (nanites-core, nanites-rig, nanites-chat). Core substrate implemented: Task/IoTask split, dynamic graph via ctx.spawn, Frontier, ExecGraph, Scaffold system, TaskRegistry, Runtime. LLM tasks via rig. Active development.
:::

**Repository:** [github.com/rhi-zone/nanites](https://github.com/rhi-zone/nanites)

## The Problem

Modern AI agent architectures share a structural flaw: they build on **conversation as the foundational primitive**. Conversation accumulates context — and accumulating context is context poisoning. Every turn that appends prior outputs narrows the possibility space, fills context with conversational artifacts, and conditions the model on its own errors.

The "Dumb Zone," compaction, episode compression, subagent isolation — these are patches on a broken foundation.

The key insight: instruct-tuned models are trained on **turns**, not conversations. A turn is context in, output out. Accumulating context between turns is an assumption the industry imposed, not a requirement of the model.

## The Thesis

1. **The right unit is the function call.** Stateless, typed (`T → U`), composable, parallelizable. An LLM call is one implementation — so is a deterministic function, a database lookup, or any other callable.

2. **Recursive decomposition is the architecture.** Problems break into trees of subproblems. Smaller chunks are more well-defined. Well-defined problems don't need world knowledge — they need execution. LLMs fall away at the leaves.

3. **The orchestrator is a program, not an agent.** Orchestration is regular Rust code. The LLM is an oracle the program calls when world knowledge is needed. The LLM decides; the program acts.

4. **No trait, just functions.** The fundamental primitive is `async Fn(I) -> Result<O, E>`. No framework trait wrapping it. Composition, parallelism, and model-swapping fall out naturally.

## Architecture

### Task vs IoTask

```rust
// Pure task: implements run() directly
impl Task for Double {
    type Input = i64;
    type Output = i64;
    async fn run(&self, input: i64, ctx: &Ctx) -> Result<i64, Infallible> {
        Ok(input * 2)
    }
}

// I/O task: pure data, executor injected at runtime
#[derive(Serialize, Deserialize)]
struct CompletionTask { model: String, system: Option<String> }

impl IoTask for CompletionTask {}  // marker only — no run()
```

- **`Task`** — implement `run()` for pure computation. Blanket `Execute` impl handles dispatch.
- **`IoTask`** — pure data marker. Register a `TaskExecutor` on the Runtime that injects external resources (model clients, DB connections) at execution time.

Task structs stay as pure serializable data throughout — no resource handles, no non-serializable fields.

### Dynamic Graph

Tasks compose by spawning subtasks through `Ctx`. The graph grows dynamically as tasks execute:

```rust
async fn run(&self, input: Problem, ctx: &Ctx) -> Result<Solution, Error> {
    let a = ctx.spawn(StepA, input.part_a());   // TaskHandle<OutputA>
    let b = ctx.spawn(StepB, a);                // depends on a
    ctx.spawn_all(StepC, vec![b, ...]).await     // fan-out
}
```

### Frontier and ExecGraph

Two separate structures with different lifecycles:

- **`Frontier`** — pending tasks only. Inspectable, prunable, reorderable. Shrinks as tasks complete.
- **`ExecGraph`** — monotonically growing audit record. Every spawned task, its params snapshot, parent, children, terminal state.

### Scaffolds

`Scaffold` is `Fn(&DynTask) -> DynTask` — inspect any pending task and return it transformed. Applied before every spawn. Used for logging, conditional prompt injection, task replacement.

## Crates

| Crate | Description |
|-------|-------------|
| `nanites-core` | Task, IoTask, TaskExecutor, Frontier, ExecGraph, Scaffold, TaskRegistry, Runtime, Ctx |
| `nanites-rig` | LLM tasks via rig: CompletionTask, ChatTask, RigCompletionExecutor |
| `nanites-chat` | Chat-oriented task layer |

## Goal

Build a fully general software engineering agent that beats frontier tools (Claude Code, Codex) on reliability, cost, and task length — or prove the thesis wrong. If the architecture is right, it wins by being simpler.

## Related

- [Unshape](/projects/unshape) — same registry-based design patterns, different execution model (synchronous tight loop vs. async I/O)

## Links

- [GitHub](https://github.com/rhi-zone/nanites)
