#!/bin/zsh


function -dot-github-repo-install() {
  # Idempotently clone repo from GitHub into directory.
  #
  # Usage:
  #   $1 (required) = Namespace/ProjectName
  #   $2 (required) = Filesystem Location
  #   $3            = Protocol (SSH|HTTPS)

  local __test
  local __url
  local __repo="${1}"
  local __dir="${2}"
  local __protocol="${GIT_PROTOCOL:=ssh}"

  if ! test -d $__dir; then
    mkdir -p $__dir;
  fi

  __test=$(git -C $__dir remote -v &>/dev/null)

  if test $? -ne 0 -o ! -d "${__dir}/.git"; then
    if test "$3"; then __protocol="$3"; fi;

    case $__protocol in
      https|HTTPS) # Use HTTPS
        __url="https://github.com/${__repo}.git"
        ;;
      ssh|SSH|*)   # Default
        __url="git@github.com:${__repo}.git"
        ;;
    esac;

    rm -r ${__dir} || true;

    git clone --depth 10 $__url $__dir;
  fi
}


function -dot-github-plugin-add() {
  # Install Github Plugin
  #
  # Usage:
  #   $1 = Group + Plugin Name
  #   $2 = Install Directory

  local name="${1}"
  local __dir="${2:=${ZSH_CUSTOM}/plugins}"
  local plugin_name="${name#*/}"

  -dot-install-github-repo \
    "$name" \
    "${__dir}/${plugin_name}" \
    "HTTPS";

  plugins=($plugins $plugin_name)
}


function -dot-zsh-plugins-upgrade() {
  # Update plugins for ZSH in "${ZSH_CUSTOM}/plugins"

  -dot-dir-repos-upgrade "${ZSH_CUSTOM}/plugins"
}


function -dot-omz-install() {
  # Installs OMZ into the ZSH directory

  -dot-install-github-repo \
    "robbyrussell/oh-my-zsh" \
    "${ZSH:=${ZSH_CACHE_DIR}/oh-my-zsh}"
}
