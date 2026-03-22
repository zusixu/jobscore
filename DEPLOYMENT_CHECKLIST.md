# 部署公网访问检查清单

## ✅ 前置检查

- [ ] 已安装Node.js 14+
- [ ] 已安装Docker和docker-compose
- [ ] 已注册域名
- [ ] 已拥有Linux服务器（推荐Ubuntu 20.04+）
- [ ] 已获得服务器root权限或sudo权限

## 🔧 配置阶段

- [ ] 修改`.env.production`中的域名和API地址
- [ ] 修改`nginx.conf`中的域名（替换所有`your-domain.com`）
- [ ] 修改`docker-compose.yml`中的卷挂载路径（如需自定义）
- [ ] 更新`deploy.sh`中的`DOMAIN`变量

## 🚀 部署阶段

- [ ] 上传项目文件到Linux服务器
- [ ] 执行`chmod +x deploy.sh manage.sh`
- [ ] 执行`./deploy.sh`进行一键部署
- [ ] 监控部署过程输出信息
- [ ] 检查SSL证书申请是否成功

## 📊 验证阶段

- [ ] 执行`docker-compose ps`确保容器运行
- [ ] 使用`curl https://your-domain.com`测试HTTPS访问
- [ ] 访问浏览器`https://your-domain.com`查看页面
- [ ] 检查浏览器开发者工具网络标签，确认所有资源加载成功
- [ ] 执行`./manage.sh health your-domain.com`检查健康状态

## 🔒 安全验证

- [ ] 确认HTTPS连接（地址栏显示绿色锁图标）
- [ ] 检查HTTP自动重定向到HTTPS
- [ ] 验证安全响应头
  ```bash
  curl -I https://your-domain.com | grep -i "strict-transport"
  curl -I https://your-domain.com | grep -i "x-frame"
  ```
- [ ] 测试禁止访问隐藏文件
  ```bash
  curl https://your-domain.com/.env  # 应该返回403
  ```

## 📈 性能验证

- [ ] 检查Gzip压缩是否启用
  ```bash
  curl -I -H "Accept-Encoding: gzip,deflate" https://your-domain.com
  ```
- [ ] 查看响应时间
  ```bash
  curl -w "Time: %{time_total}s\n" https://your-domain.com
  ```
- [ ] 使用Chrome DevTools检查页面加载时间

## 🔄 维护验证

- [ ] 确认自动续期任务已添加到Cron
  ```bash
  crontab -l | grep certbot
  ```
- [ ] 验证应用更新脚本工作正常
  ```bash
  ./manage.sh update --dry-run
  ```
- [ ] 测试备份功能
  ```bash
  ./manage.sh backup
  ls -lh /var/backups/job-score/
  ```

## 📝 日志检查

- [ ] 检查无错误信息
  ```bash
  ./manage.sh logs | grep ERROR
  ```
- [ ] 检查访问日志正常
  ```bash
  tail -20 /var/log/nginx/job-score-access.log
  ```
- [ ] 检查容器日志无警告
  ```bash
  docker-compose logs job-score
  ```

## 🎯 联系和支持

- [ ] 记录服务器IP和SSH登录信息
- [ ] 备份SSL证书文件
- [ ] 建立监控告警（可选）
- [ ] 设置定期备份任务（可选）

---

**部署完成后，您的应用将:**
- ✅ 在Linux服务器上运行
- ✅ 支持HTTPS加密访问
- ✅ 自动续期SSL证书
- ✅ 使用Gzip压缩优化性能
- ✅ 实现响应式设计在所有设备上完美显示
- ✅ 支持高并发访问