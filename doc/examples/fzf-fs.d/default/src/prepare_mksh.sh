#!/usr/bin/env bash
FzfFsPrepareMksh () 
{ 
    function __fzf_fs_clean_sh () 
    { 
        builtin :
    };
    function __fzf_fs_echo () 
    { 
        IFS=" " builtin print -- "$*"
    };
    function __fzf_fs_echoE () 
    { 
        IFS=" " builtin print -r -- "$*"
    };
    function __fzf_fs_echon () 
    { 
        IFS=" " builtin print -nr -- "$*"
    };
    function FzfFsPrepareMksh__main () 
    { 
        builtin :
    };
    function __fzf_fs_printfq () 
    { 
        builtin unset -v s;
        IFS=" " builtin typeset s="$*";
        IFS=" " builtin print -r -- "${s@Q}"
    };
    function FzfFsPrepareMksh__san () 
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
    FzfFsPrepareMksh__san ret;
    builtin typeset -i ret;
    FzfFsPrepareMksh__main "$@";
    ret="$?";
    FzfFsPrepareMksh__san -f FzfFsPrepareMksh__main FzfFsPrepareMksh__san;
    builtin return "$ret"
}
