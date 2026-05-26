# Claude Code Hook Schema

Empirical findings for `UserPromptSubmit` hooks. Verified in practice; annotated where behavior may shift across Claude Code versions.

## Output formats

Hooks write to stdout. Two forms are accepted:

**Plain text** — bare string is injected as additional context. Simplest.

```bash
echo "Reminder: don't act on what you haven't verified."
```

**JSON** — use when combining `additionalContext` with other fields (e.g. `sessionTitle`):

```json
{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "..."}}
```

Top-level `additionalContext` is also accepted per docs, but the nested form is preferred when other fields are present.

## Where output lands (empirical)

Output is wrapped in `<system-reminder>` tags:

```
<system-reminder>UserPromptSubmit hook success: ...</system-reminder>
```

Position: just before the user's prompt in the incoming turn. Not literally end-of-context, but recent enough to act on.

Multiple hook entries in the same array all fire; each gets its own `<system-reminder>` wrapper. These coexist with harness-generated reminders (e.g. EnterPlanMode, TaskCreate).

## Exit codes

| Code | Behavior |
|------|----------|
| `0` | Success. stdout injected as additional context (JSON or plain). |
| `2` | Blocking error. Prompt rejected; stderr shown to user. |
| other non-zero | Non-blocking warning. First line of stderr surfaced. |

## Durability

Per docs, injected `additionalContext` is saved in the session transcript and replayed on `/resume`. Each new turn fires the hook fresh regardless — content is dynamic per turn if needed.

Transcript replay has not been empirically verified here.

## Minimal working example

```bash
#!/usr/bin/env bash
set -euo pipefail
cat >/dev/null  # discard prompt input
echo "Reminder: don't act on what you haven't verified."
```

## Multiple hooks

`hooks.UserPromptSubmit` is an array of entries, each with their own `hooks` sub-array. All fire per turn:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/post-history.sh" }
        ]
      }
    ]
  }
}
```

## Conventions

- Scripts live in `tooling/claude-hooks/<name>.sh` in this repo.
- Per-repo wiring: `.claude/settings.json`.
- Global wiring: `~/.claude/settings.json`.

## Caveats

- Positional ordering relative to other `<system-reminder>` blocks is not strictly documented. Observed behavior may shift across Claude Code versions.
- Transcript replay durability (on `/resume`) has not been empirically verified.
