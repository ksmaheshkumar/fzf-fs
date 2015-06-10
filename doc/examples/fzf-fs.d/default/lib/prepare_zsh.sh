#!/usr/bin/env bash
FzfFsPrepareZsh () 
{ 
    function __fzf_fs_clean_sh () 
    { 
        builtin setopt +o shwordsplit;
        builtin setopt +o NULL_GLOB;
        builtin unset -v o;
        builtin typeset o;
        for o in "${FZF_FS_ZSH_OPTS_OLD[@]}";
        do
            builtin setopt "$o";
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
    function FzfFsPrepareZsh__main () 
    { 
        builtin unset -v FZF_FS_ZSH_OPTS_OLD;
        builtin set -A FZF_FS_ZSH_OPTS_OLD $(builtin setopt);
        builtin setopt shwordsplit;
        builtin setopt NULL_GLOB;
        builtin setopt +o dotglob
    };
    function __fzf_fs_printfq () 
    { 
        IFS=" " builtin printf "%q\n" "$*"
    };
    builtin unset -v ret;
    builtin typeset -i ret;
    FzfFsPrepareZsh__main "$@";
    ret="$?";
    builtin unset -f FzfFsPrepareZsh__main;
    builtin return "$ret"
}
