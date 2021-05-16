let mapleader =" "

" syntax highlighting
syntax on

" No annoying bell sounds
set noerrorbells
set novisualbell
set vb t_vb=

" line numbering
set nu

" indentation: tabs rendered to sane 4 spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartindent
" set nowrap
set linebreak
set noswapfile

" vimtex
let g:tex_flavor = 'latex'

" plugins
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'junegunn/goyo.vim'
Plug 'ycm-core/YouCompleteMe'
Plug 'lervag/vimtex'
Plug 'scrooloose/nerdtree'
Plug 'vim-scripts/LanguageTool'
call plug#end()

" keymappings
nnoremap <Leader>f :Goyo<CR>

" colors and transparency
function! s:patch_colors()
	highlight Normal     ctermbg=NONE guibg=NONE
	highlight LineNr     ctermbg=NONE guibg=NONE
	highlight SignColumn ctermbg=NONE guibg=NONE
	let g:ycm_autoclose_preview_window_after_insertion = 1
endfunction

autocmd! colorscheme gruvbox call s:patch_colors()

colorscheme gruvbox 
call s:patch_colors()

