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
function! NumberCore(pattern, prepend_str, append_str, start_increment) range
    let increment = a:start_increment
    for i in range(a:firstline, a:lastline)
        call cursor(i, 1)
        let cur_line = getline('.')
        let pat_end_index = matchend(cur_line, a:pattern)
        if pat_end_index !=# -1
            let new_line1 = strpart(cur_line, 0, pat_end_index)
            " We append the incrementing number to the first match of
            " 'pattern' we see regardless of whether 'pattern' is followed by
            " any digits.
            if match(cur_line, a:pattern) ==# match(cur_line, a:pattern . '\d\+')
                let new_line2 = strpart(cur_line, matchend(cur_line, a:pattern . '\d\+'), len(cur_line))
            else
                let new_line2 = strpart(cur_line, pat_end_index, len(cur_line))
            endif
            call setline('.', new_line1 . a:prepend_str . increment . a:append_str . new_line2)
            let increment += 1
        endif
    endfor
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
    '<,'>call NumberCore(pattern, '', '', 1)
endfunction

" Suggestd mappings:
" vnoremap <silent> <leader>o :call NumberWrapper()<CR>
" vnoremap <leader>O :call Number('
" vnoremap <leader><C-o> :call NumberCore('
