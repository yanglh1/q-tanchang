# Q探长 🐢

Q探长 是一个基于 Spring Boot 3 + JDK 21 开发的轻量级 OCI 管理面板，后端采用 SQLite 存储，整体通过 Docker 容器化运行，支持一键脚本结合 docker-compose 快速部署。

## 🔒 安全加固内容

1. **凭证环境变量化** — 管理员密码、Telegram Bot Token、AI API Key 全部改为环境变量注入，不再硬编码
2. **认证绕过修复** — 修复 AuthInterceptor 中 `contains("/api")` 导致的路径绕过
3. **CORS 限制** — 默认同源策略，不再允许任意来源跨域
4. **WebSocket 来源限制** — 支持通过环境变量配置允许的来源
5. **命令注入防护** — Ping 和 VNC 连接命令增加输入验证和白名单过滤
6. **密码不外泄** — 登录失败通知中不再包含密码信息（即使是脱敏后的）
7. **错误信息脱敏** — 未知异常不再向客户端泄露内部错误详情
8. **Docker 非 root** — 容器以 `ocihelper` 用户运行，降低逃逸风险
9. **.dockerignore** — 排除敏感文件（.git、db、keys 等）不进入镜像

## ⚙️ 核心功能

- 支持批量添加多个租户配置，模糊搜索、状态筛选
- 更改实例配置、引导卷配置
- 一键附加 IPv6、一键放行所有端口
- 一键开启免费 AMD 实例下行 500Mbps
- 一键自动救援/缩小硬盘（默认 47GB）
- 根据多个 CIDR 网段更换实例公共 IP
- 多租户同时批量开机、断点续抢
- Cloud Shell 控制台
- Cloudflare DNS 管理
- Telegram 机器人操作
- MFA 登录验证
- 加密备份恢复
- AI 聊天助手（硅基流动免费 API）

## 🚀 一键部署

```bash
# 部署前请先设置环境变量
export WEB_ACCOUNT=your_account
export WEB_PASSWORD=your_strong_password
export BOOT_BROADCAST_CHANNEL="https://api.telegram.org/botYOUR_TOKEN/sendMessage?chat_id=@your_channel"

# 一键部署
bash <(wget -qO- https://raw.githubusercontent.com/yanglh1/q-tanchang/main/deploy.sh)
```

或手动 Docker Compose 部署：

```bash
mkdir -p /app/q-tanchang/keys && cd /app/q-tanchang

# 下载配置文件
wget https://raw.githubusercontent.com/yanglh1/q-tanchang/main/docker-compose.yml
wget https://raw.githubusercontent.com/yanglh1/q-tanchang/main/application.yml

# 修改 application.yml 中的配置，或通过环境变量设置
# 启动服务
docker-compose up -d
```

访问 `http://your-ip:8818`（建议通过 Nginx 反代 + HTTPS）

## 🔐 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `WEB_ACCOUNT` | 管理员账号 | changeme |
| `WEB_PASSWORD` | 管理员密码 | changeme_strong_password |
| `BOOT_BROADCAST_CHANNEL` | Telegram Bot 通知 URL | (空) |
| `AI_API_KEY` | 硅基流动 API Key | sk-xxx |
| `OCI_KEY_DIR` | OCI 密钥目录 | /app/q-tanchang/keys |
| `CORS_ORIGIN` | CORS 允许来源 | 同源策略 |
| `WS_ALLOWED_ORIGIN` | WebSocket 允许来源 | (空) |

## 📝 更新日志

> 基于原项目 v3.4.8 安全加固，详见 [CHANGELOG](./CHANGELOG.md)

## 📄 License

Apache 2.0
