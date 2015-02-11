" Appends an increasing number to a pattern on a range of lines. For example,
" say you had a list like this:

" Task1 Some stuff about task1
" Task2 Some stuff about task2
" Task3 Some stuff about task3
" Task4 Some stuff about task4

" If you wanted to insert another 'Task' between Task2 and Task3 it would be
" fairly annoying to re-number all the 'Task's. But with this plugin it would
" be simple. Just visually select the text to reorder and run the command:

"                :call Number()

" You can get more specific about which patterns you'd like to adjust. Say
" that the 'task's at the end got out of order. You could visually select the
" list and run:

"                :call NumberStr('task')

" Author; Lucas Groenendaal

" The old NumberCore() function was a bit too complicated for my taste so I
" made this next iteration simpler.  All it does is replaces 'pattern' with an
" increasing number. You can still get the same effect as the old function
" (i.e appending an increasing number to a 'pattern') through appropriate use
" of the \zs and \ze atoms
function! NumberCore(strings, pattern, sub_strings)
    let result = []
    let i = 0
    for str in a:strings
        if match(str, a:pattern) !=# -1
            let str = substitute(str, a:pattern, a:sub_strings[i], '')
            let i += 1
        endif
        call add(result, str)
    endfor
    return result
endfunction

" Returns the most frequent non-empty string in a list of strings. If the list
" only contains non-empty strings, then the empty string will be returned. If
" multiple strings occurr with the same frequency, the first one found will be
" returned.
function! GetMostCommonNonEmptyStr(strings)
    let dict = {}
    let num_occurrences = 0
    let result = ''
    for str in a:strings
        if str !=# ''
            if has_key(dict, str)
                let dict[str] += 1
            else
                let dict[str] = 1
            endif
            if dict[str] > num_occurrences
                let num_occurrences = dict[str]
                let result = str
            endif
        endif
    endfor
    return result
endfunction

" Turns a list of strings into another list of strings X using a regex. Then
" returns the string that occurred most often in X with a little extra
" regex-ness tacked on. The whole point is to automatically find a pattern
" that, when used with the NumberCore() function, will correctly number a
" series of lines.
function! FindRegexEndingInNumber(string_list)
    let regex = '\v^[^0-9]*\d+\S*'
    " Those 4 backslashes in a row look pretty bad but they're necessary.
    call map(a:string_list, 'substitute(escape(matchstr(v:val, regex), "\\"), "\\d\\+", "\\\\zs\\\\d\\\\+\\\\ze", "")')
    " I turn on the 'very nomagic' switch so all characters returned from
    " GetMostCommonNonEmptyStr() will be treated literally.
    " TODO: Don't use the \s\* when the pattern ACTUALLY matched at the beginning of the line.
    return '\V\^\s\*' . substitute(GetMostCommonNonEmptyStr(a:string_list), '^\s*', '', '')
endfunction

" Changes the buffer.
function! ChangeLines(startline, endline, pattern)
    let new_lines = NumberCore(map(range(a:startline, a:endline), 'getline(v:val)'), a:pattern, range(1, a:endline - a:startline + 1))
    for i in range(a:startline, a:endline)
        call setline(i, new_lines[i-a:startline])
    endfor
endfunction


" These three functions are the things which should be mapped.

" A wrapper to the 'NumberCore()' function wich requires the least amount of
" thinking and will do exactly what you want 95% of the time.
function! Number() range
    let lines = map(range(a:firstline, a:lastline), 'getline(v:val)')
    let pattern = FindRegexEndingInNumber(lines)
    call ChangeLines(a:firstline, a:lastline, pattern)
endfunction

" The next level up in specificity. Allows you to specify a plain old string
" which will have an increasing number appended to it whether or not the string
" ends in a number.
function! NumberStr(string) range
    let regex = '\V' . escape(a:string, '\') . '\zs\(\d\+\)\?'
    call ChangeLines(a:firstline, a:lastline, regex)
endfunction

" The highest level of specificity. Give the actual regex which will be
" replaced with an increasing number.
function! NumberReg(regex) range
    call ChangeLines(a:firstline, a:lastline, a:regex)
endfunction
