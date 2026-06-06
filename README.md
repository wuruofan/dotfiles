# dotfiles

## 设计思路

### 文件分离

| 文件 | 作用 | 同步策略 |
|------|------|---------|
| `zsh/_zshrc` | 跨机器通用配置（PATH、alias、函数等） | 提交 git |
| `~/.gitconfig` | git 主配置（用户身份 + include 通用/本地配置） | 本地生成，不提交 |
| `~/.gitconfig-local` | 本地 git 覆盖配置（includeIf 公司邮箱、GitHub 代理等） | 本地管理，不提交 |
| `~/.secrets.config` | API keys（MINIMAX_API_KEY 等） | 本地管理，不提交 |
| `~/.local.zshrc` | 本地私密配置（nexus token、路径等） | 本地管理，不提交 |

### 加载顺序

```
~/.zshrc
  ├── oh-my-zsh
  ├── starship（检测是否安装）
  ├── ~/.secrets.config
  ├── ~/.local.zshrc
  └── ~/.local/bin/env
```

### Git 配置加载顺序

```
~/.gitconfig（生成文件，非符号链接）
  ├── [user]                ← 用户身份（sandboxed 工具也能读到）
  ├── [include] _gitconfig-shared  ← 通用配置（aliases, core, pull, etc.）
  ├── [include] ~/.gitconfig-local  ← 本地覆盖
  └── [safe]
        └── ~/.gitconfig-local
              └── [includeIf] ~/.gitconfig-company  ← 公司仓库覆盖（按 remote URL 匹配）
```

> **为什么 `~/.gitconfig` 不是符号链接？** 某些 sandboxed 工具（如 claude CLI）可能跳过 `[include]` 指令，
> 导致 `[user]` 身份丢失，git 会 fallback 到 `用户名@主机名`。将 `[user]` 放在主文件中可避免此问题。

### 本地文件

本地文件参考 `examples/` 目录下的 `.example` 文件：
- `examples/_secrets.config.example` → `~/.secrets.config`
- `examples/_local.zshrc.example` → `~/.local.zshrc`
- `git/_gitconfig-local.example` → `~/.gitconfig-local`

### zshrc 特性

- **主题**：安装了 starship 则用 starship，否则用 agnoster-rfw
- **插件**：z、zsh-autosuggestions、zsh-syntax-highlighting
- **平台**：仅适配 macOS

---

## 用法

### 安装

```bash
git clone https://github.com/wuruofan/dotfiles.git ~/devkits/dotfiles
cd ~/devkits/dotfiles
./link.sh
```

### 首次配置

```bash
# 1. 配置 API keys
cp examples/_secrets.config.example ~/.secrets.config
vim ~/.secrets.config  # 填入实际 key

# 2. 配置本地私密配置（可选）
cp examples/_local.zshrc.example ~/.local.zshrc
vim ~/.local.zshrc  # 按需修改

# 3. 配置本地 git 覆盖配置（可选）
cp git/_gitconfig-local.example ~/.gitconfig-local
vim ~/.gitconfig-local  # 按需修改（includeIf 公司邮箱、GitHub 代理等）

# 4. 安装 vim 插件
vim +PlugInstall +qa
```

### 更新 dotfiles

```bash
cd ~/devkits/dotfiles
git pull
./link.sh
```

> **升级说明**：v0.5.0 起 `~/.gitconfig` 从符号链接改为生成文件。`link.sh` 会自动检测旧符号链接并迁移，
> 从 `~/.gitconfig-local` 读取旧的 `[user]` 身份作为默认值。迁移后建议移除 `~/.gitconfig-local` 中的 `[user]` 段。

---

## 可选配置

### @claude/AGENTS.md + link_agents_md.sh

全局 AI 编码提案-批准协议（强约束版），兼容 Claude Code 和 OpenCode。创建 `AGENTS.md` 软链接后，Agent 会在每次代码修改前先提案，获得批准后再执行。

**文件说明：**

- `AGENTS.md` - 提案-批准协议模板（强约束版）
- `link_agents_md.sh` - 快速创建软链接的脚本

**配置方法：**

```bash
# 运行链接脚本，选择目标位置
~/devkits/dotfiles/claude/link_agents_md.sh
```

**脚本功能：**

- 支持三个选项：
  1. `~/AGENTS.md`
  2. `~/.claude/CLAUDE.md`
  3. 两个都创建
