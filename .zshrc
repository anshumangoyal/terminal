#!/bin/zsh -e
stty -echoctl

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="gallifrey"

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
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

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
# HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git brew kubectl docker zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search
    git-flow-completion
)

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

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
alias k="kubectl"
alias d="docker"
alias kgp="kubectl get pods"
alias echo="echo -e"

unset PATH
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/substring
if [[ $(uname -p) == 'arm' ]]; then
    PATH=$PATH:/opt/homebrew/bin
fi

if [[ $(python3 -c "import distro;print(str(distro.name()).lower())") == "darwin" ]]; then
    PREFIX=$(brew --prefix)
else
    PREFIX=/usr/bin
fi

export FPATH="$PREFIX/share/zsh/site-functions:$FPATH"
source $ZSH/oh-my-zsh.sh

unset PATH
addPaths=(
    $PREFIX/opt/gnu-sed/libexec/gnubin
    $PREFIX/opt/curl/bin
    $PREFIX/opt/grep/libexec/gnubin
    $PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin
    $PREFIX/opt/python@3.8/bin
    $PREFIX/opt/openssl@3/bin
    $PREFIX/opt/sqlite/bin
    $PREFIX/opt/postgresql@9.6/bin
    $PREFIX/bin $PREFIX/sbin
    /bin /usr/bin /usr/local/bin
    /sbin /usr/sbin /usr/local/sbin
    $HOME/.krew/bin
    $HOME/.fzf
    $HOME/.local/bin
)
for s in "${addPaths[@]}"; do
    if [[ -d $s ]]; then
        export PATH="$PATH:$s"
    fi
done

if [[ $(uname -s) == 'Darwin' ]]; then
    eval "$(brew shellenv)"
fi

# Source Functions
if [[ -f ~/Code/terminal/.func_profile ]]; then
    source ~/Code/terminal/.func_profile
fi

# Source FZF (Fuzzy)
if [[ -f $HOME/Code/terminal/.fzf/completion.zsh ]]; then
    source "$HOME/Code/terminal/.fzf/completion.zsh" 2>/dev/null
fi
if [[ -f $HOME/Code/terminal/.fzf/key-bindings.zsh ]]; then
    source "$HOME/Code/terminal/.fzf/key-bindings.zsh" 2>/dev/null
fi

if [[ -f $PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc ]]; then
    source $PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
fi

export JENKINS_HOME="/var/lib/jenkins"
export E2E_PASSWORD='7735R!U-qN#r'
export LOG_LEVEL='INFO'
export CI_USER_TOKEN='ci.user:69cdf75b-91f6-4aeb-ba3c-c4b8751ce282'
export TESTING_USER_TOKEN='testing.user:0d081fc8-ccdb-4018-8aee-4454055307b5-4acc-bc39-c28551a87495'
export GCS_VOLUME=$HOME/GcsData
export KUBE_CONFIGS_PATH=$HOME/GcsData
export CREDS_PATH=$HOME/GcsData/creds.yaml
export PROMPT_EOL_MARK=''

# activate venv
if [[ -f ~/Code/venv/bin/activate ]]; then
    source ~/Code/venv/bin/activate
fi
