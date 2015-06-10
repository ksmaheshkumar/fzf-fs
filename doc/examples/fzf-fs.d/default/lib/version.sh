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
    builtin unset -v ret;
    builtin typeset -i ret;
    FzfFsVersion__main "$@";
    ret="$?";
    builtin unset -f FzfFsVersion__main FzfFsVersion__version;
    builtin return "$ret"
}
