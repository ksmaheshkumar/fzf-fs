#!/usr/bin/env bash
FzfFsVersion () 
{ 
    function FzfFsVersion__main () 
    { 
        FzfFsVersion__version
    };
    function FzfFsVersion__version () 
    { 
        builtin unset -v version;
        builtin typeset version=v0.2.2;
        if [[ -n "$KSH_VERSION" ]]; then
            command printf '%s\n' "$version";
        else
            builtin unset -v md5sum;
            builtin typeset md5sum="$(command md5sum "$source")";
            command printf '%s\n' "${version} (${md5sum%  *})";
        fi
    };
    function FzfFsVersion__san () 
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
    FzfFsVersion__san ret;
    builtin typeset -i ret;
    FzfFsVersion__main "$@";
    ret="$?";
    FzfFsVersion__san -f FzfFsVersion__main FzfFsVersion__san FzfFsVersion__version;
    builtin return "$ret"
}
