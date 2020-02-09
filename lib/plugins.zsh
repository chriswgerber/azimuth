#!/usr/bin/env zsh


function -dot-install-github-plugin() {
  # Install Github Plugin
  local plugin_name=${1#*/}
  local name=$1
  local URL="https://github.com/$name.git"

  IFS='/' read -A parts <<<$1
  test -d "${ZSH_CUSTOM}/plugins" || mkdir -p "${ZSH_CUSTOM}/plugins"
  if ! test -d "${ZSH_CUSTOM}/plugins/${parts[2]}"; then
      cd ${ZSH_CUSTOM}/plugins
      git clone $URL
    fi
    plugins=($plugins $plugin_name)
}


function -dot-upgrade-zsh-plugins() {
  # Update plugins from Github
  for i in $(ls ${ZSH_CUSTOM}/plugins/); do
    (set -v; git -C ${ZSH_CUSTOM}/plugins/$i pull origin master) &
  done
  wait
}
