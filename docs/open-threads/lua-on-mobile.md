# Lua on mobile (Android / Termux)

**Project(s) touched:** crescent, moonlet (deployment story)

**Status:** Open — paused substrate-scope question

**Surfaced in:** session `6842c90d` (io, 2026-04-30), a 169-turn drift that ended on browser-based local UIs and whether LuaJIT runs on Termux. Last assistant message: "Interpreter mode is still Lua, still runs, just slower. For the kinds of apps we're talking about — notes, tracking, navigation — that's fine. Not a blocker." No continuation followed.

---

## The question

Is a mobile (Android / Termux) target for crescent/moonlet **in scope**?

## What's established

- Android disallows JIT, so LuaJIT falls back to the interpreter.
- The interpreter is still Lua and still runs — for light apps (notes,
  tracking, navigation) the performance is acceptable, not a blocker.

## What's still open

- Performance not being a blocker is *not* the same as the mobile target being
  in scope. Whether crescent/moonlet should commit to a mobile deployment story
  at all is unresolved.

## Related

Rooted in the same conversation as
[out-of-scope-stance](./out-of-scope-stance) ("the moment we call something out
of scope is the moment we fail") — the scope decision here is exactly the kind of
call that stance bears on.

## Working answer

None — interpreter fallback works; in-scope decision unmade.
