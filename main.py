import asyncio
import os
from fastapi import FastAPI
from fastapi.responses import StreamingResponse

app = FastAPI()

async def fake_data_streamer():
    worker_pid = os.getpid()
    # 模拟大模型生成，总共吐出 15 条数据，每秒 1 条
    for i in range(1, 16):
        print(f"Worker PID: {worker_pid} | 生成数据: Chunk {i}/15")
        yield f"Chunk {i}/15 | 处理此请求的 Worker PID: {worker_pid}\n"
        await asyncio.sleep(1)

@app.get("/stream")
async def stream():
    return StreamingResponse(fake_data_streamer(), media_type="text/plain")