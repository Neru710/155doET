#!/usr/bin/env bash

# installer.sh - Script de Instalação/Atualização para Arch Linux
# (Hyprland, Waybar, Dotfiles, Fontes, Yay, Xwayland, XDG Portal e Diretórios de Usuário)

# --- Variáveis de Configuração ---
PROJECT_NAME="Configurações Hyprland/Waybar"
DOTFILES_REPO="https://github.com/Neru710/155doET.git"   # Repositório de dotfiles
INSTALL_DIR="$HOME/.${PROJECT_NAME// /_}_temp"
DOTFILES_LOCAL_PATH="$INSTALL_DIR/dotfiles"

# --- Funções Auxiliares ---

# Exibir mensagens de status
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Exibir erro e sair
error_exit() {
    echo "ERRO: $1"
    echo "----------------------------------------------------"
    echo "A instalação/atualização falhou."
    echo "----------------------------------------------------"
    exit 1
}

# Verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Copiar e atualizar diretórios de configuração
copy_dotfiles() {
    local source_dir="$1"
    local dest_dir="$2"
    local item_name="$3"

    log_message "Copiando/Atualizando $item_name para $dest_dir..."
    if [ -d "$source_dir" ]; then
        if [ -d "$dest_dir" ]; then
            log_message "Removendo $dest_dir existente antes de copiar..."
            rm -rf "$dest_dir" || error_exit "Falha ao remover $dest_dir."
        fi
        cp -r "$source_dir" "$dest_dir" || error_exit "Falha ao copiar a pasta '$item_name'."
        log_message "Pasta '$item_name' copiada/atualizada."
    else
        log_message "Aviso: Pasta '$item_name' não encontrada em $source_dir. Pulando."
    fi
}

# --- Início do Script ---
log_message "Iniciando instalação/atualização de $PROJECT_NAME..."

# 1. Checar pacman (Arch Linux)
log_message "Verificando pacman..."
if ! command_exists pacman; then
    error_exit "Este script é para Arch Linux e o pacman não foi encontrado."
fi

# 2. Atualizar o sistema
log_message "Atualizando sistema..."
sudo pacman -Syu --noconfirm || error_exit "Falha ao atualizar o sistema."
log_message "Sistema atualizado."

# 3. Instalar pacotes oficiais
PACKAGES=(
    wayland hyprland hyprpaper firefox discord lutris wine-staging
    qbittorrent networkmanager network-manager-applet 
    grim nano neovim flatpak flameshot
    xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr
    gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav
    waybar pavucontrol cava mako sddm thunar engrampa unzip tar unrar
    rofi kitty starship btop zsh lxappearance qt5ct qt6ct kvantum-qt5 git
    ttf-dejavu ttf-liberation ttf-roboto ttf-ubuntu-font-family
    ttf-fira-code ttf-jetbrains-mono noto-fonts noto-fonts-cjk
    noto-fonts-emoji ttf-droid ttf-inconsolata ttf-cascadia-code
    ttf-hack ttf-hack-nerd ttf-fira-sans ttf-nerd-fonts-symbols
    ttf-font-awesome base-devel xorg-xwayland xdg-user-dirs mpv curl
)

log_message "Instalando pacotes oficiais..."
sudo pacman -S --noconfirm --needed "${PACKAGES[@]}" \
    || error_exit "Falha ao instalar pacotes oficiais."
log_message "Pacotes instalados."

# 4. Instalar yay
log_message "Verificando yay..."
if ! command_exists yay; then
    log_message "Clonando e instalando yay..."
    git clone https://aur.archlinux.org/yay.git "$INSTALL_DIR/yay-build" \
        || error_exit "Falha ao clonar yay."
    (cd "$INSTALL_DIR/yay-build" && makepkg -si --noconfirm) \
        || error_exit "Falha ao instalar yay."
    log_message "Yay instalado."
else
    log_message "Yay já instalado."
fi

# 4.2 Instalar temas AUR
install_aur_package() {
    local pkg="$1"
    log_message "Instalando AUR: $pkg"
    yay -S --noconfirm --needed "$pkg" \
        || error_exit "Falha ao instalar AUR: $pkg"
}

AUR_PACKAGES=(
    catppuccin-gtk-theme dracula-gtk-theme nordic-theme materia-gtk-theme
    arc-gtk-theme papirus-icon-theme ttf-firacode-nerd wlogout
)

for pkg in "${AUR_PACKAGES[@]}"; do
    install_aur_package "$pkg"
done

# 5. Starship e shell padrão
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    chsh -s "$ZSH_PATH" || error_exit "Falha ao alterar shell padrão."
    log_message "Shell padrão alterado para zsh."
else
    log_message "Zsh já é shell padrão."
fi

eval "$(starship init zsh)"

# 6. Dotfiles
log_message "Clonando/atualizando dotfiles: $DOTFILES_REPO"
mkdir -p "$INSTALL_DIR" || error_exit "Não foi possível criar $INSTALL_DIR."

if [ -d "$DOTFILES_LOCAL_PATH" ]; then
    (cd "$DOTFILES_LOCAL_PATH" && git pull) \
        || error_exit "Falha ao atualizar dotfiles."
    log_message "Dotfiles atualizados."
