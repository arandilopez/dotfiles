export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
export PATH="./bin:/usr/local/bin:/usr/local/sbin:$ZSH/bin:$HOME/.bin:/usr/local/texlive/2016/bin/x86_64-darwin:$PATH"

export SOCKET_DIR="/usr/local/var/www"
export LOG_DIR="/usr/local/var/log/nginx"

if [ "$(uname -s)" == "Linux" ]; then
  export PATH="$HOME/.nodenv/bin:$PATH"
  export PATH="$HOME/.nodenv/plugins/node-build/bin:$PATH"

  export PATH="$HOME/.rbenv/bin:$PATH"
  export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
fi
