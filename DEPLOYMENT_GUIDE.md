# 📦 部署指南

在 Ubuntu 24.04 系统上部署应用

---

## ✅ 前置要求

- **系统**: Ubuntu 24.04 LTS (推荐) 或其他支持的Linux发行版
- **权限**: Root 或 sudo 权限
- **域名**: 已注册的域名并指向服务器IP
- **端口**: 80/443 开放

---

## 🚀 一键部署

```bash
# 1. SSH连接服务器
ssh root@your-server-ip

# 2. 进入任意目录并克隆项目
cd /opt
git clone https://github.com/your-username/job-score.git
cd job-score

# 3. 配置部署参数
cp .env.deployment.example .env.deployment
# 编辑配置文件，根据实际情况修改路径和域名
nano .env.deployment

# 4. 执行部署
chmod +x deploy.sh manage.sh
sudo ./deploy.sh
```

---

## ⚙️ 配置文件说明 (.env.deployment)

部署脚本不再使用硬编码路径，所有配置都在 `.env.deployment` 中管理：

```bash
# 应用基础目录（存放项目代码）
APP_BASE_DIR="/opt/job-score"

# 日志目录
LOG_DIR="/var/log/job-score"

# 数据备份目录
BACKUP_DIR="/var/backups/job-score"

# 域名配置
DOMAIN="your-domain.com"
DOMAIN_WWW="www.your-domain.com"

# SSL证书路径
SSL_CERT_PATH="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
SSL_KEY_PATH="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"

# Nginx配置
NGINX_ROOT="/var/www/job-score/dist"
NGINX_ACCESS_LOG="${LOG_DIR}/nginx-access.log"
NGINX_ERROR_LOG="${LOG_DIR}/nginx-error.log"

# Docker容器名称
DOCKER_CONTAINER_NAME="job-score-app"
```

**重要**: 复制 `.env.deployment.example` 为 `.env.deployment` 并根据实际情况修改。

---

## 🔐 关键配置步骤

### 1. 修改域名配置

编辑 `.env.deployment`：

```bash
DOMAIN="your-real-domain.com"
DOMAIN_WWW="www.your-real-domain.com"
```

### 2. 配置应用路径（可选）

如果想使用不同的安装路径，修改：

```bash
APP_BASE_DIR="/path/to/your/app"
LOG_DIR="/path/to/your/logs"
BACKUP_DIR="/path/to/your/backups"
```

### 3. 申请SSL证书

部署脚本会自动配置 Nginx，但需要先申请证书：

```bash
# 申请证书
certbot certonly --standalone \
  -d your-real-domain.com \
  -d www.your-real-domain.com \
  --non-interactive \
  --agree-tos \
  -m admin@your-real-domain.com

# 验证证书
certbot certificates
```

---

## 📊 应用管理

所有管理命令自动使用 `.env.deployment` 中的配置：

```bash
# 启动应用
./manage.sh start

# 停止应用
./manage.sh stop

# 重启应用
./manage.sh restart

# 查看日志（实时）
./manage.sh logs -f

# 查看状态
./manage.sh status

# 更新应用（拉取最新代码并重启）
./manage.sh update

# 备份数据
./manage.sh backup

# 检查健康状态
./manage.sh health your-real-domain.com
```

---

## ✅ 验证部署

```bash
# 1. 查看容器运行状态
docker-compose -f $APP_BASE_DIR/docker-compose.yml ps

# 2. 检查应用可访问性
curl -I https://your-real-domain.com

# 3. 查看实时日志
docker-compose -f $APP_BASE_DIR/docker-compose.yml logs -f

# 4. 查看Nginx状态
nginx -t
systemctl status nginx
```

---

## 🛠️ 常见问题

### Q: 如何修改部署路径？

A: 编辑 `.env.deployment` 文件：
```bash
# 修改应用目录
APP_BASE_DIR="/your/custom/path"
# 修改日志目录
LOG_DIR="/your/custom/log/path"
# 重新运行部署脚本或管理脚本
```

### Q: 所有路径都是从哪里读取的?

A: 所有路径都从 `.env.deployment` 读取，部署脚本和管理脚本会自动加载此文件。避免了硬编码路径问题。

