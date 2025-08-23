#!/usr/bin/env bash
# setup_vps.sh — Instala/Atualiza a app Human Body Measurements na VPS
# Uso:
#   curl -sSL https://raw.githubusercontent.com/Diego-Tolentino/Human-Body-Measurements-using-Computer-Vision/master/setup_vps.sh | sudo bash

set -Eeuo pipefail

### =========================
### Configurações
### =========================
APP_DIR="/opt/body-measurements"
REPO_URL="https://github.com/Diego-Tolentino/Human-Body-Measurements-using-Computer-Vision.git"
IMAGE_NAME="human-measurements"
CONTAINER_NAME="human-measurements"
HOST_PORT="8080"
CONTAINER_PORT="8080"
# --- NOVO: Configurações do Volume Compartilhado ---
HOST_SHARED_DIR="/srv/shared_images"
CONTAINER_SHARED_DIR="/app/shared_images"


### =========================
### Funções auxiliares
### =========================
log()   { printf "\033[1;34m%s\033[0m\n" "$*"; }
ok()    { printf "\033[1;32m%s\033[0m\n" "$*"; }
warn()  { printf "\033[1;33m%s\033[0m\n" "$*"; }
err()   { printf "\033[1;31mERRO: %s\033[0m\n" "$*" >&2; }
abort(){ err "$*"; exit 1; }

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    abort "Execute como root (use sudo)."
  fi
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

### =========================
### Passo 1 — Docker
### =========================
ensure_docker() {
  log "======================================================"
  log "=== PASSO 1/6: Preparando e Instalando o Docker    ==="
  log "======================================================"

  apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates curl gnupg lsb-release

  if ! have_cmd docker; then
    log "Docker não encontrado. Instalando Docker Engine (repositório oficial)..."
    install -m 0755 -d /etc/apt/keyrings
    if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      chmod a+r /etc/apt/keyrings/docker.gpg
    fi

    . /etc/os-release
    echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" \
      > /etc/sources.list.d/docker.list

    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ok "Docker instalado."
  else
    ok "Docker já instalado."
  fi

  systemctl enable docker >/dev/null 2>&1 || true
  systemctl start docker  >/dev/null 2>&1 || true

  if ! docker info >/dev/null 2>&1; then
    abort "Docker instalado, mas o daemon não está ativo. Verifique 'systemctl status docker'."
  fi
  ok "Docker ativo."
}

### =========================
### Passo 2 — Código (clone/update)
### =========================
pull_code() {
  log "======================================================"
  log "=== PASSO 2/6: Baixando/Atualizando a Aplicação    ==="
  log "======================================================"

  if ! have_cmd git; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y git
  fi

  if [[ -d "$APP_DIR/.git" ]]; then
    log "Diretório Git encontrado. Atualizando..."
    # Corrigido para usar a branch 'master' como vimos que é a correta
    git -C "$APP_DIR" fetch --all --prune
    git -C "$APP_DIR" reset --hard origin/master
    ok "Repositório sincronizado com origin/master."
  elif [[ -d "$APP_DIR" ]]; then
    warn "Diretório '$APP_DIR' existe mas não é um repositório Git."
    TS=$(date +%Y%m%d-%H%M%S)
    BACKUP="${APP_DIR}.backup-${TS}"
    warn "Movendo diretório existente para: ${BACKUP}"
    mv "$APP_DIR" "$BACKUP"
    log "Clonando repositório limpo para '$APP_DIR'..."
    git clone "$REPO_URL" "$APP_DIR"
    ok "Clonado."
  else
    log "Clonando repositório em '$APP_DIR'..."
    git clone "$REPO_URL" "$APP_DIR"
    ok "Clonado."
  fi
  }

