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
:set backspace=indent,eol,start

call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

"""Coc-NVIM"""
set updatetime=300
set signcolumn=yes
nnoremap <silent> K :call ShowDocumentation()<CR>
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>


highlight CocFloating ctermbg=black
highlight SignColumn ctermbg=black
