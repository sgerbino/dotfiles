if command -v gpgconf > /dev/null 2>&1; then
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpg-connect-agent updatestartuptty /bye > /dev/null
fi

function smartcard() {
    local retval=0
    case $1 in
        'load')
            local server
            server=$(smartcard keyserver) && \
                gpg --fetch-keys $server && \
                gpg --card-status && \
                ssh-add -K && \
                smartcard reload
            retval=$?
            ;;
        'reload')
            local key
            key=$(smartcard key) && \
                gpg-connect-agent "scd serialno" "learn --force" /bye && \
                git config --global user.signingkey $key
            retval=$?
            ;;
        'key')
            local key
            key=$(gpg --card-status) && \
                key=$(echo $key | grep 'General key info') && \
                key=$(echo $key | awk -F'/' '{print $2}') && \
                key=$(echo $key | sed 's/ .*//') && \
                echo $key
            retval=$?
            ;;
        'keyserver')
            local server
            server=$(gpg --card-status) && \
                server=$(echo $server | grep 'URL of public key') && \
                server=$(echo $server | awk -F': ' '{print $2}') && \
                echo $server
            retval=$?
            ;;
        *)
            echo "invalid argument:" $1
            retval=1
            ;;
        esac
    return retval
}

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

eval "$(starship init zsh)"

source ~/.config/fzf/fzf.zsh

export EDITOR=nvim
export CC=clang
export CXX=clang++
if command -v ccache > /dev/null 2>&1; then
    export CMAKE_CXX_COMPILER_LAUNCHER=ccache
    export CMAKE_C_COMPILER_LAUNCHER=ccache
fi
export CMAKE_EXPORT_COMPILE_COMMANDS=1
export CLICOLOR_FORCE=1

export ENABLE_LSP_TOOL=1
#if [[ $TERM == "xterm-kitty" ]]; then
#    fastfetch
#else
#    fastfetch --logo-type chafa
#fi

export PATH="$PATH:$HOME/.local/bin"
