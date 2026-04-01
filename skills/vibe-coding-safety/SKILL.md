---
name: vibe-coding-safety
description: >-
  Deploy automatic git checkpoint hooks for AI-assisted coding sessions.
  Prevents losing work when AI introduces bugs by auto-committing after each
  AI response. Supports Cursor, Claude Code, and Codex CLI. Use when the user
  mentions vibe coding safety, auto commit, checkpoint, auto save, preventing
  AI code loss, or setting up version control safety nets.
---

# Vibe Coding Safety — Auto-Checkpoint for AI Coding

Deploys a "safety net" so every AI response automatically creates a git commit checkpoint.
If the AI introduces a bug, you can `git log` and roll back to any prior checkpoint.

## When to Use

- User asks to set up vibe coding safety / auto-checkpoint / auto-save
- User lost work because AI changes were never committed
- User wants to prevent uncommitted AI modifications from piling up
- Starting a new project that will use AI-assisted development

## How It Works

```
AI writes code → AI response ends → Hook fires → git add -A + git commit
```

Two layers of protection:

1. **Hook (mechanical)**: Auto-commits after every AI response — zero human effort
2. **Rule (behavioral)**: Tells the AI to commit after each logical unit of work

## Step 1: Detect the AI Tool

Check which tool is active by looking for config directories:

| Tool | Indicator |
|------|-----------|
| Cursor | `.cursor/` exists or user says "Cursor" |
| Claude Code | `.claude/` exists or user says "Claude Code" |
| Codex CLI | `.codex/` exists or user says "Codex" |

If unclear, ask the user. Deploy for **all detected tools** in one pass.

## Step 2: Deploy Hook Config

### Cursor

Create `.cursor/hooks.json`:

```json
{
  "version": 1,
  "hooks": {
    "stop": [
      {
        "command": "powershell -ExecutionPolicy Bypass -File .cursor/hooks/auto-checkpoint.ps1"
      }
    ]
  }
}
```

On Mac/Linux, replace the command with:

```json
{ "command": "bash .cursor/hooks/auto-checkpoint.sh" }
```

### Claude Code

Add to `.claude/settings.json` (create if missing, merge into existing):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit|CreateFile",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/auto-checkpoint.sh"
          }
        ]
      }
    ]
  }
}
```

On Windows, use the `.ps1` variant:

```json
{
  "type": "command",
  "command": "powershell -ExecutionPolicy Bypass -File .claude/hooks/auto-checkpoint.ps1"
}
```

### Codex CLI

Create `.codex/hooks.json`:

```json
{
  "hooks": [
    {
      "event": "Stop",
      "command": ["bash", ".codex/hooks/auto-checkpoint.sh"]
    }
  ]
}
```

Ensure `config.toml` has hooks enabled:

```toml
[features]
codex_hooks = true
```

## Step 3: Deploy the Checkpoint Scripts

Copy the appropriate script from this skill's `scripts/` directory:

- **Windows**: `scripts/auto-checkpoint.ps1`
- **Mac/Linux**: `scripts/auto-checkpoint.sh`

Place the script in the tool's hooks directory:

| Tool | Script Location |
|------|----------------|
| Cursor | `.cursor/hooks/auto-checkpoint.ps1` (or `.sh`) |
| Claude Code | `.claude/hooks/auto-checkpoint.ps1` (or `.sh`) |
| Codex | `.codex/hooks/auto-checkpoint.sh` |

On Mac/Linux, make the script executable: `chmod +x <path>`

Read the scripts from this skill directory and write them to the target locations:
- PowerShell script: [scripts/auto-checkpoint.ps1](scripts/auto-checkpoint.ps1)
- Bash script: [scripts/auto-checkpoint.sh](scripts/auto-checkpoint.sh)

## Step 4: Deploy the Safety Rule

Create a rule file that tells the AI to commit proactively.

| Tool | Rule Location |
|------|--------------|
| Cursor | `.cursor/rules/vibe-coding-safety.md` |
| Claude Code | Append to `CLAUDE.md` |
| Codex | Append to `AGENTS.md` |

Rule content:

```markdown
## Vibe Coding Safety — Commit Discipline

1. After completing each independent feature, fix, or refactor: `git add -A && git commit -m "type: description"`
2. Before any high-risk operation (file splits, bulk renames, core system changes): commit current state first.
3. Never run destructive git commands (checkout -f, clean -fd, reset --hard) without stashing or committing first.
4. This project has auto-checkpoint hooks as a fallback, but meaningful manual commits are always preferred.
```

## Step 5: Verify

1. Check `git status` — should be clean after deployment (commit the hook files themselves).
2. Confirm the hook fires: make a trivial change, let the AI respond, then check `git log --oneline -3` for a `[checkpoint]` commit.

## Cleanup Note

Checkpoint commits can be squashed before merging to main:

```bash
git rebase -i HEAD~N   # squash [checkpoint] commits into meaningful ones
```
