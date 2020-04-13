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
echo $PWD


if [ -f ~/.vimrc ]; then
    mv ~/.vimrc ~/.vimrc.orig
    mv ~/.vim/ ~/.vim.orig/
fi

if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.orig
fi

ln -s $PWD/_vimrc ~/.vimrc
ln -s $PWD/_vimrc.bundles ~/.vimrc.bundles

ln -s $PWD/_git-completion.bash ~/.git-completion.bash
ln -s $PWD/_gitconfig ~/.gitconfig

ln -s $PWD/_zshrc ~/.zshrc
ln -s $PWD/agnoster-rfw.zsh-theme ~/.oh-my-zsh/custom/themes/
