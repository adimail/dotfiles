if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

alias f='fzf'
alias cls='clear'
alias cr='clear'
alias t='tmux'
alias tls='t ls'
alias nv='nvim .'
alias nva='source ./venv/bin/activate && nv'
alias pxa="source ../venv/bin/activate"

alias sessionizer='~/scripts/sessionizer'
alias gclt='~/scripts/gclt'
alias newproj='~/scripts/newproject'
alias countdown='~/scripts/countdown'
alias grepforllm='~/scripts/grepforllm'
alias openvsc='~/scripts/openvsc'
alias ff='~/scripts/lazyffmpeg.sh'
alias mediadownloader='~/scripts/mediadownloader'

alias d='docker'
alias di='docker images'
alias dvls='docker volume ls'
alias dstats='docker stats --no-stream'
alias dc='docker-compose'
alias dcd='docker-compose down'
alias dcup='docker-compose up -d --build'

alias gs='git status --short'
alias G='lazygit'
alias gitl="git log --graph --decorate --all --pretty=format:'%C(auto)%h%d %C(#888888)(%an; %ar)%Creset %s'"
alias gd="git diff --output-indicator-new='' --output-indicator-old=''"
alias ga='git add'
alias gac='git add . && git commit'
alias gc='git commit'
alias gp='git push'
alias gu='git pull'
alias gl="git log --graph --decorate --all --pretty=format:'%C(auto)%h%d %C(bold)%s%Creset %C(dim)(%an, %ad)%Creset' --date=local"
alias gb='git branch'
alias gi='git init'
alias gcl='git clone'

alias ni='npm install'
alias nd='npm run dev'
alias ns='npm run start'
alias nb='npm run build'

alias c='zi'

setopt interactive_comments
setopt autocd
setopt inc_append_history

zstyle ':completion:*' menu select
_comp_options+=(globdots)

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
DISABLE_MAGIC_FUNCTIONS="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)

source $ZSH/oh-my-zsh.sh
source <(fzf --zsh)

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

function whereis {
    command -v "$1"
}

function srv() {
    local port=${1:-3000}
    if lsof -iTCP:$port -sTCP:LISTEN &>/dev/null; then
        echo "Error: Port $port is already in use." >&2
        return 1
    fi
    echo "Starting Python HTTP server on port $port..."
    python3 -m http.server "$port"
}

function sol() {
    local clear_flag=0
    local file="sol.cpp"

    for arg in "$@"; do
        if [[ "$arg" == "--clear" ]]; then
            clear_flag=1
        else
            file="$arg"
        fi
    done

    if [[ $clear_flag -eq 1 ]]; then
        clear
    fi

    if [[ -f "$file" ]]; then
        g++ -std=c++11 "$file" -o out && ./out
    else
        echo "Error: File '$file' not found." >&2
    fi
}

function notebook {
    cd ~/notes/notebooks && jupyter lab
}

tks() {
  if [[ -z "$1" ]]; then
    echo "Please provide a session name." >&2
    return 1
  fi
  tmux kill-session -t "$1"
}

ta() {
  if [[ -z "$1" ]]; then
    echo "Please provide a session name to attach to." >&2
    return 1
  fi
  tmux attach-session -t "$1"
}

tk0() {
  tmux kill-session -t 0
}

function cursor {
  open -a "/Applications/Cursor.app" "$@"
}

export PATH="/Users/aditya/perl5/bin${PATH:+:${PATH}}"
export PERL5LIB="/Users/aditya/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="/Users/aditya/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"/Users/aditya/perl5\""
export PERL_MM_OPT="INSTALL_BASE=/Users/aditya/perl5"

if [[ -z "$JAVA_HOME" ]]; then
    export JAVA_HOME=$(/usr/libexec/java_home -v 25.0.1 2>/dev/null)
fi
[[ -n "$JAVA_HOME" ]] && export PATH="$JAVA_HOME/bin:$PATH"

export PNPM_HOME="/Users/aditya/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export HOMEBREW_NO_AUTO_UPDATE=1

[ -s "/Users/aditya/.bun/_bun" ] && source "/Users/aditya/.bun/_bun"

export PATH="$HOME/go/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"
export PATH="/Users/aditya/.bun/bin:$PATH"
export PATH="/Users/aditya/.antigravity/antigravity/bin:$PATH"
export PATH="/Applications/MiKTeX Console.app/Contents/Resources/miktex/bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.rbenv/shims:$PATH"
export PATH="/Users/aditya/.opencode/bin:$PATH"
export PATH="/Users/aditya/scripts:$PATH"

unset zle_bracketed_paste
eval "$(zoxide init zsh)"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
