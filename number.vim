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

" Finds all the strings on each line that match a regex and returns the string
" that occurrs the most number of times.
" let regex = "\\v[^0-9 \t]*\\ze\\d+" 
function! GetMostFrequentPattern(line_nums, regex)
    " Count up how many times each pattern occurrs
    let pattern_dict = {}
    for line_no in a:line_nums
        let pattern = substitute(matchstr(getline(line_no), a:regex), '\s*', '', '')
        if pattern !=# ''
            if has_key(pattern_dict, pattern)
                let pattern_dict[pattern] += 1
            else
                let pattern_dict[pattern] = 1
            endif
        endif
    endfor
    return pattern_dict
endfunction

" Tries to find a pattern that ends in a number. That is the pattern that will
" be incremented.
function! FindPattern(startline, endline)
    " Pick 5 random lines to look through to find a common pattern
    let num_lines_to_look_through = 5
    if a:endline - a:startline + 1 <# num_lines_to_look_through
        let num_lines_to_look_through = a:endline - a:startline + 1
    endif
    " Return the pattern that occurrs most often
    let pattern_dict = GetMostFrequentPattern(range(a:startline, a:startline + num_lines_to_look_through), "\\v[^0-9 \t]*\\ze\\d+")
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


" I like the idea of having all those parameters to the 'NumberCore()' function
" because it offers more control, but most of the time you won't need them. So
" this calls that function in a 'reasonable' way.
function! Number(pattern) range
    '<,'>call NumberCore(a:pattern, '', '', 1)
endfunction

" Most of the time you'll probably just want to increment the first set of
" numbers you see. This function allows you to do that. It will get the first
" sequence of non-whitespace characters which are followed by a sequence of
" digits. It takes the non-whitespace characters to be the 'pattern' which
" gets passed to the 'NumberCore()' function.
function! NumberWrapper() range
    let first_line = getline(a:firstline)
    let pattern = matchstr(first_line, '\S*\ze\d\+')
    if match(first_line, pattern) ==# 0
        let pattern = '^' . pattern
    endif
    '<,'>call NumberCore2(pattern)
endfunction

" Suggestd mappings:
" vnoremap <silent> <leader>o :call NumberWrapper()<CR>
" vnoremap <leader>O :call Number('
" vnoremap <leader><C-o> :call NumberCore('
