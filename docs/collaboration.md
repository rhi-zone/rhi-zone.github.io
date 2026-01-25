# Collaboration

**See also:** [Problems](/problems) (why this matters), [Vision](/vision) (philosophy this serves)

Why is it hard? What does implementing it actually look like?

## The technology is solved

CRDTs exist. Yjs, Automerge, yrs (Rust port). Mature, multi-language, production-ready. The *research* is done. The *libraries* exist.

So why isn't everything collaborative?

## Why is collaboration hard to implement?

### Most software assumes single user

The default assumption everywhere:
- One cursor
- One selection
- One undo stack
- State changes are local and immediate
- No conflicts because there's only one source of truth

These assumptions are baked deep. Not in one place you can swap out - everywhere.

### State management wasn't designed for it

Typical app state:
```
user clicks button → update state → re-render
```

Collaborative app state:
```
user clicks button → update local state → sync to network →
receive remote changes → merge without losing local changes →
resolve conflicts → re-render → handle latency →
show what others are doing → don't flicker
```

The complexity isn't the CRDT. It's everything around it.

### What do you have to tear out?

Depends on how the app was built:

**Centralized state (Redux, Zustand, etc.):** Easier. State is in one place. Replace the store with a CRDT-backed version. Still work, but contained.

**Scattered state (useState everywhere, vanilla JS):** Harder. State is all over. You have to find it all, centralize it, then make it collaborative. Major refactor before you even start.

**Assumed single-user UI:** Your text input assumes one cursor. Your selection assumes one user. Your drag-and-drop assumes one drag at a time. These need to become multi-user aware.

**Undo/redo:** Single user: stack of operations, pop to undo. Multi-user: whose undo? Undo *your* action even if others acted after? Operational transform territory.

### The network layer

Once state syncs, you need:
- Transport (WebSocket, WebRTC, etc.)
- Presence (who's connected, where's their cursor)
- Awareness (what are they selecting, what are they doing)
- Persistence (what if everyone disconnects - who has the truth?)
- Reconnection (sync missed changes when someone comes back)

Yjs handles the CRDT part. The network part is still on you (though y-websocket, y-webrtc exist).

### The UI layer

Multi-user UI needs:
- Multiple cursors, labeled
- Multiple selections, colored
- "Someone is typing..." indicators
- Conflict visualization (rare with CRDTs, but possible)
- Latency hiding (optimistic updates)

None of this is free. Each is a feature to build.

## Framework-specific: Vue reactivity

Vue's reactivity is proxy-based - it wraps objects and detects mutations. How does this interact with CRDTs?

**The mental model conflict:**
- Vue: mutate state directly (`this.count++`), Vue detects and re-renders
- CRDT: changes go through the CRDT API, which handles merge/sync

These aren't naturally compatible. You either:
1. Make the CRDT look like normal Vue state (wrap it in reactive proxy)
2. Or give up Vue's nice mutation syntax and always go through CRDT methods

**Two sources of truth problem:**
```
Local mutation → Vue reactive state → ??? → CRDT → sync
Remote change → CRDT → ??? → Vue reactive state → re-render
```

You need bidirectional binding between Vue's reactive system and the CRDT. Both directions need to work without infinite loops.

**Granularity mismatch:**
- Vue tracks at property level
- Yjs has Y.Map, Y.Array, Y.Text with their own granularity
- Deep nesting gets complicated - which layer "owns" reactivity?

**What exists:**
- `y-vue` - but how maintained? How deep is the integration?
- Vue devs often end up writing custom binding layers
- The "just works" experience isn't there

**A pragmatic pattern that works:**
```ts
// Create reactive views of CRDT state
function useYText(text: Y.Text) {
  const content = ref<string>()
  watchEffect((onCleanup) => {
    const update = () => content.value = text.toJSON()
    update()
    text.observe(update)
    onCleanup(() => text.unobserve(update))
  })
  return content
}
```

This is the "wrap and observe" approach - don't try to make the CRDT *be* a Vue reactive object. Instead, create reactive refs that are views of CRDT state, using `watchEffect` for lifecycle (setup observers, clean up on unmount). You still interact with Yjs types directly, but you get reactive views for the template.

Not as elegant as native integration, but it works. The cleanup handling via `onCleanup` is the key insight - Vue's reactivity lifecycle manages Yjs observers.

