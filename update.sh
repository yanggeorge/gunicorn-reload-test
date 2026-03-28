cat << 'EOF' > start_server.sh
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
EOF

cat << 'EOF' > run_client.sh
#!/bin/bash
echo "📡 启动测试客户端，开始接收流式响应..."

uv run python test_client.py
EOF

cat << 'EOF' > reload_server.sh
#!/bin/bash

# 检查 PID 文件是否存在
if [ -f "gunicorn.pid" ]; then
    PID=$(cat gunicorn.pid)
    echo "🔄 正在向 Gunicorn 主进程 (PID: $PID) 发送平滑重载信号 (HUP)..."
    
    kill -HUP $PID
    
    echo "✅ 信号已发送！"
    echo "👀 现在请去观察 run_client.sh 的窗口，看流式输出是否中断，以及 Worker PID 是否在下一次请求时发生变化。"
else
    echo "❌ 错误: 找不到 gunicorn.pid 文件。请确保先运行了 start_server.sh 并且服务正在运行。"
fi
EOF

chmod +x start_server.sh run_client.sh reload_server.sh
echo "✅ 三个测试脚本已生成，并已赋予执行权限！"