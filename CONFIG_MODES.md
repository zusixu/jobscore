# 👉 配置模式快速选择指南

快速决定你应该使用哪种配置模式：

## 我应该选择哪一个？

### ✅ 选择 **自包含模式** 如果你...

```bash
cp .env.deployment.self-contained .env.deployment
```

- 📁 想把所有文件放在 git clone 的文件夹内
- 🔄 需要频繁迁移到不同服务器
- 💾 想方便地备份整个应用
- 👥 在同一台服务器部署多个应用实例
- 🐳 使用Docker进行开发/测试
- 👤 没有root权限修改 `/var/log` 等系统目录

**配置示例:**
```env
PROJECT_ROOT="/opt/job-score"
APP_BASE_DIR="${PROJECT_ROOT}"
LOG_DIR="${PROJECT_ROOT}/logs"
DATA_DIR="${PROJECT_ROOT}/data"
BACKUP_DIR="${PROJECT_ROOT}/backups"
```

---

### ✅ 选择 **标准模式** 如果你...

```bash
cp .env.deployment.example .env.deployment
```

- 🖥️ 在生产服务器部署单个应用
- 📋 遵循Linux文件系统规范（FHS）
- 🔒 有系统管理员权限
- 📊 希望日志和数据分散在标准系统目录
- 🏢 在企业环境中
- 📈 应用需要独立扩展

**配置示例:**
```env
APP_BASE_DIR="/opt/job-score"
LOG_DIR="/var/log/job-score"
DATA_DIR="/var/lib/job-score"
BACKUP_DIR="/var/backups/job-score"
```

---

## 两种模式的直观对比

### 文件位置对比

```
标准模式 (分散在系统不同位置)
├── /opt/job-score/              ← 应用代码
├── /var/log/job-score/          ← 日志
├── /var/lib/job-score/          ← 数据
└── /var/backups/job-score/      ← 备份

自包含模式 (所有在一个文件夹)
└── /opt/job-score/
    ├── src/                     ← 应用代码
    ├── logs/                    ← 日志
    ├── data/                    ← 数据
    └── backups/                 ← 备份
```

### 操作对比

| 操作 | 标准模式 | 自包含模式 |
|------|--------|---------|
| **备份** | `tar -czf backup.tar.gz /opt/job-score /var/log/job-score /var/backups/job-score` | `tar -czf backup.tar.gz /opt/job-score` |
| **恢复** | `tar -xzf backup.tar.gz` (需要在根目录) | `cd /opt && tar -xzf backup.tar.gz` |
| **迁移** | 📕 复杂（需要同步多个目录） | 📗 简单（复制一个文件夹） |
| **多实例** | ⚙️ 需要修改部分脚本 | ✅ 开箱即用 |
| **删除** | 手动删除多个位置 | `rm -rf /opt/job-score` |
| **权限** | 需要系统管理员权限 | 普通用户权限即可 |

---

## 典型场景

### 场景1️⃣：企业生产环境

```bash
# 使用标准模式
cp .env.deployment.example .env.deployment

# 配置
APP_BASE_DIR="/opt/job-score"
LOG_DIR="/var/log/job-score"
DOMAIN="api.company.com"
```

**原因:**
- 符合企业规范
- 系统备份工具可以单独处理 `/var/log` 等
- 多个应用共享系统资源

---

### 场景2️⃣：初次部署/开发测试

```bash
# 使用自包含模式
cp .env.deployment.self-contained .env.deployment

# 配置
PROJECT_ROOT="/opt/job-score"
DOMAIN="dev.example.com"
```

**原因:**
- 简单易懂
- 易于调试
- 快速重建

---

### 场景3️⃣：Docker容器内

```bash
# 使用自包含模式
cp .env.deployment.self-contained .env.deployment

# 配置
PROJECT_ROOT="/app/job-score"
DOMAIN="app.local"
```

**原因:**
- 容器通常是临时的
- 数据通过Volume映射
- 自包含便于容器打包

---

### 场景4️⃣：多个应用实例

```bash
# 实例1
cd /opt/job-score-prod
cp .env.deployment.self-contained .env.deployment
# 配置 DOMAIN="prod.example.com"

# 实例2
cd /opt/job-score-test
cp .env.deployment.self-contained .env.deployment
# 配置 DOMAIN="test.example.com"

# 完全隔离，互不影响
```

**原因:**
- 自包含模式支持完全隔离
- 标准模式容易出现路径冲突

---

## 快速命令

### 小改造：在标准模式间切换

```bash
# 发现你选错了？没关系，很容易改

# 从标准模式改为自包含模式
cp .env.deployment.self-contained .env.deployment
# 修改 PROJECT_ROOT 并其他配置
sudo ./deploy.sh  # 重新部署

# 从自包含模式改为标准模式
cp .env.deployment.example .env.deployment
# 修改 APP_BASE_DIR, LOG_DIR 等
sudo ./deploy.sh  # 重新部署
```

---

## 我是新手，应该选哪个？

### 🎯 第一次部署？使用 **自包含模式**

```bash
# 3个命令快速上手
cp .env.deployment.self-contained .env.deployment
nano .env.deployment  # 只改 DOMAIN
sudo ./deploy.sh      # 搞定
```

### 🎯 生产环境？使用 **标准模式**

```bash
# 符合Linux规范的部署
cp .env.deployment.example .env.deployment
nano .env.deployment   # 修改多个配置
sudo ./deploy.sh       # 遵循最佳实践
```

---

## 常见问题

**Q: 两种模式可以混合吗？**  
A: 可以的。虽然不推荐，但你可以在 `.env.deployment` 中混合使用：
```env
PROJECT_ROOT="/opt/job-score"
APP_BASE_DIR="${PROJECT_ROOT}"
LOG_DIR="/var/log/job-score"  # 系统路径
BACKUP_DIR="${PROJECT_ROOT}/backups"
```

**Q: 后期可以从一种模式改为另一种吗？**  
A: 可以。只需编辑 `.env.deployment` 并运行 `sudo ./deploy.sh`，脚本会创建新的目录结构。旧的数据不会自动迁移，需要手动处理。

**Q: 哪种模式性能更好？**  
A: 性能基本相同。如果数据目录在高速SSD上，标准模式可能稍微快一点。

**Q: 能同时运行两种模式吗？**  
A: 不能。一个服务器上只能有一个 `/opt/job-score`，但可以部署多个不同名称的实例：
- `/opt/job-score-prod` (使用自包含模式)
- `/opt/job-score-test` (使用自包含模式)

---

## 下一步

已选择配置模式？

👉 **自包含模式** → 参考 [SELF_CONTAINED_MODE.md](SELF_CONTAINED_MODE.md)  
👉 **标准模式** → 参考 [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)  
👉 **快速开始** → 参考 [QUICK_START.md](QUICK_START.md)
