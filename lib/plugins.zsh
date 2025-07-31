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

  -dot-github-repo-install \
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

  -dot-github-repo-install \
    "robbyrussell/oh-my-zsh" \
    "${ZSH:=${ZSH_CACHE_DIR}/oh-my-zsh}"
}


function -dot-omz-load-plugin() {
  # Loads OMZ plugin file and any completions.
  local _plgn_name="${1}";
  local _plgn_dir="${ZSH}/plugins/${_plgn_name}";
  local _custom_plgn_dir="${ZSH_CUSTOM}/plugins/${_plgn_name}";
  local _plgn_filename="${_plgn_name}.plugin.zsh";
  local _plgn_file;

  # Load plugin files
  if test -d "${_custom_plgn_dir}"; then
    local _plgn_file="${_custom_plgn_dir}/${_plgn_filename}";
  else if test -d "${_plgn_dir}"; then
    local _plgn_file="${_plgn_dir}/${_plgn_filename}";
  fi
  source "${_plgn_file}";

  # Load autoload files.

}
