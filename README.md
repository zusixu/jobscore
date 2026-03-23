# 📊 工作性价比计算器

> 一个简洁高效的工作评估工具 | 帮您理性判断工作是否值得

**在线体验**: 

---

## 🎯 核心功能

通过综合评估多个维度，科学计算工作性价比：

- 📚 **学历系数** - 学位要求评分
- 🏢 **工作环境** - 遵守纪律评分  
- 💃 **异性环境** - 工作氛围评分
- 👥 **同事质量** - 团队协作评分
- 📜 **职业资格** - 证书价值评分
- ⏰ **早起系数** - 时间付出评分

## 📈 性价比判断标准

| 评分 | 评价 | 建议 |
|-----|------|------|
| < 0.8 | 很惨 | ❌ 不推荐 |
| 0.8-1.5 | 一般 | ⚠️ 谨慎 |
| 1.5-2.0 | 不错 | ✅ 可考虑 |
| ≥ 2.0 | 爽到爆 | 🎉 推荐！ |

---

## 🚀 快速开始

### 本地开发

```bash
# 安装依赖
npm install

# 开发模式
npm run dev

# 生产构建
npm run build

# 预览构建结果
npm run serve
```

### 线上部署

详见 [部署指南](DEPLOYMENT_GUIDE.md)

---

## 🛠️ 技术栈

- **框架**: Vue 3
- **构建工具**: Vite
- **UI组件**: Element Plus
- **样式**: Tailwind CSS
- **容器**: Docker

---

## 📋 项目结构

```
.
├── src/                    # 源代码
│   ├── App.vue            # 主应用组件
│   ├── main.js            # 入口文件
│   └── index.css           # 全局样式
├── config/                # 构建配置
│   ├── vite.config.js     # Vite配置
│   ├── tailwind.config.js # Tailwind配置
│   └── postcss.config.js  # PostCSS配置
├── docker-compose.yml     # Docker编排
├── Dockerfile             # Docker镜像
├── nginx.conf             # Web服务器
├── deploy.sh              # 部署脚本
└── manage.sh              # 应用管理
```

---

## 🌐 部署

### 一键部署

```bash
# 1. 上传项目到服务器
scp -r . root@your-server:/opt/job-score

# 2. 进入项目目录
ssh root@your-server
cd /opt/job-score

# 3. 执行部署
chmod +x deploy.sh
sudo ./deploy.sh
```

详细部署步骤和常见问题处理请查看 [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

---

## 📊 应用管理

```bash
# 启动应用
./manage.sh start

# 停止应用
./manage.sh stop

# 重启应用
./manage.sh restart

# 查看日志
./manage.sh logs -f

# 查看状态
./manage.sh status

# 更新应用
./manage.sh update

# 备份数据
./manage.sh backup
```

---

## 🔒 特性

✅ **响应式设计** - 完美适配所有设备（手机、平板、桌面）  
✅ **HTTPS加密** - Let's Encrypt自动申请和续期  
✅ **高性能** - Gzip压缩、缓存优化  
✅ **容器化部署** - Docker一键部署  
✅ **自动维护** - 定时自动续期证书  

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

**快速链接**
- 📖 [部署指南](DEPLOYMENT_GUIDE.md)
- 📊 [应用管理工具](manage.sh)
- 🚀 [部署脚本](deploy.sh)
