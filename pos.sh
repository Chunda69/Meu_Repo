#!/usr/bin/env bash
# =====================================================================
# Pós-Instalação Debian Minimal (GNOME Boxes) - v2
# Autor: O Cara
# Objetivo: Instalar Xorg + i3, integrar ao Boxes e iniciar no modo gráfico.
# =====================================================================
# Modos de inicialização:
#   USE_DISPLAY_MANAGER=true  -> LightDM (recomendado)
#   USE_DISPLAY_MANAGER=false -> autologin tty1 + startx automático (i3)
# =====================================================================

set -euo pipefail

# ====== CONFIGURAÇÕES ======
USE_DISPLAY_MANAGER=true     # mude para false se quiser sem DM
TARGET_USER="${SUDO_USER:-${TARGET_USER:-}}"

# ====== FUNÇÕES UTIL ======
die() { echo "ERRO: $*" >&2; exit 1; }
info() { echo -e "\n=== $* ==="; }

# Detectar usuário alvo se não foi passado
if [[ -z "${TARGET_USER}" || "${TARGET_USER}" == "root" ]]; then
  # tenta descobrir o primeiro usuário normal do sistema
  FIRST_USER="$(awk -F: '$3>=1000 && $1!="nobody"{print $1; exit}' /etc/passwd || true)"
  if [[ -n "${FIRST_USER}" && "${FIRST_USER}" != "root" ]]; then
    TARGET_USER="${FIRST_USER}"
  else
    die "Não foi possível determinar o usuário não-root. Rode assim: TARGET_USER=seuusuario ./posinstalacao_boxes.sh"
  fi
fi

# Verificações
[[ "$(id -u)" -eq 0 ]] || die "Rode como root (su -)."
command -v apt >/dev/null || die "Apt não encontrado."

# ====== ATUALIZA SISTEMA ======
info "Atualizando repositórios e sistema"
apt update
apt -y upgrade

# ====== PACOTES BASE GRÁFICOS + i3 ======
info "Instalando base gráfica (Xorg + i3 + utilitários)"
apt install -y \
  xorg \
  xserver-xorg-video-all \
  xserver-xorg-input-all \
  x11-xserver-utils \
  mesa-utils \
  i3 i3status i3lock \
  dmenu rofi \
  lxappearance \
  fonts-dejavu \
  xterm alacritty

# ====== REDE, SISTEMA E INTEGRAÇÃO BOXES ======
info "Instalando rede, ferramentas e integração com Boxes (SPICE)"
apt install -y \
  network-manager network-manager-gnome \
  policykit-1 dbus-x11 \
  spice-vdagent \
  curl wget nano bc htop ranger \
  python3 python3-pip python3-venv

# Habilitar NetworkManager no boot (só garante)
systemctl enable NetworkManager || true

# ====== PREPARAR ~/.local/bin ======
info "Preparando diretório de scripts do usuário"
install -d -o "${TARGET_USER}" -g "${TARGET_USER}" "/home/${TARGET_USER}/.local/bin"

# ====== MODO COM DISPLAY MANAGER (RECOMENDADO) ======
if [[ "${USE_DISPLAY_MANAGER}" == "true" ]]; then
  info "Instalando e habilitando LightDM (tela de login)"
  apt install -y lightdm lightdm-gtk-greeter

  # Remover qualquer autologin antigo no tty1 para não conflitar
  if [[ -d /etc/systemd/system/getty@tty1.service.d ]]; then
    rm -rf /etc/systemd/system/getty@tty1.service.d
    systemctl daemon-reload
  fi

  # Subir sempre no gráfico + habilitar LightDM
  systemctl set-default graphical.target
  systemctl enable lightdm

  info "Configuração com LightDM concluída."

# ====== MODO SEM DISPLAY MANAGER (AUTLOGIN + STARTX) ======
else
  info "Configurando autologin no tty1 e startx automático (sem DM)"

  # agetty override para autologin no tty1
  AGETTY="$(command -v agetty)"
  mkdir -p /etc/systemd/system/getty@tty1.service.d
  cat >/etc/systemd/system/getty@tty1.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=-${AGETTY} -o '-p -- \\u' --autologin ${TARGET_USER} --noclear %I \$TERM
EOF
  systemctl daemon-reload
  systemctl enable getty@tty1

  # ~/.xinitrc para iniciar i3
  sudo -u "${TARGET_USER}" bash -c 'cat > "$HOME/.xinitrc" <<EOF
exec i3
EOF'

  # Iniciar X automaticamente ao logar no tty1
  AUTOSTART_SNIPPET='
# Iniciar X automaticamente no tty1
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  startx
fi
'
  PROFILE_FILE="/home/${TARGET_USER}/.profile"
  if ! sudo -u "${TARGET_USER}" grep -q "Iniciar X automaticamente no tty1" "${PROFILE_FILE}" 2>/dev/null; then
    sudo -u "${TARGET_USER}" bash -c "printf '%s\n' \"${AUTOSTART_SNIPPET}\" >> '${PROFILE_FILE}'"
  fi

  # Garantir target gráfico (opcional mas útil p/ serviços gráficos)
  systemctl set-default graphical.target

  info "Configuração sem DM concluída."
fi

# ====== TOQUES FINAIS ======
info "Limpando pacotes órfãos e finalizando"
apt -y autoremove
apt -y autoclean

# ====== RESUMO ======
echo -e "\n✅ Pronto! Usuário alvo: ${TARGET_USER}"
if [[ "${USE_DISPLAY_MANAGER}" == "true" ]]; then
  echo "→ Próximo passo: 'reboot' e faça login pelo LightDM (escolha a sessão i3)."
else
  echo "→ Próximo passo: 'reboot' e você cairá no tty1; o i3 sobe automaticamente via startx."
fi
echo "→ No GNOME Boxes, a integração (clipboard/resolução) é via spice-vdagent, já instalado."
