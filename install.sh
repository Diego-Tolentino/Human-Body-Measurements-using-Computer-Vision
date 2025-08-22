#!/bin/bash

echo ">> Iniciando a configuração do ambiente..."

# 1. Cria um ambiente virtual com o Python 3.7
python3.7 -m venv venv

# 2. Ativa o ambiente virtual
source venv/bin/activate

echo ">> Ambiente virtual criado e ativado."
echo ">> Instalando dependências do Python... (Isso pode levar alguns minutos)"

# 3. Instala pacotes de pré-requisito primeiro para evitar erros de compilação
pip install numpy cython wheel

# 4. Instala versões específicas de pacotes problemáticos e o Flask
pip install protobuf==3.20.0 Flask

# 5. Instala todas as outras bibliotecas do requirements.txt
pip install --no-cache-dir -r requirements.txt

# Verifica se a instalação foi bem-sucedida
if [ $? -ne 0 ]; then
    echo "!! Erro ao instalar as dependências do Python. O script será encerrado."
    exit 1
fi

echo ">> Baixando os arquivos de modelo..."

# 6. Cria a pasta 'models' se ela não existir
mkdir -p models

# 7. Baixa cada modelo para dentro da pasta 'models'
wget -O models/model.ckpt-667589.data-00000-of-00001 https://diegotolentino.com.br/bibliotecas-aifit/models/model.ckpt-667589.data-00000-of-00001
wget -O models/model.ckpt-667589.index https://diegotolentino.com.br/bibliotecas-aifit/models/model.ckpt-667589.index
wget -O models/model.ckpt-667589.meta https://diegotolentino.com.br/bibliotecas-aifit/models/model.ckpt-667589.meta
wget -O models/neutral_smpl_with_cocoplus_reg.pkl https://diegotolentino.com.br/bibliotecas-aifit/models/neutral_smpl_with_cocoplus_reg.pkl

echo ">> Download dos modelos concluído."
echo ">> Configuração finalizada com sucesso!"
echo ">> Para usar a aplicação, primeiro ative o ambiente com o comando: source venv/bin/activate"
