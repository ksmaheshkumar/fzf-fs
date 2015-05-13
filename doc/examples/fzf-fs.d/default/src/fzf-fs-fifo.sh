#!/usr/bin/env bash
builtin . "${1}/default/src/daemon.sh"

command printf '%s\n' "daemon[0]=\"${1}/daemon/fifo\"" "daemon[1]=\"${$}\"" > "${1}/daemon/info";
command printf '%s' "${0}: Info: Starting daemon with pid: '${$}'... " 1>&2;

while builtin read -r
do
    echo $REPLY
done < "${1}/daemon/fifo"
