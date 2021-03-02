" Script Name: tinygo.vim
" Description: tinygo integration for vim
"
" Copyright:   (C) 2021 sago35
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  sago35 <sago35@gmail.com>
"
" Dependencies:
"  - Requires Vim 8.0 or higher.
"  - Requires git.
"
" Version:     0.1.0
" Changes:
"   0.1.0
"       Initial release

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_tinygo') || (v:version < 800)
    finish
endif
let g:loaded_tinygo = 1
let s:save_cpo = &cpo
set cpo&vim

command! -complete=customlist,tinygo#TinygoTargets -nargs=? TinygoTarget :cal tinygo#TinygoTarget(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=4 sts=0 sw=4

