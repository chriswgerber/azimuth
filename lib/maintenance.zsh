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


function -upgrade-shell-env() {
    # Upgrade the Shell Environment
    -dot-upgrade-dotfiles-dir
    # We have to run the brew upgrade first since everything is installed by it.
    -dot-upgrade-brew
    # The Rest
    -dot-upgrade-omz
    -dot-upgrade-zsh-plugins
    -dot-upgrade-dotfiles-projects

    eval "${SHELL}"
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


function -dot-upgrade-omz() {
    # Update ZSH
    (
        set -v
        git -C "${ZSH}" pull origin master
    )
}


function -dot-upgrade-brew() {
    # Upgrade Homebrew
    local _upgrade_args _dump_args

    # Update && upgrade
    brew update --force

    _upgrade_args="--display-times"
    if [[ -n "$ZSH_DEBUG" ]]; then _upgrade_args="--verbose ${_upgrade_args}"; fi

    echo "brew upgrade $_upgrade_args"
    brew upgrade $_upgrade_args

    # Cleanup
    _dump_args="--describe --force"
    if [ -n "$BREW_FILE" ]; then _dump_args="--file=$BREW_FILE ${_dump_args}"; fi

    (
      set -v;
      brew cleanup --verbose --prune=$BREW_CLEANUP_PRUNE_DAYS
    ) &

    (
      set -v;
      brew bundle dump $_dump_args
    ) &

    wait
}
