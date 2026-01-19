" =============================================================================
" VIM CHEAT SHEET (Common Shortcuts)
" =============================================================================
" CUT / COPY / PASTE (Internal Vim Buffers):
" v (select) + d   -> Cut (Delete) selection
" v (select) + y   -> Copy (Yank) selection
" dd               -> Cut (Delete) current line
" yy               -> Copy (Yank) current line
" p                -> Paste AFTER cursor
" P                -> Paste BEFORE cursor
"
" SYSTEM CLIPBOARD COPY/PASTE (OSC 52 / SSH):
" 1. Press 'v', 'V', or 'Ctrl+v' to select text
" 2. Press ',c' (Leader + c) -> Copy to LOCAL computer clipboard
"
" SEARCH & REPLACE EXAMPLES:
" :%s/foo/bar/g    -> Replace ALL 'foo' with 'bar' in entire file
" :s/foo/bar/g     -> Replace 'foo' with 'bar' in CURRENT line only
" :%s/foo/bar/gc   -> Replace with CONFIRMATION (y=yes, n=no, a=all)
"
" NAVIGATION:
" gg               -> Go to first line
" G                -> Go to last line
" :[num]           -> Go to line [num] (e.g. :42)
" 0                -> Go to start of line
" $                -> Go to end of line
" w / b            -> Move forward / backward by word
" Ctrl + d / u     -> Scroll DOWN / UP half a page
"
" EDITING:
" i                -> Enter INSERT mode (ESC to exit)
" v                -> Enter VISUAL mode (to select text)
" x                -> Delete character under cursor
" u                -> Undo
" Ctrl + r         -> Redo
"
" SEARCH:
" /pattern         -> Search for 'pattern'
" n / N            -> Next / Previous match
" :nohl            -> Clear search highlighting
"
" =============================================================================
" Full Vim Configuration
" =============================================================================
set nocompatible            " Disable compatibility with old Vi
filetype on                 " Enable filetype detection
filetype plugin on
filetype indent on
set encoding=utf-8
syntax on                   " Enable syntax highlighting
set number                  " Show line numbers
set relativenumber          " Show relative line numbers
set cursorline              " Highlight the current line
set showmatch               " Highlight matching parenthesis
set laststatus=2            " Always show status line
colorscheme desert          " Set color scheme

" Indentation
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start

" Search
set incsearch
set hlsearch
set ignorecase
set smartcase

" Clipboard & Mouse
set mouse=a                 " Enable mouse support
set clipboard=unnamedplus   " Link Vim yank/paste to system clipboard

" Wayland Clipboard Support (requires wl-clipboard)
if exists('$WAYLAND_DISPLAY') && executable('wl-copy')
  let g:clipboard = {
        \   'name': 'wl-clipboard',
        \   'copy': {
        \      '+': 'wl-copy',
        \      '*': 'wl-copy',
        \    },
        \   'paste': {
        \      '+': 'wl-paste --no-newline',
        \      '*': 'wl-paste --no-newline',
        \   },
        \   'cache_enabled': 1,
        \ }
endif

" Key Mappings
let mapleader = ","

" Press <Space> to clear search highlights
nnoremap <silent> <Space> :nohlsearch<CR>

" Quick save/quit
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>

" Move lines up and down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi

" =============================================================================
" OSC 52 Clipboard Integration (for SSH)
" =============================================================================
function! Osc52Yank()
    " Check if 'base64' is available
    if !executable('base64')
        echo "Error: base64 command not found"
        return
    endif

    " yank the current selection into the " register
    let raw = getreg('"')
    
    " Base64 encode the text (handle busybox base64 vs GNU base64)
    " We strip newlines from the base64 output
    let b64 = system('base64', raw)
    let b64 = substitute(b64, "\n", "", "g")

    " Construct the OSC 52 escape sequence
    let esc = "\e]52;c;" . b64 . "\x07"

    " Send to terminal (works for most modern terminals)
    " Note: If using tmux, you might need a different wrapping
    if exists('$TMUX')
        let esc = "\ePtmux;\e" . esc . "\e\\"
    endif
    
    " Write to the terminal directly
    call writefile([esc], "/dev/tty", "b")
endfunction

" Map <Leader>c to copy to system clipboard
vnoremap <Leader>c y:call Osc52Yank()<CR>
noremap <Leader>c y:call Osc52Yank()<CR>
