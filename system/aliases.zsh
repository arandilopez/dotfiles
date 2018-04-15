#
# Default prompt and appearance

# Prompting Options
setopt \
  prompt_cr \
  prompt_subst \

# Color module, should give us access to associative array of colors:
# ${color[red]}
autoload colors;
colors;

IMG_COLORS="*.png=01;35:*.jpg=00;35:*.gif=00;35:*.bmp=00;35:*.ppm=00;35:*.tga=00;35:*.xbm=00;35:*.xpm=00;35:*.tif=00;35:*.pdf=00;35"
SOUND_COLORS='*.mp3=00;35:*.mod=00;35:*.wav=00;35:*.mid=00;35:*.xm=00;35:*.s3m=00;35'
MOVIE_COLORS='*.mpg=00;35:*.avi=00;35:*.mov=00;35'
ARCHIVE_COLORS='*.tar=00;31:*.tgz=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.zip=00;31:*.bz2=00;31:*.rpm=00;31:*.deb=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31'
EXE_COLORS='*.cmd=00;32:*.exe=00;32:*.com=00;32:*.btm=00;32:*.bat=00;32'
CODE_COLORS='*.c=00;33:*.h=00;95:*.gl=00;33:*.cc=00;33:*.cpp=00;33:*.ino=00;33:*.m=00;33:*.php=00;35:*.tex=00;33:*.rb=00;91:*.js=00;33:*.coffee=00;33:*.json=00;93:*.ḧtml=00;103:*.css=00;96:*.scss=00;96:*.less=00;96'

# Understood by GNU ls and used for completion
LS_COLORS="no=00:fi=00:di=00;36:ln=00;35:pi=47;33:so=00;35:bd=47;33;00:cd=47;33;00:or=47;31;00:ex=00;32:${IMG_COLORS}:${SOUND_COLORS}:${MOVIE_COLORS}:${ARCHIVE_COLORS}:${EXE_COLORS}:${CODE_COLORS}";
LS_OPTIONS_GNU=(-F --color -T 0);
export LS_COLORS

# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
case `uname` in
  Darwin)
    if $(gls &>/dev/null)
    then
      alias ls="gls -F --color"
      alias l="gls -lAh --color"
      alias ll="gls -l --color"
      alias la='gls -A --color'
    fi
  ;;
  Linux)
    alias ls='ls $LS_OPTIONS_GNU'
    alias l='ls -lAh'
    alias la='ls -A'
    alias ll='ls -l'
  ;;
esac

alias lgrep="ls | grep"

alias cl='clear'
