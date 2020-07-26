#!/bin/zsh


function -dot-install-github-repo() {
  # Idempotently clone repo from GitHub into directory.
  # Usage:
  # $1 (required) = Namespace/ProjectName
  # $2 (required) = Filesystem Location
  # $3            = Protocol (SSH|HTTPS)

  local __test __url __dir=$2 __protocol="${GIT_PROTOCOL:=ssh}"

  if ! test -d $__dir; then mkdir -p $__dir; fi

  __test=$(git -C $__dir remote -v &>/dev/null)

  if test $? -ne 0 -o ! -d "${__dir}/.git"; then
    if test "$3"; then __protocol="$3"; fi;

    case $__protocol in
      https|HTTPS) # Use HTTPS
        __url="https://github.com/$1.git"
        ;;
      ssh|SSH|*)   # Default
        __url="git@github.com:$1.git"
        ;;
    esac;

    rm -r ${__dir} || true;

    git clone --depth 10 $__url $__dir;
  fi
}


function -dot-install-github-plugin() {
  # Install Github Plugin
  # Usage:
  # $1 = Group + Plugin Name
  # $2 = Install Directory

  local name=$1 plugin_name=${1#*/} __dir="${2:=${ZSH_CUSTOM}/plugins}"

  -dot-install-github-repo \
    "$name" \
    "${__dir}/${plugin_name}" \
    "HTTPS";

  plugins=($plugins $plugin_name)
}


function -dot-install-omz() {
  # Installs OMZ into the ZSH directory
  # Usage:
  #

  -dot-install-github-repo \
    "robbyrussell/oh-my-zsh" \
    "${ZSH:=${ZSH_CACHE_DIR}/oh-my-zsh}"
}
