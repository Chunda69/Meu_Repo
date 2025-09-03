#!/usr/bin/env bash
# setup minimal i3wm no Debian + LightDM

# Atualiza repositórios e instala pacotes essenciais
sudo apt update && sudo apt install -y \
    xorg xinit i3 i3status dmenu \
    xfce4-terminal feh picom \
    udisks2 udiskie gvfs-backends \
    ranger chafa bat fzf fd-find ripgrep \
    firefox-esr \
    lxappearance fonts-dejavu fonts-noto-color-emoji \
    lightdm lightdm-gtk-greeter

# Ativa o LightDM para iniciar no boot
sudo systemctl enable lightdm

echo "=========================================="
echo " Instalação concluída!"
echo " Reinicie o sistema: sudo reboot"
echo " Ao iniciar, escolha a sessão i3 no LightDM"
echo "=========================================="
