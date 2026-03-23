# 部署路径配置改进说明

## 问题回顾

上次部署中发现的主要问题：
- ❌ 硬编码路径导致部署灵活性差
- ❌ 多个脚本中路径不一致
- ❌ 修改路径需要编辑多个文件

## 解决方案

### 1. 统一配置文件系统 (.env.deployment)

创建了中心化的配置管理：
- 所有可配置的路径集中在 `.env.deployment` 中
- 避免多个脚本中的硬编码重复
- 便于统一管理和修改

### 2. 脚本改进

#### deploy.sh
✅ 自动加载配置文件  
✅ 使用变量替代硬编码路径  
✅ 自动配置Nginx（从模板生成）  
✅ 提供清晰的配置加载提示  

#### manage.sh
✅ 与deploy.sh保持路径同步  
✅ 所有目录操作都使用环境变量  

### 3. 容器配置

#### docker-compose.yml
- 卷挂载使用环境变量
- 容器名称可配置
- 完整支持环境变量替代

#### nginx.conf
- 从模板创建，避免硬编码
- 自动替换域名、证书路径、Web根目录
- 部署时自动生成实际配置

### 4. 路径对应关系

| 配置项 | 用途 | 默认值 |
|------|------|-------|
| APP_BASE_DIR | 应用代码目录 | /opt/job-score |
| LOG_DIR | 应用日志目录 | /var/log/job-score |
| BACKUP_DIR | 备份目录 | /var/backups/job-score |
| DOMAIN | 主域名 | your-domain.com |
| NGINX_ROOT | Web根目录 | /var/www/job-score/dist |
| SSL_CERT_PATH | SSL证书路径 | /etc/letsencrypt/live/${DOMAIN} |

## 使用流程

### 首次部署

```bash
# 1. 复制配置模板
cp .env.deployment.example .env.deployment

# 2. 编辑配置
nano .env.deployment
# 修改: DOMAIN, APP_BASE_DIR 等

# 3. 执行部署
sudo ./deploy.sh
# 脚本自动加载配置文件并使用配置的路径
```

### 后续管理

所有管理脚本都自动读取 `.env.deployment`：

```bash
./manage.sh start    # 自动使用配置的路径
./manage.sh stop     # 不需要手动指定路径
./manage.sh update   # 完全配置驱动
```

## Ubuntu 24.04 特定改进

1. **包管理器支持**
   - 自动检测 apt-get/yum/dnf
   - 兼容最新的Ubuntu 24.04

2. **Docker Compose**
   - 支持最新的 docker-compose-plugin
   - 自动从多个源下载

3. **Nginx配置**
   - 自动禁用default配置
   - 正确处理sites-enabled/sites-available

4. **系统路径**
   - 完全使用变量（不再硬编码）
   - 支持自定义任何部署路径

## 安全改进

✅ 所有涉及路径的操作都可通过 `.env.deployment` 控制  
✅ 减少手动操作中可能的错误  
✅ 便于环境【开发/测试/生产】的切换  
✅ 备份和日志路径可独立配置  

## 验证清单

部署完成后检查：

```bash
# 1. 检查配置已加载
cat $APP_BASE_DIR/.env.deployment

# 2. 检查Nginx配置
cat /etc/nginx/sites-available/job-score | head -20

# 3. 检查Docker环境变量
docker-compose -f $APP_BASE_DIR/docker-compose.yml config | grep -A5 environment

# 4. 检查日志目录
ls -la $LOG_DIR/

# 5. 验证应用运行
curl -I https://$(grep DOMAIN $APP_BASE_DIR/.env.deployment | cut -d= -f2)
```

## 文件清单

| 文件 | 改进 |
|-----|------|
| .env.deployment.example | 新建 - 配置模板 |
| deploy.sh | 修改 - 添加配置加载和Nginx配置步骤 |
| manage.sh | 修改 - 添加配置加载 |
| docker-compose.yml | 修改 - 使用环境变量 |
| nginx.conf | 修改 - 改为模板格式 |
| DEPLOYMENT_GUIDE.md | 修改 - 更新部署说明和Ubuntu 24.04支持 |

## 后续维护建议

1. **定期备份配置**
   ```bash
   cp .env.deployment /path/to/backup/.env.deployment.$(date +%Y%m%d)
   ```

2. **监控路径使用**
   ```bash
   du -sh $APP_BASE_DIR $LOG_DIR $BACKUP_DIR
   ```

3. **路径迁移**
   - 只需修改 `.env.deployment` 中的相应项
   - 重新运行 `./deploy.sh` 即可

## 常见问题

**Q: 脚本找不到配置文件怎么办?**  
A: 脚本会使用 `.env.deployment.example` 中的默认值，并提示复制 `.env.deployment.example` 为 `.env.deployment`

**Q: 可以同时部署多个实例吗?**  
A: 可以！只需创建不同的配置文件（如 `.env.deployment.app1`），修改脚本加载相应的配置文件即可

**Q: 部署后想修改路径怎么办?**  
A: 编辑 `.env.deployment` 后重新运行部署脚本，脚本会检查并创建必要的目录
