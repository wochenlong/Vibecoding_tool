#!/usr/bin/env bash
# AI 回复结束后自动 git commit，防止丢失未提交的修改
cat >/dev/null 2>&1 || true
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo '{}'; exit 0; }
[ -z "$(git status --porcelain 2>/dev/null)" ] && { echo '{}'; exit 0; }

# 没有 .gitignore 时警告（git add -A 会把所有文件提交）
[ ! -f .gitignore ] && echo "[checkpoint] 警告: 没有 .gitignore，敏感文件可能被提交" >> .git/checkpoint.log

n=$(git status --porcelain | wc -l | tr -d ' ')
br=$(git branch --show-current 2>/dev/null || echo "detached")
msg="[checkpoint] $(date '+%Y-%m-%d %H:%M:%S') [$br] ($n files)"
if git add -A && git commit -m "$msg" --no-verify >/dev/null 2>&1; then
  echo "$msg" >> .git/checkpoint.log
else
  echo "[checkpoint] 提交失败: $(date '+%Y-%m-%d %H:%M:%S')" >> .git/checkpoint.log
fi
echo '{}'
