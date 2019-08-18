" if !exists(':Ctrlp')
"   finish
" endif

" Ctrlp custom open file logic
function! OpenFileInEmptyBufferOrNewTab(action, line)
  call ctrlp#exit() " Cerrar el panel de ctrlp para ver el tab o buffer actual
  let action = a:action
  " Si la accion es abrir sobre el buffer actual, pero este no es un buffer
  " vacio, entonces abrirlo sobre un tab.
  " Esto es un comportamiento como en otros editores de texto.
  if action == 'e' && bufname("%") != ''
    let action = 't'
  endif
  call call('ctrlp#acceptfile', [action, a:line])
endfunction
" ctrlp settings
let g:ctrlp_open_new_file = 't'
let g:ctrlp_open_func = { 'files': 'OpenFileInEmptyBufferOrNewTab' }
let g:ctrlp_map = '<C-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_switch_buffer = 'ET'
let g:ctrlp_user_command = {
	\ 'types': {
		\ 1: ['.git', 'cd %s && git ls-files -co --exclude-standard'],
		\ 2: ['.hg', 'hg --cwd %s locate -I .'],
		\ },
	\ 'fallback': 'find %s -type f'
	\ }

let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]\.(git|hg|svn)$',
      \ 'file': '\v\.(exe|so|dll)$',
      \ }
