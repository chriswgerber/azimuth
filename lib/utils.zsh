#!/bin/zsh


function -profile-zsh-load() {
  # exposes zprofexport
    if [[ -z "$ZSH_DEBUG" ]]; then
        echo 'Set $ZSH_DEBUG=1 to enable profiling.'
    else
        zmodload zsh/zprof
        time (
            zsh -i -c exit
        )
        zprof
    fi
}


function -reload-compinit() {
    __dir=$1
    # Setup fpath
    # --------------------------------------
    fpath=($__dir/functions $__dir/completions $fpath)

    # Reload/Setup Autoload functions and compinit
    # --------------------------------------
    autoload -Uz +X compinit
    autoload -Uz +X bashcompinit

    # Autoload fpath and bash completes compat, as well
    for func in $^fpath/*(N-.x:t); do
        autoload -Uz $func
    done

    compinit -C -i -d "${ZSH_COMPDUMP}" && bashcompinit
}
