# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set locale to avoid iconv error
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Suppress Powerlevel10k instant prompt warning
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Aliases
alias vv='nvim'
alias f='fzf'
alias gd='gotodesktop'
alias cls='clear'
alias wr='writenote'
alias t='tmux'
alias nv='nvim .'
alias ks='t kill-server'
alias tls='t ls'

#git alias
alias gs='git status'

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# export PATH="$HOME/.zig:$PATH"
# export PATH="/usr/local/opt/tcl-tk/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)

source $ZSH/oh-my-zsh.sh
source <(fzf --zsh)

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
function whereis {
    command -v "$1"
}

function la {
    if [ "$1" == "hidden" ]; then
        ls -a
    else
        ls
    fi
}

function notebook {
	cd ~/desktop/notes/notebooks
	jupyter lab
}

function Get-Calendar {
    monthName="${1:-$(date '+%b')}"
    year="${2:-$(date '+%Y')}"

    cal -h "$monthName" "$year"
}

function remove {
    if [ -n "$1" ]; then
        rm -rf "$1"
        echo "Successfully removed $1"
    else
        echo "Please enter the name of the file/folder you would like to remove"
    fi
}

function yt {
    if [ "$1" == "hist" ]; then
        open "https://www.youtube.com/feed/history"
    elif [ -z "$1" ]; then
        open "https://www.youtube.com"
    else
        echo "Invalid command: commands available=> hist"
    fi
}

function gd {
    cd "~/Desktop"
}

function Get-InternetStatus {
    network=$(networksetup -getairportnetwork en0 | awk -F": " '{print $2}')
    if [ -n "$network" ]; then
        echo "Connected to $network"
    else
        echo "Offline"
    fi
}

function getwifipasswords {
    networksetup -listpreferredwirelessnetworks en0 | while read -r line; do
        networksetup -getairportpassword en0 "$line"
        echo "------------------------"
    done
}

function readwifinearme {
    airport -s
}

function writenote {
    d=$(date)
    month=$(date '+%b' | tr '[:upper:]' '[:lower:]')
    date=$(date '+%d')
    year=$(date '+%Y')

    dirName="${month}${year}"
    dirPath="$HOME/Desktop/notes/self/$dirName"
    fileName="${date}${month}.md"

    if [ ! -d "$dirPath" ]; then
        mkdir -p "$dirPath"
    fi

    cd "$dirPath"

    nvim "$fileName"
}


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
