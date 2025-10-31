# --- Início do .zshrc clean e otimizado ---

# Caminho padrão do usuário
export ZDOTDIR="$HOME"

# Ativa o Starship
eval "$(starship init zsh)"

# Executa o Fastfetch apenas na primeira aba
if [ -z "$FASTFETCH_SHOWN" ]; then
    fastfetch
    export FASTFETCH_SHOWN=1
fi

# Alias úteis e rápidos
alias cls='clear'
alias ll='ls -lh --color=auto'
alias la='ls -lha --color=auto'
alias grep='grep --color=auto'
alias update='sudo pacman -Syu'
alias ..='cd ..'
alias ...='cd ../..'

# Se o eza estiver instalado, usa ele no lugar do ls
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first --color=always'
    alias ll='eza -lh --icons --group-directories-first --color=always'
    alias la='eza -lha --icons --group-directories-first --color=always'
fi

# Historial mais útil
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Correção automática leve
setopt correct

# Auto-sugestões (se instalado)
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Highlight de sintaxe (se instalado)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Terminal mais rápido e bonito
autoload -Uz compinit && compinit
autoload -Uz promptinit && promptinit

# --- Fim do .zshrc ---

