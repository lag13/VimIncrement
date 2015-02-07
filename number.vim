" Appends an increasing number to a pattern wherever that pattern apears on a
" range of lines. For example, say you had a list like this:

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

"                :call NumberPat('task')

" And you can get even more specific if desired. You have the ability to say where
" the number starts incrementing from and you can prepend or append strings to
" that number. For example, say you wanted to make the above list have each
" line look something like this:
"               Task (1): Some stuff about task 1
" instead of this:
"               Task1 Some stuff about task 1

" You could visually select the text and run this command:

"                :call NumberCore('Task', ' (', '):', 1)

" Author; Lucas Groenendaal

" On a range of lines, appends an increasing number to an occurrence of
" 'pattern' on the line.


" The old NumberCore() function was a bit too complicated for my taste so I
" made this next iteration simpler.  All it does is replaces 'pattern' with an
" increasing number. You can still get the same effect as the old function
" (i.e appending an increasing number to a 'pattern') through appropriate use
" of the \zs and \ze atoms
function! NumberCore(startline, endline, pattern, start_increment, prepend_str, append_str) range
    let increment = a:start_increment
    for line_no in range(a:startline, a:endline)
        let cur_line = getline(line_no)
        if match(cur_line, a:pattern) !=# -1
            let new_line = substitute(cur_line, a:pattern, a:prepend_str . increment . a:append_str, '')
            call setline(line_no, new_line)
            let increment += 1
        endif
    endfor
endfunction

" Given a list of strings and a regex, returns the string generated from the
" regex that appeared most often. 
function! GetMostFrequentPattern(string_list, regex)
    " Count the number of times each pattern occurrs
    let pattern_dict = {}
    let max_num_occurrences = 0
    let num_occurrences_empty = 0
    let result = ''
    for string in a:string_list
        let pattern = matchstr(string, a:regex)
        " We cannot use an empty key for a dictionary. HOWEVER I think
        " returning an empty match is okay so I'll keep track of the number of
        " empty matches in a separate variable.
        if pattern !=# ''
            if has_key(pattern_dict, pattern)
                let pattern_dict[pattern] += 1
            else
                let pattern_dict[pattern] = 1
            endif
            " Update the pattern that occurred most often
            if pattern_dict[pattern] > max_num_occurrences
                let max_num_occurrences = pattern_dict[pattern]
                let result = pattern
            endif
        else
            let num_occurrences_empty += 1
        endif
    endfor
    if num_occurrences_empty > max_num_occurrences
        let result = ''
    endif
    return result
endfunction

" Returns a regex of the pattern that occurred most often between a:startline
" and a:endline. This regex will be prepended with '^\s*' and appended with
" '\zs\d\+'.
function! FindRegexEndingInNumber(startline, endline)
    " Try looking through the first 5 lines to find a common pattern
    let last_line_to_check = a:startline + 5
    if last_line_to_check > a:endline
        let last_line_to_check = a:endline
    endif
    " Return the pattern that occurrs most often
    let string_list = map(range(a:startline, last_line_to_check), 'getline(v:val)')
    let result = GetMostFrequentPattern(string_list, '\v^[^0-9]*\ze\d+')
    " We want to ignore any leading whitespace. I also turn on the 'very
    " nomagic' switch so any special characters in 'result' will not affect
    " the returned regex.
    let result = '\V\^\s\*' . substitute(result, '^\s*', '', '') . '\zs\d\+'
    return result
endfunction

" I like the idea of having all those parameters to the 'NumberCore()' function
" because it offers more control, but most of the time you won't need them. So
" this calls that function in a 'reasonable' way.
function! Number() range
    let pattern = FindRegexEndingInNumber(a:firstline, a:lastline)
    call NumberCore(a:firstline, a:lastline, pattern, 1, '', '')
endfunction

" Will append an incrementing number to a specified pattern.
function! NumberPat(pattern) range
    echo 'test'
endfunction

" Suggestd mappings:
" vnoremap <silent> <leader>o :call NumberWrapper()<CR>
" vnoremap <leader>O :call Number('
" vnoremap <leader><C-o> :call NumberCore('
