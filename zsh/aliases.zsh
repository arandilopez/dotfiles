alias reload!='source ~/.zshrc'
if [[ $OS_NAME == 'Darwin' ]]; then
  alias pgstart='pg_ctl -D /usr/local/var/postgres start'
  alias pgstop='pg_ctl -D /usr/local/var/postgres stop'
fi
if type nvim > /dev/null 2>&1; then
  alias vim='nvim'
fi

if type tmux > /dev/null 2>&1; then
  alias tma="tmux attach"
fi

if type bat > /dev/null 2>&1; then
  alias cat='bat'
fi

if type rg > /dev/null 2>&1; then
  alias grep='rg'
fi

if type fzf > /dev/null 2>&1; then
  alias f='fzf'
fi

if type yazi > /dev/null 2>&1; then
  alias yy='yazi'
fi
