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
  export EDITOR='code'
  export VISUAL='code'
  export IS_SSH=0
fi

# -------------------------
# Aliases
# -------------------------
alias cat="bat"     # Reemplazo básico de cat

alias ls='lsd'      # Reemplazo básico de ls
alias ll='lsd -lh'  # Vista larga con iconos y detalles
alias la='lsd -lha' # Todo, incluyendo ocultos
alias lt='lsd --tree --depth=2'   # Vista en árbol (2 niveles)
alias ltt='lsd --tree --depth=3'   # Vista en árbol (2 niveles)

alias dots="code ~/Hyprland-Dots && cd ~/Hyprland-Dots"
alias cht="/usr/local/bin/cht.sh"
alias codeipynb="code --enable-proposed-api ms-toolsai.jupyter --enable-proposed-api ms-python.python ."

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

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
# Comands History
# -------------------------
HISTFILE="$HOME/.zsh_history" # Archivo del historial
HISTSIZE=10000            # Cantidad de comandos en memoria
SAVEHIST=10000            # Cantidad de comandos guardados en archivo
setopt EXTENDED_HISTORY   # Formato con timestamp (como el que copiaste)
setopt INC_APPEND_HISTORY # Guardar inmediatamente
setopt APPEND_HISTORY     # No sobreescribir, sino agregar
setopt SHARE_HISTORY      # Compartir entre terminales abiertas
setopt HIST_IGNORE_DUPS   # No guardar duplicados consecutivos
setopt HIST_IGNORE_SPACE      # No guardar comandos que empiecen con espacio
setopt HIST_EXPIRE_DUPS_FIRST     # Eliminar duplicados antiguos automáticamente

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

