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
  pipewire pipewire-pulse wireplumber docker 7zip unzip\ 
  xdg-desktop-portal-hyprland btop tuned dolphin qbittorrent mpv\
  yazi vpnc fastfetch satty code wiremix brightnessctl firefox vim nano\
  grub-btrfs xdg-desktop-portal xdg-desktop-portal-hyprland hyprpolkitagent nwg-look \
  docker-compose


sudo systemctl enable -now NetworkManager
sudo systemctl enable --now tuned.service
sudo usermod -aG docker $USER
sudo usermod -aG video mario $USER
sudo systemctl enable --now docker 


# Configuración Automática de grub-btrfs para Timeshift

sudo sed -i 's|ExecStart=*|ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto|' /usr/lib/systemd/system/grub-btrfsd.service

sudo systemctl enable --now grub-btrfsd.service

sudo grub-mkconfig -o /boot/grub/grub.cfg




# Pacman hook update configuracion de grub.
if [ ! -d "/etc/pacman.d/hooks" ]; then
    mkdir -p "/etc/pacman.d/hooks"
fi

cat <<EOF > "/etc/pacman.d/hooks/grub-update.hook"
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



# Crear carpetas XDG
# xdg-user-dirs-update
LC_ALL=C xdg-user-dirs-update --force

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
rm -rf ~/.config/hypr
rm -rf ~/.config/kitty

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