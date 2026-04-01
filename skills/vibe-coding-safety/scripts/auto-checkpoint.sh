#!/usr/bin/env bash
# AI 回复结束后自动 git commit，防止丢失未提交的修改
cat >/dev/null 2>&1 || true
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo '{}'; exit 0; }
[ -z "$(git status --porcelain 2>/dev/null)" ] && { echo '{}'; exit 0; }
n=$(git status --porcelain | wc -l | tr -d ' ')
git add -A && git commit -m "[checkpoint] $(date '+%Y-%m-%d %H:%M:%S') ($n files)" --no-verify >/dev/null 2>&1
echo '{}'