### Q: 云服务器需要开放哪些端口？

A: 在云控制台(安全组/防火墙)中开放：
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)

### Q: docker-compose命令找不到？

A: 脚本会自动安装，如需手动安装：
```bash
# Ubuntu 24.04
apt-get update
apt-get install -y docker-compose-plugin
# 或
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-x86_64 \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### Q: 证书申请失败？

A: 检查以下项：
```bash
# 1. 端口80是否开放
ss -tlnp | grep :80

# 2. 域名是否正确指向此服务器
nslookup your-domain.com

# 3. 检查firewall状态
ufw status
# 或
iptables -L -n

# 4. 查看certbot日志
sudo certbot renew --dry-run -v
```

### Q: 应用启动失败？

A: 查看日志：
```bash
# 查看Docker日志
docker-compose -f $APP_BASE_DIR/docker-compose.yml logs

# 查看Nginx日志
tail -f /var/log/nginx/error.log

# 检查Nginx配置
nginx -t
```

### Q: 如何更新应用？

A: 
```bash
# 自动更新（推荐）
./manage.sh update

# 或手动更新
cd $APP_BASE_DIR
git pull origin main
docker-compose up -d --build
```

---

## 🔄 系统维护

### SSL证书自动续期

已通过Cron自动配置，每月1日00:00运行。手动续期：

```bash
certbot renew --force-renewal
```

### 查看证书信息

```bash
certbot certificates
```

### 更新系统包

```bash
apt-get update
apt-get upgrade -y
```

### 查看占用存储空间

```bash
du -sh $APP_BASE_DIR
du -sh $LOG_DIR
du -sh $BACKUP_DIR
```

---

## 📋 Ubuntu 24.04 特殊注意事项

1. **Python**: Ubuntu 24.04 包含 Python 3.12，某些旧脚本可能不兼容
2. **systemd**: 使用最新的 systemd，Cron任务配置保持不变
3. **Docker**: 官方推荐使用 docker.io 包（已在脚本中处理）
4. **Firewall**: 默认启用 UFW，某些云服务器可能关闭

### 快速检查系统信息

```bash
# 查看Ubuntu版本
cat /etc/os-release

# 查看Python版本
python3 --version

# 查看内核版本
uname -r
```

---

## 🔗 相关文档

- [Docker Compose 官方文档](https://docs.docker.com/compose/)
- [Let's Encrypt 证书申请](https://letsencrypt.org/)
- [Nginx 配置文档](https://nginx.org/en/docs/)
- [Ubuntu 24.04 发布说明](https://releases.ubuntu.com/24.04/)

```bash
apt-get update && apt-get upgrade -y  # Ubuntu
yum update -y                         # CentOS
```

---

## 📈 性能检查

```bash
# 查看容器资源使用
docker stats

# 查看磁盘使用
df -h

# 查看内存使用
free -h

# 查看Gzip是否启用
curl -H "Accept-Encoding: gzip" -I https://your-domain.com
# 应该显示 Content-Encoding: gzip
```

---

## 🔍 日志查看

```bash
# 查看实时日志
docker-compose logs -f

# 查看最后100行
docker-compose logs --tail=100

# 查看Nginx访问日志
tail -100 /var/log/nginx/job-score-access.log

# 查看Nginx错误日志
tail -100 /var/log/nginx/job-score-error.log
```

---

## 🚨 紧急操作

### 重建镜像并重启

```bash
cd /opt/job-score
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 清理Docker垃圾

```bash
# 清理无用容器和镜像
docker system prune -a -f

# 清理无用卷
docker volume prune -f
```

### 完全重置

```bash
cd /opt/job-score
docker-compose down -v  # 删除关联的卷
rm -rf dist/            # 删除构建产物
docker-compose up -d    # 重新启动
```

---

## 📞 快速链接

- 项目主页: [README.md](README.md)
- 应用管理: [manage.sh](manage.sh)
- 部署脚本: [deploy.sh](deploy.sh)
- Nginx配置: [nginx.conf](nginx.conf)
- Docker配置: [docker-compose.yml](docker-compose.yml)

---

**🎉 部署完成后，您的应用应该在 https://your-domain.com 上线了！**