# Collaboration

Why is it hard? What does implementing it actually look like?

## The Technology Is Solved

CRDTs exist. Yjs, Automerge, yrs (Rust port). Mature, multi-language, production-ready. The *research* is done. The *libraries* exist.

So why isn't everything collaborative?

## Why Is Collaboration Hard To Implement?

### Most Software Assumes Single User

The default assumption everywhere:
- One cursor
- One selection
- One undo stack
- State changes are local and immediate
- No conflicts because there's only one source of truth

These assumptions are baked deep. Not in one place you can swap out - everywhere.

### State Management Wasn't Designed For It

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

### What Do You Have To Tear Out?

Depends on how the app was built:

**Centralized state (Redux, Zustand, etc.):** Easier. State is in one place. Replace the store with a CRDT-backed version. Still work, but contained.

**Scattered state (useState everywhere, vanilla JS):** Harder. State is all over. You have to find it all, centralize it, then make it collaborative. Major refactor before you even start.

**Assumed single-user UI:** Your text input assumes one cursor. Your selection assumes one user. Your drag-and-drop assumes one drag at a time. These need to become multi-user aware.

**Undo/redo:** Single user: stack of operations, pop to undo. Multi-user: whose undo? Undo *your* action even if others acted after? Operational transform territory.

### The Network Layer

Once state syncs, you need:
- Transport (WebSocket, WebRTC, etc.)
- Presence (who's connected, where's their cursor)
- Awareness (what are they selecting, what are they doing)
- Persistence (what if everyone disconnects - who has the truth?)
- Reconnection (sync missed changes when someone comes back)

Yjs handles the CRDT part. The network part is still on you (though y-websocket, y-webrtc exist).

### The UI Layer

Multi-user UI needs:
- Multiple cursors, labeled
- Multiple selections, colored
- "Someone is typing..." indicators
- Conflict visualization (rare with CRDTs, but possible)
- Latency hiding (optimistic updates)

None of this is free. Each is a feature to build.

## Framework Dependency

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

## What Would "Easy Collaboration" Look Like?

If we're bridging CRDTs to humans, what's needed?

1. **State layer that's collaborative by default** - You define your data, it syncs. Don't think about CRDTs.

2. **Presence/awareness built in** - "Who's here" and "where's their cursor" are automatic.

3. **UI primitives that handle multi-user** - Text inputs, selections, drag-drop that just work with multiple users.

4. **Network transport handled** - Don't configure WebSockets. Just "this is shared."

5. **Works offline, syncs when online** - Local-first by default.

6. **Doesn't require understanding CRDTs** - The abstraction is "shared state" not "conflict-free replicated data types."

This is the "bridge to humans" layer. Yjs handles the CRDT. Something needs to handle everything else.

## Prior Art

- **Yjs ecosystem** - y-websocket, y-webrtc, y-indexeddb. Building blocks but still requires assembly.
- **Liveblocks** - Hosted service, nice DX, but vendor lock-in and not self-hostable.
- **PartyKit** - Cloudflare-based, simpler than raw WebSockets, but still requires understanding.
- **Automerge + their sync protocol** - Similar to Yjs ecosystem.
- **Replicache** - Sync engine, different approach (not CRDT but sync framework).

All of these are closer to "for developers who know what they're doing" than "for anyone building an app."

## The Gap

The technology is solved. The developer experience isn't.

"Add collaboration to your app" should be as easy as "add authentication to your app" (which itself isn't that easy, but at least there are turnkey solutions).

We're not there. The pieces exist. The bridge doesn't.

## See Also

- [Problems](/problems) - Why collaboration matters
- [Vision](/vision) - Philosophy this serves
