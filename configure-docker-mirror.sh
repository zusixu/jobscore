#!/bin/bash

# Docker镜像源配置脚本
# 用于在已经运行的系统上快速配置Docker阿里云镜像源

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Docker镜像源配置脚本${NC}"
echo -e "${YELLOW}========================================${NC}"

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker未安装${NC}"
    exit 1
fi

# 检查是否以root身份运行
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ 此脚本需要root权限运行${NC}"
    exit 1
fi

echo -e "\n${YELLOW}正在配置Docker阿里云镜像源...${NC}"

# 创建Docker配置目录
mkdir -p /etc/docker

# 配置Docker daemon.json - 使用阿里云和其他国内镜像源
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
  },
  "storage-driver": "overlay2"
}
EOF

echo -e "${GREEN}✓${NC} daemon.json配置已更新"

# 重启Docker使配置生效
echo -e "\n${YELLOW}重启Docker服务...${NC}"
systemctl daemon-reload
systemctl restart docker

# 验证配置
echo -e "\n${YELLOW}验证Docker镜像源配置...${NC}"
docker info | grep -A 10 "Registry Mirrors"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Docker镜像源配置成功！"
    echo -e "\n${GREEN}已配置的镜像源:${NC}"
    echo "  1. Docker中国官方镜像:     registry.docker-cn.com"
    echo "  2. 中科大镜像:             docker.mirrors.ustc.edu.cn"
    echo "  3. Google镜像:             gcr.mirrors.ustc.edu.cn"
    echo "  4. GitHub镜像:             ghcr.io.mirror.1001.workers.dev"
else
    echo -e "${RED}✗${NC} 配置可能未成功，请检查Docker服务状态"
    exit 1
fi

# 测试下载镜像速度
echo -e "\n${YELLOW}测试下载nginx镜像速度...${NC}"
docker pull alpine:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} 镜像源下载测试成功！"
else
    echo -e "${YELLOW}⚠ 镜像下载可能受网络影响，请稍后重试${NC}"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}配置完成！${NC}"
echo -e "${GREEN}========================================${NC}"