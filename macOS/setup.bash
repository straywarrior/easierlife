#! /bin/bash -e
#
# setup.bash
# Copyright (C) 2018 StrayWarrior <i@straywarrior.com>
#

__WORKDIR=$PWD

install_brew() {
    bash -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
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
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    for tap in command-not-found services; do
        brew tap --custom-remote --force-auto-update "homebrew/${tap}" "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-${tap}.git"
    done
    brew update
}

install_fish() {
    brew install fish

    # Install Oh My Fish
    curl -L https://get.oh-my.fish | fish
    fish -c "omf install agnoster; omf theme agnoster"

    # Install autojump
    brew install autojump

    # Patch agnoster
    cd $HOME/.local/share/omf/themes/agnoster
    git apply $__WORKDIR/fish.agnoster.patch
    echo "omf agnoster patched."
    cd $__WORKDIR
}

configure_fish() {
    cat >> ~/.config/fish/config.fish <<-EOF
[ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish
set -x HOMEBREW_API_DOMAIN https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api
set -x HOMEBREW_BOTTLE_DOMAIN https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
set -x HOMEBREW_BREW_GIT_REMOTE https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
set -x HOMEBREW_CORE_GIT_REMOTE https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
set VIRTUAL_ENV_DISABLE_PROMPT false
set -x LC_ALL="en_US.UTF-8"
EOF

    echo "Try to add fish shell as standard shell. Root privilege is required."
    __FISH_PATH="/opt/homebrew/bin/fish"
    if [ ! -f $__FISH_PATH ]; then
        echo "Fish shell does not exist. Expected path: $__FISH_PATH"
    fi
    sudo bash -c "grep $__FISH_PATH /etc/shells || echo $__FISH_PATH >> /etc/shells"
    chsh -s $__FISH_PATH
}

configure_vim() {
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

install_others_from_brew() {
    brew install the_silver_searcher
    brew install wget
}

setup_ssh_client() {
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa -C i@straywarrior.com
}

main() {
    install_brew
    install_git
    configure_git
    configure_brew
    install_fish
    configure_fish
    configure_vim
    install_others_from_brew
    setup_ssh_client
}

main
