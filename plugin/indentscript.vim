if exists('g:loaded_indentscript')
  finish
endif
let g:loaded_indentscript = 1

let s:save_cpo = &cpo
set cpo&vim

let g:indentscript_indent_size = get(g:, 'indentscript_indent_size', 4)
let g:indentscript_auto_format = get(g:, 'indentscript_auto_format', 0)
let g:indentscript_auto_lint = get(g:, 'indentscript_auto_lint', 1)
let g:indentscript_executable = get(g:, 'indentscript_executable', 'indentscript')
let g:indentscript_show_diagnostics = get(g:, 'indentscript_show_diagnostics', 1)
let g:indentscript_highlight_errors = get(g:, 'indentscript_highlight_errors', 1)

function! s:ISCFormat()
  let l:save_cursor = getpos('.')
  let l:lines = getline(1, '$')
  let l:formatted = []
  let l:indent_level = 0
  let l:in_multiline_string = 0
  let l:in_comment_block = 0
  
  for l:line in l:lines
    let l:stripped = trim(l:line)
    
    if l:stripped =~# '^"""' || l:stripped =~# "^'''"
      let l:in_multiline_string = !l:in_multiline_string
      call add(l:formatted, repeat(' ', l:indent_level * g:indentscript_indent_size) . l:stripped)
      continue
    endif
    
    if l:in_multiline_string
      call add(l:formatted, l:line)
      continue
    endif
    
    if l:stripped =~# '^/\*'
      let l:in_comment_block = 1
      call add(l:formatted, repeat(' ', l:indent_level * g:indentscript_indent_size) . l:stripped)
      continue
    endif
    
    if l:stripped =~# '\*/$'
      let l:in_comment_block = 0
      call add(l:formatted, repeat(' ', l:indent_level * g:indentscript_indent_size) . l:stripped)
      continue
    endif
    
    if l:in_comment_block
      call add(l:formatted, l:line)
      continue
    endif
    
    if empty(l:stripped)
      call add(l:formatted, '')
      continue
    endif
    
    if l:stripped =~# '^\(else\|elif\|except\|finally\):'
      let l:indent_level = max([0, l:indent_level - 1])
    elseif l:stripped =~# '^\(elif\|except\)\s'
      let l:indent_level = max([0, l:indent_level - 1])
    endif
    
    if l:stripped =~# '^}'
      let l:indent_level = max([0, l:indent_level - 1])
    endif
    
    if l:stripped =~# '^]'
      let l:indent_level = max([0, l:indent_level - 1])
    endif
    
    if l:stripped =~# '^)'
      let l:indent_level = max([0, l:indent_level - 1])
    endif
    
    call add(l:formatted, repeat(' ', l:indent_level * g:indentscript_indent_size) . l:stripped)
    
    if l:stripped =~# ':$'
      let l:indent_level += 1
    endif
    
    if l:stripped =~# '{$'
      let l:indent_level += 1
    endif
    
    if l:stripped =~# '\[$'
      let l:indent_level += 1
    endif
    
    if l:stripped =~# '($' && l:stripped !~# 'def\|if\|for\|while\|class'
      let l:indent_level += 1
    endif
    
    if l:stripped =~# '^return\s' || l:stripped ==# 'return'
      if l:indent_level > 0
        let l:indent_level -= 1
      endif
    endif
  endfor
  
  call setline(1, l:formatted)
  call setpos('.', l:save_cursor)
  
  if g:indentscript_show_diagnostics
    echo "✓ Buffer formatted successfully"
  endif
endfunction

