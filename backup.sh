#!/bin/sh

set -eu

BASE=$(dirname $0)
BASE=$(readlink -f $BASE)
cd ""

file_date=$(date "+%Y-%m-%d")

cd "${HOME}"

tar --exclude-from="${BASE}/resources/backup_exclusion.conf" \
    --files-from="${BASE}/resources/backup_list.conf" \
    -zcvf "${HOME}/backup_conf_${file_date}.tgz" 