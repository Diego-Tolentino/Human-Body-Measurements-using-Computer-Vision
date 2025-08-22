#!/bin/bash

# --- In�cio do Script de Instala��o ---

echo ">> Iniciando a configura��o do ambiente..."

# 1. Cria um ambiente virtual chamado 'venv'
python3 -m venv venv

# 2. Ativa o ambiente virtual
source venv/bin/activate

echo ">> Ambiente virtual criado e ativado."
echo ">> Instalando depend�ncias do Python... (Isso pode levar alguns minutos)"

# 3. Instala todas as bibliotecas do requirements.txt
pip install -r requirements.txt

# Verifica se a instala��o foi bem-sucedida
if [ $? -ne 0 ]; then
    echo "!! Erro ao instalar as depend�ncias do Python. O script ser� encerrado."
    exit 1
fi

echo ">> Depend�ncias instaladas com sucesso."
echo ">> Baixando os arquivos de modelo..."

# 4. Cria a pasta 'models' se ela n�o existir
mkdir -p models

# 5. Baixa cada modelo para dentro da pasta 'models'
wget -O models/model.ckpt-667589.data-00000-of-00001 https://diegotolentino.com.br/bibliotecas-aifit/models/model.ckpt-667589.data-00000-of-00001
wget -O models/model.ckpt-667589.index https://diegotolentino.com.br/bibliotecas-aifit/models/model.ckpt-667589.index
wget -O models/model.ckpt-667589.meta https://diegotolentino.com.br/bibliotecas-aifit/models/model.ckpt-667589.meta
wget -O models/neutral_smpl_with_cocoplus_reg.pkl https://diegotolentino.com.br/bibliotecas-aifit/models/neutral_smpl_with_cocoplus_reg.pkl

echo ">> Download dos modelos conclu�do."
echo ">> Configura��o finalizada com sucesso!"
echo ">> Para usar a aplica��o, primeiro ative o ambiente com o comando: source venv/bin/activate"

# --- Fim do Script de Instala��o ---