#Bash_aliases
#
#Aliases
# 1. Testa rapidamente se a internet está ativa e mostra o IP público
alias netcheck='ping -c1 8.8.8.8 >/dev/null && curl -s ifconfig.me || echo "Sem conexão"'

# 2. Cria backup rápido de qualquer arquivo mantendo a data no nome
alias backup='f(){ cp "$1" "${1}_$(date +%Y%m%d_%H%M%S).bak"; }; f'

# 3. Lista arquivos por tamanho, do maior para o menor, com legibilidade humana
alias bigfiles='ls -lhS --color=auto'

# 4. Mostra temperatura da CPU e uso total
alias cputemp='sensors | grep -E "Package id|Tdie|Tctl|Core" && top -bn1 | grep "Cpu(s)"'

# 5. Procura qualquer texto em qualquer arquivo da pasta atual (case-insensitive)
alias busca='f(){ grep -Rin --color=always "$1" .; }; f'
# 6. Mini arquivador de páginas completas, com pasta por data e download de HTML + imagens + CSS.
alias gethtml='f(){ 
    DATA=$(date +%Y%m%d_%H%M%S)
    DIR="pagina_${DATA}"
    mkdir -p "$DIR"
    wget --page-requisites --convert-links --no-check-certificate --span-hosts --adjust-extension -P "$DIR" "$1" && \
    echo -e "\e[32mPágina salva em:\e[0m $DIR"
}; f'
# 7. Mostra arquivos grandes
alias arq='echo -e "\n📂 Arquivos maiores que 100MB no diretório home:"
        find ~ -type f -size +100M -exec du -h {} + 2>/dev/null | sort -hr | head -n 5'
# 8. Mostra data/hora
alias agora='date +"📅 %d/%m/%Y ⏰ %H:%M:%S"'
alias pingtest='ping -c 4 1.1.1.1 | grep "time="'
alias c='clear'
alias 3-i3config='nano ~/.config/i3/config'
alias bsh-aliases='nano ~/.bash_aliases'
alias att-bsh_aliases='. ~/.bash_aliases'
alias spd='systemctl suspend'
alias shut='systemctl poweroff'
alias reb='systemctl reboot'
alias tor='~/tor-browser/Browser/start-tor-browser --detach'
alias htr='history | grep'
alias lb='lsblk'
alias somctrl='pavucontrol'
alias lmp='sudo apt autoremove && sudo apt autoclean && sudo apt clean'
alias rst='sudo systemctl restart'
alias netvelocidade='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'
alias seguranca='sudo apt list --upgradable 2>/dev/null | grep -i security'
alias recursos='htop || top'
alias portas='sudo netstat -tulnpe'
alias limpar='sudo rm -rf ~/.cache/* /var/tmp/* /tmp/*'
alias detectar_erros='f(){ grep -Ei -C 3 "error|fail|fatal|exception|critical|segfault|denied|unauthorized|abort" "$1" | less; }; f'
alias update='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean'
alias portas='sudo netstat -tulnpe'
alias ll='ls -lah --color=auto'
alias ativar_venv='source .venv/bin/activate'
alias desativar_venv='deactivate'
alias la='ls -a'
#Funções
 #Função Diagnóstico
diagnostico_sistema() {
    LOG_DIR="$HOME/logs_diagnostico"
    mkdir -p "$LOG_DIR"

    LOG_FILE="$LOG_DIR/diagnostico_$(date '+%Y-%m-%d_%H-%M-%S').log"

    {
        echo -e "\n===== Diagnóstico do Sistema ===================================================="

        echo -e "\n Memória RAM e SWAP:"
        free -h

        echo -e "\n  Uso de CPU (top 5 processos):"
        ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

        echo -e "\n  Temperatura da CPU:"
        sensors 2>/dev/null || echo "Comando 'sensors' não disponível."

        echo -e "\n  GPU NVIDIA (se presente):"
        nvidia-smi 2>/dev/null || echo "NVIDIA não detectada ou driver não instalado."

        echo -e "\n  Espaço em disco:"
        df -h --total | grep -E 'Filesystem|total'

        echo -e "\n Arquivos maiores que 100MB no diretório home:"
        find ~ -type f -size +100M -exec du -h {} + 2>/dev/null | sort -hr | head -n 5

        echo -e "\n  Informações de rede:"
        hostname -I
        ip route show default | awk '/default/ {print "Gateway:", $3}'
        nmcli -t -f active,ssid dev wifi | grep '^yes' || echo "Rede WiFi não detectada"

        echo -e "\n  Informações gerais do sistema:"
        echo "Uptime (desde): $(uptime -s)"
        echo "Load average: $(cat /proc/loadavg)"
        echo "Kernel: $(uname -r)"
        echo "Usuário: $USER"
        echo "Host: $(hostname)"
        echo "Shell: $SHELL"

        echo -e "======================================================================================\n"
    } | tee "$LOG_FILE"
}

