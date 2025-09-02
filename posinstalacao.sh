 #!/bin/bash
# =====================================================================
# Script de Pós-Instalação - Debian Minimal
# Autor: O Cara (Setup customizado)
# =====================================================================
# DISCLAIMER:
#   - Este script instala apenas pacotes essenciais e ferramentas
#   - Inclui i3wm, rede, terminal e utilitários
#   - NÃO adiciona áudio completo nem GNOME pesado
# =====================================================================

set -e

echo "=== Atualizando repositórios ==="
apt update && apt upgrade -y

echo "=== Instalando base gráfica (Xorg + i3wm) ==="
apt install -y \
    xorg \
    xserver-xorg-video-all \
    xserver-xorg-input-all \
    x11-xserver-utils \
    mesa-utils \
    i3 \
    i3status \
    i3lock \
    dmenu \
    rofi \
    lxappearance \
    fonts-dejavu \
    xterm \
    alacritty

echo "=== Rede e conexões ==="
apt install -y \
    network-manager \
    network-manager-gnome \
    curl wget

echo "=== Ferramentas de sistema ==="
apt install -y \
    nano \
    bc \
  
    htop \
    ranger \
    python3 python3-pip python3-venv \
    



echo "=== Ajustando autologin no tty1 (agetty) ==="
AGETTY="$(command -v agetty)"
USER_NAME="$SUDO_USER"
mkdir -p /etc/systemd/system/getty@tty1.service.d
tee /etc/systemd/system/getty@tty1.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-${AGETTY} -o '-p -- \\u' --autologin ${USER_NAME} --noclear %I \$TERM
EOF
systemctl daemon-reload
systemctl restart getty@tty1

echo "=== Criando diretório para scripts pessoais ==="
mkdir -p /home/$USER_NAME/.local/bin
chown $USER_NAME:$USER_NAME /home/$USER_NAME/.local/bin

echo "=== Finalizado com sucesso! Reinicie para aplicar ==="
