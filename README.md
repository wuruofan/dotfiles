# dotfiles

## 设计思路

### 文件分离

| 文件 | 作用 | 同步策略 |
|------|------|---------|
| `zsh/_zshrc` | 跨机器通用配置（PATH、alias、函数等） | 提交 git |
| `~/.gitconfig` | 跨机器通用 git 配置 | 提交 git |
| `~/.local.gitconfig` | 本地 git 配置（hooksPath、gitlab token、github 代理、按仓库区分用户身份等） | 本地管理，不提交 |
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

### 本地文件

本地文件参考 `sh/` 目录下的 `.example` 文件：
- `sh/_secrets.config.example` → `~/.secrets.config`
- `sh/_local.zshrc.example` → `~/.local.zshrc`
- `git/_local.gitconfig.example` → `~/.local.gitconfig`

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
cp sh/_secrets.config.example ~/.secrets.config
vim ~/.secrets.config  # 填入实际 key

# 2. 配置本地私密配置（可选）
cp sh/_local.zshrc.example ~/.local.zshrc
vim ~/.local.zshrc  # 按需修改

# 3. 配置本地 git 配置
cp git/_local.gitconfig.example ~/.local.gitconfig
vim ~/.local.gitconfig  # 填入实际值

# 4. 安装 vim 插件
vim +PlugInstall +qa
```

### 更新 dotfiles

```bash
cd ~/devkits/dotfiles
git pull
./link.sh
```

---

## 可选配置

### @claude/AGENTS.md + link_agents_md.sh

全局 AI 编码审计协议模板，兼容 Claude Code 和 OpenCode。在项目根目录创建 `AGENTS.md` 软链接后，Agent 会在每次代码修改前自动激活审计矩阵。

**文件说明：**

- `AGENTS.md` - 协议模板
- `link_agents_md.sh` - 快速创建软链接的脚本（在当前项目根目录创建 `AGENTS.md` → `~/AGENTS.md`）

**配置方法：**

```bash
# 1. 在 ~/.zshrc 中已配置 claude 函数自动加载 AGENTS.md
#    （仅在 ~/AGENTS.md 存在时生效，两台电脑共享 dotfiles 时无副作用）

# 2. 在项目目录中创建软链接
cd ~/path-to-project
~/devkits/dotfiles/claude/link_agents_md.sh

# 或手动创建
ln -sf ~/AGENTS.md ./AGENTS.md
```

**协议内容：**

- **第一阶段**：逻辑审计矩阵（Pre-flight Check）- 修改代码前必须输出审计表格
- **第二阶段**：确定性交付（Verified Delivery）- 修改后验证逻辑正确性
- **行为禁令**：禁止自信提交、局部失明、重构式修复

---

### @claude/skills

通过 `npx skills` 从 GitHub 安装全局 skills（wuruofan/agent-skills）。

`skills/` 目录已迁移至独立仓库，请跳转 [agent-skills](https://github.com/wuruofan/agent-skills) 查看。

**配置方法：**

```bash
# 运行安装脚本（需要 npx）
~/devkits/dotfiles/claude/link_skills.sh
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

# tmux 封装函数（zshrc 中已 source）
tmux-cc-m27      # 创建 MiniMax-M2.7 Claude session
tmux-cc-qwen     # 创建 Qwen/Dashscope Claude session
```

**功能：**

- `tmux-cc-m27` - 在空闲的 m27_N session 中启动 MiniMax-M2.7
- `tmux-cc-qwen [model]` - 在空闲的 qwen_N session 中启动，支持 model 参数
- 自动查找空闲 session 名称，避免冲突

---

```
dotfiles/
├── README.md
├── .gitignore
├── link.sh              # 软链脚本
├── git/
│   ├── _gitconfig       # git 全局配置
│   ├── _local.gitconfig.example  # 本地配置参考
│   └── _git-completion.bash
├── sh/
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
    ├── AGENTS.md        # 全局 AI 编码审计协议模板
    ├── link_agents_md.sh  # 项目 AGENTS.md 软链接脚本
    ├── link_skills.sh     # npx skills 安装脚本
    ├── settings.json
    ├── statusline.sh
    └── claude-code.shrc  # Claude Code 全局配置（API keys、claude 函数等）
```
