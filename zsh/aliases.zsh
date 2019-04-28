alias reload!='source ~/.zshrc'
if [[ $OS_NAME == 'Darwin' ]]; then
  alias pgstart='pg_ctl -D /usr/local/var/postgres start'
  alias pgstop='pg_ctl -D /usr/local/var/postgres stop'
fi
