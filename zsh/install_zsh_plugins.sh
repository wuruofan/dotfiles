#!/bin/bash
# ====================================================
#   Copyright (C)2020 All rights reserved.
#
#   Author        : rf.w
#   Email         : demonsimon#gmail.com
#   File Name     : install_zsh.sh
#   Last Modified : 2020-04-13 16:52
#   Describe      :
#
# ====================================================

echo ">> Installing on-my-zsh ..."
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

echo ">> Installing zsh plugin: autosuggestions ..."
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

echo ">> Installing zsh plugin: syntax highlighting ..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
