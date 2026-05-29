# ADR-0229: Platform interface exposes low-level 2D primitives, not engine/sprite operations

- Status: Accepted
- Date: 2026-05-29

**Context.** The existing `system/` traits in reincarnate-core (Renderer, Audio, Input, SaveLoad, Timing, Ui) were intended as the platform interface but were pitched at the wrong abstraction level — `Renderer::draw_sprite()` assumes a sprite-based engine, `Ui::show_message()` is an engine-level concept. Flash uses a display list, not sprites, so an engine-level interface cannot be shared across engines.

**Decision.** Redesign the platform interface around engine-agnostic low-level capabilities. Graphics provides `draw_image()`/`fill_rect()`, not `add_to_display_list()`; the display list, event bubbling, and frame timelines live in the API shim above. SaveLoad becomes a byte key-value Persistence interface (store/fetch/remove, not save/load — serialization is the shim's job). Ui is removed entirely — dialogue boxes and menus are engine-level and each shim builds its own from graphics+input.

**Alternatives rejected.**
- *Keep the existing Renderer/Ui system traits as the platform interface* — They encode engine-level concepts (sprites, message boxes) that are not shareable: Flash uses a display list not sprites, and a UI message box is not a platform capability. An engine-specific interface defeats the swap-the-platform goal.

**Consequences.** Graphics replaces Renderer (2D primitives), Persistence replaces SaveLoad (key-value bytes, no serde), Ui is removed. The interface is a cross-language contract (TS, Rust, C#/Unity, SDL) using only primitive types and opaque u32 handles in exported signatures; unsupported calls fail explicitly rather than no-op silently. Mined from: /home/me/git/rhizone/reincarnate/docs/architecture.md (881-885), /home/me/git/rhizone/reincarnate/docs/architecture.md (895-897).
