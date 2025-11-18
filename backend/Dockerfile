# 后端Dockerfile - 超简单版
# 直接用打包好的jar，不用在Docker里编译

FROM eclipse-temurin:17-jre-alpine

# 设置时区为上海，安装netcat用于健康检查
RUN apk add --no-cache netcat-openbsd tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

WORKDIR /app

# 复制jar文件（你已经打包好的）
COPY app.jar /app/app.jar

# 创建上传目录
RUN mkdir -p /app/uploads /app/logs

# 暴露端口
EXPOSE 8080

# JVM参数
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"

# 健康检查（不用actuator，直接检查端口）
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD nc -z localhost 8080 || exit 1

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