### =========================
### Passo 3 — Validar/patch Dockerfile
### =========================
patch_dockerfile() {
  log "======================================================"
  log "=== PASSO 3/6: Validando e Corrigindo Dockerfile   ==="
  log "======================================================"

  local df="$APP_DIR/Dockerfile"
  [[ -f "$df" ]] || abort "Dockerfile não encontrado em '$APP_DIR'."

  # Backup
  local ts; ts=$(date +%Y%m%d-%H%M%S)
  cp -a "$df" "${df}.bak-${ts}"

  # 1) Garantir base compatível: python:3.7-slim-buster
  if grep -Eq '^FROM[[:space:]]+python:' "$df"; then
    sed -i -E 's|^FROM[[:space:]]+python:.*$|FROM python:3.7-slim-buster|' "$df"
  else
    warn "Dockerfile não declara FROM python:*. Mantendo base original."
  fi

  # 2) Corrigir ENV legado: "ENV KEY value" -> "ENV KEY=value"
  if grep -Eq '^ENV[[:space:]]+PYTHONPATH[[:space:]]+/app' "$df"; then
    sed -i -E 's|^ENV[[:space:]]+PYTHONPATH[[:space:]]+/app|ENV PYTHONPATH=/app|' "$df"
  fi

  # 3) Remover python3.7-dev do apt-get install
  sed -i -E 's/[[:space:]]*python3\.7-dev[[:space:]]*\\?//g' "$df"
  sed -i -E ':a;N;$!ba;s/\\[[:space:]]*\n[[:space:]]*\\/\n    \\/g' "$df"

  # 4) Garantir limpeza de cache apt
  if ! grep -q 'rm -rf /var/lib/apt/lists/\*' "$df"; then
    sed -i -E 's|(apt-get install .*$)|\1 \&\& rm -rf /var/lib/apt/lists/\*|' "$df"
  fi

  ok "Dockerfile validado e (se necessário) corrigido."
}

### =========================
### Passo 4 — Build da imagem
### =========================
build_image() {
  log "======================================================"
  log "=== PASSO 4/6: Construindo a Imagem Docker         ==="
  log "======================================================"

  local df="$APP_DIR/Dockerfile"
  if ! grep -q "^FROM " "$df"; then
    abort "Dockerfile inválido: não há instrução FROM."
  fi

  docker build --pull -t "$IMAGE_NAME:latest" "$APP_DIR"
  ok "Imagem '$IMAGE_NAME:latest' construída com sucesso."
}

### =========================
### NOVO: Passo 5 — Criar diretório compartilhado
### =========================
create_shared_dir() {
  log "======================================================"
  log "=== PASSO 5/6: Criando a Pasta Compartilhada       ==="
  log "======================================================"
  log "Criando diretório no host: ${HOST_SHARED_DIR}"
  mkdir -p "$HOST_SHARED_DIR"
  # Dando permissão total para evitar problemas entre containers
  chmod 777 "$HOST_SHARED_DIR"
  ok "Diretório compartilhado pronto."
}

### =========================
### Passo 6 — Run container
### =========================
run_container() {
  log "======================================================"
  log "=== PASSO 6/6: Iniciando a Aplicação             ==="
  log "======================================================"

  if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
    warn "Container '$CONTAINER_NAME' já existe. Removendo..."
    docker rm -f "$CONTAINER_NAME" >/dev/null
  fi

  log "Iniciando container com volume compartilhado..."
  docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p "${HOST_PORT}:${CONTAINER_PORT}" \
    -v "${HOST_SHARED_DIR}:${CONTAINER_SHARED_DIR}" \
    "$IMAGE_NAME:latest"

  ok "Container '$CONTAINER_NAME' iniciado."
  log "Porta mapeada: http://SEU_IP:${HOST_PORT}"
  log "Pasta da VPS '${HOST_SHARED_DIR}' está conectada à pasta '${CONTAINER_SHARED_DIR}' no container."

  docker ps --filter "name=${CONTAINER_NAME}"
  echo
  log "Dicas:"
  echo " - Ver logs:  docker logs -f ${CONTAINER_NAME}"
  echo " - Reiniciar: docker restart ${CONTAINER_NAME}"
  echo " - Parar:     docker stop ${CONTAINER_NAME}"
  echo " - Remover:   docker rm -f ${CONTAINER_NAME}"
}

### =========================
### Execução
### =========================
require_root
ensure_docker
pull_code
patch_dockerfile
build_image
create_shared_dir
run_container

ok "================================================================================="
ok " Instalação finalizada! A aplicação está disponível na porta ${HOST_PORT}."
ok " Lembre-se de mapear o volume do n8n para a pasta: ${HOST_SHARED_DIR}"
ok "================================================================================="