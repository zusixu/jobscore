#!/bin/bash

# 应用管理脚本
APP_DIR="/opt/job-score"
DOCKER_COMPOSE="docker-compose -f $APP_DIR/docker-compose.yml"

case "$1" in
    start)
        echo "启动应用..."
        cd "$APP_DIR"
        $DOCKER_COMPOSE up -d
        echo "✓ 应用已启动"
        ;;
    stop)
        echo "停止应用..."
        cd "$APP_DIR"
        $DOCKER_COMPOSE down
        echo "✓ 应用已停止"
        ;;
    restart)
        echo "重启应用..."
        cd "$APP_DIR"
        $DOCKER_COMPOSE restart
        echo "✓ 应用已重启"
        ;;
    logs)
        cd "$APP_DIR"
        $DOCKER_COMPOSE logs -f ${@:2}
        ;;
    status)
        echo "应用状态:"
        cd "$APP_DIR"
        $DOCKER_COMPOSE ps
        echo ""
        echo "系统信息:"
        docker stats --no-stream
        ;;
    update)
        echo "更新应用..."
        cd "$APP_DIR"
        git pull origin main
        $DOCKER_COMPOSE up -d --build
        echo "✓ 应用已更新"
        ;;
    backup)
        BACKUP_DIR="/var/backups/job-score"
        mkdir -p "$BACKUP_DIR"
        BACKUP_FILE="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
        echo "备份应用数据到 $BACKUP_FILE..."
        tar -czf "$BACKUP_FILE" "$APP_DIR" 2>/dev/null || echo "⚠ 某些文件可能无法备份"
        echo "✓ 备份完成"
        ;;
    health)
        echo "检查应用健康状态..."
        DOMAIN=${2:-"localhost"}
        if curl -f -s https://"$DOMAIN" > /dev/null 2>&1; then
            echo "✓ 应用正常运行"
        else
            echo "✗ 应用不可访问"
            exit 1
        fi
        ;;
    *)
        echo "使用方法: $0 {start|stop|restart|logs|status|update|backup|health} [参数]"
        echo ""
        echo "命令说明:"
        echo "  start      - 启动应用"
        echo "  stop       - 停止应用"
        echo "  restart    - 重启应用"
        echo "  logs       - 查看日志（使用 'logs -f' 实时跟踪）"
        echo "  status     - 查看应用状态"
        echo "  update     - 更新应用代码"
        echo "  backup     - 备份应用数据"
        echo "  health     - 检查应用健康状态"
        exit 1
        ;;
esac