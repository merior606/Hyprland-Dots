#!/bin/bash
cd ~

# Paquetes base
sudo pacman -Syu

sudo pacman -S --needed --noconfirm \
  hyprland kitty waybar wofi zsh hyprpaper swaync go \
  git base-devel lsd bat xdg-user-dirs hyprpicker hyprsunset wget curl\
  zsh-autosuggestions zsh-syntax-highlighting \
  networkmanager network-manager-applet \
  ttf-jetbrains-mono-nerd ttf-iosevka-nerd noto-fonts-cjk\
  pipewire pipewire-pulse wireplumber \
  xdg-desktop-portal-hyprland btop \
  yazi vpnc fastfetch satty code wiremix\
  grub-btrfs xdg-desktop-portal xdg-desktop-portal-hyprland hyprpolkitagent 


# Crear carpetas XDG
xdg-user-dirs-update

# Instalar yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ~

# Fuentes
yay -S --noconfirm zsh-theme-powerlevel10k-git \ 
  noto-fonts-cjk \
  wlogout 

# Cambiar shell
chsh -s /usr/bin/zsh

# Backup existing configs (optional but recommended)
rm -r ~/.config/hypr
rm -r ~/.config/kitty

# Create symlinks
ln -sf ~/Hyprland-Dots/hypr ~/.config
ln -sf ~/Hyprland-Dots/waybar ~/.config
ln -sf ~/Hyprland-Dots/kitty ~/.config
ln -sf ~/Hyprland-Dots/wofi ~/.config
ln -sf ~/Hyprland-Dots/swaync ~/.config

# Link shell configuration
ln -sf ~/Hyprland-Dots/home/.zshrc ~/.zshrc
ln -sf ~/Hyprland-Dots/home/.p10k.zsh ~/.p10k.zsh

curl -s https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh && sudo chmod +x /usr/local/bin/cht.sh