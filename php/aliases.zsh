# Laravel Homestead alias
# for: homestead up, homestead provision, etc.
alias homestead='function __homestead() { (cd $HOME/Homestead && vagrant $*); unset -f __homestead; }; __homestead'
