" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --vimgrep
  " bind \ (backward slash) to grep shortcut
  command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
  nnoremap \ :Ag<SPACE>
endif
