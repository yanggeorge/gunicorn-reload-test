# FastAPI + Gunicorn + PM2 平滑重启测试项目 (Graceful Reload)

本项目用于验证和演示在 FastAPI 服务端存在长耗时流式请求（Stream）时，如何利用 Gunicorn 的 Master-Worker 架构配合 PM2 实现**真正的无损平滑重启（Zero-Downtime Deployment）**。

## 🎯 核心目标
在进行代码发版重启服务时：
1. **老用户不断流：** 正在进行中的长连接/流式请求不会被强行中断，旧 Worker 会等待其执行完毕再退出。
2. **新请求不报错：** 新进来的请求会被瞬间路由到刚刚启动加载了新代码的新 Worker 上。
3. **全程零感知：** Nginx / PM2 层面不报 502，用户端完全无感知。

## 📁 项目关键文件说明

* `main.py`: FastAPI 服务端代码，包含一个 `/stream` 接口，模拟长达 15 秒的大模型流式输出，并在输出中附带当前处理该请求的进程 PID。
* `test_client.py`: 客户端测试脚本，使用 `requests` 持续接收流式数据并打印时间戳。
* `ecosystem.config.js`: PM2 的核心配置文件，定义了启动参数和环境变量。
* `pm2_start.sh`: 启动服务的快捷脚本。
* `pm2_reload.sh`: **核心！** 发送平滑重载信号的快捷脚本。

## 🚀 测试运行步骤

### 1. 环境准备
确保你已经安装了 `uv` 和 `pm2`。
```bash
# 初始化环境并安装依赖
uv sync  # 或者 uv add fastapi uvicorn gunicorn requests
```

### 2. 启动服务端
打开终端 A，运行启动脚本：
```bash
./pm2_start.sh
```
你可以通过 `pm2 log fastapi-backend` 查看启动日志。

### 3. 运行客户端模拟请求
打开终端 B，运行测试客户端：
```bash
uv run python test_client.py
```
此时客户端会开始逐秒打印接收到的 Chunk 数据，并显示当前处理请求的 Worker PID。

### 4. 触发平滑重启（破坏性测试）
在终端 B 打印到第 5 秒左右时（Stream 尚未结束），立刻打开终端 C 执行重载脚本：
```bash
./pm2_reload.sh
```

### 🧐 观察测试结果
1. **旧请求无损：** 终端 B 的流式输出**不会中断**，依然会安稳地打印完剩下的 Chunk，且 PID 保持不变。
2. **新请求易主：** 等这 15 秒全部输出完毕后，如果你再次运行 `uv run python test_client.py`，会发现接收请求的 Worker PID 已经变成了全新的数字。

## ⚠️ 核心避坑指南 (Best Practices)

在配合使用 PM2、Gunicorn 和 uv 时，有三个至关重要的细节决定了平滑重启的成败：

### 1. 绕过 `uv run` 拦截
在 `ecosystem.config.js` 中，**绝对不要**使用 `script: "uv", args: "run gunicorn ..."`。这会导致 PM2 的信号发给 uv 包装器而不是 Gunicorn 主进程。
**正确做法：** 直接指向虚拟环境中的二进制文件 `script: "./.venv/bin/gunicorn"`。

### 2. 放弃 `pm2 reload`，改用精准投递
PM2 自带的 `pm2 reload` 命令逻辑会强杀进程。
**正确做法：** 使用 `pm2 sendSignal SIGHUP fastapi-backend`。只把 `SIGHUP` 信号精准投递给 Gunicorn 的主进程，让 Gunicorn 自己去完成优雅的新老 Worker 交接。

### 3. 解决 PM2 日志吞没问题
Python 默认会缓冲标准输出，导致在 PM2 中无法实时看到 `print` 日志。
**正确做法：** 在 `ecosystem.config.js` 的 `env` 节点中强制加入 `PYTHONUNBUFFERED: "1"`。