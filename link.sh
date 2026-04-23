#!/bin/bash
# ====================================================
#   Copyright (C)2020 All rights reserved.
#
#   Author        : rf.w
#   Email         : demonsimon#gmail.com
#   File Name     : link.sh
#   Describe      :
#
# ====================================================

PWD=`pwd`

# -------- 备份已有配置 --------
[ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.orig
[ -d ~/.vim ] && mv ~/.vim/ ~/.vim.orig/
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.orig
[ -f ~/.gitconfig ] && mv ~/.gitconfig ~/.gitconfig.orig
[ -f ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.orig

# -------- 建立软链接 --------
mkdir -p ~/.vim/
mkdir -p ~/.config/nvim/
mkdir -p ~/.oh-my-zsh/custom/themes/

ln -sf $PWD/vim/_vimrc ~/.vimrc
ln -sf $PWD/vim/plugins.vim ~/.vim/plugins.vim
ln -sf $PWD/vim/nvim/init.vim ~/.config/nvim/

ln -sf $PWD/git/_git-completion.bash ~/.git-completion.bash
ln -sf $PWD/git/_gitconfig ~/.gitconfig

ln -sf $PWD/zsh/_zshrc ~/.zshrc
ln -sf $PWD/zsh/agnoster-rfw.zsh-theme ~/.oh-my-zsh/custom/themes/
ln -sf $PWD/tmux/_tmux.conf ~/.tmux.conf

# =============================================
# 重要：需要手动配置的文件
# =============================================
echo ""
echo "=========================================="
echo "请手动配置以下文件："
echo ""
echo "1. ~/.secrets.config - API keys"
echo "   参考 sh/_secrets.config.example"
echo ""
echo "2. ~/.local.zshrc - 本地私密配置"
echo "   参考 sh/_local.zshrc.example"
echo ""
echo "3. ~/.local.gitconfig - 本地 git 配置"
echo "   参考 git/_local.gitconfig.example"
echo "=========================================="