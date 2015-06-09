#!/usr/bin/env bash
FzfFsCore () 
{ 
    function FzfFsCore__buffer () 
    { 
        builtin unset -v checksum cursor_off cursor_on cwd file file_inode;
        builtin typeset -a cwd;
        builtin typeset cursor_on="$(command tput cnorm || command tput ve)" cursor_off="$(command tput civis || command tput vi)" checksum file file_inode;
        FzfFsCore__init_cwd;
        FzfFsCore__complete_cwd;
        FzfFsCore__dump_cwd | command tee "${FZF_FS_CONFIG_DIR}/cache/clients/${FZF_FS_CLIENT}/cwd.client" > "${FZF_FS_CONFIG_DIR}/cache/sessions/${FZF_FS_SESSION}/var/cwd.session";
        FzfFsCore__checksum;
        FzfFsCore__show_cursor 0;
        while builtin :; do
            case "$FZF_FS_BUFFER" in 
                quit)
                    builtin return 0
                ;;
                reload)
                    builtin return 111
                ;;
                *)
                    FzfFsCore__navigator
                ;;
            esac;
        done
    };
    function FzfFsCore__checksum () 
    { 
        checksum="$(command md5sum <<-SUM
li${LC_COLLATE}${FZF_FS_LS_OPTS#-}${FZF_FS_LS_SYMLINK//-/}${FZF_FS_LS_REVERSE}${FZF_FS_LS_HIDDEN}${FZF_FS_LS_CLICOLOR}${FZF_FS_SORT}${cwd[4]}
SUM
)";
        checksum="${checksum[9]%% *}"
    };
    function FzfFsCore__complete_cwd () 
    { 
        builtin unset -v tmp;
        builtin typeset tmp;
        __ls_get_inode "cwd[4]" ".";
        cwd[4]="${cwd[4]%% *}";
        __ls_get_inode "tmp" "..";
        cwd[1]="${tmp#[0-9]* }";
        cwd[2]="${tmp%% *}"
    };
    function FzfFsCore__console () 
    { 
        FzfFsCore__show_cursor 1;
        builtin unset -v cmd console;
        builtin typeset -a console;
        builtin typeset cmd;
        console[2]=0;
        console[4]=0;
        console[5]=0;
        console[6]=0;
        for cmd in "${c[@]}";
        do
            console[0]="${FZF_FS_CONFIG_DIR}/cache/sessions/${FZF_FS_SESSION}/bin/console/${cmd%% *}";
            if [[ "$cmd" == "${cmd/ /}" ]]; then
                console[1]=;
            else
                console[1]="${cmd#* }";
            fi;
            if [[ -f "${console[0]}" ]]; then
                console[3]="$cmd";
                builtin eval . "${console[0]}" "${console[1]}";
            else
                builtin break;
            fi;
        done;
        FzfFsCore__show_cursor 0
    };
    function FzfFsCore__dump_cwd () 
    { 
        builtin unset -v i;
        builtin typeset i;
        for i in "${!cwd[@]}";
        do
            command printf '%s\n' "cwd[$i]=\"${cwd[$i]}\"";
        done;
        command printf '%s\n' "file=\"${file}\"" "file_inode=\"${file_inode}\""
    };
    function FzfFsCore__dump_env () 
    { 
        command printf '%s\n' "#!/usr/bin/env bash" "EDITOR=\"${EDITOR}\"" "FZF_FS_BG_BLACK=\"${FZF_FS_BG_BLACK}\"" "FZF_FS_COLORSCHEME=\"${FZF_FS_COLORSCHEME}\"" "FZF_FS_EXTENDED=\"${FZF_FS_EXTENDED}\"" "FZF_FS_EXTENDED_EXACT=\"${FZF_FS_EXTENDED_EXACT}\"" "FZF_FS_INLINE_INFO=\"${FZF_FS_INLINE_INFO}\"" "FZF_FS_INSENSITIV=\"${FZF_FS_INSENSITIV}\"" "FZF_FS_LS_CLICOLOR=\"${FZF_FS_LS_CLICOLOR}\"" "FZF_FS_LS_COMMAND=\"${FZF_FS_LS_COMMAND}\"" "FZF_FS_LS_COMMAND_COLOR=\"${FZF_FS_LS_COMMAND_COLOR}\"" "FZF_FS_LS_HIDDEN=\"${FZF_FS_LS_HIDDEN}\"" "FZF_FS_LS_REVERSE=\"${FZF_FS_LS_REVERSE}\"" "FZF_FS_LS_SYMLINK=\"${FZF_FS_LS_SYMLINK}\"" "FZF_FS_NO_HSCROLL=\"${FZF_FS_NO_HSCROLL}\"" "FZF_FS_NO_MOUSE=\"${FZF_FS_NO_MOUSE}\"" "FZF_FS_NO_SORT=\"${FZF_FS_NO_SORT}\"" "FZF_FS_OPENER=\"${FZF_FS_OPENER}\"" "FZF_FS_OPENER_DEFAULT=\"${FZF_FS_OPENER_DEFAULT}\"" "FZF_FS_SENSITIV=\"${FZF_FS_SENSITIV}\"" "FZF_FS_SHOW_CURSOR=\"${FZF_FS_SHOW_CURSOR}\"" "FZF_FS_STATUSBAR_TOP=\"${FZF_FS_STATUSBAR_TOP}\"" "FZF_FS_TAC=\"${FZF_FS_TAC}\"" "FZF_FS_TIEBREAK=\"${FZF_FS_TIEBREAK}\"" "LC_COLLATE=\"${LC_COLLATE}\"" "LC_COLLATE_OLD=\"${LC_COLLATE_OLD}\"" "PAGER=\"${PAGER}\"" "TERMINAL=\"${TERMINAL}\""
    };
    function FzfFsCore__enter_file () 
    { 
        if [[ -d "$file" ]]; then
            cwd[3]="$file";
            builtin cd "${cwd[3]}" && FzfFsCore__update_cwd;
        else
            builtin unset -v c;
            builtin typeset -a c;
            c="open_with ${FZF_FS_OPENER} ${file}";
            FzfFsCore__console;
        fi
    };
    function FzfFsCore__fzf () 
    { 
        FzfFsCore__san prompt;
        builtin typeset +i prompt;
        case "$1" in 
            navigator)
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
    function FzfFsCore__init_cwd () 
    { 
        cwd[0]="/";
        cwd[3]="$FZF_FS_CWD";
        if [[ "${cwd[3]}" == ".." ]]; then
            cwd[3]="${PWD%/*}";
        else
            if [[ "${cwd[3]:-.}" == \. ]]; then
                cwd[3]="$PWD";
            else
                if [[ "${cwd[3]}" == \- ]]; then
                    cwd[3]="$OLDPWD";
                else
                    if [[ -d "${cwd[3]}" ]]; then
                        cwd[3]="${cwd[3]%/}";
                    else
                        __fzf_fs_echoE "${source}:Error:79: Not a directory: '${cwd[3]}'" 1>&2;
                        builtin return 79;
                    fi;
                fi;
            fi;
        fi;
        cwd[3]="${cwd[3]:-${cwd[0]}}";
        [[ "$PWD" == "${cwd[3]}" ]] || builtin cd "${cwd[3]}"
    };
    function FzfFsCore__list () 
    { 
        case "$1" in 
            navigator)
                LS_CHECKSUM="$checksum" LS_COLOR="$FZF_FS_LS_CLICOLOR" LS_DIR_NAME="${FZF_FS_CONFIG_DIR}/cache/sessions/${FZF_FS_SESSION}/var/ls" LS_FILE_INODE="${cwd[4]}" LS_FILE_NAME="." LS_FLAG_a="$FZF_FS_LS_HIDDEN" LS_FLAG_i="1" LS_FLAG_l="1" LS_FLAG_r="$FZF_FS_LS_REVERSE" LS_HOOK_POST_TEE="1" LS_HOOK_PRAE="tail -n +2" __ls_do
            ;;
            console)
                command find -H "${FZF_FS_CONFIG_DIR}/console/." ! -name . | command sed "s#^${FZF_FS_CONFIG_DIR}/console/./##" | command sort -u
            ;;
        esac
    };
    function FzfFsCore__main () 
    { 
        builtin eval "$@"
    };
    function FzfFsCore__navigator () 
    { 
        builtin unset -v key navigator;
        builtin typeset key;
        builtin typeset -a navigator;
        FzfFsCore__show_cursor 0;
        while [[ -n "${cwd[3]}" ]]; do
            navigator[0]="$(FzfFsCore__select "navigator" "${cwd[3]}")";
            if [[ "${navigator[0]}" == '
'* ]]; then
                navigator[0]="${navigator[0]/'
'/}";
                navigator[1]="${navigator[0]%% *}";
                if [[ "${navigator[1]}" == "${cwd[4]}" ]]; then
                    builtin continue;
                else
                    FzfFsCore__set_file;
                    FzfFsCore__enter_file;
                fi;
            else
                key="${navigator[0]/'
'*/}";
                navigator[0]="${navigator[0]/*'
'/}";
                if [[ -n "${navigator[0]}" ]]; then
                    navigator[1]="${navigator[0]%% *}";
                    [[ "${navigator[1]}" == "${cwd[4]}" ]] || FzfFsCore__set_file;
                    FzfFsCore__show_cursor 0;
                    if [[ "$FZF_FS_MODE" == "normal" ]]; then
                        builtin . "${FZF_FS_CONFIG_DIR}/cache/sessions/${FZF_FS_SESSION}/etc/keybindings_normal";
                    else
                        if [[ "$FZF_FS_MODE" == "search" ]]; then
                            builtin . "${FZF_FS_CONFIG_DIR}/cache/sessions/${FZF_FS_SESSION}/etc/keybindings_search";
                        fi;
                    fi;
                    FzfFsCore__console;
                else
                    FZF_FS_MODE=normal;
                    FzfFsCore__show_cursor 0;
                fi;
            fi;
        done
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
            navigator)
                FzfFsCore__list "navigator" | FzfFsCore__fzf "navigator" "$2" | __ls_remove_color
            ;;
            console)
                FzfFsCore__list "console" | FzfFsCore__fzf "console" "$2"
            ;;
        esac
    };
    function FzfFsCore__set_file () 
    { 
        file="${cwd[3]}/$(__ls_find_inode : "${cwd[3]}" "${navigator[1]}")";
        file="${file//\/\//\/}";
        __ls_get_inode "file_inode" "$file";
        file_inode="${file_inode%% *}"
    };
    function FzfFsCore__show_cursor () 
    { 
        [[ "$FZF_FS_SHOW_CURSOR" -eq 0 ]] && { 
            case "$1" in 
                0)
                    command printf "$cursor_off"
                ;;
                1)
                    command printf "$cursor_on"
                ;;
            esac
        }
    };
    function FzfFsCore__update_cwd () 
    { 
        FzfFsCore__complete_cwd && FzfFsCore__checksum && FzfFsCore__dump_cwd | command tee "${FZF_FS_CONFIG_DIR}/cache/clients/${FZF_FS_CLIENT}/cwd.client" > "${FZF_FS_CONFIG_DIR}/cache/sessions/${FZF_FS_SESSION}/var/cwd.session"
    };
    function FzfFsCore__update_env () 
    { 
        FzfFsCore__checksum;
        FzfFsCore__dump_env | command tee;
        "${FZF_FS_CONFIG_DIR}/cache/clients/${FZF_FS_CLIENT}/env.client" > "${FZF_FS_CONFIG_DIR}/cache/sessions/${FZF_FS_SESSION}/var/env.session"
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
