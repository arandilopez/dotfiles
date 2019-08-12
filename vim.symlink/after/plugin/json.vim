function! DoPrettyJSON()
  let l:origft = &ft
  set ft=
  silent %!python -m json.tool
  silent %<
  1
  exe "set ft=" . l:origft
endfunction
command! PrettyJSON call DoPrettyJSON()
