# 🇨🇳 国内镜像源配置指南

本文档说明如何配置Docker和npm使用国内镜像源，加快部署速度。

---

## 📦 Docker镜像源配置

部署脚本已自动配置了以下多个国内镜像源：

### 配置的镜像源列表

| 镜像源 | 地址 | 维护者 | 说明 |
|--------|------|--------|------|
| **Docker中国官方** | registry.docker-cn.com | Docker官方 | 官方推荐，速度快 |
| **中科大** | docker.mirrors.ustc.edu.cn | 中国科学技术大学 | 稳定可靠 |
| **Google镜像** | gcr.mirrors.ustc.edu.cn | 中科大 | 用于GCR镜像 |
| **GitHub镜像** | ghcr.io.mirror.1001.workers.dev | 社区 | 用于GitHub镜像 |

### 已在以下地方应用配置

✅ **deploy.sh** - 部署时自动配置  
✅ **Dockerfile** - 构建镜像时自动使用  
✅ **configure-docker-mirror.sh** - 单独配置脚本  

---

## 🚀 如何使用

### 方式1：让deploy.sh自动配置（推荐⭐）

```bash
# 执行部署脚本时会自动配置Docker镜像源
./deploy.sh
```

这会自动：
- 从阿里云源安装Docker
- 配置Docker镜像源
- 重启Docker服务

### 方式2：手动配置（已有Docker的系统）

```bash
# 如果已经安装了Docker，可以单独运行配置脚本
chmod +x configure-docker-mirror.sh
sudo ./configure-docker-mirror.sh

# 或手动编辑Docker配置
sudo cat > /etc/docker/daemon.json << 'EOF'
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://gcr.mirrors.ustc.edu.cn",
    "https://ghcr.io.mirror.1001.workers.dev"
  ]
}
EOF

# 重启Docker使配置生效
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 方式3：验证配置

```bash
# 查看配置是否生效
docker info | grep -A 10 "Registry Mirrors"

# 输出应该显示上述镜像源地址
```

---

## 📦 npm镜像源配置

Dockerfile中已自动配置npm使用淘宝镜像（NPMmirror）。

### 手动配置npm（可选）

```bash
# 配置npm镜像源
npm config set registry https://registry.npmmirror.com

# 查看当前配置
npm config get registry

# 临时使用（不修改全局配置）
npm install --registry https://registry.npmmirror.com
```

### 其他npm镜像源选项

| 镜像源 | 地址 | 说明 |
|--------|------|------|
| **NPMmirror** | https://registry.npmmirror.com | 淘宝镜像，品质保证 |
| **腾讯云** | https://mirrors.cloud.tencent.com/npm/ | 腾讯提供 |
| **华为云** | https://repo.huaweicloud.com/repository/npm/ | 华为提供 |
| **官方** | https://registry.npmjs.org | 国际源，可能较慢 |

---

## 🐳 Docker构建优化

### 使用Dockerfile中的国内源

本项目Dockerfile已配置：

```dockerfile
# Alpine镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# npm镜像源
RUN npm config set registry https://registry.npmmirror.com
```

### 构建时检查日志

```bash
# 构建Docker镜像，观察日志
docker-compose build

# 或单独构建
docker build -t job-score:latest .

# 在构建日志中应该看到加速的下载速度
```

---

## ⚡ 性能优化建议

### 1. 第一次构建较慢（正常）

首次下载基础镜像（node:16-alpine、nginx:alpine）可能需要时间，这是正常的。

```bash
# 进度提示类似
Step 1/15 : FROM node:16-alpine as builder
 ---> Pulling from library/node
 ---> [正在下载，请稍候...]
```

### 2. 使用本地镜像加速

```bash
# 查看已下载的镜像
docker images

# 镜像下载后的后续构建会很快
docker-compose build  # 第二次会快得多
```

### 3. 多阶段构建优化

Dockerfile使用多阶段构建，只有最终的nginx镜像会被保存：

- 构建阶段：node:16-alpine（用完即弃）
- 运行阶段：nginx:alpine（最终镜像，仅30MB）

---

## 🔍 诊断和故障排查

### 镜像源配置不生效？

```bash
# 1. 查看配置文件
cat /etc/docker/daemon.json

# 2. 检查Docker是否正常重启
systemctl status docker

