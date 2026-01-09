#!/usr/bin/env bash
# 共通 PostgreSQL / Redis コンテナ管理スクリプト
# Usage: ./scripts/db.sh [up|down|status|logs]

set -euo pipefail

# 設定
POSTGRES_CONTAINER="qadiff-postgres"
REDIS_CONTAINER="qadiff-redis"
POSTGRES_VOLUME="qadiff-pgdata"
POSTGRES_IMAGE="postgres:17"
REDIS_IMAGE="redis:8"

# 色付き出力
info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[1;32m[OK]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }

# コンテナが起動中か確認
is_running() {
  docker ps --filter "name=$1" --filter "status=running" --format '{{.Names}}' | grep -q "^$1$"
}

# コンテナが存在するか確認
exists() {
  docker ps -a --filter "name=$1" --format '{{.Names}}' | grep -q "^$1$"
}

# PostgreSQL を起動
start_postgres() {
  if is_running "$POSTGRES_CONTAINER"; then
    info "$POSTGRES_CONTAINER is already running"
  elif exists "$POSTGRES_CONTAINER"; then
    info "Starting existing $POSTGRES_CONTAINER..."
    docker start "$POSTGRES_CONTAINER"
  else
    info "Creating $POSTGRES_CONTAINER..."
    docker volume create "$POSTGRES_VOLUME" 2>/dev/null || true
    docker run -d \
      --name "$POSTGRES_CONTAINER" \
      --restart unless-stopped \
      -e POSTGRES_USER=app \
      -e POSTGRES_PASSWORD=app \
      -e POSTGRES_DB=app \
      -p 5432:5432 \
      -v "$POSTGRES_VOLUME":/var/lib/postgresql/data \
      "$POSTGRES_IMAGE"
  fi
}

# Redis を起動
start_redis() {
  if is_running "$REDIS_CONTAINER"; then
    info "$REDIS_CONTAINER is already running"
  elif exists "$REDIS_CONTAINER"; then
    info "Starting existing $REDIS_CONTAINER..."
    docker start "$REDIS_CONTAINER"
  else
    info "Creating $REDIS_CONTAINER..."
    docker run -d \
      --name "$REDIS_CONTAINER" \
      --restart unless-stopped \
      -p 6379:6379 \
      "$REDIS_IMAGE"
  fi
}

# メインコマンド
case "${1:-help}" in
  up)
    info "Starting shared database containers..."
    start_postgres
    start_redis
    echo ""
    success "Shared databases are ready:"
    echo "  PostgreSQL: postgresql://app:app@host.docker.internal:5432/app"
    echo "  Redis:      redis://host.docker.internal:6379"
    ;;
  down)
    info "Stopping shared database containers..."
    docker stop "$POSTGRES_CONTAINER" "$REDIS_CONTAINER" 2>/dev/null || true
    success "Stopped."
    ;;
  status)
    echo "=== Shared Database Status ==="
    docker ps -a --filter "name=qadiff-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    ;;
  logs)
    echo "=== PostgreSQL Logs ==="
    docker logs --tail 20 "$POSTGRES_CONTAINER" 2>/dev/null || warn "Container not found"
    echo ""
    echo "=== Redis Logs ==="
    docker logs --tail 20 "$REDIS_CONTAINER" 2>/dev/null || warn "Container not found"
    ;;
  *)
    echo "Usage: $0 [up|down|status|logs]"
    echo ""
    echo "Commands:"
    echo "  up      Start PostgreSQL and Redis containers"
    echo "  down    Stop containers"
    echo "  status  Show container status"
    echo "  logs    Show container logs"
    exit 1
    ;;
esac
