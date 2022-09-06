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
    let oldenv = {}
    for key in ['GOROOT', 'GOOS', 'GOARCH', 'GOFLAGS']
        let value = getenv(key)
        if value != v:null
            let oldenv[key] = value
        endif
    endfor

    if a:target != "-"
        let output = system('tinygo info -json -target ' . a:target)
        if v:shell_error
            for line in split(output, '\n')
                echohl Error | echomsg line | echohl None
            endfor
            return
        endif
        let info = json_decode(output)

        if !has_key(info, 'goroot') || !has_key(info, 'goos') || !has_key(info, 'goarch') || !has_key(info, 'build_tags')
            echo "some problem with `tinygo info -target " . a:target . "` execution"
            return
        endif

        let $GOROOT = info['goroot']
        let $GOOS = info['goos']
        let $GOARCH = info['goarch']
        let $GOFLAGS = '-tags=' .. join(info['build_tags'], ',')
    endif


    if has('nvim')
        call execute("LspStop")
    else
        call execute("LspStopServer")
    endif

    call execute("sleep 100m")
    call execute("edit")

    for key in ['GOROOT', 'GOOS', 'GOARCH', 'GOFLAGS']
        if has_key(oldenv,key)
            call setenv(key, value)
        else
            call setenv(key, v:null)
        endif
    endfor
endfunction

function! tinygo#ChangeTinygoTarget()
    30vnew
    setlocal winfixwidth
    setlocal bufhidden=wipe
    setlocal buftype=nofile
    setlocal nonu
    let targets = split(system('tinygo targets'))
    call insert(targets, "-")
    for target in targets
        put=target
    endfor
    call execute('global/^$/d _')

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
    return filter(l:targets, 'stridx(v:val, a:A) == 0')
endfunction

" vim: ts=4 sts=0 sw=4
