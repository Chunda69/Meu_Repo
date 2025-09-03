#!/usr/bin/env bash
#Aqui inicia amágica!
sudo apt update && sudo apt install xorg \
xserver-xorg-video-all \
xserver-xorg-input-all \
x11-xserver-utils \
mesa-utils \
lightdm \
lightdm-gtk-greeter \
i3 \
slick-greeter\
i3status \
i3lock \
dmenu \
firefox \
rofi \
lxappearance \
network-manager \
network-manager-gnome \
gnome-terminal \
fonts-dejavu \
wget curl nano
#Ativar o lightdm!
sudo systemctl enable lightdm
sudo reboot
#C'est fini!!