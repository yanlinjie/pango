import socket
import time

# 目标 IP 和端口
target_ip = "192.168.0.2"
target_port = 8080

# 创建 UDP 套接字
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# 构建 8 字节的数据（可以根据需求自行修改）
data = b'\x00\x01\x02\x03\x04\x05\x06\x07\x08'  # 8 字节数据

try:
    while True:
        # 发送 8 字节数据包
        sock.sendto(data, (target_ip, target_port))
        print(f"发送数据包：{data.hex()}")

        # 控制发送频率，间隔 0.1 秒（可根据需求调整时间间隔）
        time.sleep(0.1)

except KeyboardInterrupt:
    print("\n发送终止。")

finally:
    # 关闭套接字
    sock.close()
