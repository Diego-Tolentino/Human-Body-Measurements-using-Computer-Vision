#!/bin/bash
# Script Mestre de Instalação para o projeto Human Body Measurements

echo "================================================================"
echo "=== PASSO 1/3: Preparando o Servidor (Dependências do Sistema) ==="
echo "================================================================"
apt-get update && apt-get upgrade -y
apt-get install -y git software-properties-common curl
add-apt-repository ppa:deadsnakes/ppa -y
apt-get update
apt-get install -y python3.7 python3.7-venv build-essential python3.7-dev libosmesa6-dev libgl1-mesa-dev libglu1-mesa-dev dos2unix freeglut3-dev

echo ""
echo "================================================================"
echo "=== PASSO 2/3: Baixando a Aplicação do GitHub                ==="
echo "================================================================"
# Clona o repositório em um diretório padrão /opt para manter organizado
git clone https://github.com/Diego-Tolentino/Human-Body-Measurements-using-Computer-Vision.git /opt/body-measurements

echo ""
echo "================================================================"
echo "=== PASSO 3/3: Instalando as Dependências da Aplicação       ==="
echo "================================================================"
# Entra no diretório do projeto
cd /opt/body-measurements

# Garante que o script de instalação tem o formato correto (previne erros)
dos2unix install.sh

# Executa o script de instalação do projeto (que cria o venv e instala pacotes python)
./install.sh

echo ""
echo "================================================================================================="
echo "===                                INSTALAÇÃO CONCLUÍDA!                                     ==="
echo "================================================================================================="
echo "Para iniciar a aplicação, siga os passos:"
echo "1. Acesse o diretório: cd /opt/body-measurements"
echo "2. Ative o ambiente:   source venv/bin/activate"
echo "3. Inicie o servidor:   python3 app.py"
echo "================================================================================================="
