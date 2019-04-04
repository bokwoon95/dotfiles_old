#!/bin/bash
read -p $'Initialize macOS settings? Reply "y" to proceed (leave empty for "n")\n> ' INITALIZE_MAC_SETTINGS
read -p $'Would you like to clean the dock entirely? Reply "YES THE DOCK IS FULL OF SHIT RN" to proceed (leave empty for "n")\n> ' CLEAN_DOCK
read -p $'Open new apps? Reply "y" to proceed (leave empty for "n")\n> ' OPEN_NEW

PACKAGES=(
vim
the_silver_searcher
fzf
ffmpeg
youtube-dl
neovim
python3
tmux
tig
figlet
asciinema
fd
imagemagick
imagemagick@6
ipython
pass
rmtrash
thefuck
wget
emacs
rlwrap #for mit-scheme
mit-scheme
cmake
sshfs
unison
cmus
)
PACKAGES_LEN=${#PACKAGES[@]}

CASKS=(
spectacle
box-sync
the-unarchiver
insomniax
disk-inventory-x
google-chrome
firefox
whatsapp
evernote
kitty
skim
emacs-mac
#folx
handbrake
rcdefaultapp #change default app for everything
vlc
vox
dash
keycastr
android-file-transfer
)
CASKS_LEN=${#CASKS[@]}

FONTS=(
# font-source-code-pro
# font-vollkorn
)

echo "Starting bootstrapping"

# Ask for the administrator password upfront
sudo -v

if [[ $INITALIZE_MAC_SETTINGS == "y" ]]; then
  sudo ./colorschemes/osx_settings.sh
fi

# Install zsh (needs password prompt)
if [[ $SHELL = "/bin/bash" ]]; then
  chsh -s $(which zsh)
elif [[ $SHELL = "/bin/zsh" ]]; then
  echo "Login shell is already zsh"
fi

#https://outlook.com/u.nus.edu
if [[ ! -d /Applications/Opera.app ]]; then
  #Download Opera from their shitty javascript site
  open https://www.opera.com/computer
fi
# if [[ ! -d /Applications/Folx.app ]]; then
#   #Needed for Contexts licence file & Folx activation code
#   open https://www.google.com/gmail
# fi
if [[ ! -d "/Applications/Microsoft Word.app" ]]; then
  #Download MS Office 2016
  open "https://www.office.com/?auth=2&home=1"
fi

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if [[ ! -d /Applications/Contexts.app ]]; then
  echo "Contexts: not installed"
  echo "Installing Contexts..."
  dl=$(
  curl https://contexts.co |
    sed -n 's|^.*<a class="button button--download" href="\(.*\)" id="button-download-top">Download Free Trial</a>.*$|\1|p'
  )
  curl -L "https://contexts.co$dl" -o ~/Downloads/contexts.dmg
  hdiutil attach contexts.dmg
  yes | cp -rf /Volumes/Contexts/Contexts.app /Applications
  hdiutil detach "/Volumes/Contexts"
  rm ~/Downloads/contexts.dmg
else
  echo "Contexts already installed"
fi

# Update homebrew recipes
echo "Updating Homebrew, prepare for some wait..."
brew update
brew upgrade

brew tap railwaycat/emacsmacport
brew tap thefox/brewery #cmus-control
# Important packages I want to download ASAP
brew cask install dropbox macvim iterm2 osxfuse

echo "Installing packages..."
brew install ${PACKAGES[@]}
# for i in $(seq 1 $PACKAGES_LEN); do
#   brew install ${PACKAGES[$i]}
# done
pip3 install neovim

echo "Installing cask apps..."
## For some reason this asynchronous way of downloading often runs into problems. Changing to the synchronous way instead.
# for i in $(seq 1 $CASKS_LEN); do
#   brew cask install ${CASKS[$i]} &
#   # brew cask info ${CASKS[$i]} &
# done
# brew cask install --appdir=/Applications megasync &
# wait
brew cask install ${CASKS[@]}
brew install cmus-control
brew services start thefox/brewery/cmus-control

echo "Installing fonts..."
brew tap caskroom/fonts
# brew cask install ${FONTS[@]}

# Install fonts from ~/.vim/fonts
# -z tests if the output of 'find' is zero
if [[ -z $(find ~/Library/Fonts/Vollkorn*) ]]; then
  open ~/.vim/fonts/Vollkorn/*
fi
if [[ -z $(find ~/Library/Fonts/SourceCodePro*) ]]; then
  open ~/.vim/fonts/Source\ Code\ Pro/*
fi
if [[ -z $(find ~/Library/Fonts/Go-Mono*) ]]; then
  open ~/.vim/fonts/Go\ Font/*
fi

# Install Scientific Calculator for Dashboard
if [[ $OPEN_NEW == "y" && -f ~/.vim/ecalc_calculator.zip ]]; then
  cd ~/Downloads && unzip ~/.vim/ecalc_calculator.zip
  open eCalc_Scientific.wdgt
fi

echo "Cleaning up Homebrew, prepare for some wait..."
brew cleanup

# Activate fzf keybindings
if [[ "$CLEAN_DOCK" == "YES THE DOCK IS FULL OF SHIT RN" ]]; then
  printf "Y\nY\nY\n" | /usr/local/opt/fzf/install
fi

#vim-plug for vim & neovim
#curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
#  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
#curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
#  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install zsh-autosuggestions
if [[ ! -d ~/.zsh/zsh-autosuggestions ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

# Install .emacs.d
if [[ ! -d ~/.emacs.d ]]; then
  git clone https://github.com/bokwoon95/.emacs.d ~/.emacs.d
fi

# Adjust Macvim's fullscreened height
defaults write org.vim.MacVim MMTextInsetTop 4
defaults write org.vim.MacVim MMTextInsetBottom 8
defaults write org.vim.MacVim MMTextInsetLeft 1
defaults write org.vim.MacVim MMTextInsetRight 4

# git QoL
# git config --global credential.helper osxkeychain
# git config --global core.excludesfile '~/.gitignore'

#====================#
# Establish Symlinks #
#====================#
# note that 'unlink' is simply an alias for 'rm' for OSX
echo ""
echo "Establishing Symlinks:"

#~/.zshrc
if [[ -f ~/.zshrc && ! -L ~/.zshrc ]]; then
  echo "existing ~/.zshrc found, renaming it to ~/.zshrc.bak"
  rm ~/.zshrc.bak
  mv ~/.zshrc ~/.zshrc.bak
fi
echo "symlinking ~/.zshrc@"
if [[ -L ~/.zshrc ]]; then
  unlink ~/.zshrc
fi
ln -s ~/.vim/.zshrc ~/.zshrc

#~/.bashrc
if [[ -f ~/.bashrc && ! -L ~/.bashrc ]]; then
  echo "existing ~/.bashrc found, renaming it to ~/.bashrc.bak"
  rm ~/.bashrc.bak
  mv ~/.bashrc ~/.bashrc.bak
fi
echo "symlinking ~/.bashrc@"
if [[ -L ~/.bashrc ]]; then
  unlink ~/.bashrc
fi
ln -s ~/.vim/.bashrc ~/.bashrc

#~/.tmux.conf
if [[ -f ~/.tmux.conf && ! -L ~/.tmux.conf ]]; then
  echo "existing ~/.tmux.conf found, renaming it to ~/.tmux.conf.bak"
  rm ~/.tmux.conf.bak
  mv ~/.tmux.conf ~/.tmux.conf.bak
fi
echo "symlinking ~/.tmux.conf@"
if [[ -L ~/.tmux.conf ]]; then
  unlink ~/.tmux.conf
fi
ln -s ~/.vim/.tmux.conf ~/.tmux.conf

#~/.config/nvim/init.vim
mkdir -p ~/.config/nvim/
if [[ -f ~/.config/nvim/init.vim && ! -L ~/.config/nvim/init.vim ]]; then
  echo "existing ~/config/nvim/init.vim found, renaming it to ~/config/nvim/init.vim.bak"
  rm ~/config/nvim/init.vim.bak
  mv ~/config/nvim/init.vim ~/config/nvim/init.vim.bak
fi
echo "symlinking ~/.config/nvim/init.vim@"
if [[ -L ~/.config/nvim/init.vim ]]; then
  unlink ~/.config/nvim/init.vim
fi
ln -s ~/.vim/vimrc ~/.config/nvim/init.vim

#~/.config/nvim/after
if [[ -d ~/.config/nvim/after && ! -L ~/.config/nvim/after ]]; then
  echo "existing ~/config/nvim/after found, renaming it to ~/config/nvim/after.bak"
  rm -rf ~/config/nvim/after.bak
  mv ~/config/nvim/after ~/config/nvim/after.bak
fi
echo "symlinking ~/.config/nvim/after@"
if [[ -L ~/.config/nvim/after ]]; then
  unlink ~/.config/nvim/after
fi
ln -s ~/.vim/after ~/.config/nvim/after

#~/.gitconfig
if [[ -f ~/.gitconfig && ! -L ~/.gitconfig ]]; then
  echo "existing ~/.gitconfig found, renaming it to ~/.gitconfig.bak"
  rm ~/.gitconfig.bak
  mv ~/.gitconfig ~/.gitconfig.bak
fi
echo "symlinking ~/.gitconfig@"
if [[ -L ~/.gitconfig ]]; then
  unlink ~/.gitconfig
fi
ln -s ~/.vim/gitconfig-mac ~/.gitconfig

#~/.gitignore
if [[ -f ~/.gitignore && ! -L ~/.gitignore ]]; then
  echo "existing ~/.gitignore found, renaming it to ~/.gitignore.bak"
  rm ~/.gitignore.bak
  mv ~/.gitignore ~/.gitignore.bak
fi
echo "symlinking ~/.gitignore@"
if [[ -L ~/.gitignore ]]; then
  unlink ~/.gitignore
fi
ln -s ~/.vim/gitignore-mac ~/.gitignore

#~/.hammerspoon/init.lua
if [[ -f ~/.hammerspoon/init.lua && ! -L ~/.hammerspoon/init.lua ]]; then
  echo "existing ~/.hammerspoon/init.lua found, renaming it to ~/.hammerspoon/init.lua.bak"
  rm ~/.hammerspoon/init.lua.bak
  mv ~/.hammerspoon/init.lua ~/.hammerspoon/init.lua.bak
fi
echo "symlinking ~/.hammerspoon/init.lua@"
if [[ -L ~/.hammerspoon/init.lua ]]; then
  unlink ~/.hammerspoon/init.lua
fi
ln -s ~/.vim/init.lua ~/.hammerspoon/init.lua

#~/.local/bin/
if [[ ! -d ~/.local/bin/ ]]; then
  mkdir -p ~/.local/bin
fi

#~/.local/bin/sshrc
if [[ -f ~/.local/bin/sshrc && ! -L ~/.local/bin/sshrc ]]; then
  echo "existing ~/.local/bin/sshrc found, renaming it to ~/.local/bin/sshrc.bak"
  rm ~/.local/bin/sshrc.bak
  mv ~/.local/bin/sshrc ~/.local/bin/sshrc.bak
fi
echo "symlinking ~/.local/bin/sshrc@"
if [[ -L ~/.local/bin/sshrc ]]; then
  unlink ~/.local/bin/sshrc
fi
ln -s ~/.vim/sshrc ~/.local/bin/sshrc

#~/.config/nvim/Ultisnips
if [[ -f ~/.config/nvim/Ultisnips && ! -L ~/.config/nvim/Ultisnips ]]; then
  echo "existing ~/.config/nvim/Ultisnips found, renaming it to ~/.config/nvim/Ultisnips.bak"
  rm ~/.config/nvim/Ultisnips.bak
  mv ~/.config/nvim/Ultisnips ~/.config/nvim/Ultisnips.bak
fi
echo "symlinking ~/.config/nvim/Ultisnips@"
if [[ -L ~/.config/nvim/Ultisnips ]]; then
  unlink ~/.config/nvim/Ultisnips
fi
ln -s ~/.vim/Ultisnips ~/.config/nvim/Ultisnips

#~/.config/cmus/rc
mkdir -p ~/.config/cmus/
if [[ -f ~/.config/cmus/rc && ! -L ~/.config/cmus/rc ]]; then
  echo "existing ~/.config/cmus/rc found, renaming it to ~/.config/cmus/rc.bak"
  rm ~/.config/cmus/rc.bak
  mv ~/.config/cmus/rc ~/.config/cmus/rc.bak
fi
echo "symlinking ~/.config/cmus/rc@"
if [[ -L ~/.config/cmus/rc ]]; then
  unlink ~/.config/cmus/rc
fi
ln -s ~/.vim/cmusrc ~/.config/cmus/rc

#~/.config/kitty/kitty.conf
if [[ ! -f ~/.config/kitty/kitty.conf ]]; then
  echo "copying ~/.vim/kitty.conf to ~/.config/kitty/kitty.conf"
  cp ~/.vim/kitty.conf ~/.config/kitty/kitty.conf
fi

#~/vim
if [[ ! -f ~/vim ]]; then
  echo "symlinking ~/vim@"
  ln -s ~/.vim ~/vim
fi

#~/emacs.d
if [[ ! -f ~/emacs.d ]]; then
  echo "symlinking ~/emacs.d@"
  ln -s ~/.emacs.d ~/emacs.d
fi

#~/.config/flake8
if [[ -f ~/.config/flake8 && ! -L ~/.config/flake8 ]]; then
  echo "existing ~/.config/flake8 found, renaming it to ~/.config/flake8.bak"
  rm ~/.config/flake8.bak
  mv ~/.config/flake8 ~/.config/flake8.bak
fi
echo "symlinking ~/.config/flake8@"
mkdir -p ~/.config
ln -s ~/.vim/flake8 ~/.config/flake8

#=======================#
# Download Applications #
#=======================#
echo ""
echo "Installing Applications:"

if [[ ! -d /Applications/Hammerspoon.app ]]; then
  echo "Hammerspoon: not installed"
  echo "Installing Hammerspoon..."
  gh=$(
  curl https://github.com/Hammerspoon/hammerspoon/releases/latest |
    sed -n "s:^.*href=\"\(.*\)\".*$:\1:p"
  )
  dl=$(
  curl $gh |
    tr '\n' ' ' |
    sed -n 's:^.*\(<ul class="mt-1 mt-md-2">.*</ul>\).*:\1:p' |
    perl -pe 's|^.*?<a href="(.*?)" rel="nofollow" class="d-flex flex-items-center">.*?$|\1|'
  )
  curl -L "https://github.com$dl" -o ~/Downloads/hammerspoon.zip
  unzip ~/Downloads/hammerspoon.zip
  rm ~/Downloads/hammerspoon.zip
  yes | cp -rf ~/Downloads/Hammerspoon.app /Applications
  rm -rf ~/Downloads/Hammerspoon.app
else
  echo "Hammerspoon already installed"
fi

if [[ ! -d "/Applications/Opera.app" ]]; then
  echo "Opera: not installed"
  if [[ -f ~/Downloads/OperaSetup.zip ]]; then
    echo "Installing Opera..."
    unzip ~/Downloads/OperaSetup.zip
    nohup ~/Downloads/Opera\ Installer.app/Contents/MacOS/Opera\ Installer &>/dev/null &
    rm OperaSetup.zip
  fi
else
  echo "Opera already installed"
fi

if [[ ! -d "/Applications/Microsoft Word.app" ]]; then
  echo "Microsoft Word not installed"
  for f in ~/Downloads/Microsoft_Office_*_Installer.pkg; do
    [ -e "$f" ] && msword=1 || msword=0
    break
  done
  if [[ "$msword" -eq "1" ]]; then
    echo "Installing Microsoft Word..."
    open ~/Downloads/Microsoft_Office_*_Installer.pkg
  fi
else
  echo "Microsoft Word already installed"
fi

if [[ "$OPEN_NEW" == "y" ]]; then
  open /Applications/iTerm.app
  open /Applications/MacVim.app
  open /Applications/Emacs.app
  open /Applications/Safari.app
  open /Applications/Telegram.app
fi
if [[ "$CLEAN_DOCK" == "YES THE DOCK IS FULL OF SHIT RN" ]]; then
  # Wipe all (default) app icons from the Dock
  # This is only really useful when setting up a new Mac, or if you don’t use
  # the Dock to launch apps.
  defaults write com.apple.dock persistent-apps -array
fi
if [[ "$OPEN_NEW" == "y" ]]; then
  open /Applications/Dropbox.app
  open /Applications/Box\ Sync.app
  open /Applications/MEGAsync.app
  open /Applications/Evernote.app
  open /Applications/iTunes.app
fi

#rm -rf ~/Downloads/eCalc_Scientific.wdgt

echo ""
echo "Get from App Store:"
echo "- Magnet"
echo "- Bandwidth+"
echo "- Telegram"
echo "- uBlock"
echo "- Monit"
echo ""
echo "Manually obtain:"
echo "- MS Office Suite"
echo "- Contexts licence file"
echo "- Folx activation code"
echo ""
