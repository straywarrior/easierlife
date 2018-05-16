#! /bin/bash
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
    git clone https://github.com/straywarrior/easierlife.git /tmp/easierlife
    if [ -f ~/.gitconfig ]; then
        mv -v ~/.gitconfig ~/.gitconfig.backup
    fi
    cp -v /tmp/easierlife/Git/.gitconfig ~/.gitconfig
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
set HOMEBREW_BOTTLE_DOMAIN https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
EOF
}

main() {
    install_brew
    install_git
    configure_brew
    install_fish
    configure_fish
}

main
