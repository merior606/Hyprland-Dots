# -------------------------
# Powerlevel10k Instant Prompt
# -------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -------------------------
# PATH & ENV
# -------------------------
export PATH=/usr/lib/openmpi/bin:$HOME/bin:$HOME/.local/bin:$HOME/.local/share:/usr/local/bin:$PATH
export LD_LIBRARY_PATH=/usr/lib/openmpi/lib:$LD_LIBRARY_PATH
export LIBVIRT_DEFAULT_URI="qemu:///system"
export TERMINAL=kitty

# -------------------------
# Editor
# -------------------------
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
  export VISUAL='vim'
  export IS_SSH=1
else
  export EDITOR='code -n -w'
  export VISUAL='code -n -w'
  export IS_SSH=0
fi

# -------------------------
# Aliases
# -------------------------
alias ls="lsd"
alias cat="bat"
alias dots="code ~/dotfiles && cd ~/dotfiles"
alias cdd="cd ~/Desktop"
alias cht="~/.config/cheat/cht.sh"
alias codeipynb="code --enable-proposed-api ms-toolsai.jupyter --enable-proposed-api ms-python.python ."

# -------------------------
# Completion System
# -------------------------
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' verbose true

# -------------------------
# Plugins (manual load)
# -------------------------
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -------------------------
# Git prompt (builtin)
# -------------------------
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt prompt_subst

# -------------------------
# Sudo plugin
# -------------------------
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N sudo-command-line
# Defined shortcut keys: [Esc] [Esc]
bindkey "\e\e" sudo-command-line

# -------------------------
# Powerlevel10k
# -------------------------

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

