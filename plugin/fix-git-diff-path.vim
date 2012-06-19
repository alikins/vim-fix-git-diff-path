" vim-fix-git-diff-path v 37.4.0
"   Adrian Likins <adrian@likins.com>
"
" git diff includes a "a/path/to/file" in git diff
" output. This is a pain, if you want to cut and
" paste that path. This tries to let you just
" c&p that entire prefixed path and do the
" right thing. Ie, open the file referenced.
" It should work anywhere in the git project
" of the current working dir. It's mostly
" intended for use from the command line but
" in theory, any file loading command should work
" we well.
"
" bugs: - doesn't work if you are out of the git project
"         directory.
"       - probably confused if you have an actual file
"         name something like a/path/to/file
"
"
" this is based heavily on file_line.vim form
" https://github.com/bogado/file-line


" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_fix_git_path') || (v:version < 700)
    finish
endif
let g:loaded_fix_git_path = 1

function s:FindProjectRoot()
    let l:root = substitute(system("git rev-parse --show-toplevel"), "\n", "", "")
    return l:root
endfunction

function! s:fixgitpath()
    let file = bufname("%")

    " :e command calls BufRead even though the file is a new one.
    " As a workarround Jonas Pfenniger<jonas@pfenniger.name> added an
    " AutoCmd BufRead, this will test if this file actually exists before
    " searching for a file and line to goto.
    if (filereadable(file))
        return
    endif

    " Accept file:line:column: or file:line:column and file:line also
    let names =  matchlist( file, '[abcdiwcoi]\/\(.*\)')

    if empty(names)
    return
    endif

    let file_name = names[1]
    let root_path = s:FindProjectRoot()
    let full_filename = root_path .  "/" . file_name

    if filereadable(full_filename)
        let l:bufn = bufnr("%")
        exec ":bwipeout " l:bufn
        exec "keepalt edit " . full_filename
        exec "normal! zz"
    endif

endfunction

autocmd! BufNewFile [abcdiwco]/* nested call s:fixgitpath()
autocmd! BufRead [abcdiwco]/* nested call s:fixfitpath()
