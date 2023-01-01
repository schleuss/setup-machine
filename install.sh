#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

log_color() {
  color_code="$1"
  shift

  printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}

log_red() {
  log_color "0;31" "$@"
}

log_blue() {
  log_color "0;34" "$@"
}

log_task() {
  log_blue "🔃" "$@"
}

log_error() {
  log_red "❌" "$@"
}

error() {
  log_error "$@"
  exit 1
}

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
# shellcheck disable=SC2312
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

SUDO=""
if [ $(id -u) -ne 0 ]
then
    SUDO="sudo "
fi

updated=0
if ! pip="$(command -v pip3)"; then
    log_task "Installing pip3"
    $SUDO apt update && $SUDO apt install -y --no-install-recommends python3-pip
    updated=1
fi

if ! pip="$(command -v ansible-playbook)"; then
    log_task "Installing ansible"
    $SUDO pip3 install ansible
fi

if ! pip="$(command -v git)"; then
    log_task "Installing git"
    [ $updated -eq 0 ] || $SUDO apt update 
    $SUDO apt install --no-install-recommends git -y
fi

work_dir=$script_dir
if [ ! -d "${script_dir}/ansible" ]
then
    log_task "Clone repository "
    if [ -d /tmp/setup-machine ]
    then
        rm -Rf /tmp/setup-machine
    fi
    git clone --single-branch --branch main https://github.com/schleuss/setup-machine /tmp/setup-machine
    cd /tmp/setup-machine
fi

export ANSIBLE_INVENTORY_UNPARSED_WARNING=false

log_task "Running ansible playbook"
ansible-playbook ansible/main.yml
