---
name: vibe-coding-safety
description: >-
  为 AI 编码项目部署自动 git 检查点。AI 每次回复后自动 commit，防止改出 Bug
  无法回退。支持 Cursor / Claude Code / Codex CLI。应在以下情况主动触发：
  新项目开始时、检测到项目无 hook 配置时、用户提到自动提交/检查点/代码丢失/
  版本安全时。任何预计持续超过一天的 AI 编码项目都应部署。
---

# Vibe Coding Safety — AI 编码自动检查点

## 触发时机

以下任一条件满足时，**主动**建议用户部署（不需要用户提起）：

1. 新项目第一次交互，且项目没有 `.cursor/hooks.json` 或 `.claude/settings.json` 中的 hook 配置
2. 项目有多个源码文件（>5个）且无自动提交 hook
3. 用户提到"自动提交"、"检查点"、"代码丢了"、"回退"等关键词
4. AI 即将执行大规模修改（拆分文件、重构、批量改动）前

## 效果

AI 每次回复结束后，hook 自动执行 `git add -A && git commit`。
出 Bug 时 `git log` 找到正常的 checkpoint，`git reset` 即可精确回退。

## 可能的副作用

1. **commit 数量暴增**——每轮 AI 回复一个 commit，合并前用 `git rebase -i` squash
2. **`--no-verify` 跳过 pre-commit 钩子**——lint/test 不会阻塞自动提交，需手动检查
3. **`git add -A` 会暂存所有文件**——如果 `.gitignore` 缺失，可能提交 `.env`、`node_modules` 等敏感文件。部署前务必确认 `.gitignore` 完备
4. **项目文件夹还没被 git 管理**——脚本会静默跳过，不会报错。部署前 AI 应先执行 `git init && git add -A && git commit -m "init"` 把文件夹变成 git 仓库。注意：这不是安装 git，git 已经在你电脑上了（Cursor/Claude Code/Codex 都依赖 git）

## 部署步骤

### 1. 确认项目有 git 仓库

```bash
git rev-parse --show-toplevel  # 报错说明没有仓库
git init && git add -A && git commit -m "init"  # 没有就初始化一个
```

确认 `.gitignore` 覆盖了敏感文件（`.env`、`node_modules/`、密钥等）。

### 2. 检测 AI 工具并部署 hook

根据项目中存在的配置目录判断工具类型，为每个检测到的工具部署配置。

**Cursor**（检测：`.cursor/` 目录存在）

创建 `.cursor/hooks.json`：
```json
{
  "version": 1,
  "hooks": {
    "stop": [
      { "command": "powershell -ExecutionPolicy Bypass -File .cursor/hooks/auto-checkpoint.ps1" }
    ]
  }
}
```
Mac/Linux 把 command 改成 `bash .cursor/hooks/auto-checkpoint.sh`。

将 [scripts/auto-checkpoint.ps1](scripts/auto-checkpoint.ps1) 或 [scripts/auto-checkpoint.sh](scripts/auto-checkpoint.sh) 复制到 `.cursor/hooks/`。

**Claude Code**（检测：`.claude/` 目录存在）

在 `.claude/settings.json` 中添加（已有则合并）：
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit|MultiEdit|CreateFile",
      "hooks": [{ "type": "command", "command": "bash .claude/hooks/auto-checkpoint.sh" }]
    }]
  }
}
```
Windows 把 command 改成 `powershell -ExecutionPolicy Bypass -File .claude/hooks/auto-checkpoint.ps1`。

将脚本复制到 `.claude/hooks/`。

**Codex CLI**（检测：`.codex/` 目录存在）

创建 `.codex/hooks.json`：
```json
{
  "hooks": [
    { "event": "Stop", "command": ["bash", ".codex/hooks/auto-checkpoint.sh"] }
  ]
}
```

将脚本复制到 `.codex/hooks/`，确认 `config.toml` 有 `codex_hooks = true`。

### 3. 部署行为规范

| 工具 | 写入位置 |
|------|---------|
| Cursor | `.cursor/rules/vibe-coding-safety.md` |
| Claude Code | 追加到 `CLAUDE.md` |
| Codex | 追加到 `AGENTS.md` |

规范内容：

```
## 提交纪律
1. 每完成一个独立功能后立即 git add -A && git commit -m "type: 描述"
2. 高风险操作前先提交当前状态
3. 禁止在未提交的工作区执行 git checkout -f / git clean -fd / git reset --hard
```

### 4. 验证

改一个文件，等 AI 回复结束，检查 `git log --oneline -3` 是否出现 `[checkpoint]` 提交。