**At scale, this pattern holds but complexity grows:**
- Reusable composables (`useObserveYjs`, `useObserveYjsDeep`) across the codebase
- `markRaw` for heavy objects Vue shouldn't deep-track (awareness, connections, registries)
- Undo manager state synced via Yjs observers → reactive Vue state
- Subdocument handling, provider lifecycle, reconnection logic
- Real production code doing this is substantial - not trivial glue

The pattern works, but it's work. Every project reinvents some of this.

**What would help:**
- A Y.Map that *is* a Vue reactive object (not wrapped, native)
- Or: Vue reactivity primitives that understand CRDT sync
- The frameworks need to meet in the middle, not be bridged after the fact

This is one example. React has different issues (immutability assumptions vs CRDT mutation). Svelte has others (compile-time reactivity). Each framework has its own friction with the CRDT model.

## Framework dependency

How hard this is depends enormously on your starting point:

| Starting point | Difficulty |
|----------------|------------|
| Greenfield, designed for collab | Manageable |
| React + centralized state | Medium - refactor store |
| Vanilla JS, scattered state | Hard - major refactor first |
| Native app, custom everything | Very hard |
| Game engine with networking | Often easier - networking is expected |
| Legacy codebase | Possibly impossible without rewrite |

Games often have it easier because multiplayer was always a possibility. The architecture accounts for network state. Most productivity software never considered it.

## What would "easy collaboration" look like?

If we're bridging CRDTs to humans, what's needed?

1. **State layer that's collaborative by default** - You define your data, it syncs. Don't think about CRDTs.

2. **Presence/awareness built in** - "Who's here" and "where's their cursor" are automatic.

3. **UI primitives that handle multi-user** - Text inputs, selections, drag-drop that just work with multiple users.

4. **Network transport handled** - Don't configure WebSockets. Just "this is shared."

5. **Works offline, syncs when online** - Local-first by default.

6. **Doesn't require understanding CRDTs** - The abstraction is "shared state" not "conflict-free replicated data types."

This is the "bridge to humans" layer. Yjs handles the CRDT. Something needs to handle everything else.

## Prior art

- **Yjs ecosystem** - y-websocket, y-webrtc, y-indexeddb. Building blocks but still requires assembly.
- **Liveblocks** - Hosted service, nice DX, but vendor lock-in and not self-hostable.
- **PartyKit** - Cloudflare-based, simpler than raw WebSockets, but still requires understanding.
- **Automerge + their sync protocol** - Similar to Yjs ecosystem.
- **Replicache** - Sync engine, different approach (not CRDT but sync framework).

All of these are closer to "for developers who know what they're doing" than "for anyone building an app."

## Is this solvable?

On paper, mostly yes. What "solved" means varies by ecosystem:

**JavaScript/TypeScript (Vue, React, Svelte)**

The CRDT layer is solved (Yjs). What's missing:
- First-class reactive primitives that are CRDT-backed
- `const count = ref(0)` → `const count = sharedRef(0)` and it syncs
- Framework-blessed, maintained bindings (not third-party, possibly abandoned)
- Presence/awareness in dev tools
- "Make this shared" as a one-line change, not an architecture rewrite

"Solved" = you don't think about CRDTs. You think about shared state.

**Rust**

yrs exists (Yjs port). Different situation - no reactive UI framework paradigm to integrate with. What's missing:
- Derive macros: `#[derive(Crdt)]` on a struct and it works
- Good sync transport abstractions
- Persistence story (CRDT ↔ database)

"Solved" = defining collaborative data is as easy as defining regular data.

**Other languages**

Automerge has multiple language ports. But "solved" depends on what frameworks exist in that ecosystem. Python has no dominant reactive UI framework. Go doesn't either. The problem is smaller there - or maybe just different.

**Cross-language**

The harder problem: Yjs document in browser ↔ yrs in Rust backend ↔ mobile client. The wire format is compatible, but the ergonomics of "same document, multiple languages" are rough.

"Solved" = language is an implementation detail, not a barrier.

**The meta-answer**

"Solved" = collaboration is a property you add to state, not an architecture you adopt. Like how `async` infected everything it touched, but eventually became manageable. Collaboration should be a modifier, not a rewrite.

## The gap

The technology is solved. The developer experience isn't.

"Add collaboration to your app" should be as easy as "add authentication to your app" (which itself isn't that easy, but at least there are turnkey solutions).

We're not there. The pieces exist. The bridge doesn't.

