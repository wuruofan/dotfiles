" Specify a directory for Plugs
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'Plug'

" Initialize Plug system
call plug#begin('~/.vim/bundle')

"vim 语法高亮
Plug 'pboettch/vim-cmake-syntax'

"vim环境下运行交互命令
Plug 'christoomey/vim-run-interactive'

"vim cmake
Plug 'vhdirk/vim-cmake'

"super-tab
Plug 'ervandew/supertab'

" 代码补全
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }
" 快捷键打开Quickfix/LocationList
Plug 'Valloric/ListToggle'
" 函数参数提示
"Plug 'Shougo/echodoc.vim'
"Plug 'Shougo/context_filetype.vim'
" 补全参数
Plug 'tenfyzhong/CompleteParameter.vim'

" 代码模版
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" 作者信息
Plug 'nine2/vim-copyright'

" 代码检查
"Plug 'w0rp/ale'
" 异步编译 代码检查
Plug 'neomake/neomake'

" Gtags
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/gutentags_plus'
Plug 'skywind3000/vim-preview'

" tags导航栏
Plug 'majutsushi/tagbar'
" 文件管理插件
Plug 'scrooloose/nerdtree'
" 文件管理插件
Plug 'justinmk/vim-dirvish'


" 符号成对匹配跳转，代替matchit
Plug 'andymass/vim-matchup'
" 自动补全括号、引号
Plug 'raimondi/delimitmate'
"Plug 'jiangmiao/auto-pairs'
" 用成对符号包裹文字
Plug 'tpope/vim-surround'
" .重复上一次surrounding操作
Plug 'tpope/vim-repeat'
" v模式下快速选中区域
Plug 'terryma/vim-expand-region'

" 新增文本对象
" 它新定义的文本对象主要有：
" i, 和 a, ：参数对象，写代码一半在修改，现在可以用 di, / ci, 一次性删除/改写当前参数
" ii 和 ai ：缩进对象，同一个缩进层次的代码，可以用 vii 选中，dii / cii 删除或改写
" if 和 af ：函数对象，可以用 vif / dif / cif 来选中/删除/改写函数的内容
" i' i" i< i[ i( i{ 修改成对符号内的内容
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter'

" 历史记录
Plug 'simnalamburt/vim-mundo'

" 万能跳转
Plug 'Yggdroot/LeaderF'
"Plug 'ctrlpvim/ctrlp.vim'
" 模糊搜索当前文件中所有函数
"Plug 'tacahiroy/ctrlp-funky'
" 快速跳转
Plug 'Lokaltog/vim-easymotion'
" 书签
Plug 'MattesGroeger/vim-bookmarks'
" C头文件成对切换
Plug 'vim-scripts/a.vim'

" 自动创建不存在的路径文件夹
Plug 'pbrisbin/vim-mkdir'
" 重命名buffer中文件名
Plug 'danro/rename.vim'

" 对齐插件
Plug 'godlygeek/tabular'
" 多行编辑插件
Plug 'terryma/vim-multiple-cursors'
" 注释插件
Plug 'scrooloose/nerdcommenter'


" 文件编码
Plug 'mbbill/fencview'

" 搜索
Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

" 左侧栏提示修改状态
Plug 'mhinz/vim-signify'

" VIM配色方案
Plug 'tomasr/molokai'
Plug 'altercation/vim-colors-solarized'
Plug 'croaky/vim-colors-github'
Plug 'morhetz/gruvbox'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'iCyMind/NeoSolarized'
Plug 'joshdick/onedark.vim'
Plug 'nanotech/jellybeans.vim'
Plug 'rakr/vim-one'
Plug 'hzchirs/vim-material'
Plug 'srcery-colors/srcery-vim'

" 启动界面
Plug 'mhinz/vim-startify'
" 按键映射提示
"Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }

" 状态栏插件
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" 状态栏git分支提示
Plug 'tpope/vim-fugitive'

" 自动格式化插件
Plug 'Chiel92/vim-autoformat'
"Plug 'sbdchd/neoformat'
" 去处行尾空格
Plug 'bronson/vim-trailing-whitespace'

" 表格插件Markdown
Plug 'dhruvasagar/vim-table-mode'

" VIM中文文档
"Plug 'yianwillis/vimcdoc'

call plug#end()
