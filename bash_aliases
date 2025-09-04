
  1 #Bash_aliases                                                                                                        
  2 #Aliases
  3 # 1. Testa rapidamente se a internet está ativa e mostra o IP público
  4 alias netcheck='ping -c1 8.8.8.8 >/dev/null && curl -s ifconfig.me || echo "Sem conexão"'
  5
  6 # 2. Cria backup rápido de qualquer arquivo mantendo a data no nome
  7 alias backup='f(){ cp "$1" "${1}_$(date +%Y%m%d_%H%M%S).bak"; }; f'
  8
  9 # 3. Lista arquivos por tamanho, do maior para o menor, com legibilidade humana
 10 alias bigfiles='ls -lhS --color=auto'
 11

