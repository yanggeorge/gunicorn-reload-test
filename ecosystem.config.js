module.exports = {
  apps: [
    {
      name: "fastapi-backend",
      // 关键修改 1：直接指向 uv 虚拟环境里的 gunicorn，绕过 uv run 的信号拦截
      script: "./.venv/bin/gunicorn",
      // 关键修改 2：把 main:app 放到 args 里
      args: "main:app -k uvicorn.workers.UvicornWorker -w 2 --bind 127.0.0.1:8000 --graceful-timeout 30",
      interpreter: "none",

      // 因为我们不再使用 pm2 reload，下面这两行其实可以删掉了，但留着也没坏处
      // reload_signal: "SIGHUP",
      // kill_timeout: 35000,
      env: {
        PYTHONUNBUFFERED: "1",
      },
    },
  ],
};
