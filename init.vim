" Basic look & feel
set number
set relativenumber
set termguicolors
syntax on

" Tabs / spaces
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" UI niceties
set cursorline
set signcolumn=yes

" Leader key
let mapleader = " "

" Simple file explorer (netrw)
let g:netrw_banner = 0
let g:netrw_liststyle = 3

" Open netrw like VSCode's explorer
nnoremap <leader>e :Ex<CR>

" Fuzzy-ish search using ripgrep (simple)
nnoremap <leader>f :vimgrep /<C-R><C-W>/gj **/*.<C-r>=expand("%:e")<CR><CR>:copen<CR>

" Quit & save shortcuts
nnoremap <leader>q :q<CR>
nnoremap <leader>w :w<CR>