#Dashboard
  dash() {
    
    echo -e "\e[1;34m==================== TERMINAL DASHBOARD =============================================\e[0m"
    
    # Data e Hora
    echo -e "\n  \e[1mData:\e[0m $(date '+%A, %d %B %Y')"
    echo -e "  \e[1mHora:\e[0m $(date '+%H:%M:%S')"

    # Status da Internet
        # IP Local
    IP=$(hostname -I | awk '{print $1}')
    echo "  IP Local: $IP"

    # Ping Google (só se estiver online)
    if $ONLINE; then
        echo -n "  Ping Google: "
        ping -c 1 8.8.8.8 | grep "time=" | awk -F"time=" '{print $2}'
    fi

    # Velocidade de Rede (RX/TX simples)
    IFACE=$(ip route | grep default | awk '{print $5}')
    RX_PRE=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
    TX_PRE=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
    sleep 1
    RX_POST=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
    TX_POST=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
    RX_RATE=$(echo "scale=2; ($RX_POST - $RX_PRE)/1024" | bc)
    TX_RATE=$(echo "scale=2; ($TX_POST - $TX_PRE)/1024" | bc)
    echo "  Download: ${RX_RATE} KB/s"
    echo "  Upload:   ${TX_RATE} KB/s"

    # Clima (se online)
    echo -e "\n \e[1mClima (via wttr.in):\e[0m"
    if $ONLINE; then
        curl -s "wttr.in/?format=3"
    else
        echo "Não disponível (sem conexão)"
    fi

    echo -e "\n\e[1;34m====================================================================================\e[0m"
    }
  #Função Extract
extract () {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"   ;;
      *.tar.gz)    tar xzf "$1"   ;;
      *.bz2)       bunzip2 "$1"   ;;
      *.rar)       unrar x "$1"   ;;
      *.gz)        gunzip "$1"    ;;
      *.tar)       tar xf "$1"    ;;
      *.tbz2)      tar xjf "$1"   ;;
      *.tgz)       tar xzf "$1"   ;;
      *.zip)       unzip "$1"     ;;
      *.Z)         uncompress "$1";;
      *.7z)        7z x "$1"      ;;
      *)           echo "'$1' não é um tipo de arquivo reconhecido." ;;
    esac
  else
    echo "'$1' não é um arquivo válido."
  fi
}

 #Função Lixeira

trash () {
  mv "$@" ~/.local/share/Trash/files/
}

 #Função Acha os maiores arquivos

findbig () {
  du -ah "${1:-.}" | sort -rh | head -n 10
}
 #Função Ver uso de rede em tempo real

netusage () {
  watch -n 1 "ip -s link"
}

 #Função Clima/Tempo

weather-pt () {
  curl -s "wttr.in/${1:-yourcity}?format=3&lang=pt"
}

 #Função Cotação BTC

 btcbr() {
  local url="https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=brl"
  local resposta=$(curl -s "$url")
  local preco=$(echo "$resposta" | grep -oP '(?<="brl":)[0-9.]+')
  local datahora=$(date '+%Y-%m-%d %H:%M:%S')
  local logfile="$HOME/.btcbr.log"

  # Cores ANSI
  local verde='\033[1;32m'
  local amarelo='\033[1;33m'
  local azul='\033[1;34m'
  local reset='\033[0m'

  if [[ -n "$preco" ]]; then
    local preco_formatado="R\$ ${preco//./,}"
    echo -e "${azul}📅 $datahora${reset} - ${amarelo}💰 Cotação do Bitcoin:${reset} ${verde}$preco_formatado${reset}"
    echo "$datahora - $preco_formatado" >> "$logfile"
  else
    echo "$datahora - Erro ao buscar cotação do Bitcoin" >> "$logfile"
    echo -e "${azul}📅 $datahora${reset} - ${amarelo}Erro ao buscar cotação do Bitcoin${reset}"
  fi
}


