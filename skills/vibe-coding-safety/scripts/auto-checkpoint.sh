#!/usr/bin/env bash
# auto-checkpoint.sh
# Hook script: auto-commit all working directory changes after each AI response.
# Works with Cursor (stop hook), Claude Code (PostToolUse), and Codex (Stop).

# ── 1. Consume stdin (hook runners send JSON; must drain or pipe hangs) ──
cat > /dev/null 2>&1 || true

# ── 2. Locate the git repo root ──
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo '{}'; exit 0; }
cd "$REPO_ROOT" || { echo '{}'; exit 0; }

# ── 3. Skip if no uncommitted changes ──
STATUS="$(git status --porcelain 2>/dev/null)"
if [ -z "$STATUS" ]; then
    echo '{}'
    exit 0
fi

# ── 4. Build a timestamped commit message ──
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
CHANGED_COUNT="$(echo "$STATUS" | wc -l | tr -d ' ')"
MESSAGE="[checkpoint] auto-save ${TIMESTAMP} (${CHANGED_COUNT} files)"

# ── 5. Stage and commit ──
git add -A 2>/dev/null
git commit -m "$MESSAGE" --no-verify 2>/dev/null

# ── 6. Return success to the hook runner ──
echo '{}'
exit 0
