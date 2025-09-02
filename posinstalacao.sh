 1 #!/bin/bash                                              
 2 #                                                        
   ======================================================== 
   =============                                            
 3 # Script de Pós-Instalação - Debian Minimal              
 4 # Autor: O Cara (Setup customizado)                      
 5 #                                                        
   ======================================================== 
   =============
 6 # DISCLAIMER:
 7 #   - Este script instala apenas pacotes essenciais e   
   ferramentas
 8 #   - Inclui i3wm, rede, terminal e utilitários
 9 #   - NÃO adiciona áudio completo nem GNOME pesado
10 # 
   ========================================================
   =============
11
12 set -e
13
14 echo "=== Atualizando repositórios ==="
15 apt update && apt upgrade -y
16
17 echo "=== Instalando base gráfica (Xorg + i3wm) ==="    
18 apt install -y \
19     xorg \
20     xserver-xorg-video-all \
21     xserver-xorg-input-all \
22     x11-xserver-utils \
  
