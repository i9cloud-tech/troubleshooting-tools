#!/bin/bash
set -euo pipefail

# Configurações
REPO_PATH=${1:-.} # Caminho do repositório (padrão: diretório atual)
TRIVY_IMAGE="aquasec/trivy:latest"

echo "🚀 Iniciando auditoria de segurança com Trivy no repositório: $REPO_PATH"
echo "🔍 Verificando se Docker está disponível..."

if ! command -v docker &> /dev/null; then
  echo "❌ Docker não encontrado. Instale o Docker antes de prosseguir."
  exit 1
fi

echo "✅ Docker OK. Rodando Trivy..."

# Rodando auditoria no código-fonte (IaC, secrets, etc)
docker run --rm -v "$PWD/$REPO_PATH:/repo" "$TRIVY_IMAGE" \
  fs /repo --exit-code 1 --severity CRITICAL,HIGH --no-progress

# Rodando auditoria no Dockerfile, se existir
if [[ -f "$REPO_PATH/Dockerfile" ]]; then
  echo "🐳 Dockerfile encontrado. Auditando imagem local..."
  docker build -t temp-audit-image "$REPO_PATH"
  docker run --rm "$TRIVY_IMAGE" image temp-audit-image \
    --exit-code 1 --severity CRITICAL,HIGH --no-progress
  docker rmi temp-audit-image >/dev/null
fi

echo "✅ Auditoria finalizada com sucesso!"
