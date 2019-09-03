#!/bin/zsh


function -dot-install-omz() {
    # Install OMZ

    test -d $ZSH && return

    git clone --depth=1 $OMZ_REPO $ZSH || {
        printf "Error: git clone of oh-my-zsh repo failed\n"
        echo 1
        return 1
    }
}


function -dot-upgrade-omz() {
    # Update ZSH
    (
        set -v
        git -C "${ZSH}" pull origin master
    )
}


function -dot-upgrade-dotfiles-projects() {
    # Run upgrade.zsh across project
    for i in $(ls -d $__DD/*/upgrade.zsh); do
        (
            set -v;
            source "${i}";
        ) &
    done
    wait
}


function -dot-upgrade-dotfiles-dir() {
    (
        set -v
        git -C $__DD stash
        git -C $__DD pull --ff-only origin master || true
        git -C $__DD stash pop
    ) &

    wait

    -dot-source-dotfile "init.zsh"
}


function -upgrade-shell-env() {
    # Upgrade the Shell Environment
    -dot-upgrade-dotfiles-dir
    -dot-upgrade-brew
    -dot-upgrade-omz
    -dot-upgrade-zsh-plugins
    -dot-upgrade-dotfiles-projects

    eval "${SHELL}"
}


function -dot-upgrade-brew() {
    brew update --force
    (
        set -v
        if [[ -n "$ZSH_DEBUG" ]]; then
          brew upgrade --verbose --display-times
        else
          brew upgrade --display-times
        fi
        brew cleanup --verbose --prune=$BREW_CLEANUP_PRUNE_DAYS
    ) &

    wait
}