#  nivelas: atualiza e nivela o sistema com feedback visual
nivelas() {
  ok()   { echo -e "\033[1;32m✔ $1\033[0m"; }
  info() { echo -e "\033[1;36mℹ $1\033[0m"; }
  warn() { echo -e "\033[1;33m⚠ $1\033[0m"; }
  err()  { echo -e "\033[1;31m✖ $1\033[0m"; }

  info "🔍 Verificando atualizações disponíveis..."
  sudo apt update

  UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -v "Listing..." | wc -l)

  if [ "$UPGRADABLE" -eq 0 ]; then
    ok "Nenhuma atualização disponível!"
    return
  fi

  info "⚙️ $UPGRADABLE pacotes serão atualizados:"
  apt list --upgradable 2>/dev/null | grep -v "Listing..."

  read -p $'\nDeseja aplicar as atualizações agora? (s/N): ' resp
  if [[ "$resp" =~ ^[Ss]$ ]]; then
    sudo apt upgrade -y && ok "Sistema atualizado com sucesso!"
    
    read -p $'\nDeseja fazer uma faxina agora? (limpar pacotes inúteis) (s/N): ' limpar
    if [[ "$limpar" =~ ^[Ss]$ ]]; then
      sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean -y
      ok "Sistema limpo!"
    fi
  else
    warn "Atualização cancelada pelo usuário."
  fi
}

# -----------------------------
#   SHELL EMBELEZADO BY GPT-4
# -----------------------------

# ▶️ Prompt colorido e informativo
parse_git_branch() {
  git branch 2>/dev/null | sed -n '/\* /s///p'
}

PS1='\[\033[01;36m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[0;32m\]$(parse_git_branch)\[\033[00m\]\n\$ '

# ▶️ Cores para comandos 'ls' e afins
eval "$(dircolors -b)"
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# ▶️ Atualização com estilo
alias atualiza='sudo apt update && sudo apt upgrade -y && echo -e "\n✅ Sistema atualizado com sucesso."'

# ▶️ Verificação de internet
alias netcheck='ping -q -c 1 1.1.1.1 &>/dev/null && echo "🟢 Internet OK" || echo "🔴 Sem conexão"'

# ▶️ Limpeza geral
alias limpa='sudo apt autoremove -y && sudo apt autoclean -y && echo "🧹 Limpeza feita."'
# ▶️ Melhor 'cd': abre pasta e lista conteúdo
#cd() {
#  builtin cd "$@" && ls --color=auto
#}
#   Histórico de diretórios recentes
CD_HIST_FILE="$HOME/.cd_history"

cd() {
  local dir="$1"

  # Se nenhum argumento, vai pro $HOME
  if [[ -z "$dir" ]]; then
    dir="$HOME"
  fi

  # Tenta mudar de pasta
  if builtin cd "$dir"; then
    # Salva no histórico
    echo "$(pwd)" >> "$CD_HIST_FILE"
    tail -n 1000 "$CD_HIST_FILE" > "$CD_HIST_FILE.tmp" && mv "$CD_HIST_FILE.tmp" "$CD_HIST_FILE"

    echo -e "\n📁 Entrou em: \033[1;34m$(pwd)\033[0m"

    # Verifica se está vazia
    if [ -z "$(ls -A)" ]; then
      echo -e "⚠️  Diretório vazio.\n"
      return
    fi

    # Usa tree se tiver, senão ls
    if command -v tree &>/dev/null; then
      tree -L 1 --dirsfirst --noreport -C
    else
      ls --color=auto
    fi
  else
    echo -e "  Diretório não encontrado: \033[0;31m$dir\033[0m"
  fi
}

# ▶️ Prompt dinâmico com emoji aleatório
#EMOJIS=(🔥 🌟 ⚡ 🧠 🛠️ 🧙 🚀 🧩 🧼)
#RANDOM_EMOJI=${EMOJIS[$RANDOM % ${#EMOJIS[@]}]}
#PS1="${RANDOM_EMOJI} $PS1"

# ▶️ Export PATH custom
export PATH=$PATH:$HOME/.local/bin


#Minhas alterações

# === CORES ===
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
PURPLE='\e[1;35m'
CYAN='\e[1;36m'
NC='\e[0m' # Reset

# === MENSAGENS COLORIDAS ===
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
aviso() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
erro()  { echo -e "${RED}[ERRO]${NC} $1"; }
info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
# === PROMPT COLORIDO E COM GIT ===
parse_git_branch() {
  git branch 2>/dev/null | sed -n '/\* /s///p' | sed 's/.*/ [\0]/'
}

PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\[\e[1;33m\]$(parse_git_branch)\[\e[0m\]\$ '

# === EXPORTS PADRÕES ===
export EDITOR=nano
export HISTSIZE=5000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
# === PURGADOR TOTAL ===
purgetotal() {
  local alvo="$1"

  if [[ -z "$alvo" ]]; then
    echo "Uso: purgetotal <nome-do-programa>"
    return 1
  fi

  echo "⚠️ ATENÇÃO: Esta ação é DESTRUTIVA e pode apagar rastros de '$alvo'"
  read -p "Deseja continuar? (s/N) " confirmacao

  if [[ "$confirmacao" != "s" && "$confirmacao" != "S" ]]; then
    echo "❌ Cancelado."
    return 0
  fi

  echo "🔍 Verificando e removendo $alvo..."

  # APT
  if dpkg -l | grep -q "^ii  $alvo "; then
    echo "🧹 Removendo pacote APT..."
    sudo apt remove --purge -y "$alvo"
    sudo apt autoremove -y
  fi

  # SNAP
  if command -v snap >/dev/null && snap list 2>/dev/null | grep -q "^$alvo "; then
    echo "🧹 Removendo pacote Snap..."
    sudo snap remove "$alvo"
  fi

  # FLATPAK
  if command -v flatpak >/dev/null && flatpak list --app | grep -q "$alvo"; then
    echo "🧹 Removendo pacote Flatpak..."
    flatpak uninstall -y "$alvo"
  fi

  # BINÁRIOS soltos
  for path in /usr/local/bin /usr/bin; do
    if [[ -x "$path/$alvo" ]]; then
      echo "🧹 Removendo binário em $path..."
      sudo rm -f "$path/$alvo"
    fi
  done

  # Configurações do usuário
  rm -rf "$HOME/.config/$alvo" "$HOME/.$alvo"

  echo "✅ Purga concluída para '$alvo'."
}
#
alias limpar_boxes='
read -p "Deseja realmente apagar tudo em ~/.local/share/gnome-boxes/images ? (s/n) " RESP;
if [ "$RESP" = "s" ] || [ "$RESP" = "S" ]; then
    rm -rf ~/.local/share/gnome-boxes/images/* ~/.local/share/gnome-boxes/images/.[!.]*
    echo -e "\033[1;32mMissão cumprida: pasta limpa!\033[0m"
else
    echo -e "\033[1;33mCancelado.\033[0m"
fi
'
# Função para instalar pacotes
instalar() {
    if [ $# -eq 0 ]; then
        echo "Uso: instalar <pacote>"
        return 1
    fi
    sudo apt install -y "$@"
}

# Função para remover pacotes com purge
remover() {
    if [ $# -eq 0 ]; then
        echo "Uso: remover <pacote>"
        return 1
    fi
    sudo apt remove --purge -y "$@"
    sudo apt autoremove -y
}

# ===== Git Menu Interativo =====
# Uso:
#   gitmenu                 # usa o repositório da pasta atual
#   gitmenu /caminho/repo   # abre menu já apontando para o repo informado
#
# Dica: rode dentro do repo. O menu checa tudo e orienta.

# Descobre branch padrão de forma segura (main/master/qualquer)
_git_default_branch() {
    git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|origin/||' \
    || git symbolic-ref --short HEAD 2>/dev/null \
    || echo "main"
}

# Checa se estamos num repo
_git_ensure_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "⚠️  Aqui não é um repositório Git. Entre em um repo ou passe o caminho: gitmenu /caminho/repo"
        return 1
    fi
}

gitmenu() {
    # Se foi passado caminho, entra nele
    if [[ -n "$1" ]]; then
        if [[ -d "$1" ]]; then
            cd "$1" || { echo "Erro ao entrar em $1"; return 1; }
        else
            echo "Caminho inválido: $1"
            return 1
        fi
    fi

    _git_ensure_repo || return 1

    local RESET="\033[0m" BOLD="\033[1m"
    local BLUE="\033[34m" GREEN="\033[32m" YELLOW="\033[33m" RED="\033[31m"
    local BRANCH DEFAULT_BRANCH REMOTE

    while true; do
        _git_ensure_repo || return 1
        BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
        DEFAULT_BRANCH="$(_git_default_branch)"
        REMOTE="$(git remote get-url origin 2>/dev/null || echo '(sem origin)')"

        echo -e "\n${BOLD}=== Git Menu (${BLUE}${BRANCH}${RESET}${BOLD}) ===${RESET}"
        echo -e "Repo: ${YELLOW}$(basename "$(git rev-parse --show-toplevel)")${RESET}"
        echo -e "Remoto: ${YELLOW}${REMOTE}${RESET}"
        echo -e "Branch padrão (push/pull): ${GREEN}${DEFAULT_BRANCH}${RESET}\n"

        echo "1) Status"
        echo "2) Diff (o que mudou)"
        echo "3) Add (tudo ou arquivos)"
        echo "4) Commit"
        echo "5) Push"
        echo "6) Pull"
        echo "7) Log (10 últimos)"
        echo "8) Stash (guardar mudanças)"
        echo "9) Criar/Switch de branch"
        echo "10) Sincronizar (pull -> add -> commit -> push)"
        echo "11) Trocar repo (cd para outro caminho)"
        echo "0) Sair"

        read -rp "Escolha: " op
        case "$op" in
            1)
                echo -e "${BOLD}git status${RESET}"
                git status
                ;;
            2)
                echo -e "${BOLD}git diff${RESET}"
                git diff
                ;;
            3)
                read -rp "Adicionar tudo (a) ou listar arquivos (l)? [a/l]: " modo
                if [[ "$modo" == "l" ]]; then
                    echo "Digite arquivos separados por espaço (TAB completa):"
                    read -r arquivos
                    [[ -n "$arquivos" ]] && git add $arquivos
                else
                    git add -A
                fi
                git status -s
                ;;
            4)
                read -rp "Mensagem do commit: " msg
                if [[ -z "$msg" ]]; then
                    echo -e "${RED}Mensagem vazia. Abortado.${RESET}"
                else
                    git commit -m "$msg" || echo -e "${YELLOW}Nada para commitar?${RESET}"
                fi
                ;;
            5)
                # Garante upstream se não existir
                if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
                    echo -e "${YELLOW}Upstream não configurado. Enviando para origin/${DEFAULT_BRANCH} e definindo upstream...${RESET}"
                    git push -u origin "$DEFAULT_BRANCH" || continue
                else
                    git push || echo -e "${RED}Falha no push.${RESET}"
                fi
                ;;
            6)
                git pull origin "$DEFAULT_BRANCH" || echo -e "${RED}Falha no pull.${RESET}"
                ;;
            7)
                git log --oneline --graph --decorate -n 10
                ;;
            8)
                echo "1) stash save   2) stash list   3) stash pop   4) stash drop"
                read -rp "Opção stash: " st
                case "$st" in
                    1) read -rp "Mensagem do stash (opcional): " sm; git stash save "$sm" ;;
                    2) git stash list ;;
                    3) git stash pop ;;
                    4) git stash drop ;;
                    *) echo "Opção inválida." ;;
                esac
                ;;
            9)
                echo "1) Criar nova branch   2) Trocar para branch existente   3) Listar branches"
                read -rp "Opção: " bopt
                case "$bopt" in
                    1) read -rp "Nome da nova branch: " nb; [[ -n "$nb" ]] && git checkout -b "$nb" ;;
                    2) read -rp "Nome da branch: " eb; [[ -n "$eb" ]] && git checkout "$eb" ;;
                    3) git branch -a ;;
                    *) echo "Opção inválida." ;;
                esac
                ;;
            10)
                echo -e "${BOLD}${BLUE}-> Pull${RESET}"; git pull origin "$DEFAULT_BRANCH" || true
                echo -e "${BOLD}${BLUE}-> Add${RESET}"; git add -A
                read -rp "Mensagem do commit (ou deixe vazio para pular): " m2
                if [[ -n "$m2" ]]; then
                    git commit -m "$m2" || echo "Nada para commitar."
                fi
                echo -e "${BOLD}${BLUE}-> Push${RESET}"
                if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
                    git push -u origin "$DEFAULT_BRANCH" || echo -e "${RED}Falha no push.${RESET}"
                else
                    git push || echo -e "${RED}Falha no push.${RESET}"
                fi
                ;;
            11)
                read -rp "Digite o caminho do repositório: " novo
                if [[ -d "$novo" ]]; then
                    cd "$novo" || { echo "Erro ao entrar em $novo"; continue; }
                    _git_ensure_repo || { echo "Pasta não é repo."; continue; }
                else
                    echo "Caminho inválido."
                fi
                ;;
            0)
                echo "Até mais!"
                break
                ;;
            *)
                echo "Opção inválida."
                ;;
        esac
    done
}
