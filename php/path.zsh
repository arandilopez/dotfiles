case `uname` in
  Linux )
    export PATH="$HOME/.config/composer/vendor/bin:$PATH"
    ;;
  Darwin )
    export PATH="$HOME/.composer/vendor/bin:$PATH"
    ;;
esac
