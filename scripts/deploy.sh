#!/bin/bash
# scripts/deploy.sh
# Uso: ./scripts/deploy.sh [staging|production]

set -euo pipefail

ENVIRONMENT=${1:-staging}
APP_NAME=${APP_NAME:-meu-app}
BUILD_NUMBER=${BUILD_NUMBER:-local}

echo "========================================"
echo "  Deploy: $APP_NAME → $ENVIRONMENT"
echo "  Build : #$BUILD_NUMBER"
echo "========================================"

case "$ENVIRONMENT" in
  staging)
    echo "🔵 Deploying to STAGING..."
    # Exemplo: rsync, kubectl apply, docker-compose, etc.
    # kubectl set image deployment/$APP_NAME $APP_NAME=$APP_NAME:$BUILD_NUMBER -n staging
    echo "✅ Staging deploy concluído."
    ;;

  production)
    echo "🟢 Deploying to PRODUCTION..."
    # kubectl set image deployment/$APP_NAME $APP_NAME=$APP_NAME:$BUILD_NUMBER -n production
    echo "✅ Production deploy concluído."
    ;;

  *)
    echo "❌ Ambiente desconhecido: $ENVIRONMENT"
    echo "Use: staging | production"
    exit 1
    ;;
esac
