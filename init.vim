"""Vanilla"""
imap kj <Esc>
let mapleader = "å"
set clipboard=unnamedplus
set number
set laststatus=2
set tabstop=8
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent
autocmd FileType python nnoremap <silent> <F5> :!python %<CR>
autocmd FileType python nnoremap <silent> <F6> :update<CR>
autocmd FileType tex,latex nnoremap <silent> <F5> :!pdflatex %<CR>
autocmd FileType python setlocal omnifunc=python3complete#Complete
au FileType python setlocal formatprg=autopep8\ -
hi Bang ctermfg=red guifg=red ctermbg=white guibg=white
highlight SignColumn ctermbg=black
:set backspace=indent,eol,start
"""Custom better statusline at the bottom"""
set statusline=
set statusline +=%*\ %<%F%*            "full path
set statusline +=%*%m%*                "modified flag
set statusline +=%*%=%5l%*             "current line
set statusline +=%*/%L%*               "total lines
set statusline +=%*%4v\ %*             "virtual column number
au FileType netrw nmap <buffer> h -
au FileType netrw nmap <buffer> l <CR>

"""Install with :PlugInstall"""
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'APZelos/blamer.nvim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'kevinhwang91/rnvimr'
call plug#end()


let g:ranger_explorer_keymap_edit    = '<C-o>'
let g:ranger_explorer_keymap_tabedit = '<C-t>'

" Plugin: Blamer
let g:blamer_enabled=1
hi Blamer ctermfg=darkgrey

" Plugin: RNVIMR
let $VISUAL = 'nvim'
let $EDITOR = 'nvim'
let g:NERDTreeHijackNetrw = 0
let g:rnvimr_vanilla = 1
let g:rnvimr_enable_picker = 1
let g:rnvimr_enable_ex = 1
tnoremap <silent> <M-f> <C-\><C-n>:RnvimrToggle<CR>
nnoremap <silent> <M-f> :RnvimrToggle<CR>
let g:rnvimr_draw_border = 0
let g:rnvimr_ranger_cmd = ['ranger', '--cmd=set draw_borders both', '--cmd=set status_bar_on_top false']
let g:rnvimr_layout = {
            \ 'relative': 'editor',
            \ 'width': float2nr(round(0.90 * &columns)),
            \ 'height': float2nr(round(0.85 * &lines)),
            \ 'col': float2nr(round(0.05 * &columns)),
            \ 'row': float2nr(round(0.05 * &lines)),
            \ 'style': 'minimal',
            \ 'border': 'single'
            \ }
highlight FloatBorder guifg=#ffffff guibg=NONE
highlight RnvimrNormal guifg=#ffffff guibg=NONE
let g:rnvimr_action = {
            \ '<C-t>': 'NvimEdit tabedit',
            \ '<C-x>': 'NvimEdit split',
            \ '<C-v>': 'NvimEdit vsplit',
            \ 'gw': 'JumpNvimCwd',
            \ 'yw': 'EmitRangerCwd'
            \ }