# 3. 重新启动Docker
sudo systemctl restart docker

# 4. 再次验证
docker info | grep Registry
```

### npm安装仍然很慢？

```bash
# 1. 检查npm镜像配置
npm config get registry

# 2. 清理缓存
npm cache clean --force

# 3. 重新安装
npm install --no-cache

# 4. 尝试另一个镜像源
npm config set registry https://mirrors.cloud.tencent.com/npm/
```

### 构建镜像失败？

```bash
# 1. 查看完整错误日志
docker-compose build --no-cache 2>&1 | tail -50

# 2. 检查网络连接
ping mirrors.aliyun.com

# 3. 尝试清理本地镜像
docker system prune -a --volumes
```

---

## 📊 加速效果对比

| 操作 | 无镜像源 | 有镜像源 | 加速倍数 |
|------|---------|---------|--------|
| 首次npm install | 10-20分钟 | 1-3分钟 | 5-10x |
| Docker镜像拉取 | 5-15分钟 | 1-5分钟 | 3-5x |
| docker-compose build | 15-25分钟 | 3-8分钟 | 3-5x |

---

## 🛠️ 常用命令速查

```bash
# 查看Docker镜像源配置
docker info | grep -A 10 Registry

# 查看npm镜像源配置
npm config get registry

# 测试镜像源速度
docker pull alpine:latest

# 清理Docker系统
docker system prune -a

# 重新构建镜像（不使用缓存）
docker-compose build --no-cache

# 查看镜像大小
docker images | grep job-score
```

---

## 📝 详细配置文档

### deploy.sh中的Docker安装

现在使用以下方式安装Docker：

```bash
# 步骤1：添加Docker官方GPG密钥（来自阿里云）
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -

# 步骤2：添加Docker软件源（阿里云源）
add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

# 步骤3：安装Docker相关包
apt-get install -y docker-ce docker-ce-cli containerd.io

# 步骤4：配置Docker daemon
cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [...]
}
EOF
```

### Dockerfile中的优化配置

```dockerfile
# Alpine源优化
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# npm源优化
RUN npm config set registry https://registry.npmmirror.com
```

---

## 💡 最佳实践

✅ **始终检查输出日志** - 确认是否使用了国内源  
✅ **首次构建需要时间** - 这是正常的（需要下载基础镜像）  
✅ **后续构建会很快** - 镜像缓存大大加速构建  
✅ **定期更新镜像** - 使用 `docker pull` 获取最新版本  
✅ **监控构建进度** - 使用 `--progress=plain` 查看详细信息  

```bash
# 查看详细构建进度
docker-compose build --progress=plain
```

---

## 📞 遇到问题？

### 问题1：无法连接镜像源

**症状**: 错误信息 "Failed to connect to registry"  
**解决**:
```bash
# 检查网络连接
ping mirrors.aliyun.com
# 如果是国外访问，改用官方源
```

### 问题2：镜像下载超时

**症状**: 下载一半就停止  
**解决**:
```bash
# 增加Docker下载超时时间
sudo vi /etc/docker/daemon.json
# 添加: "max-concurrent-downloads": 5

# 清理并重新下载
docker system prune -a
docker-compose pull
```

### 问题3：npm install仍然很慢

**症状**: 依然需要5-10分钟  
**解决**:
```bash
# 尝试其他镜像源
npm config set registry https://mirrors.cloud.tencent.com/npm/

# 或使用pnpm代替npm（可能更快）
npm install -g pnpm
pnpm install
```

---

## 🌍 国外服务器如何处理？

如果您的服务器在国外（美国、欧洲等），建议：

1. **使用官方源** - 通常速度更快
2. **配置备用源** - daemon.json已包含多个选项
3. **检查地理位置** - 某些镜像源优化了特定地区

```bash
# 检查当前服务器网络
curl -I https://mirrors.aliyun.com  # 会很慢（国外访问）
curl -I https://registry.npmjs.org  # 会很快（国外）
```

---

**配置完成！现在您的部署速度应该快得多了！** 🚀

相关文件：
- [deploy.sh](deploy.sh) - 自动配置脚本
- [Dockerfile](Dockerfile) - 构建优化
- [configure-docker-mirror.sh](configure-docker-mirror.sh) - 手动配置脚本