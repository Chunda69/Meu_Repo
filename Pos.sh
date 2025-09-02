#!/usr/bin/env bash
sudo apt update && sudo apt instal>
xorg \
xserver-xorg-video-all \
xserver-xorg-input-all \
x11-xserver-utils \
mesa-utils \
lightdm \
lightdm-gtk-greeter \
i3 \
i3status \
i3lock \
dmenu \
rofi \
lxappearance \
network-manager \
network-manager-gnome
fonts-dejavu \
wget curl nano

sudo systemctl enable lightdm
sudo reboot
