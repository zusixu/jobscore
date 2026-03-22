# 构建阶段
FROM node:16-alpine as builder

WORKDIR /app

# 配置Alpine镜像源为国内源（可选，加快包管理器速度）
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# 配置npm使用国内镜像源（淘宝镜像）
RUN npm config set registry https://registry.npmmirror.com

# 复制依赖文件
COPY package*.json ./

# 安装依赖
RUN npm ci

# 复制源代码
COPY . .

# 构建项目
RUN npm run build

# 部署阶段
FROM nginx:alpine

# 配置Alpine镜像源为国内源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# 安装curl（用于健康检查）
RUN apk add --no-cache curl

# 复制nginx配置
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 暴露端口
EXPOSE 80 443

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]