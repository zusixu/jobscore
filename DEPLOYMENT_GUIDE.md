# 📦 Linux服务器部署指南

**适用于**: Ubuntu 20.04 LTS 及更新版本  
**预计部署时间**: 15-30分钟  
**所需知识**: 基本的Linux命令和服务器配置

---

## 📋 前置要求

- Linux服务器（推荐 Ubuntu 20.04+）
- Root 或 sudo 权限
- 已注册的域名
- 开放的80和443端口

---

## 🚀 快速部署（推荐）

### 方式1：一键部署脚本

```bash
# 1. 登录服务器
ssh root@your-server-ip

# 2. 下载项目
cd /opt
git clone https://github.com/your-username/job-score.git
cd job-score

# 3. 更新脚本权限
chmod +x deploy.sh manage.sh

# 4. 执行部署脚本
./deploy.sh

# 脚本会自动：
# ✓ 检查系统依赖
# ✓ 安装Docker和docker-compose
# ✓ 申请SSL证书
# ✓ 构建Docker镜像
# ✓ 启动应用
# ✓ 配置自动续期
```

### 方式2：手动部署

#### 第1步：安装必要工具

```bash
# 更新系统
apt-get update && apt-get upgrade -y

# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
bash get-docker.sh

# 安装docker-compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 安装Nginx和Certbot
apt-get install -y nginx certbot python3-certbot-nginx
```

#### 第2步：配置项目

```bash
# 创建应用目录
mkdir -p /opt/job-score
cd /opt/job-score

# 克隆项目
git clone https://github.com/your-username/job-score.git .

# 创建生产环境文件
cat > .env.production << EOF
NODE_ENV=production
VITE_APP_URL_BASE=/
VITE_API_BASE_URL=https://your-domain.com
EOF

# 修改nginx.conf中的域名
sed -i 's/your-domain.com/your-actual-domain.com/g' nginx.conf
```

#### 第3步：申请SSL证书

```bash
# 使用Let's Encrypt申请证书
certbot certonly --standalone \
  -d your-domain.com \
  -d www.your-domain.com \
  --non-interactive \
  --agree-tos \
  -m admin@your-domain.com
```

#### 第4步：启动应用

```bash
# 构建并启动Docker容器
docker-compose up -d

# 检查容器状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

#### 第5步：配置自动续期

```bash
# 添加自动续期任务
crontab -e

# 添加以下行
0 0 1 * * certbot renew --quiet && docker-compose -f /opt/job-score/docker-compose.yml restart job-score
```

---

## 📊 应用管理

使用提供的管理脚本进行日常操作：

```bash
# 启动应用
./manage.sh start

# 停止应用
./manage.sh stop

# 重启应用
./manage.sh restart

# 查看实时日志
./manage.sh logs -f

# 查看应用状态
./manage.sh status

# 更新应用
./manage.sh update

# 备份应用数据
./manage.sh backup

# 检查应用健康状态
./manage.sh health your-domain.com
```

---

## 🔒 安全配置

### 已启用的安全措施

1. **HTTPS强制**
   - 所有HTTP请求重定向到HTTPS
   - HSTS头强制浏览器使用HTTPS

2. **安全头**
   - X-Frame-Options: 防止点击劫持
   - X-Content-Type-Options: 防止MIME嗅探
   - X-XSS-Protection: 浏览器XSS保护
   - Content-Security-Policy: 内容安全策略

3. **Gzip压缩**
   - 减少传输数据大小40-50%

4. **缓存策略**
   - 静态文件（JS/CSS/图片）缓存30天
   - HTML不缓存，总是获取最新版本

### 额外安全建议

```bash
# 1. 配置防火墙
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable

# 2. 配置Fail2ban防止暴力攻击
apt-get install -y fail2ban

# 3. 定期更新系统
apt-get update && apt-get upgrade -y

# 4. 监控日志
tail -f /var/log/nginx/job-score-access.log
tail -f /var/log/nginx/job-score-error.log
```

---

## 📈 性能监控

### 查看性能指标

```bash
# 查看容器资源使用
docker stats

# 查看磁盘使用
df -h

# 查看内存使用
free -h

# 查看进程
top
```

### 日志分析

```bash
# 查看最近错误
docker-compose logs job-score | grep ERROR

# 查看访问统计
tail -1000 /var/log/nginx/job-score-access.log | awk '{print $1}' | sort | uniq -c | sort -rn

# 查看响应时间
tail -100 /var/log/nginx/job-score-access.log | awk '{print $(NF-1)}'
```

---

## 🔄 更新和维护

### 更新应用

```bash
# 方式1：自动更新脚本
./manage.sh update

# 方式2：手动更新
cd /opt/job-score
git pull origin main
docker-compose up -d --build
```

### 备份内容

```bash
# 创建完整备份
./manage.sh backup

# 查看备份文件
ls -lh /var/backups/job-score/

# 恢复备份
tar -xzf /var/backups/job-score/backup-*.tar.gz -C /
```

---

## 🐛 故障排查

### 应用无法访问

```bash
# 1. 检查容器状态
docker-compose ps

# 2. 查看容器日志
docker-compose logs

# 3. 检查nginx配置
docker-compose exec job-score nginx -t

# 4. 检查端口占用
netstat -tulpn | grep -E ':80|:443'
```

### SSL证书问题

```bash
# 1. 查看证书过期时间
certbot certificates

# 2. 手动续期
certbot renew --dry-run

# 3. 重启应用
./manage.sh restart
```

### 内存不足

```bash
# 1. 查看内存使用
free -h

# 2. 清理Docker垃圾
docker system prune -a -f

# 3. 查看大文件
du -sh /var/lib/docker/*
```

### 性能缓慢

```bash
# 1. 检查资源使用
docker stats

# 2. 查看时间戳最大的访问日志
tail -100 /var/log/nginx/job-score-access.log

# 3. 检查磁盘I/O
iostat -x 1 5
```

---

## 📞 常见问题

**Q: 如何更换域名？**  
A: 编辑nginx.conf中的server_name，申请新的SSL证书，重启应用。

**Q: 如何实现高可用部署？**  
A: 使用负载均衡器（如AWS ELB）分发流量到多个应用实例。

**Q: 如何备份和恢复？**  
A: 使用`./manage.sh backup`备份，使用`tar -xzf`恢复。

**Q: 如何监控应用健康状态？**  
A: 使用`./manage.sh health`或配置Prometheus+Grafana。

---

## 📚 参考资源

- [Nginx文档](https://nginx.org/en/docs/)
- [Docker文档](https://docs.docker.com/)
- [Let's Encrypt文档](https://letsencrypt.org/docs/)
- [Vue 3官方文档](https://v3.vuejs.org/)

---

**最后更新**: 2026年3月22日  
**维护者**: 工作性价比计算器团队