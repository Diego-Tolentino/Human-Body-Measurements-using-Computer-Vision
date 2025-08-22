#!/bin/bash
# Script Mestre de Instalação com Docker

echo "======================================================"
echo "=== PASSO 1/4: Preparando e Instalando o Docker    ==="
echo "======================================================"
apt-get update && apt-get upgrade -y
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ""
echo "======================================================"
echo "=== PASSO 2/4: Baixando a Aplicação do GitHub      ==="
echo "======================================================"
git clone https://github.com/Diego-Tolentino/Human-Body-Measurements-using-Computer-Vision.git /opt/body-measurements
cd /opt/body-measurements

echo ""
echo "======================================================"
echo "=== PASSO 3/4: Construindo o Container Docker      ==="
echo "======================================================"
docker build -t human-measurements .

echo ""
echo "======================================================"
echo "=== PASSO 4/4: Iniciando a Aplicação               ==="
echo "======================================================"
docker run -d -p 8080:8080 --restart unless-stopped --name human-measurements human-measurements

echo ""
echo "================================================================================================="
echo "===                            INSTALAÇÃO CONCLUÍDA! by Tolentino                             ==="
echo "================================================================================================="
echo "A aplicação está rodando automaticamente em segundo plano."
echo "Você pode gerenciá-la pelo Portainer ou via linha de comando (ex: 'docker logs human-measurements')."
echo "O serviço estará disponível no IP da sua VPS, na porta 8080."
echo "================================================================================================="