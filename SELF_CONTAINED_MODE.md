# 自包含模式部署指南

## 什么是自包含模式？

自包含模式是指**所有应用相关的文件都在一个文件夹内**，包括：
- 源代码
- 配置文件
- 日志文件
- 数据文件
- 备份文件

这样做的好处：
✅ **易于管理** - 一个文件夹包含所有内容  
✅ **易于迁移** - 只需复制一个文件夹到新服务器  
✅ **易于备份** - 一条命令备份所有内容  
✅ **支持多实例** - 可在同一服务器部署多个相同应用  
✅ **易于开发测试** - 隔离不同的部署环境  

---

## 完整的目录结构

部署完成后，你的项目文件夹结构如下：

```
/opt/job-score/                    ← 项目根目录（PROJECT_ROOT）
├── src/                           ← 源代码
├── config/                        ← 配置文件
├── data/                          ← 数据目录
│   ├── database/                  ← 数据库数据
│   └── cache/                     ← 缓存文件
├── logs/                          ← 日志目录
│   ├── nginx-access.log
│   ├── nginx-error.log
│   └── app-*.log
├── backups/                       ← 备份目录
│   ├── database/                  ← 数据库备份
│   └── backup-20240101-******.tar.gz
├── .tmp/                          ← 临时文件
├── .env.deployment                ← 配置文件（部署后）
├── docker-compose.yml
├── Dockerfile
├── nginx.conf
├── deploy.sh
├── manage.sh
├── package.json
├── package-lock.json
└── [其他项目文件...]
```

---

## 配置步骤

### 1. 使用自包含模式配置

```bash
# 进入项目目录
cd /opt/job-score

# 复制自包含模式配置模板
cp .env.deployment.self-contained .env.deployment

# 编辑配置（只需修改2个地方）
nano .env.deployment
```

### 2. 配置文件示例

修改你的 `.env.deployment`：

```bash
# ============================================
# 项目基础路径
# ============================================
PROJECT_ROOT="/opt/job-score"

# ============================================
# 应用相关路径（都基于 PROJECT_ROOT）
# ============================================
APP_BASE_DIR="${PROJECT_ROOT}"
DATA_DIR="${PROJECT_ROOT}/data"
LOG_DIR="${PROJECT_ROOT}/logs"
BACKUP_DIR="${PROJECT_ROOT}/backups"
CONFIG_DIR="${PROJECT_ROOT}/config"

# ============================================
# 域名配置（这是主要需要改的地方）
# ============================================
DOMAIN="your-real-domain.com"
DOMAIN_WWW="www.your-real-domain.com"

# ============================================
# SSL证书（系统路径，不需要改）
# ============================================
SSL_CERT_PATH="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
SSL_KEY_PATH="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"

# ============================================
# 其他配置保持默认
# ============================================
DOCKER_CONTAINER_NAME="job-score-app"
TZ="Asia/Shanghai"
NODE_ENV="production"
```

---

## 部署步骤

### 第1步：准备

```bash
# 登录服务器
ssh root@your-server-ip

# 进入部署目录
cd /opt
git clone https://github.com/your/job-score.git
cd job-score
```

### 第2步：配置（仅需修改域名）

```bash
cp .env.deployment.self-contained .env.deployment

# 编辑 - 只需改两个地方
nano .env.deployment
# 修改:
#   DOMAIN="your-real-domain.com"
#   DOMAIN_WWW="www.your-real-domain.com"
```

### 第3步：部署

```bash
chmod +x deploy.sh manage.sh
sudo ./deploy.sh
```

### 第4步：申请SSL证书

```bash
sudo certbot certonly --standalone \
  -d your-real-domain.com \
  -d www.your-real-domain.com \
  --agree-tos \
  -m admin@your-real-domain.com
```

### 第5步：验证

```bash
# 检查目录结构是否创建正确
ls -la /opt/job-score/

# 查看日志是否生成
ls -la /opt/job-score/logs/

# 查看容器状态
docker-compose -f /opt/job-score/docker-compose.yml ps

# 访问应用
curl -I https://your-real-domain.com
```

---

## 常用命令

所有命令都自动使用项目内的路径：

```bash
cd /opt/job-score

# 查看应用状态
./manage.sh status

# 查看实时日志
./manage.sh logs -f

# 启动/停止应用
./manage.sh start
./manage.sh stop
./manage.sh restart

# 更新应用
./manage.sh update

# 备份数据（备份到 /opt/job-score/backups/）
./manage.sh backup

# 查看磁盘使用
du -sh /opt/job-score/
du -sh /opt/job-score/data
du -sh /opt/job-score/logs
du -sh /opt/job-score/backups
```

---

## 备份和恢复

### 备份整个项目

```bash
# 完整备份（包括所有数据、日志、备份）
tar -czf /tmp/job-score-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  /opt/job-score

# 只备份重要数据（代码+数据）
tar -czf /tmp/job-score-data-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  /opt/job-score/src \
  /opt/job-score/config \
  /opt/job-score/data \
  /opt/job-score/.env.deployment
```

