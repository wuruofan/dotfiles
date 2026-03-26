# dotfiles

## 设计思路

### 文件分离

| 文件 | 作用 | 同步策略 |
|------|------|---------|
| `zsh/_zshrc` | 跨机器通用配置（PATH、alias、函数等） | 提交 git |
| `~/.gitconfig` | 跨机器通用 git 配置 | 提交 git |
| `~/.local.gitconfig` | 本地 git 配置（hooksPath、gitlab token、github 代理等） | 本地管理，不提交 |
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
```

### 更新 dotfiles

```bash
cd ~/devkits/dotfiles
git pull
./link.sh
```

---

## 目录结构

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
└── zsh/
    ├── _zshrc
    └── agnoster-rfw.zsh-theme
```
