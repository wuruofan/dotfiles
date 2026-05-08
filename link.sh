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
backup_or_overwrite "$PWD/git/_gitconfig" ~/.gitconfig "gitconfig" && create_link "$PWD/git/_gitconfig" ~/.gitconfig

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
echo "3. ~/.local.gitconfig - 本地 git 配置"
echo "   参考 git/_local.gitconfig.example"
echo "=========================================="