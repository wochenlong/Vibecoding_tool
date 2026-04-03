---
name: fastclawbot
description: 在 Windows 或 macOS 上一键部署并配置 ClawBot（OpenClaw）。Use when 用户需要安装 ClawBot、部署 OpenClaw、配置 Clawbot 的 AI 模型与消息通道，或者提到"一键装机"、"快速部署 ClawBot"时使用。不涉及 VPS/Linux 服务器生产部署。
---

# FastClawBot — Windows / macOS 一键部署与配置

## Preconditions（前提条件）

- **操作系统**：Windows 10+（需启用 WSL2 或安装 Docker Desktop）或 macOS 11+。
- **Node.js**：v22 或更高版本（`node -v` 验证）。未安装时需先引导用户安装。
- **硬件最低要求**：2GB RAM、500MB 磁盘空间；若使用本地模型（Ollama），需 8GB+ RAM。
- **AI 模型 API Key**（以下任选其一）：
  - Anthropic（Claude）— 推荐，推理能力最佳
  - OpenAI（GPT-4）
  - DeepSeek — 预算友好
  - Ollama — 免费本地模型，需额外下载
- **网络**：需能访问 npm registry 和对应 AI 厂商 API。

### Missing Prerequisites Handling（前置缺失处理）

| 缺失项 | 引导方式 |
|--------|---------|
| Node.js 未安装 | Windows: `winget install OpenJS.NodeJS.LTS`；macOS: `brew install node@22` |
| WSL2 未启用（Windows） | `wsl --install`，重启后继续 |
| Docker Desktop 未安装 | 引导用户从 https://www.docker.com/products/docker-desktop 下载安装 |

## Workflow / Instructions（执行步骤）

### 路线选择

```
用户环境 → macOS？
    ├─ 是 → 方案 A（npm）或 方案 C（DMG）
    └─ 否 → Windows？
        ├─ 已有 WSL2 → 在 WSL 终端中走方案 A（npm）
        ├─ 已有 Docker Desktop → 方案 B（Docker）
        └─ 都没有 → 引导安装 WSL2 后走方案 A
```

### 方案 A：npm 本地安装（推荐，Win WSL2 / macOS）

> **为什么不用 `npm install -g`？** 全局安装会向系统目录写入文件，可能与用户已有的 Node.js 项目、全局包产生版本冲突。使用独立目录 + `--prefix` 安装，所有依赖自包含在一个文件夹中，卸载时整个删掉即可，不影响系统其他环境。

1. **创建独立安装目录**：
   ```bash
   # macOS / WSL —— 安装到用户主目录下的隔离文件夹
   mkdir -p ~/clawbot-app
   npm install clawbot@latest --prefix ~/clawbot-app
   ```
2. **将可执行文件加入 PATH**（仅当前会话生效，持久化见下方说明）：
   ```bash
   export PATH="$HOME/clawbot-app/node_modules/.bin:$PATH"
   ```
   如需**持久化**，将上面这行追加到 `~/.bashrc` 或 `~/.zshrc`：
   ```bash
   echo 'export PATH="$HOME/clawbot-app/node_modules/.bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```
3. **运行初始化向导**（交互式，引导选择模型和通道）：
   ```bash
   clawbot init
   ```
4. **启动 Gateway**：
   ```bash
   clawbot gateway start
   ```
5. **验证运行状态**：
   ```bash
   clawbot gateway status
   ```
   应看到 `Gateway running on port 18789`。

> **卸载 / 清理**：只需 `rm -rf ~/clawbot-app` 并从 `~/.bashrc` 中删除对应 PATH 行，系统恢复如初。

### 方案 B：Docker 安装（Windows / macOS 均可）

1. **拉取并运行容器**：
   ```bash
   docker run -d \
     --name clawbot \
     -v ~/.clawbot:/root/.clawbot \
     -p 18789:18789 \
     ghcr.io/steipete/clawbot:latest
   ```
2. **验证容器运行**：
   ```bash
   docker ps | grep clawbot
   ```

### 方案 C：macOS DMG（仅 macOS）

1. 从 GitHub Releases 页面下载最新 `.dmg` 文件。
2. 拖入 Applications 文件夹，双击启动。
3. 菜单栏出现 ClawBot 图标即表示 Gateway 已运行。

### 配置 AI 模型

安装完成后编辑 `~/.clawbot/clawbot.json`：

**Claude（推荐）**：
```json
{
  "ai": {
    "provider": "anthropic",
    "apiKey": "YOUR_ANTHROPIC_API_KEY",
    "model": "claude-sonnet-4-6"
  }
}
```

**Ollama（免费本地）**：
```bash
ollama pull llama3.1:8b
```
```json
{
  "ai": {
    "provider": "ollama",
    "model": "llama3.1:8b",
    "endpoint": "http://localhost:11434"
  }
}
```

| Provider | 月费参考 | 质量 | 适用场景 |
|----------|---------|------|---------|
| Anthropic Claude | $20–40 | 优秀 | 推理能力最佳，推荐首选 |
| OpenAI GPT-4 | $25–50 | 优秀 | 生态成熟，模型选择多 |
| DeepSeek | $5–15 | 良好 | 预算友好 |
| Ollama（本地） | 免费 | 因模型而异 | 最大隐私，需 8GB+ RAM |

### 连接消息通道

```bash
# Telegram（最简单，推荐新手首选）
clawbot channel add telegram

# WhatsApp（扫码连接）
clawbot channel add whatsapp

# 查看所有可用通道
clawbot channel list
```

> **注意**：WhatsApp 的服务条款不允许在个人账号上运行自动化机器人，测试请用备用号码。

### 安装常用 Skills