- 自动检测目标是否已链接到源文件，避免重复操作
- 目标存在时提示"是否覆盖（自动备份）?"，备份文件带时间戳
- 创建链接后自动验证

**协议核心：**

- **核心铁律**：权限无效（ bypass 权限视同没有）、回合分离（提案与执行严格分离）
- **回合 A**：仅提案，输出文件摘要、审计清单、diff 预览，等待批准
- **回合 B**：仅在用户回复"同意"时才执行，且操作必须与提案 diff 完全一致
- **审计清单**：改动范围确认（7项）+ 工程原则（3项）
- **工程底线**：手术刀原则、简单至上、目标驱动验证
- **绝对禁止**：清空文件写入、删除未声明的配置、跳过提案或审计清单、不验证就声称"修复好了"、猜测业务逻辑

---

### @claude/skills

通过 `npx skills` 从 GitHub 安装全局 skills（wuruofan/agent-skills）。

`skills/` 目录已迁移至独立仓库，请跳转 [agent-skills](https://github.com/wuruofan/agent-skills) 查看。

**配置方法：**

```bash
# 运行安装脚本（需要 npx）
~/devkits/dotfiles/claude/install_skills.sh
# 或手动
npx skills add wuruofan/agent-skills -g -y
```

---

### @claude/statusline.sh

Claude Code 自定义状态栏脚本，显示目录、分支、模型、context 使用率、token 统计和 git 状态。

**配置方法：**

```bash
# 在 ~/.claude/settings.json 中添加
{
  "statusline": "/Users/wuruofan/devkits/dotfiles/claude/statusline.sh"
}
```

**功能：**

- 自动检测本地 llama-server（扫描常见端口或从 `ANTHROPIC_BASE_URL` 解析）
- 从 `/props`、`/v1/models`、`/slots` 端点获取真实 context 大小
- 5分钟缓存，避免频繁请求
- 无法检测时回退到 Claude Code 提供的值或根据模型名推断

---

### @tmux

tmux 配置和封装函数，通过 `DOTFILES_DIR` 相对路径加载。

**文件说明：**

- `tmux/_tmux.conf` - tmux 主配置（prefix、vi 风格复制、鼠标等）
- `tmux/tmux.shrc` - tmux 封装函数（自动找空位避免 session 冲突）

**配置方法：**

```bash
# ~/.tmux.conf 已通过 link.sh 自动软链接
# 修改 tmux 配置后，热加载：
tmux source-file ~/.tmux.conf

# tmux 封装函数（zshrc 中已 source，需对应 API key 存在才定义）
tmux-cc-m27      # 创建 MiniMax-M2.7 Claude session（需 MINIMAX_API_KEY）
tmux-cc-qwen     # 创建 Qwen/Dashscope Claude session（需 BAILIAN_API_TOKEN）
tmux-cc-ds       # 创建 DeepSeek V4 Claude session（需 DEEPSEEK_API_KEY）
```

**功能：**

- `tmux-cc-m27` - 在空闲的 m27_N session 中启动 MiniMax-M2.7
- `tmux-cc-qwen [model]` - 在空闲的 qwen_N session 中启动，支持 model 参数
- `tmux-cc-ds` - 在空闲的 ds_N session 中启动 DeepSeek V4
- 自动查找空闲 session 名称，避免冲突

---

```
dotfiles/
├── README.md
├── .gitignore
├── link.sh              # 软链脚本
├── git/
│   ├── _gitconfig-shared  # git 通用配置片段（aliases, core, etc.）
│   ├── _gitconfig-local.example  # 本地覆盖配置参考
│   └── _git-completion.bash
├── examples/
│   ├── _secrets.config.example
│   └── _local.zshrc.example
├── vim/
│   ├── _vimrc
│   ├── plugins.vim
│   └── nvim/init.vim
├── zsh/
│   ├── _zshrc
│   └── agnoster-rfw.zsh-theme
├── tmux/
│   ├── _tmux.conf        # tmux 配置
│   └── tmux.shrc        # tmux 函数（自动找空位创建 session）
└── claude/
    ├── AGENTS.md        # 全局 AI 编码提案-批准协议模板（强约束版）
    ├── link_agents_md.sh  # AGENTS.md 软链接脚本（支持多目标选择）
    ├── install_skills.sh  # skills 安装脚本
    ├── _claude_settings.json  # Claude Code 设置（示例配置）
    ├── statusline.sh
    └── claude-code.shrc  # Claude Code 全局配置（API keys、claude 函数等）
```
