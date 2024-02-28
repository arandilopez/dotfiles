# Pipe my public key to my clipboard.
case $OS_NAME in
  Darwin )
    alias pubkey="more ~/.ssh/id_ed25519.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
    ;;
  Linux )
    alias pubkey="xclip -sel clip < ~/.ssh/id_ed25519.pub && echo '=> Public key copied to pasteboard.'"
    ;;
esac