function! s:ISCLint()
  let l:errors = []
  let l:warnings = []
  let l:lines = getline(1, '$')
  let l:indent_stack = [0]
  
  for l:i in range(len(l:lines))
    let l:line = l:lines[l:i]
    let l:line_num = l:i + 1
    let l:stripped = trim(l:line)
    
    if empty(l:stripped) || l:stripped =~# '^#' || l:stripped =~# '^//'
      continue
    endif
    
    let l:indent = 0
    for l:char in split(l:line, '\zs')
      if l:char ==# ' '
        let l:indent += 1
      elseif l:char ==# "\t"
        let l:indent += 4
      else
        break
      endif
    endfor
    
    if l:indent % g:indentscript_indent_size != 0
      call add(l:warnings, {'line': l:line_num, 'msg': 'Inconsistent indentation (expected multiple of ' . g:indentscript_indent_size . ')', 'type': 'W'})
    endif
    
    if l:stripped =~# '\vdef\s+\w+\s*\([^)]*\)\s*$' && l:stripped !~# ':$'
      call add(l:errors, {'line': l:line_num, 'msg': 'Function definition missing colon', 'type': 'E'})
    endif
    
    if l:stripped =~# '\vclass\s+\w+\s*(\([^)]*\))?\s*$' && l:stripped !~# ':$'
      call add(l:errors, {'line': l:line_num, 'msg': 'Class definition missing colon', 'type': 'E'})
    endif
    
    if l:stripped =~# '\v^(if|elif|while|for)\s+.*[^:]$' && l:stripped !~# '\s(and|or|not|is|in)\s*$'
      if l:line !~# '^\s*\(#\|//\)'
        call add(l:errors, {'line': l:line_num, 'msg': 'Control statement missing colon', 'type': 'E'})
      endif
    endif
    
    if l:stripped =~# '\v^\s*except\s+\w+\s+as\s+\w+\s*$' && l:stripped !~# ':$'
      call add(l:errors, {'line': l:line_num, 'msg': 'Except clause missing colon', 'type': 'E'})
    endif
    
    if l:stripped =~# '\vf["\x27].*\{[^}]*$'
      call add(l:errors, {'line': l:line_num, 'msg': 'Unclosed f-string interpolation', 'type': 'E'})
    endif
    
    let l:open_parens = len(split(l:line, '(', 1)) - 1
    let l:close_parens = len(split(l:line, ')', 1)) - 1
    if l:open_parens != l:close_parens
      call add(l:warnings, {'line': l:line_num, 'msg': 'Unbalanced parentheses', 'type': 'W'})
    endif
    
    let l:open_brackets = len(split(l:line, '\[', 1)) - 1
    let l:close_brackets = len(split(l:line, '\]', 1)) - 1
    if l:open_brackets != l:close_brackets
      call add(l:warnings, {'line': l:line_num, 'msg': 'Unbalanced brackets', 'type': 'W'})
    endif
    
    let l:open_braces = len(split(l:line, '{', 1)) - 1
    let l:close_braces = len(split(l:line, '}', 1)) - 1
    if l:open_braces != l:close_braces
      call add(l:warnings, {'line': l:line_num, 'msg': 'Unbalanced braces', 'type': 'W'})
    endif
  endfor
  
  if empty(l:errors) && empty(l:warnings)
    if g:indentscript_show_diagnostics
      echohl MoreMsg
      echo "✓ No issues found"
      echohl None
    endif
    return
  endif
  
  for l:error in l:errors
    echohl ErrorMsg
    echo 'Line ' . l:error.line . ': [ERROR] ' . l:error.msg
    echohl None
  endfor
  
  for l:warning in l:warnings
    echohl WarningMsg
    echo 'Line ' . l:warning.line . ': [WARN] ' . l:warning.msg
    echohl None
  endfor
  
  if g:indentscript_highlight_errors
    call s:ISCHighlightErrors(l:errors, l:warnings)
  endif
endfunction

function! s:ISCHighlightErrors(errors, warnings)
  call clearmatches()
  
  for l:error in a:errors
    call matchaddpos('ErrorMsg', [[l:error.line]])
  endfor
  
  for l:warning in a:warnings
    call matchaddpos('WarningMsg', [[l:warning.line]])
  endfor
endfunction

function! s:ISCTranspile()
  let l:filename = expand('%:p')
  
  if empty(l:filename)
    echohl ErrorMsg
    echo "Error: No file name"
    echohl None
    return
  endif
  
  if &modified
    write
  endif
  
  let l:output_file = fnamemodify(l:filename, ':r') . '.js'
  let l:cmd = g:indentscript_executable . ' --transpile ' . shellescape(l:filename) . ' ' . shellescape(l:output_file)
  
  echohl MoreMsg
  echo "Transpiling..."
  echohl None
  
  let l:result = system(l:cmd)
  
  if v:shell_error == 0
    echohl MoreMsg
    echo "✓ Transpiled successfully: " . fnamemodify(l:output_file, ':t')
    echohl None
  else
    echohl ErrorMsg
    echo "✗ Transpilation failed:"
    echo l:result
    echohl None
  endif
endfunction

function! s:ISCExecute()
  let l:filename = expand('%:p')
  
  if empty(l:filename)
    echohl ErrorMsg
    echo "Error: No file name"
    echohl None
    return
  endif
  
  if &modified
    write
  endif
  
  let l:cmd = g:indentscript_executable . ' --execute ' . shellescape(l:filename)
  
  echohl MoreMsg
  echo "Executing " . fnamemodify(l:filename, ':t') . "..."
  echohl None
  echo ""
  
  let l:output = system(l:cmd)
  
  if v:shell_error == 0
    echo l:output
  else
    echohl ErrorMsg
    echo "✗ Execution failed:"
    echo l:output
    echohl None
  endif
