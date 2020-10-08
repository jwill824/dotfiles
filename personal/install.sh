  sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
  
  git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  
  ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
  
  # edit .zshrc
  plugins=(zsh-autosuggestions,zsh-syntax-highlighting)

  # also add export SHELL="/bin/zsh" and source $HOME/.bash_profile

  # symlink .zshrc from home dir
  ln -sv $HOME/.zshrc $DOTFILES_PERSONAL_HOME 

  # also modify .hyper.js accordingly e.g. fontFamily, shell, plugins