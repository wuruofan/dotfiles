#!/bin/bash
# ====================================================
#   Copyright (C)2020 All rights reserved.
#
#   Author        : rf.w
#   Email         : demonsimon#gmail.com
#   File Name     : link.sh
#   Last Modified : 2020-04-13 11:34
#   Describe      :
#
# ====================================================

PWD=`pwd`

if [ -f ~/.vimrc ]; then
    mv ~/.vimrc ~/.vimrc.orig
    mv ~/.vim/ ~/.vim.orig/
fi

if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.orig
fi

ln -sf $PWD/vim/_vimrc ~/.vimrc
mkdir -p ~/.vim/
ln -sf $PWD/vim/plugins.vim ~/.vim/plugins.vim
mkdir -p ~/.config/nvim/
ln -sf $PWD/vim/nvim/init.vim ~/.config/nvim/

if [ -f ~/.gitconfig ]; then
    mv ~/.gitconfig ~/.gitconfig.orig
fi

ln -sf $PWD/git/_git-completion.bash ~/.git-completion.bash
ln -sf $PWD/git/_gitconfig ~/.gitconfig

ln -sf $PWD/zsh/_zshrc ~/.zshrc
ln -sf $PWD/zsh/agnoster-rfw.zsh-theme ~/.oh-my-zsh/custom/themes/

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

