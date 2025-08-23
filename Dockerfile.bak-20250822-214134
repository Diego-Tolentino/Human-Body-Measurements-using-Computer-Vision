# Usar uma imagem base do Python 3.7 (variante buster para compatibilidade)
FROM python:3.7-slim-buster

# Definir o diretório de trabalho
WORKDIR /app

# Adicionar o diretório ao PYTHONPATH para resolver importações
ENV PYTHONPATH=/app

# Instalar dependências de sistema (sem python3.7-dev)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    libosmesa6-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    wget \
    freeglut3-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copiar os arquivos do projeto
COPY . .

# Executar o script de instalação
RUN chmod +x install.sh && ./install.sh

# Expor a porta da aplicação
EXPOSE 8080

# Comando para iniciar a aplicação
CMD ["/app/venv/bin/python", "app.py"]
