# 🚀 部署快速参考指南

## Ubuntu 24.04 部署流程

### 第1步：准备阶段
```bash
# 登录服务器
ssh root@your-server-ip

# 进入部署目录
cd /opt && git clone https://github.com/your/project.git job-score
cd job-score
```

### 第2步：配置部署参数 ⭐ 重要
```bash
# 复制配置模板
cp .env.deployment.example .env.deployment

# 编辑配置文件（修改以下关键参数）
nano .env.deployment
```

**需要修改的参数：**
```ini
# 你的实际域名
DOMAIN="example.com"
DOMAIN_WWW="www.example.com"

# 应用安装路径（可选，默认 /opt/job-score）
APP_BASE_DIR="/opt/job-score"

# 其他路径可保持默认
```

### 第3步：执行部署
```bash
# 设置执行权限
chmod +x deploy.sh manage.sh

# 执行部署脚本
sudo ./deploy.sh
```

部署脚本会自动：
- 检测系统（Ubuntu 24.04）
- 安装Docker、Nginx、Certbot等
- 加载 `.env.deployment` 配置
- 创建所需目录
- 配置Nginx（自动替换域名）
- 启动容器

### 第4步：申请SSL证书
```bash
# 申请Let's Encrypt证书
sudo certbot certonly --standalone \
  -d example.com \
  -d www.example.com \
  --agree-tos \
  -m admin@example.com
```

### 第5步：验证部署

```bash
# 查看容器状态
docker-compose -f /opt/job-score/docker-compose.yml ps

# 检查Nginx配置
nginx -t

# 查看实时日志
./manage.sh logs -f

# 在浏览器中访问
# https://example.com
```

---

## 📍 关键路径说明

| 项目 | 路径 | 说明 |
|------|------|------|
| 应用代码 | `/opt/job-score` | 项目源代码目录 |
| 日志目录 | `/var/log/job-score` | 应用和Nginx日志 |
| 备份目录 | `/var/backups/job-score` | 数据备份位置 |
| Nginx配置 | `/etc/nginx/sites-available/job-score` | 生成的Nginx配置 |
| SSL证书 | `/etc/letsencrypt/live/example.com/` | Let's Encrypt证书 |

> 💡 所有这些路径都可在 `.env.deployment` 中自定义！

---

## 🛠️ 常用管理命令

```bash
# 启动应用
./manage.sh start

# 停止应用
./manage.sh stop

# 重启应用
./manage.sh restart

# 查看日志（实时）
./manage.sh logs -f

# 查看应用状态和资源使用
./manage.sh status

# 更新应用代码
./manage.sh update

# 备份数据
./manage.sh backup

# 检查应用健康状态
./manage.sh health example.com
```

---

## ✅ 部署检查清单

部署后逐项检查：

- [ ] 配置文件已正确修改 (`.env.deployment`)
- [ ] 部署脚本执行无错误
- [ ] SSL证书已成功申请
- [ ] Nginx配置文件已生成 (`/etc/nginx/sites-available/job-score`)
- [ ] Docker容器正在运行 (`docker-compose ps` 显示 "Up")
- [ ] 可以用 `curl -I https://example.com` 访问应用
- [ ] 日志目录存在 (`/var/log/job-score/`)
- [ ] 域名可以正常访问（浏览器打开https://example.com）

---

## 🔧 故障排查

### 问题：脚本报找不到配置文件

```bash
# 解决方案
cp .env.deployment.example .env.deployment
nano .env.deployment  # 修改为你的实际配置
```

### 问题：Nginx配置生成失败

```bash
# 检查nginx配置
nginx -t

# 查看生成的配置
cat /etc/nginx/sites-available/job-score | head -20

# 检查变量是否传入
cat /opt/job-score/.env.deployment
```

### 问题：证书申请失败

```bash
# 检查端口是否开放
ss -tlnp | grep :80

# 检查域名是否正确指向服务器
nslookup example.com

# 查看详细日志
sudo certbot certonly --standalone \
  -d example.com \
  --agree-tos \
  -m admin@example.com \
  -v  # 添加 -v 显示详细日志
```

### 问题：应用容器启动失败

```bash
# 查看Docker日志
docker-compose -f /opt/job-score/docker-compose.yml logs

# 查看Nginx日志
tail -50 /var/log/nginx/error.log

# 重新构建并启动
cd /opt/job-score
docker-compose up -d --build
```

---

## 📋 配置文件示例

`.env.deployment` 完整示例：

```bash
# ============================================
# 部署配置文件
# ============================================

# 应用基础目录
APP_BASE_DIR="/opt/job-score"

# 日志目录  
LOG_DIR="/var/log/job-score"

# 备份目录
BACKUP_DIR="/var/backups/job-score"

# 域名配置（必须修改）
DOMAIN="example.com"
DOMAIN_WWW="www.example.com"

# SSL证书路径
SSL_CERT_PATH="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
SSL_KEY_PATH="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"

# Nginx配置
NGINX_ROOT="/var/www/job-score/dist"
NGINX_ACCESS_LOG="${LOG_DIR}/nginx-access.log"
NGINX_ERROR_LOG="${LOG_DIR}/nginx-error.log"

# Docker容器
DOCKER_CONTAINER_NAME="job-score-app"

# 时区
TZ="Asia/Shanghai"

# 应用环境
NODE_ENV="production"
```

---

## 🔒 安全建议

1. **保护配置文件**
   ```bash
   chmod 600 .env.deployment  # 只有owner可读
   ```

2. **定期备份**
   ```bash
   ./manage.sh backup
   # 或
   tar -czf backup-$(date +%Y%m%d).tar.gz /opt/job-score
   ```

3. **SSL证书自动续期**
   - 部署脚本自动添加Cron任务
   - 每月1日自动检查并续期

4. **监控磁盘空间**
   ```bash
   du -sh $APP_BASE_DIR $LOG_DIR $BACKUP_DIR
   ```

---

## 📞 后续支持

- 查看详细部署指南: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- 查看改进说明: [DEPLOYMENT_IMPROVEMENTS.md](DEPLOYMENT_IMPROVEMENTS.md)  
- 查看项目文档: [README.md](README.md)

---

**最后更新**: 2024年 (Ubuntu 24.04 LTS)  
**版本**: 2.0 - 移除硬编码路径，支持完全配置驱动部署
