# Usar uma imagem base do Python 3.7 (variante buster para manter compatibilidade)
FROM python:3.7-slim-buster

# Definir o diret�rio de trabalho
WORKDIR /app

# Corrigir formato do ENV
ENV PYTHONPATH=/app

# Instalar depend�ncias do sistema (sem python3.7-dev)
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

# Executar o script de instala��o
RUN chmod +x install.sh && ./install.sh

# Expor a porta da aplica��o
EXPOSE 8080

# Comando para iniciar a aplica��o
CMD ["/app/venv/bin/python", "app.py"]
