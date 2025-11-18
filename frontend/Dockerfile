# 前端Dockerfile - 超简单版
# 直接用打包好的dist，用Nginx提供服务

FROM nginx:1.24-alpine

# 删除默认的nginx配置和文件
RUN rm -rf /usr/share/nginx/html/* && \
    rm /etc/nginx/conf.d/default.conf

# 复制你打包好的前端文件
COPY ./ /usr/share/nginx/html/

# 复制nginx配置（待会创建）
COPY nginx.conf /etc/nginx/nginx.conf

# 暴露80端口
EXPOSE 80

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]
