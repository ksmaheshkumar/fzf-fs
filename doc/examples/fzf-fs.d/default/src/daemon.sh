#!/usr/bin/env bash
FzfFsDaemon () 
{ 
    function FzfFsDaemon__create_daemon () 
    { 
        FzfFsDaemon__san daemon;
        builtin typeset -a daemon;
        if { 
            builtin . "${FZF_FS_CONFIG_DIR}/daemon/info" && command ps -p "${daemon[1]}"
        } > /dev/null 2>&1; then
            { 
                command printf '%s\n' "${source}: Error 79: Daemon has already been started with pid: '${daemon[1]}'" 1>&2;
                builtin return 79
            };
        else
            command mkdir -p -m 755 "${FZF_FS_CONFIG_DIR}/"{daemon,sessions};
            command chmod +x "${FZF_FS_CONFIG_DIR}/default/src/fzf-fs-fifo.sh";
            FzfFsDaemon__create_fifo && command sleep 1 && command printf '%s\n' "Done" 1>&2;
        fi
    };
    function FzfFsDaemon__create_fifo () 
    { 
        command rm "${FZF_FS_CONFIG_DIR}/daemon/fifo" > /dev/null 2>&1;
        command mkfifo "${FZF_FS_CONFIG_DIR}/daemon/fifo";
        ( exec "${FZF_FS_CONFIG_DIR}/default/src/fzf-fs-fifo.sh" "$FZF_FS_CONFIG_DIR" & )
    };
    function FzfFsDaemon__create_session () 
    { 
        builtin unset -v f;
        builtin typeset f;
        for f in "${FZF_FS_CONFIG_DIR}/default/"{env,console};
        do
            command cp -R "$f" "$FZF_FS_CONFIG_DIR";
        done
    };
    function FzfFsDaemon__kill_daemon () 
    { 
        FzfFsDaemon__san daemon;
        builtin typeset -a daemon;
        if builtin . "${FZF_FS_CONFIG_DIR}/daemon/info"; then
            if command ps -p "${daemon[1]}" > /dev/null; then
                command printf '%s' "${source}: Info: Killing daemon with pid: '${daemon[1]}'... " 1>&2;
                command kill "${daemon[1]}" && command printf '%s\n' "Done" 1>&2;
                command rm "${FZF_FS_CONFIG_DIR}/daemon/"{info,fifo};
            else
                { 
                    command printf '%s\n' "${source}: Error 80: Could not kill stored pid: '${daemon[1]}'" 1>&2;
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
    function FzfFsDaemon__main () 
    { 
        builtin typeset FZF_FS_CONFIG_DIR="${FZF_FS_CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/fzf-fs.d}";
        FzfFsDaemon__create_session
    };
    function FzfFsDaemon__san () 
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
    FzfFsDaemon__san ret;
    builtin typeset -i ret;
    FzfFsDaemon__main "$@";
    ret="$?";
    FzfFsDaemon__san -f FzfFsDaemon__create_daemon FzfFsDaemon__create_fifo FzfFsDaemon__create_session FzfFsDaemon__kill_daemon FzfFsDaemon__main FzfFsDaemon__san;
    builtin return "$ret"
}
