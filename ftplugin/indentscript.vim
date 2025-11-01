if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal commentstring=#%s
setlocal comments=:#,://,s1:/*,mb:*,ex:*/
setlocal formatoptions-=t
setlocal formatoptions+=croql
setlocal suffixesadd=.isc
setlocal includeexpr=substitute(v:fname,'\\.','/','g')

setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal expandtab
setlocal autoindent
setlocal smartindent

setlocal textwidth=88
setlocal colorcolumn=89

setlocal foldmethod=indent
setlocal foldnestmax=10
setlocal foldlevel=1
setlocal foldenable

setlocal iskeyword=@,48-57,_,192-255,$

setlocal complete+=k
setlocal completeopt=menuone,noselect,preview

if has('linebreak')
  setlocal breakindent
  setlocal breakindentopt=shift:4
endif

if has('conceal')
  setlocal conceallevel=0
  setlocal concealcursor=
endif

setlocal matchpairs+=<:>

function! s:ISCMatchWords()
  let b:match_words = '\<def\>:\<return\>'
  let b:match_words .= ',\<class\>:\<end\>'
  let b:match_words .= ',\<if\>:\<elif\>:\<else\>'
  let b:match_words .= ',\<for\>:\<break\>:\<continue\>'
  let b:match_words .= ',\<while\>:\<break\>:\<continue\>'
  let b:match_words .= ',\<try\>:\<except\>:\<finally\>'
  let b:match_words .= ',\<with\>:\<end\>'
  let b:match_words .= ',{:},\[:\],(:)'
endfunction

call s:ISCMatchWords()

function! s:ISCTextObjFunction(inner)
  let l:start_line = search('^\s*def\s', 'bnW')
  if l:start_line == 0
    return
  endif
  
  let l:start_indent = indent(l:start_line)
  let l:end_line = l:start_line
  
  while l:end_line < line('$')
    let l:end_line += 1
    let l:line = getline(l:end_line)
    
    if l:line =~# '^\s*$'
      continue
    endif
    
    if indent(l:end_line) <= l:start_indent && l:line !~# '^\s*#'
      let l:end_line -= 1
      break
    endif
  endwhile
  
  if a:inner
    let l:start_line += 1
    while getline(l:start_line) =~# '^\s*$'
      let l:start_line += 1
    endwhile
    
    while getline(l:end_line) =~# '^\s*$'
      let l:end_line -= 1
    endwhile
  endif
  
  execute 'normal! ' . l:start_line . 'GV' . l:end_line . 'G'
endfunction

function! s:ISCTextObjClass(inner)
  let l:start_line = search('^\s*class\s', 'bnW')
  if l:start_line == 0
    return
  endif
  
  let l:start_indent = indent(l:start_line)
  let l:end_line = l:start_line
  
  while l:end_line < line('$')
    let l:end_line += 1
    let l:line = getline(l:end_line)
    
    if l:line =~# '^\s*$'
      continue
    endif
    
    if indent(l:end_line) <= l:start_indent && l:line !~# '^\s*#'
      let l:end_line -= 1
      break
    endif
  endwhile
  
  if a:inner
    let l:start_line += 1
    while getline(l:start_line) =~# '^\s*$'
      let l:start_line += 1
    endwhile
    
    while getline(l:end_line) =~# '^\s*$'
      let l:end_line -= 1
    endwhile
  endif
  
  execute 'normal! ' . l:start_line . 'GV' . l:end_line . 'G'
endfunction

vnoremap <silent> <buffer> af :<C-U>call <SID>ISCTextObjFunction(0)<CR>
vnoremap <silent> <buffer> if :<C-U>call <SID>ISCTextObjFunction(1)<CR>
vnoremap <silent> <buffer> ac :<C-U>call <SID>ISCTextObjClass(0)<CR>
vnoremap <silent> <buffer> ic :<C-U>call <SID>ISCTextObjClass(1)<CR>

onoremap <silent> <buffer> af :call <SID>ISCTextObjFunction(0)<CR>
onoremap <silent> <buffer> if :call <SID>ISCTextObjFunction(1)<CR>
onoremap <silent> <buffer> ac :call <SID>ISCTextObjClass(0)<CR>
onoremap <silent> <buffer> ic :call <SID>ISCTextObjClass(1)<CR>

function! s:ISCJumpToDefinition()
  let l:word = expand('<cword>')
  let l:pattern = '^\s*\(def\|class\)\s\+' . l:word . '\>'
  
  let l:pos = getpos('.')
  
  call cursor(1, 1)
  let l:found = search(l:pattern, 'W')
  
  if l:found == 0
    call setpos('.', l:pos)
    echohl WarningMsg
    echo "Definition not found: " . l:word
    echohl None
  endif
