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

function! tinygo#ChangeTinygoTargetTo(target)
    let info = split(system('tinygo info -target ' . a:target), "\n")
    for i in info
        let data = split(i)
        if len(data) > 2 && data[0] == "build" && data[1] == "tags:"
            let l:goflags = "-tags=" . join(data[2:-1], ",")
        elseif len(data) > 1 && data[0] == "GOOS:"
            let l:goos = join(data[1:-1], ",")
        elseif len(data) > 1 && data[0] == "GOARCH:"
            let l:goarch = join(data[1:-1], ",")
        elseif len(data) > 2 && data[0] == "cached" && data[1] == "GOROOT:"
            let l:goroot = join(data[2:-1], ",")
        endif
    endfor

    if exists("l:goroot") && exists("l:goos") && exists("l:goarch") && exists("l:goflags")
        if exists($GOROOT)
            let l:org_goroot = $GOROOT
            unlet $GOROOT
        endif
        if exists($GOOS)
            let l:org_goos = $GOOS
            unlet $GOOS
        endif
        if exists($GOARCH)
            let l:org_goarch = $GOARCH
            unlet $GOARCH
        endif
        if exists($GOFLAGS)
            let l:org_goflags = $GOFLAGS
            unlet $GOFLAGS
        endif

        let $GOROOT = l:goroot
        let $GOOS = l:goos
        let $GOARCH = l:goarch
        let $GOFLAGS = l:goflags

        if has('nvim')
            call execute("LspStop")
        else
            call execute("LspStopServer")
        endif


        call execute("sleep 100m")
        call execute("edit")

        if exists("l:org_goroot")
            let $GOROOT = l:org_goroot
            unlet l:org_goroot
        else
            unlet $GOROOT
        endif
        if exists("l:org_goos")
            let $GOOS = l:org_goos
            unlet l:org_goos
        else
            unlet $GOOS
        endif
        if exists("l:org_goarch")
            let $GOARCH = l:org_goarch
            unlet l:org_goarch
        else
            unlet $GOARCH
        endif
        if exists("l:org_goflags")
            let $GOFLAGS = l:org_goflags
            unlet l:org_goflags
        else
            unlet $GOFLAGS
        endif
    else
        echo "some problem with `tinygo info -target " . a:target . "` execution"
    endif
endfunction

function! tinygo#ChangeTinygoTarget()
    30vnew
    setlocal winfixwidth
    setlocal bufhidden=wipe
    setlocal buftype=nofile
    setlocal nonu
    let targets = split(system('tinygo targets'))
    for target in targets
        put=target
    endfor
    call execute('global/^$/d')

    nmap <buffer>  <Enter>  :let target = getline('.')<CR>:quit<CR>:execute 'TinygoTarget ' . target<CR>
endfunction

function! tinygo#TinygoTarget(...)
    if !executable('tinygo')
        echo '"tinygo": executable file not found in $PATH'
        return
    endif

    if a:0 >= 1
        call tinygo#ChangeTinygoTargetTo(a:1)
    else
        call tinygo#ChangeTinygoTarget()
    end
endfunction

function! tinygo#TinygoTargets(A, L, P)
    if !executable('tinygo')
        return ['"tinygo": executable file not found in $PATH']
    endif

    let l:targets = split(system('tinygo targets'), "\n")
    return filter(l:targets, 'v:val =~? "^' . a:A . '"')
endfunction

" vim: ts=4 sts=0 sw=4
