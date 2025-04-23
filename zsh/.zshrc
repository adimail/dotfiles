if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Aliases
alias f='fzf'
alias cls='clear'
alias t='tmux'
alias nv='nvim .'
alias tls='t ls'
alias sessionizer='~/scripts/sessionizer'
alias gclt='~/scripts/gclt'
alias newproj='~/scripts/newproject'
alias countdown='~/scripts/countdown'
alias grepforllm='~/scripts/grepforllm'

#git alias
alias gs='git status'
alias G='lazygit'
alias gitl="git log --graph --decorate --all --pretty=format:'%C(auto)%h%d %C(#888888)(%an; %ar)%Creset %s'"

# Vim
alias n='nvim $(fzf)'

# Node
alias ni='npm install'
alias nd='npm run dev'
alias ns='npm run start'
alias nb='npm run build'

# Other
alias cr='clear'
alias c='cd $(fd --type directory | fzf)'

# Python
export PATH=$HOME/Library/Python/3.9/bin:$PATH

setopt interactive_comments
setopt autocd
setopt inc_append_history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# export PATH=$HOME/bin:/usr/local/bin:$PATH
# export PATH="$HOME/.zig:$PATH"
# export PATH="/usr/local/opt/tcl-tk/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"
export PATH="/Applications/MiKTeX Console.app/Contents/Resources/miktex/bin:$PATH"


ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

DISABLE_MAGIC_FUNCTIONS="true"
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)

source $ZSH/oh-my-zsh.sh
source <(fzf --zsh)

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

function whereis {
    command -v "$1"
}

function srv() {
    local port=${1:-3000}
    if lsof -iTCP:$port -sTCP:LISTEN &>/dev/null; then
        echo "Error: Port $port is already in use."
        return 1
    fi
    echo "Starting Python HTTP server on port $port..."
    python3 -m http.server $port
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
        echo "Error: File '$file' not found."
    fi
}

function notebook {
	cd ~/notes/notebooks
	jupyter lab
}

function writenote {
    # Get current date details
    month=$(date '+%b' | tr '[:upper:]' '[:lower:]')
    date=$(date '+%d')
    year=$(date '+%Y')

    # Define directory and file paths
    dirName="${month}${year}"
    dirPath="$HOME/personal/notes/self/$dirName"
    fileName="${date}${month}.md"

    # Ensure the directory exists
    mkdir -p "$dirPath"

    # Define tmux session name
    session_name="notes"

    if [[ -z "$TMUX" ]]; then
        # Not inside tmux, check if the session exists
        if tmux has-session -t "$session_name" 2>/dev/null; then
            tmux attach-session -t "$session_name"
        else
            # Create a new session and open the note
            tmux new-session -s "$session_name" -c "$dirPath" -d
            tmux send-keys -t "$session_name" "nvim $fileName" C-m
            tmux attach-session -t "$session_name"
        fi
    else
        # Already inside a tmux session
        if ! tmux has-session -t "$session_name" 2>/dev/null; then
            # Create a new detached session
            tmux new-session -ds "$session_name" -c "$dirPath"
        fi
        # Open the note in the existing session
        tmux switch-client -t "$session_name"
        tmux send-keys -t "$session_name" "nvim $fileName" C-m
    fi
}

# Kill tmux session by name
tks() {
  if [[ -z "$1" ]]; then
    echo "Please provide a session name."
    return 1
  fi

  tmux kill-session -t "$1"
}

# Attach to tmux session by name
ta() {
  if [[ -z "$1" ]]; then
    echo "Please provide a session name to attach to."
    return 1
  fi

  tmux attach-session -t "$1"
}

# Function: tlogs
# Usage:
#   tlogs             - Opens the base logs directory.
#   tlogs [subdir]    - Opens the specified subdirectory under ~/personal/logs/tmux.
#   tlogs -ui         - Runs python3 ~/personal/logs/tmux/run.py.
tlogs() {
    local base_dir="$HOME/personal/logs/tmux"

    # Ensure no more than one argument is provided.
    if [[ $# -gt 1 ]]; then
        echo "Usage: tlogs [subdirectory]" >&2
        return 1
    fi

    # If the argument is exactly "-ui", run the Python script.
    if [[ $# -eq 1 && "$1" == "-ui" ]]; then
        python3 "$base_dir/run.py"
        return $?
    fi

    # Determine the target directory: either base or base/subdirectory.
    local target_dir="$base_dir"
    if [[ $# -eq 1 ]]; then
        target_dir="$base_dir/$1"
    fi

    # Check if the target directory exists.
    if [[ -d "$target_dir" ]]; then
        open "$target_dir"
        echo "Opening: $target_dir"
    else
        echo "Error: Directory '$target_dir' does not exist." >&2
        return 2
    fi
}

tk0() {
  tmux kill-session -t 0
}

function cursor {
  open -a "/Applications/Cursor.app" "$@"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# perl
source ${HOME}/perl5/perlbrew/etc/bashrc

PATH="/Users/aditya/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/aditya/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/aditya/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/aditya/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/aditya/perl5"; export PERL_MM_OPT;

# JAVA
export JAVA_HOME=$(/usr/libexec/java_home -v 23.0.2)
export PATH=$JAVA_HOME/bin:$PATH

# pnpm
export PNPM_HOME="/Users/aditya/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export HOMEBREW_NO_AUTO_UPDATE=1
