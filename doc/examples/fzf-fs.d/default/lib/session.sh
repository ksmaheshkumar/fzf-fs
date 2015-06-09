#!/usr/bin/env bash
FzfFsSession () 
{ 
    function FzfFsSession__attend_session () 
    { 
        clients_session[${#clients[@]} - 1]="$FZF_FS_SESSION"
    };
    function FzfFsSession__create_buffer () 
    { 
        builtin unset -v i index;
        builtin typeset i index;
        index="$((${#buffers[@]} + 1))";
        buffers+=("${index}-${1:-${index}}");
        FZF_FS_SESSION="$(<"${FZF_FS_CONFIG_DIR}/daemon/clients/${FZF_FS_CLIENT}/session")";
        command mkdir -p -m 755 "${FZF_FS_CONFIG_DIR}/sessions/${FZF_FS_SESSION}/var/buffers/${index}";
        command cp "${FZF_FS_CONFIG_DIR}/sessions/${FZF_FS_SESSION}/var/env.session" "${FZF_FS_CONFIG_DIR}/sessions/${FZF_FS_SESSION}/var/buffers/${index}/env.buffer";
        command cp "${FZF_FS_CONFIG_DIR}/sessions/${FZF_FS_SESSION}/var/cwd.session" "${FZF_FS_CONFIG_DIR}/sessions/${FZF_FS_SESSION}/var/buffers/${index}/cwd.buffer";
        FzfFsSession__update_info;
        command printf '%s\n' "$index" > "${FZF_FS_CONFIG_DIR}/daemon/clients/${FZF_FS_CLIENT}/buffer";
        builtin return "$index"
    };
    function FzfFsSession__create_daemon () 
    { 
        if { 
            builtin . "${FZF_FS_CONFIG_DIR}/daemon/info" && command ps -p "${daemon[0]}"
        } > /dev/null 2>&1; then
            { 
                command printf '%s\n' "${source}: Error 79: Daemon has already been started with pid: '${daemon[0]}'" 1>&2;
                builtin return 79
            };
        else
            command mkdir -p -m 755 "${FZF_FS_CONFIG_DIR}/daemon/clients";
            command chmod +x "${FZF_FS_CONFIG_DIR}/default/lib/fzf-fs-fifo.sh";
            FzfFsSession__create_fifo;
            command sleep 0.5 && command printf '%s\n' "Done" 1>&2;
        fi
    };
    function FzfFsSession__create_fifo () 
    { 
        command rm "${FZF_FS_CONFIG_DIR}/daemon/"{request,response}.fifo > /dev/null 2>&1;
        command mkfifo "${FZF_FS_CONFIG_DIR}/daemon/"{request,response}.fifo;
        ( exec "${FZF_FS_CONFIG_DIR}/default/lib/fzf-fs-fifo.sh" "$FZF_FS_CONFIG_DIR" & )
    };
    function FzfFsSession__create_session () 
    { 
        builtin unset -v i index n;
        builtin typeset i index="$(command date --utc +%s)";
        builtin typeset n="${1:-${index}}";
        sessions[$index]="$n";
        sessions_status[$index]="open";
        command mkdir -p -m 755 "${FZF_FS_CONFIG_DIR}/cache/sessions/${index}/var/ls";
        for i in "${FZF_FS_CONFIG_DIR}/default/"{bin,etc};
        do
            command cp -R "$i" "${FZF_FS_CONFIG_DIR}/cache/sessions/${index}";
        done;
         > "${FZF_FS_CONFIG_DIR}/cache/sessions/${index}/var/env.session";
         > "${FZF_FS_CONFIG_DIR}/cache/sessions/${index}/var/cwd.session";
        FzfFsSession__update_info_session;
        builtin . "${FZF_FS_CONFIG_DIR}/cache/sessions/info.sessions";
        builtin return "$((${#sessions_ids[@]} - 1))"
    };
    function FzfFsSession__dump_sessions () 
    { 
        builtin unset -v i cwd;
        builtin typeset i;
        builtin typeset -a cwd;
        command printf '%s %s %s %s %s\n-- ----- ---- ------ ---\n' "ID" "Index" "Name" "Status" "CWD";
        for i in "${!sessions_ids[@]}";
        do
            command printf '%d %d %s %s %s\n' "$i" "${sessions_ids[$i]}" "${sessions[${sessions_ids[$i]}]}" "${sessions_status[${sessions_ids[$i]}]}" "${cwd[3]:--}";
        done 2> /dev/null
    };
    function FzfFsSession__kill_daemon () 
    { 
        FzfFsSession__san daemon;
        builtin typeset -a daemon;
        if builtin . "${FZF_FS_CONFIG_DIR}/daemon/info"; then
            if command ps -p "${daemon[0]}" > /dev/null; then
                command printf '%s' "${source}: Info: Killing daemon with pid: '${daemon[0]}' ... " 1>&2;
                command kill "${daemon[0]}" && command printf '%s\n' "Done" 1>&2;
                command rm "${FZF_FS_CONFIG_DIR}/daemon/"{info,{request,response}.fifo};
            else
                { 
                    command printf '%s\n' "${source}: Error 80: Could not kill stored pid: '${daemon[0]}'" 1>&2;
                    builtin return 80
                };
            fi;
        else
            { 
                command printf '%s\n' "${source}: Error 81: Could not find a started daemon" 1>&2;
                builtin return 81
            };
        fi
    };
    function FzfFsSession__main () 
    { 
        builtin unset -v buffers clients clients_session sessions sessions_ids sessions_status;
        builtin typeset FZF_FS_CONFIG_DIR="${FZF_FS_CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/fzf-fs.d}";
        builtin typeset -a buffers clients clients_session sessions sessions_ids sessions_status;
        command mkdir -p -m 755 "${FZF_FS_CONFIG_DIR}/"{cache,user}/sessions;
        builtin . "${FZF_FS_CONFIG_DIR}/user/sessions/info.sessions" > /dev/null 2>&1;
        builtin . "${FZF_FS_CONFIG_DIR}/cache/sessions/info.sessions" > /dev/null 2>&1;
        builtin eval "$@"
    };
    function FzfFsSession__parse_session () 
    { 
        builtin unset -v i id index name;
        builtin typeset i id index name;
        if [[ -z "$1" ]]; then
            FzfFsSession__create_session;
        else
            IFS=":" builtin read -r id index name <<< "$1";
            if [[ -n "$id" ]]; then
                if [[ -n "${sessions_ids[$id]}" ]]; then
                    if [[ "${sessions_status[${sessions_ids[$id]}]}" == "open" ]]; then
                        builtin return "$id";
                    else
                        FzfFsSession__restore_session "$id";
                    fi;
                else
                    { 
                        command printf '%s\n' "${source}:Error:255: Could not open session with id '${id}'" 1>&2;
                        builtin return 255
                    };
                fi;
            else
                if [[ -n "$index" ]]; then
                    if [[ -n "${sessions[$index]}" ]]; then
                        if [[ "${sessions_status[$index]}" == "open" ]]; then
                            for i in "${!sessions_ids[@]}";
                            do
                                [[ "${sessions_ids[$i]}" == "$index" ]] && builtin return "$i";
                            done;
                        else
                            for i in "${!sessions_ids[@]}";
                            do
                                [[ "${sessions_ids[$i]}" == "$index" ]] && { 
                                    FzfFsSession__restore_session "$i";
                                    builtin return "$?"
                                };
                            done;
                        fi;
                        builtin return 255;
                    else
                        { 
                            command printf '%s\n' "${source}:Error:255: Could not open session with index '${index}'" 1>&2;
                            builtin return 255
                        };
                    fi;
                else
                    if [[ -n "$name" ]]; then
                        for index in "${!sessions[@]}";
                        do
                            [[ "${sessions[$index]}" == "$name" ]] && { 
                                if [[ "${sessions_status[$index]}" == "open" ]]; then
                                    for i in "${!sessions_ids[@]}";
                                    do
                                        [[ "${sessions_ids[$i]}" == "$index" ]] && builtin return "$i";
                                    done;
                                else
                                    for i in "${!sessions_ids[@]}";
                                    do
                                        [[ "${sessions_ids[$i]}" == "$index" ]] && { 
                                            FzfFsSession__restore_session;
                                            builtin return "$?"
                                        };
                                    done;
                                fi;
                                builtin return 255
                            };
                        done;
                        FzfFsSession__create_session "$name";
                    else
                        FzfFsSession__create_session;
                    fi;
                fi;
            fi;
        fi
    };
    function FzfFsSession__register_client () 
    { 
        command mkdir -p -m 755 "${FZF_FS_CONFIG_DIR}/cache/clients/${FZF_FS_CLIENT}";
        clients+=("$FZF_FS_CLIENT");
        FzfFsSession__attend_session;
        FzfFsSession__update_info_client
    };
    function FzfFsSession__register_stored_sessions () 
    { 
        builtin unset -v i name;
        builtin typeset i name;
        [[ -d "${FZF_FS_CONFIG_DIR}/user/sessions" ]] && { 
            for i in "${FZF_FS_CONFIG_DIR}/user/sessions"/*;
            do
                name="$(<"${i}/var/info.session")";
                i="${i##*/}";
                [[ -n "$i" ]] && sessions[${i}]="$name";
            done
        };
        FzfFsSession__update_info
    };
    function FzfFsSession__request () 
    { 
        builtin unset -v ret;
        builtin typeset -i ret;
        command rm "${FZF_FS_CONFIG_DIR}/daemon/clients/${FZF_FS_CLIENT}/response" > /dev/null 2>&1;
        IFS=" " command printf '%s\n' "${FZF_FS_CLIENT:+${FZF_FS_CLIENT} }${*}" 1>&8;
        until [[ -f "${FZF_FS_CONFIG_DIR}/daemon/clients/${FZF_FS_CLIENT}/response" ]]; do
            builtin :;
        done;
        ret="$(<"${FZF_FS_CONFIG_DIR}/daemon/clients/${FZF_FS_CLIENT}/response")";
        builtin return "$ret"
    };
    function FzfFsSession__rename_session () 
    { 
        builtin unset -v id index n;
        builtin typeset -i id="$1" index="${sessions_ids[$1]}";
        builtin typeset n="$2";
        sessions[$index]="${n:-${index}}";
        FzfFsSession__update_info_session
    };
    function FzfFsSession__restore_session () 
    { 
        builtin unset -v id index;
        builtin typeset -i id="$1" index="${sessions_ids[$1]}";
        sessions_status[$index]="open";
        command mv "${FZF_FS_CONFIG_DIR}/user/sessions/${index}" "${FZF_FS_CONFIG_DIR}/cache/sessions/";
        FzfFsSession__update_info_session;
        builtin return "$id"
    };
    function FzfFsSession__return_status () 
    { 
        builtin unset -v i;
        builtin typeset -i i="$1";
        command printf '%s\n' "$i" > "${FZF_FS_CONFIG_DIR}/daemon/clients/${FZF_FS_CLIENT}/response"
    };
    function FzfFsSession__store_session () 
    { 
        builtin unset -v id index indexn n;
        builtin typeset -i id="$1" index="${sessions_ids[$1]}" indexn="$(command date --utc +%s)";
        builtin typeset n="$2";
        sessions[$indexn]="${n:-${indexn}}";
        sessions_status[$indexn]="closed";
        command cp -R "${FZF_FS_CONFIG_DIR}/cache/sessions/${index}/" "${FZF_FS_CONFIG_DIR}/user/sessions/${indexn}/";
        FzfFsSession__update_info_session
    };
    function FzfFsSession__update_info_client () 
    { 
        builtin unset -v i;
        builtin typeset -i i;
        for i in "${!clients[@]}";
        do
            command printf '%s\n' "clients[$i]=\"${clients[$i]}\"";
        done;
        for i in "${!clients_session[@]}";
        do
            command printf '%s\n' "clients_session[$i]=\"${clients_session[$i]}\"";
        done
    } > "${FZF_FS_CONFIG_DIR}/cache/clients/info.clients";
    function FzfFsSession__update_info_session () 
    { 
        builtin unset -v i n;
        builtin typeset -i i n=0;
        for i in "${!buffers[@]}";
        do
            command printf '%s\n' "buffers[$i]=\"${buffers[$i]}\"";
        done;
        for i in "${!clients[@]}";
        do
            command printf '%s\n' "clients[$i]=\"${clients[$i]}\"";
        done;
         > "${FZF_FS_CONFIG_DIR}/user/sessions/info.sessions" > /dev/null 2>&1;
        for i in "${!sessions[@]}";
        do
            [[ "${sessions_status[$i]}" == closed ]] && { 
                command printf '%s\n' "sessions[$i]=\"${sessions[$i]}\"" "sessions_status[$i]=\"${sessions_status[$i]}\"" >> "${FZF_FS_CONFIG_DIR}/user/sessions/info.sessions"
            };
            command printf '%s\n' "sessions[$i]=\"${sessions[$i]}\"" "sessions_status[$i]=\"${sessions_status[$i]}\"" "sessions_ids[$n]=\"${i}\"";
            ((n++));
        done
    } > "${FZF_FS_CONFIG_DIR}/cache/sessions/info.sessions";
    function FzfFsSession__update_cwd () 
    { 
        FZF_FS_SESSION="$(<"${FZF_FS_CONFIG_DIR}/daemon/clients/${FZF_FS_CLIENT}/session")";
        FZF_FS_BUFFER="$(<"${FZF_FS_CONFIG_DIR}/daemon/clients/${FZF_FS_CLIENT}/buffer")";
        command cp -f "${FZF_FS_CONFIG_DIR}/sessions/${FZF_FS_SESSION}/var/buffers/${FZF_FS_BUFFER}/cwd.buffer" "${FZF_FS_CONFIG_DIR}/sessions/${FZF_FS_SESSION}/var/cwd.session";
        builtin return 0
    };
    function FzfFsSession__update_env () 
    { 
        FZF_FS_SESSION="$(<"${FZF_FS_CONFIG_DIR}/daemon/clients/${FZF_FS_CLIENT}/session")";
        FZF_FS_BUFFER="$(<"${FZF_FS_CONFIG_DIR}/daemon/clients/${FZF_FS_CLIENT}/buffer")";
        command cp -f "${FZF_FS_CONFIG_DIR}/sessions/${FZF_FS_SESSION}/var/buffers/${FZF_FS_BUFFER}/env.buffer" "${FZF_FS_CONFIG_DIR}/sessions/${FZF_FS_SESSION}/var/env.session";
        builtin return 0
    };
    function FzfFsSession__san () 
    { 
        case "$1" in 
            -[fn])
                IFS=" " builtin unset ${*}
            ;;
            *)
                IFS=" " builtin unset -v ${*}
            ;;
        esac
    };
    FzfFsSession__san ret;
    builtin typeset -i ret;
    FzfFsSession__main "$@";
    ret="$?";
    FzfFsSession__san -f FzfFsSession__create_daemon FzfFsSession__create_fifo FzfFsSession__create_session FzfFsSession__kill_daemon FzfFsSession__main FzfFsSession__san;
    builtin return "$ret"
}
