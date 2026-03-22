# 📦 部署指南

快速在 Linux 服务器上部署应用

---

## ✅ 前置要求

- **系统**: Ubuntu 20.04+ 或 CentOS 7+
- **权限**: Root 或 sudo
- **域名**: 已注册的域名
- **端口**: 80/443 开放

---

## 🚀 一键部署

```bash
# 1. SSH连接服务器
ssh root@your-server-ip

# 2. 进入/opt目录
cd /opt

# 3. 克隆项目
git clone https://github.com/your-username/job-score.git
cd job-score

# 4. 执行部署
chmod +x deploy.sh
sudo ./deploy.sh
```

**脚本自动完成:**
- ✅ 检测操作系统并安装依赖（支持Ubuntu/CentOS）
- ✅ 安装Docker和docker-compose（自动使用国内镜像源）
- ✅ 配置Docker国内镜像源加快速度
- ✅ 创建应用目录和环境变量
- ✅ 构建Docker镜像

---

## 🔧 部署前配置（关键！）

修改以下文件中的域名：

### 1. nginx.conf
```bash
sed -i 's/your-domain.com/your-real-domain.com/g' nginx.conf
```

### 2. .env.production
```bash
# 编辑或创建
cat > .env.production << EOF
NODE_ENV=production
VITE_APP_URL_BASE=/
VITE_API_BASE_URL=https://your-real-domain.com
EOF
```

### 3. docker-compose.yml（可选）
```bash
sed -i 's/your-domain.com/your-real-domain.com/g' docker-compose.yml
```

---

## 🔐 申请SSL证书

```bash
# 确保80和443端口开放
# 运行以下命令申请证书
certbot certonly --standalone \
  -d your-domain.com \
  -d www.your-domain.com \
  --non-interactive \
  --agree-tos \
  -m admin@your-domain.com
```

---

## 📊 应用管理

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
./manage.sh health your-domain.com
```

---

## ✅ 验证部署

```bash
# 1. 查看容器运行状态
docker-compose ps

# 2. 检查应用可访问性
curl -I https://your-domain.com

# 3. 查看实时日志
docker-compose logs -f

# 4. 浏览器访问
# 打开 https://your-domain.com
```

---

## 🛠️ 常见问题

### Q: 云服务器需要开放哪些端口？

A: 在云控制台(安全组/防火墙)中开放：
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)

### Q: docker-compose命令找不到？

A: 手动安装：
```bash
curl -L https://get.daocloud.io/docker/compose/releases/download/v2.20.0/docker-compose-Linux-x86_64 \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### Q: 证书申请失败？

A: 检查：
```bash
# 1. 80端口是否开放
telnet your-domain.com 80

# 2. 域名是否正确指向此服务器
nslookup your-domain.com

# 3. 查看Certbot日志
sudo certbot renew --dry-run
```

### Q: 应用启动失败？

A: 查看日志：
```bash
docker-compose logs  # 查看错误
docker-compose ps    # 查看容器状态
docker images        # 查看镜像
```

### Q: 如何更新应用？

A: 
```bash
cd /opt/job-score
git pull origin main
./manage.sh restart
```

---

## 🔄 系统维护

### SSL证书自动续期

已通过Cron自动配置，无需手动续期。但如需手动续期：

```bash
certbot renew --force-renewal
```

### 查看证书信息

```bash
certbot certificates
```

### 更新系统包

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