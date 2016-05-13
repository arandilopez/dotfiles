alias reload!='. ~/.zshrc'

if (( $+commands[ionic] ))
then
  alias apk-sign='ionic build --release android -- --keystore=~/Code/arandilopez.keystore --storePassword=arandilopez --alias=arandilopez --password=arandilopez';
fi
