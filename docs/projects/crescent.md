# Crescent

**Comprehensive LuaJIT ecosystem — stdlib, typechecker, package manager.**

::: info Status: Fleshed Out ◐
44 commits, 287 Lua files. Type inference engine with structural operator dispatch, discriminated unions, generics, and metatable slot handling. Test infrastructure in place. Active development on type system features.
:::

Crescent is a monorepo of composable LuaJIT libraries, inspired by [thi.ng/umbrella](https://thi.ng/umbrella). All libraries are vendorable: copy what you need into your project and own it.

LuaJIT is the fastest scripting runtime with the best FFI. What it doesn't have is an ecosystem. Crescent is that ecosystem.

## Key features

- **stdlib** - HTTP, websocket, DNS, SQLite, filesystem, and more
- **Typechecker** - Type inference for Lua with FFI cdef parsing (single source of truth)
- **Package manager** - Vendor-first: installs by copying .lua files into your project
- **Pure Lua first** - FFI only when pure Lua can't do it
- **Hackable** - Every library is readable, modifiable, yours

## Prior art

- [thi.ng/umbrella](https://thi.ng/umbrella) - 210 TypeScript packages in one monorepo. Same model: one repo, one vision, composable pieces.
- [luapower](https://luapower.com/) - Collection of LuaJIT+FFI libraries with a similar vendor-friendly philosophy.

## Links

- [GitHub](https://github.com/rhi-zone/crescent)
