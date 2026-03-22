#!/bin/bash

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
APP_NAME="job-score"
APP_DIR="/opt/job-score"
LOG_DIR="/var/log/$APP_NAME"
DOMAIN="your-domain.com"

# 检测系统信息
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="$ID"
    OS_VERSION="$VERSION_ID"
else
    echo -e "${RED}❌ 无法检测操作系统${NC}"
    exit 1
fi

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}工作性价比计算器 - Linux部署脚本${NC}"
echo -e "${BLUE}检测到操作系统: $OS_NAME $OS_VERSION${NC}"
echo -e "${YELLOW}========================================${NC}"

# 检查是否以root身份运行
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ 此脚本需要root权限运行${NC}"
    exit 1
fi

# 确定包管理器
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    PKG_UPDATE="apt-get update"
    PKG_INSTALL="apt-get install -y"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    PKG_UPDATE="yum update -y"
    PKG_INSTALL="yum install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    PKG_UPDATE="dnf update -y"
    PKG_INSTALL="dnf install -y"
else
    echo -e "${RED}❌ 不支持的包管理器${NC}"
    exit 1
fi

echo -e "${BLUE}使用包管理器: $PKG_MANAGER${NC}\n"

# 1. 系统依赖检查
echo -e "${YELLOW}[1/8]${NC} 检查系统依赖..."
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 已安装"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $1 未安装，正在安装..."
        return 1
    fi
}

# 安装curl和wget
check_command curl || {
    $PKG_UPDATE
    $PKG_INSTALL curl
}

# 安装Docker
if ! check_command docker; then
    echo -e "${YELLOW}从国内源安装Docker...${NC}"
    $PKG_UPDATE
    
    if [ "$PKG_MANAGER" = "apt-get" ]; then
        # Ubuntu/Debian安装
        $PKG_INSTALL ca-certificates curl gnupg lsb-release
        curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add - 2>/dev/null
        add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
        $PKG_UPDATE
        $PKG_INSTALL docker-ce docker-ce-cli containerd.io docker-compose-plugin 2>/dev/null || {
            # 如果阿里云源失败，使用官方源
            curl -fsSL https://get.docker.com -o get-docker.sh
            bash get-docker.sh
        }
    else
        # CentOS/RHEL安装
        $PKG_INSTALL yum-utils
        yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        $PKG_INSTALL docker-ce docker-ce-cli containerd.io docker-compose-plugin 2>/dev/null || {
            # 如果阿里云源失败，使用官方源
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            $PKG_INSTALL docker-ce docker-ce-cli containerd.io
        }
    fi
fi

# 配置Docker镜像源
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << 'EOF'
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://gcr.mirrors.ustc.edu.cn",
    "https://ghcr.io.mirror.1001.workers.dev"
  ],
  "insecure-registries": [],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "3"
  }
}
EOF

# 启动并启用Docker
systemctl daemon-reload
systemctl enable docker
systemctl start docker
echo -e "${GREEN}✓${NC} Docker已安装并配置完成"

# 安装docker-compose
if ! check_command docker-compose; then
    echo -e "${YELLOW}安装docker-compose...${NC}"
    
    # 尝试多个源
    DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"
    BACKUP_URLS=(
        "https://get.daocloud.io/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)"
        "https://raw.githubusercontent.com/docker/compose/master/script/install/install.sh"
    )
    
    # 尝试主URL
    if curl -L -f -s -o /tmp/dc_check "$DOCKER_COMPOSE_URL"; then
        curl -L -f -o /usr/local/bin/docker-compose "$DOCKER_COMPOSE_URL"
    else
        # 尝试备用URL
        for URL in "${BACKUP_URLS[@]}"; do
            if curl -L -f -s "$URL" -o /tmp/docker-compose.tmp; then
                mv /tmp/docker-compose.tmp /usr/local/bin/docker-compose
                break
            fi
        done
    fi
    
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓${NC} docker-compose安装完成"
fi

# 安装nginx
if ! check_command nginx; then
    echo -e "${YELLOW}安装nginx...${NC}"
    $PKG_INSTALL nginx
    systemctl enable nginx
    systemctl start nginx
    echo -e "${GREEN}✓${NC} nginx安装完成"
fi

# 安装certbot
if ! check_command certbot; then
    echo -e "${YELLOW}安装certbot...${NC}"
    if [ "$PKG_MANAGER" = "apt-get" ]; then
        $PKG_INSTALL certbot python3-certbot-nginx
    else
        $PKG_INSTALL certbot python3-certbot-nginx python3-certbot
    fi
    echo -e "${GREEN}✓${NC} certbot安装完成"
