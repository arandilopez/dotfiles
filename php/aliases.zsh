# Thanks to Oh My ZSH and https://github.com/pi0
#Alias
alias artisan='php artisan'

alias phpunit="vendor/bin/phpunit --color --debug"

# Laravel Homestead alias
# for: homestead up, homestead provision, etc.
# alias homestead='function __homestead() { (cd $HOME/Homestead && vagrant $*); unset -f __homestead; }; __homestead'
function homestead() {
    ( cd ~/Homestead && vagrant $* )
}
