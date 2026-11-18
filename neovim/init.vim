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
"Custom better statusline at the bottom
set statusline=
set statusline +=%*\ %<%F%*            "full path
set statusline +=%*%m%*                "modified flag
set statusline +=%*%=%5l%*             "current line
set statusline +=%*/%L%*               "total lines
set statusline +=%*%4v\ %*             "virtual column number
au FileType netrw nmap <buffer> h -
au FileType netrw nmap <buffer> l <CR>

"""Plug: Install with :PlugInstall"""
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'APZelos/blamer.nvim'
"Plug 'kevinhwang91/rnvimr'  " Ranger in Vim
Plug 'nvim-lua/plenary.nvim'
Plug 'mikavilpas/yazi.nvim'
call plug#end()


let g:ranger_explorer_keymap_edit    = '<C-o>'
let g:ranger_explorer_keymap_tabedit = '<C-t>'

" Plugin: Blamer
let g:blamer_enabled=1
hi Blamer ctermfg=darkgrey

" Yazi integration (yazi.nvim)
let $VISUAL = 'nvim'
let $EDITOR = 'nvim'
let g:NERDTreeHijackNetrw = 0
let g:loaded_netrwPlugin = 1
command! -nargs=? -complete=dir Explore Yazi
command! -nargs=? -complete=dir Ex Yazi
cnoreabbrev <expr> explore (getcmdtype() == ':' && getcmdline() ==# 'explore') ? 'Yazi' : 'explore'
cnoreabbrev <expr> ex (getcmdtype() == ':' && getcmdline() ==# 'ex') ? 'Yazi' : 'ex'
nnoremap <silent> <Leader>- :Yazi<CR>
nnoremap <silent> <Leader>n :Yazi<CR>
nnoremap <silent> <Leader>cw :Yazi cwd<CR>
nnoremap <silent> <M-f> :Yazi toggle<CR>

lua << LUA_EOF
local ok, yazi = pcall(require, "yazi")
if ok then
  yazi.setup({
    open_for_directories = true,
  })
end
LUA_EOF
