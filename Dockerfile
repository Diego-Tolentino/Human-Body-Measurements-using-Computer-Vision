# Usar uma imagem base do Python 3.7
FROM python:3.7-slim-buster

# Definir o diretório de trabalho
WORKDIR /app

# Adicionar o diretório ao PYTHONPATH para resolver importações
ENV PYTHONPATH /app

# Instalar todas as dependências do sistema que descobrimos
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3.7-dev \
    libosmesa6-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    wget \
    freeglut3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar os arquivos do projeto
COPY . .

# Executar o script de instalação (com todas as correções)
RUN chmod +x install.sh && ./install.sh

# Expor a porta da aplicação
EXPOSE 8080

# Comando para iniciar a aplicação
CMD ["/app/venv/bin/python", "app.py"]