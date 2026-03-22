#!/bin/bash

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置变量
APP_NAME="job-score"
APP_DIR="/opt/job-score"
LOG_DIR="/var/log/$APP_NAME"
SERVICE_USER="www-data"
DOMAIN="your-domain.com"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}工作性价比计算器 - Linux部署脚本${NC}"
echo -e "${YELLOW}========================================${NC}"

# 检查是否以root身份运行
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ 此脚本需要root权限运行${NC}"
    exit 1
fi

# 1. 系统依赖检查
echo -e "\n${YELLOW}[1/8]${NC} 检查系统依赖..."
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 已安装"
        return 0
    else
        echo -e "${RED}✗${NC} $1 未安装，正在安装..."
        return 1
    fi
}

# 检查和安装必要工具
if ! check_command docker; then
    echo -e "${YELLOW}从阿里云源安装Docker...${NC}"
    # 使用阿里云镜像源安装Docker
    curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add - 2>/dev/null
    add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # 配置Docker镜像源为阿里云
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://gcr.mirrors.ustc.edu.cn",
    "https://ghcr.io.mirror.1001.workers.dev"
  ],
  "insecure-registries": []
}
EOF
    # 重启Docker使配置生效
    systemctl daemon-reload
    systemctl restart docker
    echo -e "${GREEN}✓${NC} Docker安装完成，已配置阿里云镜像源"
fi

if ! check_command docker-compose; then
    echo -e "${YELLOW}从Github安装docker-compose...${NC}"
    # 使用GitHub下载docker-compose（国内如果下载慢可替换为国内源）
    DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"
    # 备用国内源（如果GitHub下载慢）
    # DOCKER_COMPOSE_URL="https://get.daocloud.io/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m)"
    
    curl -L "$DOCKER_COMPOSE_URL" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓${NC} docker-compose安装完成"
fi

if ! check_command nginx; then
    apt-get install -y nginx
fi

if ! check_command certbot; then
    apt-get install -y certbot python3-certbot-nginx
fi

# 2. 创建应用目录
echo -e "\n${YELLOW}[2/8]${NC} 创建应用目录..."
mkdir -p "$APP_DIR"
mkdir -p "$LOG_DIR"
chown "$SERVICE_USER:$SERVICE_USER" "$LOG_DIR"
echo -e "${GREEN}✓${NC} 目录创建完成"

# 3. 获取最新代码（如果使用git）
echo -e "\n${YELLOW}[3/8]${NC} 获取最新代码..."
if [ -d "$APP_DIR/.git" ]; then
    cd "$APP_DIR"
    git pull origin main
else
    echo -e "${YELLOW}提示：${NC}请手动将项目文件复制到 $APP_DIR"
fi

# 4. 配置环境变量
echo -e "\n${YELLOW}[4/8]${NC} 配置环境变量..."
if [ ! -f "$APP_DIR/.env.production" ]; then
    cp "$APP_DIR/.env.production.example" "$APP_DIR/.env.production" 2>/dev/null || cat > "$APP_DIR/.env.production" << EOF
NODE_ENV=production
VITE_APP_URL_BASE=/
VITE_API_BASE_URL=https://$DOMAIN
EOF
fi
echo -e "${GREEN}✓${NC} 环境变量配置完成"

# 5. 配置SSL证书（Let's Encrypt）
echo -e "\n${YELLOW}[5/8]${NC} 配置SSL证书..."
if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo -e "${YELLOW}首次运行，需要申请SSL证书...${NC}"
    certbot certonly --standalone -d "$DOMAIN" -d "www.$DOMAIN" --non-interactive --agree-tos -m admin@"$DOMAIN"
else
    echo -e "${GREEN}✓${NC} SSL证书已存在"
fi

# 6. 构建Docker镜像
echo -e "\n${YELLOW}[6/8]${NC} 构建Docker镜像..."
cd "$APP_DIR"
docker-compose build
echo -e "${GREEN}✓${NC} Docker镜像构建完成"

# 7. 启动容器
echo -e "\n${YELLOW}[7/8]${NC} 启动应用容器..."
docker-compose up -d
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} 容器启动成功"
else
    echo -e "${RED}✗${NC} 容器启动失败，请检查日志"
    exit 1
fi

# 8. 设置自动续期
echo -e "\n${YELLOW}[8/8]${NC} 配置自动续期..."
if ! crontab -l | grep -q "certbot renew"; then
    (crontab -l 2>/dev/null; echo "0 0 1 * * certbot renew --quiet && docker-compose -f $APP_DIR/docker-compose.yml restart job-score") | crontab -
    echo -e "${GREEN}✓${NC} 自动续期任务已添加"
fi

# 检查应用状态
echo -e "\n${YELLOW}验证应用状态...${NC}"
sleep 3
if curl -f -s https://"$DOMAIN" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 应用已成功部署并可访问${NC}"
    echo -e "${GREEN}✓ 访问地址: https://$DOMAIN${NC}"
else
    echo -e "${YELLOW}⚠ 应用启动中，请稍候几秒后访问${NC}"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n常用命令:"
echo "  查看日志:     docker-compose -f $APP_DIR/docker-compose.yml logs -f"
echo "  重启应用:     docker-compose -f $APP_DIR/docker-compose.yml restart"
echo "  停止应用:     docker-compose -f $APP_DIR/docker-compose.yml down"
echo "  更新应用:     cd $APP_DIR && git pull && docker-compose up -d --build"