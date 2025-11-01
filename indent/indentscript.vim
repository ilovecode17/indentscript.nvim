if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal indentexpr=GetIndentScriptIndent(v:lnum)
setlocal indentkeys=!^F,o,O,<:>,0),0],0},=elif,=else,=except,=finally
setlocal nosmartindent
setlocal autoindent

let s:block_start_keywords = '\v^\s*(def|class|if|elif|else|for|while|try|except|finally|with|async)'
let s:dedent_keywords = '\v^\s*(return|pass|break|continue|raise)'
let s:dedent_next_keywords = '\v^\s*(elif|else|except|finally)'

function! GetIndentScriptIndent(lnum)
  if a:lnum == 1
    return 0
  endif
  
  let l:prev_lnum = prevnonblank(a:lnum - 1)
  
  if l:prev_lnum == 0
    return 0
  endif
  
  let l:prev_line = getline(l:prev_lnum)
  let l:curr_line = getline(a:lnum)
  let l:prev_indent = indent(l:prev_lnum)
  
  if l:prev_line =~# '^\s*#' || l:prev_line =~# '^\s*//'
    return l:prev_indent
  endif
  
  if l:curr_line =~# '^\s*#' || l:curr_line =~# '^\s*//'
    return indent(a:lnum)
  endif
  
  if l:curr_line =~# '^\s*"""' || l:curr_line =~# "^\\s*'''"
    return indent(a:lnum)
  endif
  
  if s:IsInMultilineString(a:lnum)
    return indent(a:lnum)
  endif
  
  if l:curr_line =~# s:dedent_next_keywords
    return l:prev_indent - shiftwidth()
  endif
  
  if l:curr_line =~# '^\s*}'
    return l:prev_indent - shiftwidth()
  endif
  
  if l:curr_line =~# '^\s*]'
    return l:prev_indent - shiftwidth()
  endif
  
  if l:curr_line =~# '^\s*)'
    return s:GetMatchingParenIndent(a:lnum)
  endif
  
  if l:prev_line =~# ':$'
    return l:prev_indent + shiftwidth()
  endif
  
  if l:prev_line =~# '{$'
    return l:prev_indent + shiftwidth()
  endif
  
  if l:prev_line =~# '\[$'
    return l:prev_indent + shiftwidth()
  endif
  
  if l:prev_line =~# '($'
    return l:prev_indent + shiftwidth()
  endif
  
  if l:prev_line =~# s:block_start_keywords && l:prev_line =~# ':$'
    return l:prev_indent + shiftwidth()
  endif
  
  if l:prev_line =~# '\\\s*$'
    return l:prev_indent + shiftwidth()
  endif
  
  if s:IsInParens(a:lnum)
    return s:GetParenIndent(a:lnum)
  endif
  
  if l:prev_line =~# s:dedent_keywords
    let l:block_start = s:FindBlockStart(l:prev_lnum)
    if l:block_start > 0
      return indent(l:block_start)
    endif
  endif
  
  if l:prev_line =~# ',\s*$'
    return l:prev_indent
  endif
  
  if l:prev_line =~# '\(+\|-\|\*\|/\|%\|=\|<\|>\|&\||\)\s*$'
    return l:prev_indent + shiftwidth()
  endif
  
  return l:prev_indent
endfunction

function! s:IsInMultilineString(lnum)
  let l:lnum = a:lnum - 1
  let l:in_string = 0
  
  while l:lnum > 0
    let l:line = getline(l:lnum)
    
    if l:line =~# '^\s*"""' || l:line =~# "^\\s*'''"
      let l:in_string = !l:in_string
    endif
    
    let l:lnum -= 1
  endwhile
  
  return l:in_string
endfunction

function! s:IsInParens(lnum)
  let l:lnum = a:lnum - 1
  let l:paren_count = 0
  
  while l:lnum > 0
    let l:line = getline(l:lnum)
    
    let l:open_parens = len(split(l:line, '(', 1)) - 1
    let l:close_parens = len(split(l:line, ')', 1)) - 1
    
    let l:paren_count += l:open_parens - l:close_parens
    
    if l:paren_count > 0
      return 1
    endif
    
    let l:lnum -= 1
  endwhile
  
  return 0
endfunction

function! s:GetParenIndent(lnum)
  let l:lnum = a:lnum - 1
  let l:paren_count = 0
  
  while l:lnum > 0
    let l:line = getline(l:lnum)
    
    let l:open_parens = len(split(l:line, '(', 1)) - 1
    let l:close_parens = len(split(l:line, ')', 1)) - 1
    
    let l:paren_count += l:close_parens - l:open_parens
    
    if l:open_parens > l:close_parens
      let l:paren_pos = match(l:line, '(')
      return l:paren_pos + 1
    endif
    
    let l:lnum -= 1
  endwhile
  
  return indent(a:lnum - 1)
endfunction

function! s:GetMatchingParenIndent(lnum)
  let l:lnum = a:lnum - 1
  let l:paren_count = 1
  
  while l:lnum > 0
    let l:line = getline(l:lnum)
    
    let l:open_parens = len(split(l:line, '(', 1)) - 1
    let l:close_parens = len(split(l:line, ')', 1)) - 1
    
    let l:paren_count += l:close_parens - l:open_parens
    
    if l:paren_count == 0
      return indent(l:lnum)
    endif
    
    let l:lnum -= 1
  endwhile
  
  return indent(a:lnum - 1)
endfunction

function! s:FindBlockStart(lnum)
  let l:lnum = a:lnum - 1
  let l:target_indent = indent(a:lnum)
  
  while l:lnum > 0
    let l:line = getline(l:lnum)
    let l:curr_indent = indent(l:lnum)
    
    if l:curr_indent < l:target_indent && l:line =~# s:block_start_keywords
      return l:lnum
    endif
    
    let l:lnum -= 1
  endwhile
  
  return 0
endfunction

function! s:GetPrevNonBlankLine(lnum)
  let l:lnum = a:lnum - 1
  
  while l:lnum > 0
    let l:line = getline(l:lnum)
    
    if l:line !~# '^\s*$' && l:line !~# '^\s*#' && l:line !~# '^\s*//'
      return l:lnum
    endif
    
    let l:lnum -= 1
  endwhile
  
  return 0
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