endfunction

function! s:ISCComplete(findstart, base)
  if a:findstart
    let l:line = getline('.')
    let l:start = col('.') - 1
    
    while l:start > 0 && l:line[l:start - 1] =~# '\w'
      let l:start -= 1
    endwhile
    
    return l:start
  else
    let l:keywords = [
      \ 'def', 'class', 'if', 'else', 'elif', 'for', 'while', 'return',
      \ 'import', 'from', 'in', 'as', 'with', 'pass', 'break', 'continue',
      \ 'print', 'len', 'range', 'enumerate', 'lambda', 'async', 'await',
      \ 'try', 'except', 'finally', 'raise', 'assert', 'del', 'global',
      \ 'yield', 'and', 'or', 'not', 'is', 'None', 'True', 'False',
      \ 'function', 'const', 'let', 'var', 'this', 'new', 'typeof',
      \ 'instanceof', 'delete', 'void', 'super', 'static'
      \ ]
    
    let l:builtins = [
      \ 'console', 'Array', 'Object', 'String', 'Number', 'Boolean',
      \ 'Math', 'Date', 'JSON', 'Promise', 'Error'
      \ ]
    
    let l:methods = [
      \ 'append', 'extend', 'insert', 'remove', 'pop', 'clear',
      \ 'upper', 'lower', 'strip', 'split', 'join', 'replace',
      \ 'startswith', 'endswith', 'find', 'index', 'keys', 'values', 'items'
      \ ]
    
    let l:all_completions = l:keywords + l:builtins + l:methods
    let l:matches = []
    
    for l:word in l:all_completions
      if l:word =~# '^' . a:base
        call add(l:matches, {'word': l:word, 'kind': 'k'})
      endif
    endfor
    
    return l:matches
  endif
endfunction

function! s:ISCFoldText()
  let l:line = getline(v:foldstart)
  let l:line_count = v:foldend - v:foldstart + 1
  let l:indent = indent(v:foldstart)
  
  return repeat(' ', l:indent) . '▸ ' . trim(l:line) . ' (' . l:line_count . ' lines)'
endfunction

function! s:ISCCheckSyntax()
  let l:lines = getline(1, '$')
  let l:has_errors = 0
  
  for l:i in range(len(l:lines))
    let l:line = l:lines[l:i]
    let l:stripped = trim(l:line)
    
    if l:stripped =~# '\vdef\s+\w+\s*\([^)]*\)\s*$' && l:stripped !~# ':$'
      let l:has_errors = 1
      break
    endif
    
    if l:stripped =~# '\vclass\s+\w+' && l:stripped !~# ':$'
      let l:has_errors = 1
      break
    endif
  endfor
  
  return !l:has_errors
endfunction

augroup IndentScript
  autocmd!
  autocmd BufNewFile,BufRead *.isc setlocal filetype=indentscript
  
  autocmd FileType indentscript setlocal omnifunc=s:ISCComplete
  autocmd FileType indentscript setlocal foldtext=s:ISCFoldText()
  
  if g:indentscript_auto_lint
    autocmd BufWritePost *.isc call s:ISCLint()
  endif
  
  if g:indentscript_auto_format
    autocmd BufWritePre *.isc call s:ISCFormat()
  endif
  
  autocmd FileType indentscript nnoremap <buffer> <silent> <leader>if :call <SID>ISCFormat()<CR>
  autocmd FileType indentscript nnoremap <buffer> <silent> <leader>il :call <SID>ISCLint()<CR>
  autocmd FileType indentscript nnoremap <buffer> <silent> <leader>it :call <SID>ISCTranspile()<CR>
  autocmd FileType indentscript nnoremap <buffer> <silent> <leader>ie :call <SID>ISCExecute()<CR>
  autocmd FileType indentscript nnoremap <buffer> <silent> <F5> :call <SID>ISCExecute()<CR>
  autocmd FileType indentscript nnoremap <buffer> <silent> <F6> :call <SID>ISCTranspile()<CR>
  autocmd FileType indentscript nnoremap <buffer> <silent> <F7> :call <SID>ISCFormat()<CR>
  autocmd FileType indentscript nnoremap <buffer> <silent> <F8> :call <SID>ISCLint()<CR>
augroup END

command! -buffer ISCFormat call s:ISCFormat()
command! -buffer ISCLint call s:ISCLint()
command! -buffer ISCTranspile call s:ISCTranspile()
command! -buffer ISCExecute call s:ISCExecute()
command! -buffer ISCCheckSyntax call s:ISCCheckSyntax()

let &cpo = s:save_cpo
unlet s:save_cpo
