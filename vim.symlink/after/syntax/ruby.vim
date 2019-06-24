let saved_syntax = b:current_syntax
unlet! b:current_syntax
" Load SQL syntax.
syntax include @SQL syntax/sql.vim
" Restore original syntax.
let b:current_syntax = saved_syntax
unlet! saved_syntax

syn region sqlHeredoc start=/\v\<\<[-~]SQL/ end=/\vSQL/ keepend contains=@SQL
