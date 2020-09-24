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
autocmd FileType python nnoremap <silent> <F7> :!svn commit -m "New update"<CR>
autocmd FileType tex,latex nnoremap <silent> <F5> :!pdflatex %<CR>
autocmd FileType python setlocal omnifunc=python3complete#Complete
:highlight ExtraWhitespace ctermbg=red guibg=red
:match ExtraWhitespace /\s\+$/
set laststatus=2
hi Bang ctermfg=red guifg=red ctermbg=white guibg=white
match Bang /\%>79v.*\%<81v/

