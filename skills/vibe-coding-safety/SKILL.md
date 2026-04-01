---
name: vibe-coding-safety
description: >-
  为 AI 编码项目部署自动 git 检查点。AI 每次回复后自动 commit，防止改出 Bug
  无法回退。支持 Cursor / Claude Code / Codex CLI。新项目首次交互时、检测到
  项目无 hook 时、用户提到自动提交/检查点/代码丢失时，应主动建议部署。
---

# Vibe Coding Safety

AI 每次回复结束 → hook 自动 `git add -A && git commit` → 出 Bug 可精确回退。

## 副作用与安全机制

- commit 多——合并前 `git rebase -i` squash
- `--no-verify`——跳过 pre-commit 钩子，推远程前手动检查
- `git add -A`——脚本会检测 `.gitignore` 是否存在，缺失时写入警告日志
- 无 git 仓库——脚本静默跳过，需先 `git init && git add -A && git commit -m "init"`
- 提交失败——不再静默吞掉，记录到 `.git/checkpoint.log` 便于排查

## 部署

### 1. 确认 git 仓库和 .gitignore

`git rev-parse --show-toplevel` 报错就先 `git init`。

### 2. 部署 hook（按检测到的工具）

将 [scripts/auto-checkpoint.ps1](scripts/auto-checkpoint.ps1)（Windows）或 [scripts/auto-checkpoint.sh](scripts/auto-checkpoint.sh)（Mac/Linux）复制到对应目录，并创建配置：

**Cursor** → `.cursor/hooks/` + `.cursor/hooks.json`
```json
{ "version": 1, "hooks": { "stop": [{ "command": "powershell -ExecutionPolicy Bypass -File .cursor/hooks/auto-checkpoint.ps1" }] } }
```

**Claude Code** → `.claude/hooks/` + 合并到 `.claude/settings.json`
```json
{ "hooks": { "PostToolUse": [{ "matcher": "Write|Edit|MultiEdit|CreateFile", "hooks": [{ "type": "command", "command": "bash .claude/hooks/auto-checkpoint.sh" }] }] } }
```

**Codex** → `.codex/hooks/` + `.codex/hooks.json`，确认 `config.toml` 有 `codex_hooks = true`
```json
{ "hooks": [{ "event": "Stop", "command": ["bash", ".codex/hooks/auto-checkpoint.sh"] }] }
```

Mac/Linux 用 `.sh`，Windows 用 `.ps1`，command 相应替换。Mac/Linux 需 `chmod +x`。

### 3. 部署行为规范

写入 `.cursor/rules/vibe-coding-safety.md` 或追加到 `CLAUDE.md` / `AGENTS.md`：

```
## 提交纪律
1. 每完成一个独立功能后立即 git add -A && git commit -m "type: 描述"
2. 高风险操作前先提交当前状态
3. 禁止在未提交的工作区执行 git checkout -f / git clean -fd / git reset --hard
```

### 4. 验证

`git log --oneline -3` 看到 `[checkpoint]` 即成功。