fi

# 安装git
check_command git || $PKG_INSTALL git

# 2. 创建应用目录
echo -e "\n${YELLOW}[2/8]${NC} 创建应用目录..."
mkdir -p "$APP_DIR"
mkdir -p "$LOG_DIR"
chmod 755 "$LOG_DIR"
echo -e "${GREEN}✓${NC} 目录创建完成"

# 3. 获取最新代码
echo -e "\n${YELLOW}[3/8]${NC} 获取最新代码..."
if [ -d "$APP_DIR/.git" ]; then
    cd "$APP_DIR"
    git pull origin main || git pull origin master
    echo -e "${GREEN}✓${NC} 代码已更新"
else
    echo -e "${BLUE}提示:${NC} 请手动将项目文件复制到 $APP_DIR"
    echo -e "${BLUE}例如:${NC} git clone https://github.com/your/project.git $APP_DIR"
fi

# 4. 配置环境变量
echo -e "\n${YELLOW}[4/8]${NC} 配置环境变量..."
if [ ! -f "$APP_DIR/.env.production" ]; then
    cat > "$APP_DIR/.env.production" << EOF
NODE_ENV=production
VITE_APP_URL_BASE=/
VITE_API_BASE_URL=https://$DOMAIN
EOF
    echo -e "${YELLOW}⚠${NC} 已生成.env.production，请手动编辑并修改DOMAIN"
else
    echo -e "${GREEN}✓${NC} .env.production已存在"
fi
echo -e "${GREEN}✓${NC} 环境变量配置完成"

# 5. 配置SSL证书
echo -e "\n${YELLOW}[5/8]${NC} 配置SSL证书..."
if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo -e "${YELLOW}⚠${NC} SSL证书不存在，跳过此步骤"
    echo -e "${BLUE}提示:${NC} 部署成功后，请手动运行以下命令生成证书:"
    echo -e "${BLUE}certbot certonly --standalone -d $DOMAIN -d www.$DOMAIN${NC}"
else
    echo -e "${GREEN}✓${NC} SSL证书已存在"
fi

# 6. 构建Docker镜像
echo -e "\n${YELLOW}[6/8]${NC} 构建Docker镜像..."
if [ -d "$APP_DIR" ] && [ -f "$APP_DIR/docker-compose.yml" ]; then
    cd "$APP_DIR"
    docker-compose build
    echo -e "${GREEN}✓${NC} Docker镜像构建完成"
else
    echo -e "${YELLOW}⚠${NC} docker-compose.yml不存在，跳过构建"
fi

# 7. 启动容器
echo -e "\n${YELLOW}[7/8]${NC} 启动应用容器..."
if [ -f "$APP_DIR/docker-compose.yml" ]; then
    cd "$APP_DIR"
    docker-compose up -d
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} 容器启动成功"
        sleep 3
        docker-compose ps
    else
        echo -e "${YELLOW}⚠${NC} 容器启动可能失败，请查看日志:"
        docker-compose logs
    fi
else
    echo -e "${YELLOW}⚠${NC} docker-compose.yml不存在，跳过启动"
fi

# 8. 设置自动续期
echo -e "\n${YELLOW}[8/8]${NC} 配置自动续期..."
if [ -f "$APP_DIR/docker-compose.yml" ]; then
    if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
        (crontab -l 2>/dev/null; echo "0 0 1 * * certbot renew --quiet && docker-compose -f $APP_DIR/docker-compose.yml restart job-score 2>&1 | logger") | crontab -
        echo -e "${GREEN}✓${NC} 自动续期任务已添加"
    else
        echo -e "${GREEN}✓${NC} 自动续期任务已存在"
    fi
fi

# 最终信息
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✓ 部署脚本执行完成！${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${BLUE}后续步骤:${NC}"
echo "1. 修改配置文件（如未修改）:"
echo "   sed -i 's/your-domain.com/your-real-domain/g' $APP_DIR/nginx.conf"
echo ""
echo "2. 生成SSL证书:"
echo "   certbot certonly --standalone -d your-real-domain"
echo ""
echo "3. 查看应用状态:"
echo "   cd $APP_DIR && docker-compose ps"
echo "   docker-compose logs -f"
echo ""
echo "4. 常用命令:"
echo "   ./manage.sh start|stop|restart|logs|status"
echo ""
echo -e "${YELLOW}⚠ 注意:${NC} 请确保:/opt/job-score 目录下有完整的项目文件（包括docker-compose.yml）"