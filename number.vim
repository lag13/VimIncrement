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

" TODO: 
" 1. Try to make any non-whitespace characters AFTER the number part of the
" pattern as well.  I say this because my current implementation would fail if
" we had a numbered list and the second line of one of the lists began with a
" number i.e if it looked like this: 
"                   1. This is a really long list item
"                      3 things I want to do are...
"                   4. Some mor stuff
" My implementation would change the '3' in front of the word 'things' which
" is no good. This will involve changing the regex that the
" FindRegexEndingInNumber() passes to the GetMostFrequentPattern() function.
" 2. This very TODO list will NOT get properly numbered because there are too
" many patterns that come up empty and so those rule out any other patterns we
" see.  Improve the GetMostFrequentPattern() function to prevent this. I've
" already removed it's ability to keep count of empty patterns. This has had
" more positive results than I originally intended! For example, this list IS
" now being properly numbered. There are still improvements to be made though.
" For example if I have a list like this:
"               // 1. This is the first number
"               //4. This is the second number
"               //  4. This is the second number
" Then this won't be properly numbered because the spacing doesn't match.
" Maybe detetcting this is a little nitpicky but it's something to keep in
" mind I suppose.
" 3. Improve this so that if a pattern DOES match at the begginning of the
" line, then FindRegexEndingInNumber() will NOT prepend '^\s\*' to the
" returned regex, it will JUST prepend '^'.


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

" Given a list of strings and a regex, returns the string generated from the
" regex that appeared most often. 
function! GetMostFrequentPattern(string_list, regex)
    " Count the number of times each pattern occurrs
    let pattern_dict = {}
    let max_num_occurrences = 0
    let result = ''
    for string in a:string_list
        let pattern = matchstr(string, a:regex)
        if pattern !=# ''
            if has_key(pattern_dict, pattern)
                let pattern_dict[pattern] += 1
            else
                let pattern_dict[pattern] = 1
            endif
            if pattern_dict[pattern] > max_num_occurrences
                let max_num_occurrences = pattern_dict[pattern]
                let result = pattern
            endif
        endif
    endfor
    return result
endfunction

" Returns the most frequent non-empty string in a list of strings. If the list
" only contains non-empty strings, then the empty string will be returned.
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

" Returns a regex of the pattern that occurred most often between a:startline
" and a:endline. This regex will be prepended with '^\s*' (so indenting won't
" matter) and appended with '\zs\d\+' (which allows us to increment the number
" following the pattern).
function! FindRegexEndingInNumber(startline, endline)
    " Return the pattern that occurrs most often
    let string_list = map(range(a:startline, a:endline), 'getline(v:val)')
    "let result = GetMostFrequentPattern(string_list, '\v^[^0-9]*\ze\d+')
    let regex = '\v^[^0-9]*\d+'
    " Get's a list of all strings resulting from the regex then turns any
    " numbers in those resulting strings into the string '\zs\d\+'
    call map(string_list, 'substitute(matchstr(v:val, regex), "\\d\\+", "\\\\zs\\\\d\\\\+", "")')
    " I turn on the 'very nomagic' switch so any special characters in
    " 'result' will not affect the returned regex.
    " TODO: Probably need to escape any backslashes that might be in the
    " string.
    let result = '\V\^\s\*' . substitute(GetMostCommonNonEmptyStr(string_list), '^\s*', '', '')
    return result
endfunction

" Changes the buffer.
function! NumberLines(startline, endline, pattern)
    let new_lines = NumberCore(map(range(a:startline, a:endline), 'getline(v:val)'), a:pattern, range(1, a:endline - a:startline + 1))
    for i in range(a:startline, a:endline)
        call setline(i, new_lines[i-a:startline])
    endfor
endfunction

" A wrapper to the 'NumberCore()' function wich requires the least amount of
" thinking and will do exactly what you want 95% of the time.
function! Number() range
    let pattern = FindRegexEndingInNumber(a:firstline, a:lastline)
    call NumberLines(a:firstline, a:lastline, pattern)
endfunction

" The next level up in specificity. Allows you to specify a plain old string
" which will have an increasing number appended to it.
function! NumberStr(string) range
    let regex = '\V' . escape(a:string, '\') . '\zs\(\d\+\)\?'
    call NumberLines(a:firstline, a:lastline, regex)
endfunction

" The highest level of specificity. Give the actual regex which will be
" replaced with an increasing number.
function! NumberReg(regex) range
    call NumberLines(a:firstline, a:lastline, a:regex)
endfunction

" Suggestd mappings:
" vnoremap <silent> <leader>o :call NumberWrapper()<CR>
" vnoremap <leader>O :call Number('
" vnoremap <leader><C-o> :call NumberCore('
