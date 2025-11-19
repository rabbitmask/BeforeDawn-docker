# BeforeDawn - Docker一键部署



## 🚀 一键启动

```bash
cd BeforeDawn-docker
docker-compose up -d
```

### 访问系统
- 访问地址：http://IP:1988
- （后端API通过Nginx代理，无需直接访问）

## 📊 常用命令

```bash
# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 进入后端容器
docker exec -it beforedawn-backend sh

# 进入MySQL
docker exec -it beforedawn-mysql mysql -ubeforedawn -p"beforedawn^*#483956" beforedawn_vuln
```

## 🔧 配置说明

### 默认账号密码

**MySQL：**
- 地址：localhost:3306（需要取消docker-compose.yml中端口注释）
- 数据库：beforedawn_vuln
- 用户：beforedawn
- 密码：beforedawn^*#483956

**Redis：**
- 地址：localhost:6379（需要取消docker-compose.yml中端口注释）
- 密码：redis^*#483956

**系统账号：**
- 第一次启动会自动从`mysql/init/2-data.sql`导入
- 具体账号密码看data.sql文件 默认admin/123456

### 数据库自动初始化

**已经自动搞定了！**

第一次启动时，MySQL会自动执行：
- `mysql/init/1-schema.sql` - 创建表结构
- `mysql/init/2-data.sql` - 插入初始数据



### 修改密码（生产环境必改）

编辑`docker-compose.yml`，修改：
```yaml
MYSQL_PASSWORD: 你的新密码
DB_PASSWORD: 你的新密码      # 这个也要改！
REDIS_PASSWORD: 你的新密码
JWT_SECRET: 你的新密钥（至少32字符）
```

## 📝 更新部署

**当你修改了代码，需要重新部署：**

```bash
# 1. 重新打包后端（jar里虽然是dev，但Docker运行时用prod）
cd BeforeDawn
mvn clean package -DskipTests

# 2. 重新打包前端（生产环境，读取.env.production）
cd beforedawn-web
npm run build

# 3. 复制文件到Docker目录
cp BeforeDawn/target/beforedawn-vuln-platform.jar BeforeDawn-docker/backend/app.jar

# 只复制前端文件（不要删Dockerfile和nginx.conf）
cp -r BeforeDawn-web/dist/* BeforeDawn-docker/frontend/

# 4. 重新构建并启动
cd BeforeDawn-docker
docker-compose up -d --build
```



---

## 🚀 生产环境部署

### 安全配置（重要）

**当前配置默认只暴露前端1988端口（生产环境）：**

```yaml
✅ 1988端口  - 前端Nginx（对外访问）
❌ 8080   - 后端（已注释，Docker内网访问）
❌ 3306   - MySQL（已注释，Docker内网访问）
❌ 6379   - Redis（已注释，Docker内网访问）
```

**访问流程：**
```
外网用户 → VPS:1988 (Nginx)
            ├─→ 静态页面
            └─→ /api/* → backend:8080 (Docker内网)
                          ├─→ mysql:3306
                          └─→ redis:6379
```

### 本地开发需要

如果你需要用Navicat连接MySQL、RedisInsight连接Redis，或直接访问后端：

**编辑`docker-compose.yml`，取消注释相关端口：**
```yaml
# backend:
#   ports:
#     - "8080:8080"  # ← 删掉注释

# mysql:
#   ports:
#     - "3306:3306"  # ← 删掉注释

# redis:
#   ports:
#     - "6379:6379"  # ← 删掉注释
```

### 修改密码（生产环境必改！）

**编辑`docker-compose.yml`，搜索并替换所有密码：**
```yaml
MYSQL_ROOT_PASSWORD: root^*#483956      # ← 改成你的强密码
MYSQL_PASSWORD: beforedawn^*#483956     # ← 改成你的强密码
REDIS_PASSWORD: redis^*#483956          # ← 改成你的强密码
JWT_SECRET: beforedawn_jwt_secret_key_20241118  # ← 改成随机字符串（至少32字符！）
```

**⚠️ 注意**：
- 改完密码后要同步修改`DB_PASSWORD`、`REDIS_PASSWORD`等环境变量
- **JWT_SECRET必须至少32个字符**（HMAC-SHA256要求），否则后端启动失败

---
