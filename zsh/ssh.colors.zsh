# iTerm2 tab color commands
# http://code.google.com/p/iterm2/wiki/ProprietaryEscapeCodes

if [[ -n "$ITERM_SESSION_ID" ]]; then
  tab-color() {
    echo -ne "\033]6;1;bg;red;brightness;$1\a"
    echo -ne "\033]6;1;bg;green;brightness;$2\a"
    echo -ne "\033]6;1;bg;blue;brightness;$3\a"
  }
  # tab-red() { tab-color 255 0 0 }
  # tab-green() { tab-color 0 255 0 }
  # tab-blue() { tab-color 0 0 255 }
  tab-reset() { echo -ne "\033]6;1;bg;*;default\a" }

  function iterm2_tab_precmd() {
    tab-reset
  }

  function iterm2_tab_preexec() {
    if [[ "$1" =~ "ssh" ]]; then
      tab-color 255 80 120
    elif [[ "$1" =~ "bundle" ]]; then
      tab-color 255 160 80
    elif [[ "$1" =~ "rails" ]]; then
      tab-color 0 160 255
    else
      tab-color 255 255 160
    fi
  }

  autoload -U add-zsh-hook
  add-zsh-hook precmd  iterm2_tab_precmd
  add-zsh-hook preexec iterm2_tab_preexec
fi
