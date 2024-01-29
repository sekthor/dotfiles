# Colors
PS1_DARK_RED="\[\e[0;31m\]"
PS1_DARK_OLIVE="\[\e[0;32m\]"
PS1_DARK_YELLOW='\[\e[0;33m\]'
PS1_DARK_BLUE='\[\e[0;34m\]'
PS1_DARK_MAGENTA='\[\e[0;35m\]'
PS1_DARK_GREEN='\[\e[0;36m\]'
PS1_DARK_GRAY='\[\e[0;37m\]'
PS1_LIGHT_RED="\[\e[1;31m\]"
PS1_LIGHT_OLIVE="\[\e[1;32m\]"
PS1_LIGHT_YELLOW='\[\e[1;33m\]'
PS1_LIGHT_BLUE='\[\e[1;34m\]'
PS1_LIGHT_MAGENTA='\[\e[1;35m\]'
PS1_LIGHT_GREEN='\[\e[1;36m\]'
PS1_LIGHT_GRAY='\[\e[1;37m\]'
PS1_COLOR_CLEAR="\[\e[m\]"

# Emojis
EMJ_SKULL=💀
EMJ_SUCCESS=🚀

# Variables
PS1_GITON=1
PS1_KUBEON=1
PS1_USER=0
PS1_RETURN_SYMBOL=1

function ps1 () {
    case $1 in
    "giton")
        PS1_GITON=1
        ;;
    "gitoff")
        PS1_GITON=0
        ;;
    "kubeon")
        PS1_KUBEON=1
        ;;
    "kubeoff")
        PS1_KUBEON=0
        ;;
    "useron")
        PS1_USER=1
        ;;
    "useroff")
        PS1_USER=0
        ;;
    "symbolon")
        PS1_RETURN_SYMBOL=1
        ;;
    "symboloff")
        PS1_RETURN_SYMBOL=0
        ;;
    *)
        echo "unkown option!"
        ;;
    esac
}

PROMPT_COMMAND=__prompt_command

git_ps1() {
    GIT_BRANCH="$(__git_ps1 "%s")"
    if [[ $PS1_GITON == 1 && -n $GIT_BRANCH ]];
    then
        echo ":${PS1_DARK_OLIVE}${GIT_BRANCH}${PS1_COLOR_CLEAR}"
    else
        echo ""
    fi
}

kube_ps1() {
    if [[ $PS1_KUBEON == 0 ]]; then
       return
    fi

    local KUBE_CONTEXT=$(kubectl config view --minify -o jsonpath='{.current-context}')

    local KUBE_NAMESPACE=$(kubectl config view --minify -o jsonpath='{..namespace}')

    if [[ $KUBE_CONTEXT == p* ]];
    then
        local CTX_COLOR=${PS1_DARK_RED}
    else
        local CTX_COLOR=${PS1_DARK_YELLOW}
    fi
    echo "(${CTX_COLOR}${KUBE_CONTEXT}${PS1_COLOR_CLEAR}:${PS1_LIGHT_GREEN}${KUBE_NAMESPACE}${PS1_COLOR_CLEAR})"
}

function user_ps1 () {
    if [[ $PS1_USER == 0 ]]; then
        return
    fi
    echo "${PS1_DARK_GREEN}\\u${COLOR_CLEAR} "

}

__prompt_command() {
    local EXIT="$?"

    if [[ $EXIT != 0 ]];
    then
        local RETURN_SYMBOL="${EMJ_SKULL} "
    else
        local RETURN_SYMBOL="${EMJ_SUCCESS} "
    fi

    if [[ $PS1_RETURN_SYMBOL == 0 ]]; then
        local RETURN_SYMBOL=""
    fi

    PS1="${RETURN_SYMBOL}[$(user_ps1)${PS1_LIGHT_GREEN}\W${PS1_COLOR_CLEAR}$(git_ps1)]$(kube_ps1)$ "
}
