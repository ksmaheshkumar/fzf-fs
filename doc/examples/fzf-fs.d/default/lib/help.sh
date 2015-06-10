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
    builtin unset -v ret;
    builtin typeset -i ret;
    FzfFsHelp__main "$@";
    ret="$?";
    builtin unset -f FzfFsHelp__help FzfFsHelp__main;
    builtin return "$ret"
}
