" Appends an increasing number to a pattern wherever that pattern apears on a
" range of lines. For example, say you had a list like this:

" Task1 Some stuff about task1
" Task2 Some stuff about task2
" Task3 Some stuff about task3
" Task4 Some stuff about task4

" If you wanted to insert another 'Task' between Task2 and Task3 it would be
" fairly annoying to re-number all the 'Task's. But with this plugin it would
" be simple. Just visually select the text to reorder and run the command:

"                :call NumberWrapper()

" You can get more specific about which patterns you'd like to adjust. Say
" that the 'task's at the end got out of order. You could visually select the
" list and run:

"                :call Number('task')

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
function! NumberCore(pattern, prepend_str, append_str, start_increment) range
    let increment = a:start_increment
    for line_no in range(a:firstline, a:lastline)
        let cur_line = getline(line_no)
        if match(cur_line, a:pattern) !=# -1
            let new_line = substitute(cur_line, a:pattern, a:prepend_str . increment . a:append_str, '')
            call setline(line_no, new_line)
            let increment += 1
        endif
    endfor
endfunction

" Given a list of strings and a regex, returns the regex that appears most
" often. 
function! GetMostFrequentPattern(string_list, regex)
    " Count the number of times each pattern occurrs
    let pattern_dict = {}
    for string in a:string_list
        let pattern = matchstr(string, a:regex)
        if pattern !=# ''
            if has_key(pattern_dict, pattern)
                let pattern_dict[pattern] += 1
            else
                let pattern_dict[pattern] = 1
            endif
        endif
    endfor
    " Return the pattern that occurred the most
    let result = ''
    let max_val = max(pattern_dict)
    for [key, value] in items(pattern_dict)
        if value ==# max_val
            let result = key
            break
        endif
    endfor
    return result
endfunction

" Tries to find a pattern that ends in a number
function! FindPattern(startline, endline)
    " Pick 5 random lines to look through to find a common pattern
    let last_line_to_check = a:startline + 5
    if last_line_to_check > a:endline
        let last_line_to_check = a:endline
    endif
    " Return the pattern that occurrs most often
    let string_list = map(range(a:startline, last_line_to_check), 'substitute(getline(v:val), "\\s*", "", "")')
    return GetMostFrequentPattern(string_list, "\\v[^0-9 \t]*\\ze\\d+")
endfunction

" I like the idea of having all those parameters to the 'NumberCore()' function
" because it offers more control, but most of the time you won't need them. So
" this calls that function in a 'reasonable' way.
function! Number() range
    let pattern = FindPattern(a:firstline, a:lastline)
    if pattern !=# ''
        let pattern = pattern . '\zs\d\+'
        '<,'>call NumberCore(pattern, '', '', 1)
    endif
endfunction

" Suggestd mappings:
" vnoremap <silent> <leader>o :call NumberWrapper()<CR>
" vnoremap <leader>O :call Number('
" vnoremap <leader><C-o> :call NumberCore('
