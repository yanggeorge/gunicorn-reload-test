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
