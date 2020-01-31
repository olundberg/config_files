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
autocmd FileType tex,latex nnoremap <silent> <F5> :!pdflatex %<CR>
autocmd FileType python setlocal omnifunc=python3complete#Complete
:highlight ExtraWhitespace ctermbg=red guibg=red
:match ExtraWhitespace /\s\+$/
set laststatus=2
