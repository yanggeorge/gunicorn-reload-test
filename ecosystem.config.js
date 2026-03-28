module.exports = {
  apps: [
    {
      name: "fastapi-backend", // PM2 面板里显示的服务名称
      script: "uv", // 我们使用 uv 命令来启动
      args: "run gunicorn main:app -k uvicorn.workers.UvicornWorker -w 2 --bind 127.0.0.1:8000 --graceful-timeout 30",
      interpreter: "none", // 关键：告诉 PM2 这不是 Node 脚本，直接执行上面的指令

      // === 以下是保障平滑重启的核心配置 ===
      reload_signal: "SIGHUP", // 告诉 PM2：重载时发送 HUP 信号，而不是默认的 SIGINT
      kill_timeout: 35000, // 告诉 PM2：发送关机信号后，最多等 35 秒再强制杀进程（比 Gunicorn 的 30 秒稍微长一点作为兜底）

      // 其他常规配置
      autorestart: true, // 崩溃自动重启
      watch: false, // 生产环境建议关闭 watch，用手动 reload
      env: {
        NODE_ENV: "production",
      },
    },
  ],
};
