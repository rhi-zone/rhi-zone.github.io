# Deskspace

**Unified file workspace server.**

::: info Status: Idea ○
No code yet—project just scaffolded.
:::

Deskspace is a file browser, viewer, editor, and sharing server where browsing and authoring are the same surface. Open a file and it's just there—as a tab, a panel, a window in your file browser. The separation between browsing and editing was always artificial; deskspace removes it.

## Key features

- **Browse, view, edit, share** - All first-class, no mode switching
- **Tabs/windows/panels** - Files open inline, not in a separate editor
- **Plugin architecture** - Core handles fundamentals, plugins extend everything
- **Web server** - Access from any device on your network
- **Localhost-first** - Secure by default, explicit opt-in for sharing

## Prior art

- [copyparty](https://github.com/9001/copyparty) - Portable file server with editing bolted on. Feature-rich monolith. Deskspace takes a different approach: core + plugins, and editing is integrated into the browsing surface rather than being a separate mode.

## Links

- [GitHub](https://github.com/rhi-zone/deskspace)
- [Documentation](https://rhi.zone/deskspace/)
