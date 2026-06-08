#!/bin/bash
set -e # Detiene el script si ocurre algún error crítico

cd ~

# 1. Actualizar sistema
sudo pacman -Syu --noconfirm

# 2. Instalar paquetes base (Corregido y sin duplicados)
sudo pacman -S --needed --noconfirm \
  hyprland kitty waybar wofi zsh hyprpaper swaync go \
  git base-devel lsd bat xdg-user-dirs hyprpicker hyprsunset wget curl \
  zsh-autosuggestions zsh-syntax-highlighting \
  networkmanager network-manager-applet ttf-hack-nerd\
  ttf-jetbrains-mono-nerd ttf-iosevka-nerd noto-fonts-cjk \
  pipewire pipewire-pulse wireplumber docker 7zip unzip \
  xdg-desktop-portal-hyprland btop tuned dolphin qbittorrent mpv \
  yazi fastfetch satty code brightnessctl firefox vim nano \
  grub-btrfs xdg-desktop-portal hyprpolkitagent nwg-look \
  docker-compose resolvconf  nvtop bat-extras


# Paquetes opcionales para mi
# sudo pacman -S --needed --noconfirm \
#   syncthing wireguard-tools vpnc

# 3. Habilitar servicios y configurar grupos
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now tuned.service
sudo systemctl enable --now docker 

sudo usermod -aG docker $USER
sudo usermod -aG video $USER

# 4. Configuración Automática de grub-btrfs para Timeshift (Corregido el SED)
sudo sed -i 's|ExecStart=.*|ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto|' /usr/lib/systemd/system/grub-btrfsd.service
sudo systemctl enable --now grub-btrfsd.service
sudo grub-mkconfig -o /boot/grub/grub.cfg

# 5. Pacman hook para actualización de GRUB
if [ ! -d "/etc/pacman.d/hooks" ]; then
    sudo mkdir -p "/etc/pacman.d/hooks"
fi

cat <<EOF | sudo tee /etc/pacman.d/hooks/grub-update.hook > /dev/null
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = linux
Target = grub

[Action]
Description = Regenerando configuración de GRUB...
When = PostTransaction
Exec = /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg
EOF

# 6. Crear carpetas XDG
LC_ALL=C xdg-user-dirs-update --force

# 7. Instalar AUR helper (yay)
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf ~/yay
fi

# 8. Instalar paquetes de AUR
yay -S --noconfirm zsh-theme-powerlevel10k-git wlogout

# 9. Cambiar shell a ZSH
sudo chsh -s /usr/bin/zsh $USER

# 10. Configurar Dotfiles (Asegúrate de tener la carpeta ~/Hyprland-Dots)
if [ -d "~/Hyprland-Dots" ]; then
    rm -rf ~/.config/hypr ~/.config/kitty ~/.config/waybar ~/.config/wofi ~/.config/swaync
    
    ln -sf ~/Hyprland-Dots/hypr ~/.config/
    ln -sf ~/Hyprland-Dots/waybar ~/.config/
    ln -sf ~/Hyprland-Dots/kitty ~/.config/
    ln -sf ~/Hyprland-Dots/wofi ~/.config/
    ln -sf ~/Hyprland-Dots/swaync ~/.config/
    ln -sf ~/Hyprland-Dots/home/.zshrc ~/.zshrc
    ln -sf ~/Hyprland-Dots/home/.p10k.zsh ~/.p10k.zsh
else
    echo "Advertencia: ~/Hyprland-Dots no existe. No se crearon los enlaces simbólicos."
fi

# 11. Cheat.sh CLI
curl -s https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh > /dev/null
sudo chmod +x /usr/local/bin/cht.sh

echo "¡Instalación completada con éxito! Reinicia para aplicar todos los cambios."