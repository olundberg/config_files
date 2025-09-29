imap kj <Esc>
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
:set backspace=indent,eol,start
"""Custom better statusline at the bottom"""
set statusline=
set statusline +=%*\ %<%F%*            "full path
set statusline +=%*%m%*                "modified flag
set statusline +=%*%=%5l%*             "current line
set statusline +=%*/%L%*               "total lines
set statusline +=%*%4v\ %*             "virtual column number
" Wayland clipboard provider that strips carriage returns (GTK3 issue).
" This is needed because currently there's an issue where GTK3 applications on
" Wayland contain carriage returns at the end of the lines (this is a root
" issue that needs to be fixed).
"
"
"
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
"Plug 'iberianpig/ranger-explorer.vim'
"Plug 'rbgrouleff/bclose.vim'
call plug#end()

"""nnoremap <C-t> :NERDTreeToggle<CR>"""
"nnoremap <silent><Leader>n :RangerOpenCurrentFile<CR>
"nnoremap <silent><Leader>c :RangerOpenCurrentDir<CR>
"nnoremap <silent><Leader>f :RangerOpenProjectRootDir<CR>

let g:ranger_explorer_keymap_edit    = '<C-o>'
let g:ranger_explorer_keymap_tabedit = '<C-t>'
let g:blamer_enabled=1
hi Blamer ctermfg=darkgrey

highlight SignColumn ctermbg=black
