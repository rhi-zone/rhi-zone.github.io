# Contributing

Guidelines for contributing to Rhizome projects.

## Development Setup

### Standard Setup

Most projects need Rust and/or Bun:

```bash
# Rust projects (Moss, Resin)
cargo build
cargo test

# TypeScript/docs
bun install
bun run dev
```

### Nix (Optional)

For reproducible environments, projects include `flake.nix`:

```bash
nix develop
# or with direnv: direnv allow
```

This ensures exact versions of all dependencies but isn't required.

## Commit Conventions

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(parser): add support for Lua 5.4 syntax
fix(audio): prevent clipping in sine oscillator
docs(api): document Field trait combinators
refactor(mesh): extract half-edge operations to module
```

## Code Style

### Rust

- Run `cargo fmt` before committing
- Run `cargo clippy` and address warnings
- Prefer explicit over implicit
- No trait default implementations (compiler should enforce completeness)
- Named structs over tuples for return values

### TypeScript

- Use Bun as the runtime
- Prefer functional patterns
- Types are required, no `any`

## Pull Requests

1. Fork the repository
2. Create a feature branch from `master`
3. Make your changes with conventional commits
4. Ensure tests pass: `cargo test`
5. Open a PR with a clear description

## Documentation

Each project has a `docs/` directory with VitePress:

```bash
cd docs
bun install
bun run dev
```

When adding features, update relevant documentation. Prefer updating existing docs over creating new files.

## Project-Specific Guidelines

- **Moss**: See `CLAUDE.md` for detailed behavioral rules and design philosophy
- **Bloom**: Check `docs/development.md` for build instructions
- **Resin**: See `docs/philosophy.md` for design principles

## Questions?

Open an issue in the relevant repository or start a discussion.
