"""~/.config/nvim/init.vim"""
:imap kj <Esc>
set clipboard=unnamed
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
:highlight ExtraWhitespace ctermbg=red guibg=red
:match ExtraWhitespace /\s\+$/

hi Bang ctermfg=red guifg=red ctermbg=white guibg=white
match Bang /\%>79v.*\%<81v/
:set backspace=indent,eol,start

au FileType netrw nmap <buffer> h -
au filetype netrw nmap <buffer> l <CR>

"""Custom better statusline at the bottom"""
set statusline=
set statusline +=%*\ %<%F%*            "full path
set statusline +=%*%m%*                "modified flag
set statusline +=%*%=%5l%*             "current line
set statusline +=%*/%L%*               "total lines
set statusline +=%*%4v\ %*             "virtual column number

"""Install with :PlugInstall"""
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'psf/black', { 'branch': 'stable' }
Plug 'APZelos/blamer.nvim'
call plug#end()

nnoremap <C-t> :NERDTreeToggle<CR>

let g:black_linelength=79
let g:blamer_enabled=1
hi Blamer ctermfg=darkgrey

highlight SignColumn ctermbg=black