else
    git clone "$DOTFILES_REPO" "$DOTFILES_LOCAL_PATH" \
        || error_exit "Falha ao clonar dotfiles."
    log_message "Dotfiles clonados."
fi

# 7. Diretórios padrão do usuário
log_message "Criando diretórios padrão..."
xdg-user-dirs-update || log_message "Aviso: xdg-user-dirs-update falhou."
log_message "Diretórios verificados."

# 8. Copiar configurações
log_message "Copiando configurações Hyprland, Waybar, wlogout e rofi..."
mkdir -p "$HOME/.config"

copy_dotfiles "$DOTFILES_LOCAL_PATH/hypr" "$HOME/.config/hypr" hyprland
copy_dotfiles "$DOTFILES_LOCAL_PATH/waybar" "$HOME/.config/waybar" waybar
copy_dotfiles "$DOTFILES_LOCAL_PATH/wlogout" "$HOME/.config/wlogout" wlogout
copy_dotfiles "$DOTFILES_LOCAL_PATH/rofi" "$HOME/.config/rofi" rofi
copy_dotfiles "$DOTFILES_LOCAL_PATH/flameshot" "$HOME/.config/flameshot" flameshot
copy_dotfiles "$DOTFILES_LOCAL_PATH/gtk-3.0" "$HOME/.config/gtk-3.0" gtk-3.0
copy_dotfiles "$DOTFILES_LOCAL_PATH/gtk-4.0" "$HOME/.config/gtk-4.0" gtk-4.0

log_message "Atualizando .zshrc..."
if [ -f "$DOTFILES_LOCAL_PATH/.zshrc" ]; then
    cp -f "$DOTFILES_LOCAL_PATH/.zshrc" "$HOME/.zshrc" \
        || error_exit "Falha ao copiar .zshrc."
    log_message ".zshrc atualizado."
else
    log_message "Aviso: .zshrc não encontrado nos dotfiles."
fi

# Plugins Zsh
log_message "Instalando plugins Zsh..."
ZSH_CUSTOM_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
mkdir -p "$ZSH_CUSTOM_PLUGINS"

if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" \
        || log_message "Aviso: falha ao clonar zsh-autosuggestions."
fi

if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting" \
        || log_message "Aviso: falha ao clonar zsh-syntax-highlighting."
fi

sed -i '/^plugins=(/d' "$HOME/.zshrc"
echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" >> "$HOME/.zshrc" \
    || log_message "Aviso: falha ao atualizar plugins no .zshrc."
log_message "Plugins Zsh configurados."

# Tornar scripts executáveis
SCRIPTS_TO_CHMOD=(
    "$HOME/.config/waybar/scripts/power-menu.sh"
    "$HOME/.config/hypr/scripts/screenshot.sh"
)

for script in "${SCRIPTS_TO_CHMOD[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script" || error_exit "Falha ao chmod em $script."
        log_message "Permissão concedida: $script"
    else
        log_message "Aviso: script não encontrado: $script"
    fi
done

# 9. Habilitar SDDM
log_message "Habilitando SDDM..."
if ! systemctl is-enabled sddm &> /dev/null; then
    sudo systemctl enable sddm || error_exit "Falha ao habilitar SDDM."
    log_message "SDDM habilitado."
else
    log_message "SDDM já habilitado."
fi

# 10. Variáveis de ambiente para Wayland e Hyprland
log_message "Configurando variáveis de ambiente..."
ENV_D_DIR="$HOME/.config/environment.d"
mkdir -p "$ENV_D_DIR" || error_exit "Falha ao criar $ENV_D_DIR."

# WAYLAND_DISPLAY
WAYLAND_ENV_FILE="$ENV_D_DIR/wayland.conf"
sed -i '/^WAYLAND_DISPLAY=/d' "$WAYLAND_ENV_FILE" 2>/dev/null
echo "WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}" >> "$WAYLAND_ENV_FILE"

# XDG_CURRENT_DESKTOP
DESKTOP_ENV_FILE="$ENV_D_DIR/desktop.conf"
sed -i '/^XDG_CURRENT_DESKTOP=/d' "$DESKTOP_ENV_FILE" 2>/dev/null
echo "XDG_CURRENT_DESKTOP=Hyprland" >> "$DESKTOP_ENV_FILE"

# 11. Configurar QT_QPA_PLATFORMTHEME
log_message "Configurando QT_QPA_PLATFORMTHEME..."
GLOBAL_ENV_FILE="/etc/environment"
sudo sed -i '/^QT_QPA_PLATFORMTHEME=/d' "$GLOBAL_ENV_FILE" 2>/dev/null
echo "QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a "$GLOBAL_ENV_FILE" > /dev/null

# 12. Limpar temporários
log_message "Removendo $INSTALL_DIR..."
rm -rf "$INSTALL_DIR" || log_message "Aviso: não foi possível remover $INSTALL_DIR."

# --- Finalização ---
log_message "Instalação/atualização de $PROJECT_NAME concluída com sucesso!"
echo "----------------------------------------------------"
echo "Instalação/atualização concluída!"
echo "Reinicie o sistema para aplicar todas as alterações."
echo "----------------------------------------------------"

# Pergunta para reiniciar
read -p "Deseja reiniciar agora? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    log_message "Reiniciando sistema..."
    sudo reboot
else
    log_message "Reinício adiado pelo usuário."
fi

exit 0

