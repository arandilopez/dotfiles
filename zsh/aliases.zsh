alias reload!='source ~/.zshrc'
if [[ $OS_NAME == 'Darwin' ]]; then
  alias pgstart='pg_ctl -D /usr/local/var/postgres start'
  alias pgstop='pg_ctl -D /usr/local/var/postgres stop'
fi
if type nvim > /dev/null 2>&1; then
  alias vim='nvim'
fi
