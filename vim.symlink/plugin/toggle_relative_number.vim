function g:ToggleRelativeNumber()
  if &nu == 1   " if numbering is enable
    set nonu    " disable numbering
    set rnu     " enable relative numbering
  else          " otherwise
    set nornu   " disable relative numbering
    set nu      " and re-enable numbering
  endif

endfunction

nnoremap <silent><leader>tn :call g:ToggleRelativeNumber()<CR>
