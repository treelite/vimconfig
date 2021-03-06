" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2002 Sep 19
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,gbk,ucs-bom,cp936
language message zh_CN.UTF-8

execute pathogen#infect()

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible | filetype indent plugin on | syn on

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set guioptions-=m
set guioptions-=T

"map <silent> <F4> :if &guioptions =~# 'T' <Bar>
"        \set guioptions-=T <Bar>
"        \set guioptions-=m <bar>
"    \else <Bar>
"        \set guioptions+=T <Bar>
"        \set guioptions+=m <Bar>
"    \endif<CR>

set nobackup		" do not keep a backup file, use versions instead

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

set autoindent
set expandtab 
set tabstop=4 
set shiftwidth=4
set softtabstop=4
set nu
set linespace=4

set autochdir
set noerrorbells

colorscheme yytextmate
set guifont=menlo:h12

"InsertMode use IME else set imdisable                    
"need to disable macvim'option(COMMAND+,):  Draw marked text inline
set imdisable                                             
set imsearch=0                                            
autocmd! CompleteDone  * set imdisable|set iminsert=0 "for macvim
autocmd! InsertEnter * set noimdisable|set iminsert=0     
autocmd! InsertLeave * set imdisable|set iminsert=0  

nmap <S-H> :bp<CR>
nmap <S-L> :bn<CR>
nmap <D-k> :cp<CR>
nmap <D-j> :cn<CR>
nmap <F2> :nohlsearch<CR>
nmap <F3> :NERDTreeToggle<CR>
nmap <F4> :JSBeautify<CR>
" nmap <F5> :JSHint<CR>
nmap <F5> :FECS<CR>
nmap <C-i> :JSC<CR>
nmap <D-K> :JSCprev<CR>
nmap <D-J> :JSCnext<CR>
nmap <F8> :TagbarToggle<CR>

let g:miniBufExplorerMoreThanOne = 0
let g:neocomplcache_enable_at_startup = 1
let g:vim_markdown_folding_disabled = 1

" multiple-cursors 配置
let g:multi_cursor_use_default_mapping = 0
let g:multi_cursor_next_key = '<M-n>'
let g:multi_cursor_prev_key = '<M-p>'
let g:multi_cursor_skip_key = '<M-x>'
let g:multi_cursor_quit_key = '<Esc>'

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  " autocmd FileType text setlocal textwidth=78

  au BufRead,BufNewFile *.text set filetype=mkd

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

  " do check before save js file
  " autocmd BufWritePre,FileWritePre,FileAppendPre *.js : JSHint
  let g:user_emmet_install_global = 0
  autocmd FileType html,tpl,vm EmmetInstall

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" beautify js
function! s:beautify()
    let cmdline = ['%!js-beautify']

    let filename = expand('%')
    let suffix = strpart(filename, stridx(filename, '.') + 1)

    if (suffix == 'css')
        call add(cmdline, ' --type css')
        call add(cmdline, ' --no-preserve-newlines')
    elseif ('html|htm|tpl' =~ suffix )
        call add(cmdline, ' --type html') 
    endif

    call add(cmdline, ' -')

    silent execute join(cmdline)

endfunction

function! s:edpHint()
    let cmdline = ['edp']

    let filename = expand('%')
    let suffix = strpart(filename, strridx(filename, '.') + 1)

    " 暂时只做了JS的检查
    if (suffix != 'js')
        return
    endif

    call add(cmdline, 'jshint')
    call add(cmdline, getcwd().'/'.filename)

    let res = system(join(cmdline, ' '))

    let lines = split(res, "\n")

    call filter(lines, 'strlen(v:val) > 0')

    cclose

    if len(lines) == 1
        echo lines[0]
        return
    endif

    call remove(lines, 0)

    let max = len(lines)
    let index = 0

    let qflist = []
    while index < max
        let item = split(lines[index], ':')
        let index = index + 1

        if (len(item) <= 1)
            continue
        endif

        let head = split(item[0], ' ')
        call remove(item, 0)
        let text = join(item, ':')

        let o = {}
        let o.bufnr = bufnr('%')
        let o.lnum = str2nr(head[4])
        let o.col = str2nr(head[6])
        let o.text = text
        let o.type = toupper(strpart(head[1], 0, 1))
        call add(qflist, o)

    endwhile

    echo 'There are '.len(qflist).' errors found!'
    call setqflist(qflist)
    belowright copen

endfunction

" color conversion
function! s:color(str)
    let value = ''
    if (stridx(a:str, '#') == 0)
        let res = []
        let str = strpart(a:str, 1)
        while (strlen(str) > 0)
            call add(res, printf('%d', '0x' . strpart(str, 0, 2)))
            let str = strpart(str, 2)
        endwhile
        let value = 'rgb(' . join(res, ',') . ')'
    else
        let value = a:str 
    endif
    return value
endfunction

" vim-airline setting
set laststatus=2
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#enabled = 0
let g:airline_left_sep = '»'
"let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
"let g:airline_right_sep = '◀'
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
"let g:airline_symbols.linenr = '␊'
"let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
"let g:airline_symbols.paste = 'Þ'
"let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

command! JSBeautify call s:beautify()
command! -nargs=1 Color echo s:color(<f-args>)

command! EdpHint call s:edpHint()
