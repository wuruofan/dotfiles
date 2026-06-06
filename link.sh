#!/bin/bash
# ====================================================
#   Setup symlinks for dotfiles
#   Author        : rf.w
#   Email         : demonsimon#gmail.com
# ====================================================

PWD=$(cd "$(dirname "$0")" && pwd)

# -------- 检查并备份/覆盖已有配置 --------
backup_or_overwrite() {
  local src="$1"
  local dst="$2"
  local name="$3"

  if [[ -e "$dst" || -L "$dst" ]]; then
    echo -n "$name ($dst) 已存在，是否覆盖（自动备份）? [y/N] "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      local backup="${dst}.backup_$(date +%Y%m%d%H%M%S)"
      mv "$dst" "$backup"
      echo "  已备份为 $backup"
    else
      echo "  跳过"
      return 1
    fi
  fi
  return 0
}

# -------- 建立软链接 --------
create_link() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  echo "  $dst -> $src"
}

echo "=========================================="
echo "开始配置 dotfiles"
echo "=========================================="
echo ""

# vim
mkdir -p ~/.vim/ ~/.config/nvim/
backup_or_overwrite "$PWD/vim/_vimrc" ~/.vimrc "vimrc" && create_link "$PWD/vim/_vimrc" ~/.vimrc
backup_or_overwrite "$PWD/vim/plugins.vim" ~/.vim/plugins.vim "vim plugins" && create_link "$PWD/vim/plugins.vim" ~/.vim/plugins.vim
create_link "$PWD/vim/nvim/init.vim" ~/.config/nvim/init.vim

# git
mkdir -p ~/.oh-my-zsh/custom/themes/
backup_or_overwrite "$PWD/git/_git-completion.bash" ~/.git-completion.bash "git completion" && create_link "$PWD/git/_git-completion.bash" ~/.git-completion.bash

# gitconfig — generate as real file (not symlink) so [user] is always readable
# Upgrade note: old setup used symlink to _gitconfig (now renamed _gitconfig-shared).
# After git pull, the symlink may break. We try to read user identity from:
# 1. Current git config (works if symlink is still valid)
# 2. ~/.gitconfig-local (old setup had [user] there)
# 3. Fallback to empty
CURRENT_NAME=""
CURRENT_EMAIL=""
if [[ -e ~/.gitconfig ]]; then
  # Valid file or valid symlink — read from git config
  CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
  CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
fi
if [[ -z "$CURRENT_NAME" && -f ~/.gitconfig-local ]]; then
  # Broken symlink or no name — try reading from gitconfig-local (old setup)
  CURRENT_NAME=$(git config -f ~/.gitconfig-local user.name 2>/dev/null || echo "")
  CURRENT_EMAIL=$(git config -f ~/.gitconfig-local user.email 2>/dev/null || echo "")
fi

echo ""
echo "--- 配置 git 用户身份 ---"
echo -n "Git user.name [${CURRENT_NAME:-YOUR_NAME}]: "
read -r git_name
git_name="${git_name:-${CURRENT_NAME:-YOUR_NAME}}"

echo -n "Git user.email [${CURRENT_EMAIL:-YOUR_EMAIL}]: "
read -r git_email
git_email="${git_email:-${CURRENT_EMAIL:-YOUR_EMAIL}}"

if backup_or_overwrite "generated" ~/.gitconfig "gitconfig"; then
  cat > ~/.gitconfig << GITCONFIG
[user]
	name = ${git_name}
	email = ${git_email}

[include]
	path = ${PWD}/git/_gitconfig-shared

[include]
	path = ~/.gitconfig-local

[safe]
	directory = *
GITCONFIG
  echo "  已生成 ~/.gitconfig (name=${git_name}, email=${git_email})"
  # Migration: if ~/.gitconfig-local still has [user] section, suggest removing it
  if [[ -f ~/.gitconfig-local ]] && grep -q '^\[user\]' ~/.gitconfig-local 2>/dev/null; then
    echo "  ⚠️  ~/.gitconfig-local 仍包含 [user] 段，建议移除（身份已在 ~/.gitconfig 主文件中定义）"
  fi
fi

# zsh
backup_or_overwrite "$PWD/zsh/_zshrc" ~/.zshrc "zshrc" && create_link "$PWD/zsh/_zshrc" ~/.zshrc
create_link "$PWD/zsh/agnoster-rfw.zsh-theme" ~/.oh-my-zsh/custom/themes/agnoster-rfw.zsh-theme

# tmux
backup_or_overwrite "$PWD/tmux/_tmux.conf" ~/.tmux.conf "tmux.conf" && create_link "$PWD/tmux/_tmux.conf" ~/.tmux.conf

# =============================================
# 重要：需要手动配置的文件
# =============================================
echo ""
echo "=========================================="
echo "请手动配置以下文件："
echo ""
echo "1. ~/.secrets.config - API keys"
echo "   参考 examples/_secrets.config.example"
echo ""
echo "2. ~/.local.zshrc - 本地私密配置"
echo "   参考 examples/_local.zshrc.example"
echo ""
echo "3. ~/.gitconfig-local - 本地 git 覆盖配置（includeIf 公司邮箱、GitHub 代理等）"
echo "   参考 git/_gitconfig-local.example"
echo "=========================================="
