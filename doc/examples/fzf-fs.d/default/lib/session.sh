#!/usr/bin/env bash
FzfFsSession () 
{ 
    function FzfFsSession__attend_session () 
    { 
        clients_session[${#clients[@]} - 1]="$FZF_FS_SESSION"
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
    builtin unset -v ret;
    builtin typeset -i ret;
    FzfFsSession__main "$@";
    ret="$?";
    builtin unset -f FzfFsSession__main;
    builtin return "$ret"
}