### 在新服务器恢复

```bash
# 1. 复制备份到新服务器
scp /tmp/job-score-backup-*.tar.gz root@new-server:/opt/

# 2. 在新服务器上解压
cd /opt
tar -xzf job-score-backup-*.tar.gz

# 3. 进入项目并重新部署
cd job-score
sudo ./deploy.sh

# 4. 重新申请/配置SSL证书
sudo certbot certonly --standalone -d your-domain.com

# 5. 启动应用
./manage.sh start
```

---

## Docker卷挂载说明

在 `docker-compose.yml` 中，本地路径和容器内路径的映射：

```yaml
volumes:
  # 日志挂载
  - ${LOG_DIR:-/var/log/job-score}:/var/log/nginx
  
  # 数据挂载（如果使用数据库）
  - ${DATA_DIR:-/opt/job-score/data}:/app/data
  
  # Web根目录挂载
  - ${NGINX_ROOT:-/var/www/job-score/dist}:/usr/share/nginx/html
```

**路径对应关系：**
| 本地路径 | 容器内路径 | 用途 |
|--------|---------|------|
| `/opt/job-score/logs` | `/var/log/nginx` | Nginx日志 |
| `/opt/job-score/data` | `/app/data` | 应用数据 |
| 构建产物 | `/usr/share/nginx/html` | Web服务 |

---

## 多实例部署

如需在同一服务器上部署多个应用实例：

```bash
# 第一个实例
cd /opt
git clone <repo> job-score-prod
cd job-score-prod
cp .env.deployment.self-contained .env.deployment
nano .env.deployment  # 修改 PROJECT_ROOT 和 DOMAIN

# 第二个实例
cd /opt
git clone <repo> job-score-test
cd job-score-test
cp .env.deployment.self-contained .env.deployment
nano .env.deployment  # 修改不同的 PROJECT_ROOT 和 DOMAIN

# 分别部署
cd job-score-prod && sudo ./deploy.sh
cd job-score-test && sudo ./deploy.sh

# 这样两个实例完全隔离，互不影响
```

---

## 故障排查

### 问题：日志文件不在 PROJECT_ROOT 内

**检查配置：**
```bash
cat /opt/job-score/.env.deployment | grep LOG_DIR

# 应该看到类似:
# LOG_DIR="/opt/job-score/logs"
```

**重新部署：**
```bash
# 确保配置正确后重新运行
sudo ./deploy.sh
```

### 问题：容器无法访问数据目录

**检查权限：**
```bash
# 确保目录有正确的权限
ls -la /opt/job-score/data/

# 必要时调整权限
sudo chown -R $(whoami):$(whoami) /opt/job-score/data
```

### 问题：备份占用过多空间

**清理旧备份：**
```bash
# 只保留最近7个备份
cd /opt/job-score/backups
ls -t | tail -n +8 | xargs rm -f

# 或设置自动清理（添加cron任务）
# 每周清理超过30天的备份
```

---

## 性能优化建议

### 1. 日志轮转

```bash
# 配置 logrotate（如果没有自动配置）
cat > /etc/logrotate.d/job-score << EOF
/opt/job-score/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0600 $(whoami) $(whoami)
}
EOF
```

### 2. 数据目录定期清理

```bash
# 删除超过30天的临时文件
find /opt/job-score/.tmp -type f -mtime +30 -delete

# 自动化（添加到cron）
# 每天凌晨2点执行
0 2 * * * find /opt/job-score/.tmp -type f -mtime +30 -delete
```

### 3. 监控磁盘空间

```bash
#!/bin/bash
# 检查磁盘使用，如果超过85%则报警

PROJECT_ROOT="/opt/job-score"
USAGE=$(du -s "$PROJECT_ROOT" | awk '{print $1}')
MAX_SIZE=$((50 * 1024 * 1024))  # 50GB

if [ $USAGE -gt $MAX_SIZE ]; then
    echo "警告: 项目文件夹超过50GB"
    du -sh "$PROJECT_ROOT"/*
fi
```

---

## 总结

自包含模式的关键优势：

| 操作 | 标准模式 | 自包含模式 |
|------|--------|---------|
| 备份 | `tar -czf backup.tar.gz /opt /var/log /var/backups` | `tar -czf backup.tar.gz /opt/job-score` |
| 恢复 | 需要恢复多个目录 | `tar -xzf backup.tar.gz` |
| 迁移 | 复杂（路径分散） | 简单（一个文件夹） |
| 多实例 | 困难 | 简单 |
| 清理 | 散落各处 | 一个文件夹 `rm -rf /opt/job-score` |

---

**推荐阅读:**
- [QUICK_START.md](QUICK_START.md) - 快速开始
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - 完整部署指南
- [DEPLOYMENT_IMPROVEMENTS.md](DEPLOYMENT_IMPROVEMENTS.md) - 改进说明
