#!/bin/bash
set -euo pipefail

# Caminho do repositório (padrão: diretório atual)
REPO_PATH=${1:-.}
TRIVY_IMAGE="aquasec/trivy:latest"
DO_REPORT=false

# Analisa argumentos
for arg in "$@"; do
  case $arg in
    --report)
      DO_REPORT=true
      shift
      ;;
    *)
      REPO_PATH="$arg"
      ;;
  esac
done

ABS_PATH=$(realpath "$REPO_PATH")

echo "🚀 Iniciando auditoria com Trivy no repositório: $REPO_PATH"
if $DO_REPORT; then
  REPORT_DIR="trivy-report"
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  mkdir -p "$REPORT_DIR"
  echo "📝 Relatórios serão salvos em ./$REPORT_DIR"
fi

# 🔍 Scan filesystem
echo "🔍 Rodando scan no filesystem..."

TRIVY_FS_CMD=(
  docker run --rm
  -v "$ABS_PATH:/repo"
)

if $DO_REPORT; then
  TRIVY_FS_CMD+=(
    -v "$PWD/$REPORT_DIR:/report"
    "$TRIVY_IMAGE" fs /repo
    --exit-code 0
    --severity CRITICAL,HIGH
    --format table
    --output /report/report-$TIMESTAMP.txt
    --format json
    --output /report/report-$TIMESTAMP.json
  )
else
  TRIVY_FS_CMD+=(
    "$TRIVY_IMAGE" fs /repo
    --exit-code 0
    --severity CRITICAL,HIGH
  )
fi

"${TRIVY_FS_CMD[@]}"
echo "✅ Scan do filesystem completo!"

# 🐳 Dockerfile scan
if [[ -f "$REPO_PATH/Dockerfile" ]]; then
  echo "🐳 Dockerfile encontrado. Buildando imagem temporária..."

  docker build -t temp-audit-image "$REPO_PATH" > /dev/null

  if $DO_REPORT; then
    docker run --rm \
      -v "$PWD/$REPORT_DIR:/report" \
      "$TRIVY_IMAGE" image temp-audit-image \
      --exit-code 0 \
      --severity CRITICAL,HIGH \
      --format table \
      --output /report/image-report-$TIMESTAMP.txt \
      --format json \
      --output /report/image-report-$TIMESTAMP.json
  else
    docker run --rm \
      "$TRIVY_IMAGE" image temp-audit-image \
      --exit-code 0 \
      --severity CRITICAL,HIGH
  fi

  docker rmi temp-audit-image >/dev/null
  echo "✅ Scan da imagem concluído!"
else
  echo "⚠️ Dockerfile não encontrado. Pulando scan da imagem."
fi

if $DO_REPORT; then
  echo "📦 Relatórios salvos em '$REPORT_DIR'"
fi

echo "🎯 Auditoria finalizada com sucesso!"
