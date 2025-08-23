#!/usr/bin/env bash
set -Eeuo pipefail

echo ">> Iniciando a configuração do ambiente..."

# 1) Criar e ativar venv (usa o 'python' da imagem base 3.7)
python -m venv venv
# shellcheck disable=SC1091
source venv/bin/activate

echo ">> Ambiente virtual criado e ativado."
echo ">> Atualizando instaladores (pip/setuptools/wheel)..."
python -m pip install --no-cache-dir --upgrade pip wheel "setuptools<58"

echo ">> Instalando pré-requisitos (compilações mais comuns)..."
python -m pip install --no-cache-dir "numpy==1.16.4" cython wheel

echo ">> Instalando pacotes específicos e Flask..."
python -m pip install --no-cache-dir 'protobuf==3.20.*' Flask

echo ">> Instalando dependências do requirements.txt..."
python -m pip install --no-cache-dir -r requirements.txt

echo ">> Forçando a reinstalação limpa do opendr..."
python -m pip install --no-cache-dir --force-reinstall --no-deps opendr==0.78

echo ">> Baixando os arquivos de modelo..."
mkdir -p models

wget -O models/model.ckpt-667589.data-00000-of-00001 \
  https://diegotolentino.com.br/bibliotecas-aifit/models/model.ckpt-667589.data-00000-of-00001

wget -O models/model.ckpt-667589.index \
  https://diegotolentino.com.br/bibliotecas-aifit/models/model.ckpt-667589.index

wget -O models/model.ckpt-667589.meta \
  https://diegotolentino.com.br/bibliotecas-aifit/models/model.ckpt-667589.meta

wget -O models/neutral_smpl_with_cocoplus_reg.pkl \
  https://diegotolentino.com.br/bibliotecas-aifit/models/neutral_smpl_with_cocoplus_reg.pkl

echo ">> Download dos modelos concluído."
echo ">> Configuração finalizada com sucesso!"
