#!/bin/zsh


function -dot-add-fpath() {
  # Add the directory, and any 1st level directories, to the fpath.
  #
  # Usage:
  #   1 - Directory to begin search. azimuth/functions azimuth/completions
  #   2 - Name of directory to load within the base directory

  local fpath_dir="${1}"
  local skipZwc="${2:="not"}"
  local fncPath

  if ! test -d ${fpath_dir}; then
    return
  fi
  if test "${skipZwc}" != "not"; then
    fncPath="${fpath_dir}"
  else
    fncPath="$(-dot-cache-fnc-dir "${fpath_dir}")"
  fi

  export fpath=(${fncPath} $fpath)

  for fnc in $(find ${fpath_dir} \( -type f -o -type l \) -print0 | tr "\0" " "); do
    autoload -Uz $fnc
  done
}


function -dot-cache-fnc-dir() {
  # Cache the contents of a zsh `functions` directory.
  #
  # Usage :
  #   $1 = Target Directory
  #   $2 = Optional file name of the compiled functions.

  local target_dir="${1}"
  local suffix=".zwc"
  local zwc

  if ! test -d ${target_dir}; then
    return
  fi

  zwc="${target_dir}${suffix}"

  if [[ "$(find ${target_dir} \( -type f -o -type l \) -print0)" == "" ]]; then
    printf "%s" ${target_dir}
    return
  fi

  if ! test -f ${zwc}; then
    rm -f ${zwc}
    touch ${zwc}
    (
      set -v
      zcompile -Uz ${zwc} $(find ${target_dir} \( -type f -o -type l \) -print0 | tr "\0" " ")
    )
  fi

  printf "%s" ${zwc}
}


function -dot-cache-fnc-clear() {
  # Delete all compiled ZSH functions.
  #
  # Usage :
  #   $1 = Target Directory to search

  local target_dir="${1:=${DOTFILES_DIR}}"
  local suffix=".zwc"
  local del_compdump="true"

  for fncfile in $(find "$target_dir" -type f -name "*${suffix}" -print); do
    rm -f "${fncfile}" || true
  done

  if [[ "${del_compdump}" == "true" ]] ; then
    rm -f "${ZSH_COMPDUMP}" || true
  fi
}
