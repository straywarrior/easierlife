#! /bin/bash -e
#
# setup.bash
# Copyright (C) 2018 StrayWarrior <i@straywarrior.com>
#

install_brew() {
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

install_git() {
    if [ ! $(which git) ]; then
        echo "Git is not installed. Install Git from brew"
        brew install git
    fi
}

configure_git() {
    if [ -f ~/.gitconfig ]; then
        mv -v ~/.gitconfig ~/.gitconfig.backup
    fi
    curl "https://raw.githubusercontent.com/straywarrior/easierlife/master/Git/.gitconfig" -o ~/.gitconfig
    echo ".gitconfig saved to user's home."
}


configure_brew() {
    # Use faster mirror for formula
    cd "$(brew --repo)"
    git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
    cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
    git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
    brew update

    # Use faster mirror for bottle
    echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles' >> ~/.bash_profile
}

install_fish() {
    brew install fish

    # Install Oh My Fish
    curl -L https://get.oh-my.fish | fish
    fish -c "omf install agnoster; omf theme agnoster"

    # Install autojump
    brew install autojump
}

configure_fish() {
    cat >> ~/.config/fish/config.fish <<-EOF 
[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish
set -x HOMEBREW_BOTTLE_DOMAIN https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
set VIRTUAL_ENV_DISABLE_PROMPT false
EOF

    echo "Try to add fish shell as standard shell. Root privilege is required."
    sudo bash -c "grep /usr/local/bin/fish /etc/shells || echo /usr/local/bin/fish >> /etc/shells"
    chsh -s /usr/local/bin/fish
}

configure_vim() {
    __WORKDIR=$PWD
    cd $HOME
    git clone https://github.com/straywarrior/vimfiles.git .vim
    cd .vim
    git submodule update --init
    # patch vim plugins
    cd bundle/neomru.vim
    git apply $__WORKDIR/neomru.autoload.patch
    echo "Vim plugin neomru patched."
    cd $__WORKDIR
}

main() {
    install_brew
    install_git
    configure_git
    configure_brew
    install_fish
    configure_fish
    configure_vim
}

main
