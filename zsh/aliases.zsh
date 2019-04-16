alias reload!='source ~/.zshrc'
if [[ `uname` == 'Darwin' ]]; then
  alias pgstart='pg_ctl -D /usr/local/var/postgres start'
  alias pgstop='pg_ctl -D /usr/local/var/postgres stop'
fi
