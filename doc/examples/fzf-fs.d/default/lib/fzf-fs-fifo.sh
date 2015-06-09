#!/usr/bin/env bash
FZF_FS_CONFIG_DIR="$1";

exec 9<>"${FZF_FS_CONFIG_DIR}/daemon/response.fifo";
exec 7<>"${FZF_FS_CONFIG_DIR}/daemon/LOG";

command printf '%s' "${0}: Info: Starting daemon with pid: '${$}' ... " 1>&2;

daemon[0]="$$";
builtin typeset -p daemon > "${FZF_FS_CONFIG_DIR}/daemon/info"

builtin . "${FZF_FS_CONFIG_DIR}/default/lib/daemon.sh";
FzfFsSession FzfFsSession__register_stored_sessions;

while builtin read -r
do
    case "$REPLY" in
        *create_buffer* | *create_session* | *register_client* | *update_cwd* | *update_env* | *attend_session* | *restore_session* )
            FZF_FS_CLIENT="${REPLY%% *}";
            builtin eval "FzfFsSession FzfFsSession__${REPLY#* }";
            FzfFsSession FzfFsSession__return_status "$?"
        ;;
        *)
            command printf '%s\n' "${0}: Error: Unknown request: '${REPLY}'"
        ;;
    esac;
done < "${FZF_FS_CONFIG_DIR}/daemon/request.fifo" 1>&7 2>&1
