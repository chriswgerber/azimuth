#!/bin/zsh


function -dot-file-source() {
  # Source a file in the dotfile dir.
  #
  # If it doesn't find the matching file in the dotfile directory, it will
  # source it from the current working directory.
  #
  # Usage :
  #   $1 = The name of the file to find in the dotfiles directory.

  local fh="${1}"
  local base_dir="${2:=${DOTFILES_DIR}}"

  if test -r "${base_dir}/${fh}"; then
    source "${base_dir}/${fh}";
  elif test -r "${fh}"; then
    source "${fh}";
  fi

}


function -dot-dir-glob-source() {
  # Sources all files matching argument, beginning with the root file and then
  # source all in 1st level subdirectory.
  #
  # Usage :
  #   $1 = The name of the file to find across directories.

  local _target_file=$1
  local base_dir=${2:=$DOTFILES_DIR}

  -dot-file-source "${_target_file}"

  # if command -v fd; then
  #   fd -pd 2 "${base_dir}/[a-z]*/${_target_file}" "${base_dir}" -exec -dot-file-source
  #   return
  # fi

  for the_file in $($SHELL +o nomatch -c "ls ${base_dir}/*/${_target_file} 2>/dev/null"); do
    -dot-file-source $the_file;
  done

}


function -dot-dir-projects-upgrade() {
  # Run upgrade.zsh for all projects in ${DOTFILES_DIR}
  #
  # Usage ;
  #     $1: The target directory

  -dot-file-source "upgrade.zsh"
  -dot-dir-glob-source "upgrade.zsh"
  -dot-file-source "post-upgrade.zsh"
}


function -dot-dir-repos-upgrade() {
  # Update plugins from Github
  #
  # Usage:
  #   $1 = Directory to check for repos.
  #   $2 = Array of directory names to ignore

  local _remote_url
  local _found
  local _target_dir=$1
  local _ignore_dirs=(${2})

  if test ${#__ignore_dirs[@]} -eq 0; then
    _found=($(find "${_target_dir}" -maxdepth 1 -type d \
      -not -path "${_target_dir}" \
      -not \( \
        -name "${_ignore_dirs[1]}" \
        $(printf -- '-o -name "%s" ' "${_ignore_dirs[2,-1]}") \
      \)))
  else
    _found=($(find "${_target_dir}" -maxdepth 1 -type d \
      -not -path "${_target_dir}" \
      ));
  fi

  for i in $_found; do
    (
      printf "=> Upgrading directory %s from origin %s.\n=> git -C %s pull origin master\n" \
        $i \
        "$(git -C $i config remote.origin.url)" \
        $i

      git -C $i pull origin master
    ) &
  done

  wait
}


function -dot-symlink-update() {
  # Creates symlink in the $HOME directory
  #
  # Usage :
  #   $1 = Source file to use as link.
  #   $2 = Destination for symlink.

  local _src="$DOTFILES_DIR/${1#"$DOTFILES_DIR/"}"
  local _dest="$HOME/${2#"$HOME/"}"
  local _dest_dir

  if ! test -L "$_dest"; then
    stat "$_dest"

    printf "\n\nLinking config file\n\tsrc: %s\n\tdest: %s\n\n" \
      "${_src}" \
      "${_dest}"

    if ! test -e "$_dest"; then
      _dest_dir="$(dirname "$_dest")"
      printf "Creating link for file %s at %s\n" "$_src" "$_dest"

      if test -e "$_src"; then
        printf "Creating target directory %s\n" "$_dest_dir"

        mkdir -p "$_dest_dir"
        ln -sf "$_src" "$_dest"
        return
      else
        printf \
          "Unable to create symlink for %s; src file %s does not exist.\n" \
          "$_dest" \
          "$_src"
      fi
    else
      printf \
        "Unable to create symlink for %s; dest file %s already exists.\n" \
        "$_src" \
        "$_dest"
    fi
  fi

}
