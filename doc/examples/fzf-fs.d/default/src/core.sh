#!/usr/bin/env bash
FzfFsCore () 
{ 
    function FzfFsCore__buffer () 
    { 
        FzfFsCore__san browser;
        builtin typeset -a browser;
        browser[0]="/";
        browser[3]="$1";
        if [[ "${browser[3]}" == ".." ]]; then
            browser[3]="${PWD%/*}";
        else
            if [[ "${browser[3]:-.}" == \. ]]; then
                browser[3]="$PWD";
            else
                if [[ "${browser[3]}" == \- ]]; then
                    browser[3]="$OLDPWD";
                else
                    if [[ -d "${browser[3]}" ]]; then
                        browser[3]="${browser[3]%/}";
                    else
                        __fzf_fs_echoE "${source}:Error:79: Not a directory: '${browser[3]}'" 1>&2;
                        builtin return 79;
                    fi;
                fi;
            fi;
        fi;
        browser[3]="${browser[3]:-${browser[0]}}";
        __fzffs_cursor 0;
        while builtin :; do
            case "$FZF_FS_BUFFER" in 
                quit)
                    builtin return 0
                ;;
                reload)
                    builtin return 111
                ;;
                *)
                    __fzffs_browser "${browser[3]}"
                ;;
            esac;
        done
    };
    function FzfFsCore__fzf () 
    { 
        FzfFsCore__san prompt;
        builtin typeset +i prompt;
        case "$1" in 
            browser)
                if [[ "$FZF_FS_MODE" == "normal" ]]; then
                    FzfFsCore FzfFsCore__prompt "$2";
                    FZF_FLAG_ANSI="$FZF_FS_LS_CLICOLOR" FZF_FLAG_PROMPT="$prompt" FZF_FLAG_COLOR="$FZF_FS_COLORSCHEME" FZF_FLAG_NO_MOUSE="$FZF_FS_NO_MOUSE" FZF_FLAG_REVERSE="$FZF_FS_STATUSBAR_TOP" FZF_FLAG_BLACK="$FZF_FS_BG_BLACK" FZF_FLAG_NO_HSCROLL="$FZF_FS_NO_HSCROLL" FZF_FLAG_INLINE_INFO="$FZF_FS_INLINE_INFO" FZF_FLAG_NO_SORT=1 FZF_FLAG_INSENSITIVE= FZF_FLAG_SENSITIVE= FZF_FLAG_EXTENDED_EXACT= FZF_FLAG_EXTENDED= FZF_FLAG_WITH_NTH= FZF_FLAG_NTH= FZF_FLAG_DELIMITER= FZF_FLAG_TIEBREAK= FZF_FLAG_TAC= FZF_FLAG_SELECT_1= FZF_FLAG_EXPECT="f1,f2,f3,f4,q,w,e,r,t,z,u,i,o,p,[,],a,s,d,f,g,h,j,k,l,;,y,x,c,v,b,n,m,Q,W,E,R,T,Z,U,I,O,P,A,S,D,F,G,H,J,K,L,Y,X,C,V,B,N,M,ä,Ä,ö,Ö,ü,Ü,,,.,1,2,3,4,5,6,7,8,9,0,-,=,~,!,@,#,$,%,^,&,*,(,),_,+,{,},:,\",|,<,>,?,ctrl-q,ctrl-w,ctrl-e,ctrl-r,ctrl-t,ctrl-z,ctrl-u,ctrl-i,ctrl-o,ctrl-a,ctrl-s,ctrl-d,ctrl-h,ctrl-l,ctrl-y,ctrl-x,ctrl-c,ctrl-v,alt-q,alt-w,alt-e,alt-r,alt-t,alt-z,alt-u,alt-i,alt-o,alt-p,alt-a,alt-s,alt-d,alt-f,alt-g,alt-h,alt-j,alt-k,alt-l,alt-y,alt-x,alt-c,alt-v,alt-b,alt-n,alt-m,\`,/,\\, " __fzf_wrapper;
                else
                    if [[ "$FZF_FS_MODE" == "find" ]]; then
                        prompt="  >";
                        FZF_FLAG_SELECT_1=1;
                    else
                        prompt="  /";
                        FZF_FLAG_SELECT_1=0;
                    fi;
                    FZF_FLAG_INSENSITIVE=1 FZF_FLAG_EXTENDED_EXACT=1 FZF_FLAG_ANSI="$FZF_FS_LS_CLICOLOR" FZF_FLAG_PROMPT="$prompt" FZF_FLAG_COLOR="$FZF_FS_COLORSCHEME" FZF_FLAG_NO_MOUSE="$FZF_FS_NO_MOUSE" FZF_FLAG_REVERSE="$FZF_FS_STATUSBAR_TOP" FZF_FLAG_BLACK="$FZF_FS_BG_BLACK" FZF_FLAG_NO_HSCROLL="$FZF_FS_NO_HSCROLL" FZF_FLAG_INLINE_INFO="$FZF_FS_INLINE_INFO" FZF_FLAG_EXPECT="ctrl-i";
                    __fzf_wrapper;
                fi
            ;;
            console)
                FZF_FLAG_EXPECT="ctrl-i" FZF_FLAG_EXTENDED=1 FZF_FLAG_NO_SORT=1 FZF_FLAG_PRINT_QUERY=1 FZF_FLAG_PROMPT=":" FZF_FLAG_QUERY="$2" FZF_FLAG_COLOR="$FZF_FS_COLORSCHEME" FZF_FLAG_NO_MOUSE="$FZF_FS_NO_MOUSE" FZF_FLAG_REVERSE="$FZF_FS_STATUSBAR_TOP" FZF_FLAG_BLACK="$FZF_FS_BG_BLACK" FZF_FLAG_NO_HSCROLL="$FZF_FS_NO_HSCROLL" FZF_FLAG_INLINE_INFO="$FZF_FS_INLINE_INFO" __fzf_wrapper
            ;;
        esac
    };
    function FzfFsCore__list () 
    { 
        case "$1" in 
            browser)
                LS_CHECKSUM="${browser[9]}" LS_COLOR="$FZF_FS_LS_CLICOLOR" LS_DIR_NAME="${FZF_FS_CONFIG_DIR}/browser" LS_FILE_INODE="${browser[4]}" LS_FILE_NAME="." LS_FLAG_a="$FZF_FS_LS_HIDDEN" LS_FLAG_i="1" LS_FLAG_l="1" LS_FLAG_r="$FZF_FS_LS_REVERSE" LS_HOOK_POST_TEE="1" LS_HOOK_PRAE="tail -n +2" __ls_do
            ;;
            console)
                command find -H "${FZF_FS_CONFIG_DIR}/console/." ! -name . | command sed "s#^${FZF_FS_CONFIG_DIR}/console/./##" | command sort -u
            ;;
        esac
    };
    function FzfFsCore__prompt () 
    { 
        FzfFsCore__san cols prompt_leng;
        builtin typeset -i prompt_leng;
        builtin typeset -i cols;
        cols="${COLUMNS:-$(__spath_get_cols :)}";
        __spath_do "prompt" "${1/${HOME}/"~"}";
        prompt="  ${USER}@${HOSTNAME}:${prompt} ";
        prompt_leng="${#prompt}"
    };
    function FzfFsCore__select () 
    { 
        case "$1" in 
            browser)
                FzfFsCore FzfFsCore__list "browser" | FzfFsCore FzfFsCore__fzf "browser" "$2" | __ls_remove_color
            ;;
            console)
                FzfFsCore FzfFsCore__list "console" | FzfFsCore FzfFsCore__fzf "console" "$2"
            ;;
        esac
    };
    function FzfFsCore__main () 
    { 
        IFS=" " builtin eval "$*"
    };
    function FzfFsCore__san () 
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
    FzfFsCore__san ret;
    builtin typeset -i ret;
    FzfFsCore__main "$@";
    ret="$?";
    builtin return "$ret"
}