endfunction

function! s:ISCJumpToUsage()
  let l:word = expand('<cword>')
  let l:pattern = '\<' . l:word . '\>'
  
  let l:pos = getpos('.')
  
  let l:found = search(l:pattern, 'W')
  
  if l:found == 0
    call setpos('.', l:pos)
    echohl WarningMsg
    echo "No more usages found: " . l:word
    echohl None
  endif
endfunction

nnoremap <silent> <buffer> gd :call <SID>ISCJumpToDefinition()<CR>
nnoremap <silent> <buffer> gD :call <SID>ISCJumpToDefinition()<CR>
nnoremap <silent> <buffer> <C-]> :call <SID>ISCJumpToDefinition()<CR>
nnoremap <silent> <buffer> <leader>u :call <SID>ISCJumpToUsage()<CR>

function! s:ISCInsertDocstring()
  let l:line = getline('.')
  
  if l:line =~# '^\s*def\s'
    let l:indent = indent('.')
    let l:docstring = repeat(' ', l:indent + 4) . '"""'
    
    call append(line('.'), [l:docstring, repeat(' ', l:indent + 4) . '"""'])
    call cursor(line('.') + 1, col('$'))
    
    startinsert!
  else
    echohl WarningMsg
    echo "Not on a function definition line"
    echohl None
  endif
endfunction

nnoremap <silent> <buffer> <leader>ds :call <SID>ISCInsertDocstring()<CR>

function! s:ISCToggleComment()
  let l:line = getline('.')
  
  if l:line =~# '^\s*#'
    let l:new_line = substitute(l:line, '^\(\s*\)#\s*', '\1', '')
  else
    let l:indent = matchstr(l:line, '^\s*')
    let l:new_line = l:indent . '# ' . trim(l:line)
  endif
  
  call setline('.', l:new_line)
endfunction

nnoremap <silent> <buffer> <leader>c :call <SID>ISCToggleComment()<CR>
vnoremap <silent> <buffer> <leader>c :call <SID>ISCToggleComment()<CR>

function! s:ISCSelectBlock()
  let l:start_line = line('.')
  let l:start_indent = indent(l:start_line)
  
  let l:end_line = l:start_line
  while l:end_line < line('$')
    let l:end_line += 1
    let l:line = getline(l:end_line)
    
    if l:line =~# '^\s*$'
      continue
    endif
    
    if indent(l:end_line) < l:start_indent
      let l:end_line -= 1
      break
    endif
  endwhile
  
  execute 'normal! V' . (l:end_line - l:start_line) . 'j'
endfunction

nnoremap <silent> <buffer> vab :call <SID>ISCSelectBlock()<CR>

function! s:ISCFoldHeader()
  let l:line = getline(v:foldstart)
  let l:line_count = v:foldend - v:foldstart + 1
  
  let l:indent = indent(v:foldstart)
  let l:marker = repeat(' ', l:indent) . '▸ '
  
  let l:text = substitute(l:line, '^\s*', '', '')
  
  return l:marker . l:text . ' (' . l:line_count . ' lines) '
endfunction

setlocal foldtext=s:ISCFoldHeader()

inoremap <silent> <buffer> <Tab> <C-R>=<SID>ISCSmartTab()<CR>

function! s:ISCSmartTab()
  if pumvisible()
    return "\<C-N>"
  endif
  
  let l:col = col('.') - 1
  
  if l:col == 0 || getline('.')[l:col - 1] =~# '\s'
    return "\<Tab>"
  else
    return "\<C-X>\<C-O>"
  endif
endfunction

let b:undo_ftplugin = "setl cms< com< fo< sua< inex< ts< sw< sts< et< ai< si< tw< cc< fdm< fdn< fdl< fen< isk< cpt< cot< bri< briopt< cocu< cole< mp< mw<"
let b:undo_ftplugin .= " | unlet! b:match_words"
let b:undo_ftplugin .= " | execute 'silent! nunmap <buffer> gd'"
let b:undo_ftplugin .= " | execute 'silent! nunmap <buffer> gD'"
let b:undo_ftplugin .= " | execute 'silent! nunmap <buffer> <C-]>'"
let b:undo_ftplugin .= " | execute 'silent! nunmap <buffer> <leader>u'"
let b:undo_ftplugin .= " | execute 'silent! nunmap <buffer> <leader>ds'"
let b:undo_ftplugin .= " | execute 'silent! nunmap <buffer> <leader>c'"
let b:undo_ftplugin .= " | execute 'silent! vnoremap <buffer> <leader>c'"
let b:undo_ftplugin .= " | execute 'silent! nunmap <buffer> vab'"

let &cpo = s:cpo_save
unlet s:cpo_save
