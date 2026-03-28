#!/bin/bash
echo "🚀 准备启动 Gunicorn 服务端 (2 个 Worker)..."
echo "提示: 按 Ctrl+C 可以停止服务。"

# 使用 uv 运行 gunicorn，并将主进程 PID 写入 gunicorn.pid
uv run gunicorn main:app \
  -k uvicorn.workers.UvicornWorker \
  -w 2 \
  --bind 127.0.0.1:8000 \
  --graceful-timeout 30 \
  --pid gunicorn.pid
