#!/usr/bin/env bash
FzfFsHelp () 
{ 
    function FzfFsHelp__help () 
    { 
        builtin unset -v help;
        { 
            builtin typeset help="$(</dev/fd/0)"
        }  <<-'HELP'
Usage
    [ . ] fzf-fs [ -h | -i | -v | <directory> ]

Options
    -h, --help      Show this instruction
    -i, --init      Initialize configuration directory
    -v, --version   Print version

Environment variables
    FZF_FS_CONFIG_DIR
            ${XDG_CONFIG_HOME:-${HOME}/.config}/fzf-fs.d
HELP

        command printf '%s\n' "$help"
    };
    function FzfFsHelp__main () 
    { 
        FzfFsHelp__help
    };
    function FzfFsHelp__san () 
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
    FzfFsHelp__san ret;
    builtin typeset -i ret;
    FzfFsHelp__main "$@";
    ret="$?";
    FzfFsHelp__san -f FzfFsHelp__help FzfFsHelp__main FzfFsHelp__san;
    builtin return "$ret"
}
