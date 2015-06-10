#!/usr/bin/env bash
FzfFsPrepareBash () 
{ 
    function __fzf_fs_clean_sh () 
    { 
        [[ "$FZF_FS_GLOBINORE_OLD" == FZF_FS_GLOBINORE_OLD ]] || builtin typeset -x GLOBIGNORE="$FZF_FS_GLOBINORE_OLD";
        builtin unset -v o;
        builtin typeset o;
        for o in "${FZF_FS_BASH_OPTS_OLD[@]}";
        do
            builtin $o;
        done
    };
    function __fzf_fs_echo () 
    { 
        IFS=" " builtin printf '%b\n' "$*"
    };
    function __fzf_fs_echoE () 
    { 
        IFS=" " builtin printf '%s\n' "$*"
    };
    function __fzf_fs_echon () 
    { 
        IFS=" " builtin printf '%s' "$*"
    };
    function FzfFsPrepareBash__main () 
    { 
        builtin unset -v FZF_FS_BASH_OPTS_OLD FZF_FS_GLOBINORE_OLD REPLY;
        builtin typeset -g FZF_FS_GLOBINORE_OLD;
        if [[ ${GLOBIGNORE+x} == x ]]; then
            FZF_FS_GLOBINORE_OLD="$GLOBIGNORE";
        else
            FZF_FS_GLOBINORE_OLD=FZF_FS_GLOBINORE_OLD;
        fi;
        builtin unset -v GLOBIGNORE;
        builtin typeset -ga FZF_FS_BASH_OPTS_OLD;
        builtin typeset REPLY;
        while builtin read -r; do
            FZF_FS_BASH_OPTS_OLD+=("$REPLY");
        done < <(builtin shopt -p);
        builtin shopt -u dotglob;
        builtin shopt -s nullglob
    };
    function __fzf_fs_printfq () 
    { 
        IFS=" " builtin printf "%q\n" "$*"
    };
    builtin unset -v ret;
    builtin typeset -i ret;
    FzfFsPrepareBash__main "$@";
    ret="$?";
    builtin unset -f FzfFsPrepareBash__main;
    builtin return "$ret"
}