```bash
# 浏览可用 Skills
clawbot skills browse

# 通用效率（日历、GitHub、每日简报）
clawbot skills install google-calendar github-assistant daily-briefing
```

#### 欧美游戏策划推荐 Skills

以下 Skills 按「策划工作流」分类整理，覆盖从世界观构建到系统设计到文档输出的完整链路。

**游戏设计 & GDD 生成**

| Skill | 来源 | 热度 | 说明 |
|-------|------|------|------|
| `game-cog` | ClawHub | DeepResearch Bench #1 | 一站式游戏设计推理引擎：GDD、关卡设计、角色美术、Tileset、UI、音乐、3D 模型，支持 Unity/Unreal 导出 |
| `game-architect` | ClawHub | — | 游戏系统设计参考库：战斗、技能、AI、UI、多人、叙事等系统范式选型指南 |
| `gdd-writer` | LobeHub | v1.0.2 | 精简 GDD 生成器：核心循环、机制、数值、进度、里程碑，适合独立开发者快速出文档 |

```bash
clawbot skills install game-cog game-architect
```

**世界观 & 叙事设计**

| Skill | 来源 | 热度 | 说明 |
|-------|------|------|------|
| `worldbuilding` | LobeHub | 高下载量 | 虚构世界生成：地理、文化、政治、魔法/科技体系、宗教、经济，含内部一致性交叉校验 |
| `create-world` | LobeHub | — | 世界观项目脚手架：自动生成标准化文件夹结构（地理/历史/文化/阵营/魔法/NPC/任务/物品/地图） |
| `narrative-story-structure-game` | LobeHub | — | 游戏叙事框架：分支剧情、玩家主体性、对话树、多结局、后果系统、涌现叙事设计 |
| `storybook-generator` | ClawHub | 246 下载 | 视觉故事生成器：插画叙事、分镜脚本，适合概念阶段的视觉化表达 |

**通用写作 & 文档**

| Skill | 来源 | 热度 | 说明 |
|-------|------|------|------|
| `book-writing` | ClawHub | 1.4k 下载 / 17 安装 | 长文写作：章节架构、语气一致性、修订工作流，适合写系统策划案、世界观圣经 |
| `write` | ClawHub | 905 下载 | 内容写作引擎：规划→草稿→版本管理→质量审计，适合迭代式策划文档 |

```bash
clawbot skills install book-writing write storybook-generator
```

#### 相关 GitHub 开源项目（非 ClawBot Skill，但策划高度相关）

| 项目 | Stars | 说明 |
|------|-------|------|
| [Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) | 7.6k+ | 48 个 AI Agent + 36 个工作流 Skill，模拟完整游戏工作室层级（总监→部门主管→专员），含设计评审和质量门禁 |
| [openagenticgame-gdd](https://github.com/wanghaisheng/GDDMarkdownTemplate) | — | 面向 AI 的 GDD Markdown 模板：15 章完整体系、6 大细化模块、8 种游戏类型适配、中英双语 |

> **安全提醒**：ClawHub 上约 7.6% 的 Skills 存在安全风险（Skills 以全权限运行且无沙箱隔离）。只安装经过验证的发布者的 Skills，避免使用新发布、用户量少的 Skills。安装前可用 `clawbot skills info <skill-name>` 查看作者和下载量。

## Output Format（输出格式）

- **安装摘要**：使用的方案（A/B/C）、ClawBot 版本号、Gateway 端口。
- **配置状态**：AI 模型 provider 与 model 名称、已连接的消息通道列表。
- **测试结果**：至少执行一条测试消息并展示 AI 响应。

## Verification Checklist（验收清单）

- [ ] `clawbot --version` 输出版本号（npm 方案，需确认 PATH 已生效）或 `docker ps` 显示容器运行中（Docker 方案）
- [ ] `clawbot gateway status` 显示 `Gateway running on port 18789`
- [ ] `~/.clawbot/clawbot.json` 中已配置 AI provider 和 model
- [ ] 至少一个消息通道已连接（`clawbot channel list` 显示 active）
- [ ] 通过消息 App 发送测试消息，收到 AI 回复
- [ ] API Key 未出现在终端回显或聊天记录中

## Common Pitfalls（常见问题）

- **Windows 原生不支持**：ClawBot 不能直接在 Windows CMD/PowerShell 原生运行，必须通过 WSL2 或 Docker。如果用户直接在 PowerShell 运行 `npm install clawbot` 会安装成功但 `clawbot init` 会报错。
- **PATH 未生效**：使用 `--prefix` 本地安装后，如果 `clawbot` 命令找不到，说明 PATH 未正确设置。确认 `~/clawbot-app/node_modules/.bin` 已加入 PATH，新开终端窗口需重新 source 或写入 `~/.bashrc`。
- **端口 18789 被占用**：先用 `lsof -i :18789`（macOS/WSL）检查占用进程，关闭后再启动 Gateway。
- **API Key 写错格式**：Anthropic 的 Key 以 `sk-ant-` 开头，OpenAI 以 `sk-` 开头。Key 填错时 Gateway 启动正常但发消息会返回认证错误。
- **WSL2 网络问题**：WSL2 默认 NAT 模式，如果 Gateway 需要接收外部 Webhook 回调，需配置端口转发或改用 Docker 的 `-p` 映射。
- **macOS 权限弹窗**：首次运行可能触发"无法验证开发者"弹窗，需到「系统设置 → 隐私与安全性」中点击"仍然允许"。
- **Ollama 模型下载慢**：本地模型文件较大（4–8GB），下载慢时可用 `OLLAMA_HOST=0.0.0.0 ollama serve` 配合代理加速。
- **Skills 安全风险**：ClawHub 上恶意 Skills 比例约 7.6%，Skills 以全权限运行且无沙箱隔离，务必只装来源可信的 Skills。
