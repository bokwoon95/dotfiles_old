init () {
  echo "hello! this is https://raw.githubusercontent.com/bokwoon95/dotfiles/master/init.sh"
  bash -c "$(curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/bokwoon95/dotfiles/master/gitconfig.sh)"
  echo "I reached here!"
}
init
