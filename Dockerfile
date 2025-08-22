FROM python:3.7-slim

ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

WORKDIR /app

# Instala dependências do sistema para OpenCV e outras bibliotecas
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      libgl1-mesa-dev \
      libglu1-mesa-dev \
      libosmesa6-dev \
      pkg-config \
      libglib2.0-0 \
      libsm6 \
      libxext6 \
      libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Copia requirements e instala dependências Python
COPY requirements.txt .
RUN pip install numpy==1.19.5 && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir 'protobuf<3.20' Flask

# Copia o restante do código
COPY . .

# Expõe a porta da API Flask
EXPOSE 8080

# Define o entrypoint para rodar o servidor Flask
CMD ["python", "app.py"]
