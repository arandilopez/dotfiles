if !exists(':Startify')
  finish
endif


let g:startify_ascii = [
      \"                               ____   ",
      \"       ,---.  ,--,           ,'  , `. ",
      \"      /__./|,--.'|        ,-+-,.' _ | ",
      \" ,---.;  ; ||  |,      ,-+-. ;   , || ",
      \"/___/ \\  | |`--'_     ,--.'|'   |  || ",
      \"\\   ;  \\ ' |,' ,'|   |   |  ,', |  |, ",
      \" \\   \\  \\: |'  | |   |   | /  | |--'  ",
      \"  ;   \\  ' .|  | :   |   : |  | ,     ",
      \"   \\   \\   ''  : |__ |   : |  |/      ",
      \"    \\   `  ;|  | '.'||   | |`-'       ",
      \"     :   \\ |;  :    ;|   ;/           ",
      \"      '---\" |  ,   / '---'            ",
      \"             ---`-'                   ",
      \]

let g:startify_custom_header = 'map(g:startify_ascii + startify#fortune#quote(), "\"   \".v:val")'
let g:startify_lists = [
      \ { 'header': ['   MRU '. getcwd()], 'type': 'dir' },
      \ ]

let g:startify_skiplist = [
      \ 'COMMIT_EDITMSG',
      \ '^/tmp',
      \ escape(fnamemodify(resolve($VIMRUNTIME), ':p'), '\') .'doc',
      \ 'bundle/.*/doc',
      \ ]

let g:startify_files_number = 15
let g:startify_padding_left = 3
let g:startify_relative_path = 1
let g:startify_fortune_use_unicode = 1
let g:startify_change_to_vcs_root = 1
" let g:startify_session_autoload = 1
let g:startify_update_oldfiles = 1
let g:startify_use_env = 0

hi! link StartifyHeader Title
hi! link StartifyFile Directory
hi! link StartifyPath LineNr
hi! link StartifySlash StartifyPath
hi! link StartifyBracket StartifyPath
hi! link StartifyNumber Title

