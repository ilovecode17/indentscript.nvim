autocmd BufNewFile,BufRead *.isc setfiletype indentscript
autocmd BufNewFile,BufRead *.indentscript setfiletype indentscript
autocmd BufNewFile,BufRead indentscript setfiletype indentscript

function! s:DetectIndentScript()
  if getline(1) =~# '^#!.*indentscript'
    setfiletype indentscript
  endif
endfunction

autocmd BufNewFile,BufRead * call s:DetectIndentScript()
