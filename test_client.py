import requests
import time

def run_test():
    print("开始连接服务端请求流式数据...")
    url = "http://127.0.0.1:8000/stream"
    
    try:
        # stream=True 是接收流式响应的关键
        with requests.get(url, stream=True, timeout=30) as response:
            for line in response.iter_lines():
                if line:
                    current_time = time.strftime('%H:%M:%S')
                    print(f"[{current_time}] 收到数据: {line.decode('utf-8')}")
    except Exception as e:
        print(f"\n连接中断或报错: {e}")
    
    print("流式请求结束。")

if __name__ == "__main__":
    run_test()