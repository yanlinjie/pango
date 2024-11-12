from PIL import Image, ImageFont, ImageDraw
import numpy as np
import socket
import struct
import threading
import time
from functools import partial
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QLabel, QVBoxLayout, QWidget,
    QPushButton, QHBoxLayout, QSlider, QGroupBox, QGridLayout,
    QComboBox, QLineEdit, QTextEdit, QStackedWidget, QSizePolicy
)
from PyQt5.QtGui import QImage, QPixmap
from PyQt5.QtCore import QTimer, Qt, pyqtSignal
from collections import deque
import sys
import pyqtgraph as pg

# 导入 Scapy
from scapy.all import sniff, Ether, get_if_list, TCP, UDP, ICMP, Raw, IP

# 设置本地 IP 和端口
LOCAL_IP = "192.168.0.3"
LOCAL_PORT = 8080

# 设置目标 IP 和端口
TARGET_IP = "192.168.0.2"
TARGET_PORT = 8080

# 图像宽度和高度
IMAGE_WIDTH = 640
IMAGE_HEIGHT = 480
BYTES_PER_PIXEL = 2

# 创建UDP套接字（用于ADC数据接收）
adc_udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
adc_udp_socket.bind((LOCAL_IP, LOCAL_PORT))
print(f"ADC UDP socket bound to {LOCAL_IP}:{LOCAL_PORT}")

# 创建原始套接字（用于视频数据接收）
sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_IP)
sock.bind((LOCAL_IP, 0))
sock.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL, 1)
sock.ioctl(socket.SIO_RCVALL, socket.RCVALL_ON)

# 目标 UDP 套接字（用于发送指令和文本数据）
udp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

IP_HEADER_LEN = 20
UDP_HEADER_LEN = 8

def parse_ip_header(ip_header):
    ip_header_fields = struct.unpack('!BBHHHBBH4s4s', ip_header[:IP_HEADER_LEN])
    ihl = ip_header_fields[0] & 0xF
    identification = ip_header_fields[3]
    return ihl, identification

def rgb565_to_rgb888(data):
    data_16bit = np.frombuffer(data, dtype=np.uint16).byteswap()
    r = (data_16bit >> 11) & 0x1F
    g = (data_16bit >> 5) & 0x3F
    b = data_16bit & 0x1F
    r = (r << 3) | (r >> 2)
    g = (g << 2) | (g >> 4)
    b = (b << 3) | (b >> 2)
    rgb888_image = np.stack((r, g, b), axis=-1)
    return rgb888_image

def receive_data(window):
    received_lines = 0
    frame_start_time = None
    while window.is_running:
        if window.is_adc_mode:
            time.sleep(0.1)
            continue  # 如果是ADC模式，则暂停视频数据接收
        try:
            raw_data, addr = sock.recvfrom(65535)
            ip_header = raw_data[:IP_HEADER_LEN]
            ihl, identification = parse_ip_header(ip_header)
            udp_data_start = ihl * 4
            udp_data = raw_data[udp_data_start + UDP_HEADER_LEN:]

            if len(udp_data) == IMAGE_WIDTH * BYTES_PER_PIXEL:
                line_number = identification - 1
                if 1 <= line_number < IMAGE_HEIGHT:
                    if received_lines == 0:
                        frame_start_time = time.time()
                    rgb888_row = rgb565_to_rgb888(udp_data)
                    window.update_line(line_number, rgb888_row)
                    received_lines += 1

            if received_lines == IMAGE_HEIGHT:
                window.update_image()
                received_lines = 0
                window.add_frame_time()

                if frame_start_time is not None:
                    frame_end_time = time.time()
                    latency = (frame_end_time - frame_start_time) * 1000
                    window.current_latency = latency
                    frame_start_time = None

        except Exception as e:
            print(f"Error receiving data: {e}")
            continue  # 不退出循环

def receive_ethernet_data(window):
    # 获取可用的网络接口列表
    interfaces = get_if_list()
    print(f"可用的网络接口: {interfaces}")
    # 指定要使用的网络接口（请根据您的系统修改）
    iface = "以太网"  # 

    # 定义数据包处理函数
    def packet_handler(packet):
        if packet.haslayer(Ether):
            # 获取源 IP 地址
            src_ip = None
            if packet.haslayer(IP):
                src_ip = packet[IP].src
            else:
                src_ip = "未知"

            # 获取帧类型（Ethertype）
            ethertype = packet[Ether].type

            # 获取数据包大小
            packet_size = len(packet)

            # 尝试获取数据部分
            data = None
            if packet.haslayer(Raw):
                data = packet[Raw].load
            else:
                # 尝试从其他层获取数据，例如 TCP、UDP 等
                if packet.haslayer(TCP):
                    data = bytes(packet[TCP].payload)
                elif packet.haslayer(UDP):
                    data = bytes(packet[UDP].payload)
                elif packet.haslayer(ICMP):
                    data = bytes(packet[ICMP].payload)

            # 初始化解析数据字符串
            parsed_data = f"源 IP: {src_ip}, 帧类型: {hex(ethertype)}, 数据包大小: {packet_size} 字节"

            if data:
                # 尝试将数据内容解码为字符串
                try:
                    decoded_data = data.decode('utf-8', errors='replace')
                except Exception as e:
                    decoded_data = f"无法解码的数据: {e}"
                parsed_data += f"\n数据内容: {decoded_data}"

            # print(parsed_data)
            # 通过信号将数据发送到主线程
            window.data_received_signal.emit(parsed_data)

    # 开始嗅探数据包
    print(f"开始在接口 {iface} 上接收以太网数据...")
    window.is_sniffing = True
    try:
        while window.is_network_capture_mode:
            sniff(
                iface=iface,
                prn=packet_handler,
                count=0,
                timeout=1,
                stop_filter=lambda x: not window.is_network_capture_mode
            )
    except Exception as e:
        print(f"接收以太网数据出错: {e}")
    print("以太网数据接收已停止。")

def reverse_bits(byte):
    return int(f"{byte:08b}"[::-1], 2)

def extract_bitmap(text, font_path, font_size, output_width, output_height):
    font = ImageFont.truetype(font_path, font_size)
    text_bbox = font.getbbox(text)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    image = Image.new('1', (output_width, output_height), color=1)
    draw = ImageDraw.Draw(image)
    text_position = (
        (output_width - text_width) // 2,
        (output_height - text_height) // 2
    )
    draw.text(text_position, text, font=font, fill=0)
    bitmap = np.invert(np.array(image))
    return bitmap

def bitmap_to_8bit_values(bitmap):
    bitmap = bitmap.astype(int)
    rows, cols = bitmap.shape
    bit_values = []
    for row in bitmap:
        for i in range(0, cols, 8):
            byte = row[i:i + 8]
            byte_str = ''.join(map(str, byte))
            byte_val = int(byte_str, 2)
            byte_val = reverse_bits(byte_val)
            bit_values.append(byte_val)
    return bit_values

def send_text_data(text, font_path, font_size, output_width,
                   output_height, target_ip, target_port):
    bitmap = extract_bitmap(text, font_path, font_size, output_width,
                            output_height)
    bit_values = bitmap_to_8bit_values(bitmap)
    data_bytes = bytes(bit_values)
    udp_sock.sendto(data_bytes, (target_ip, target_port))
    print(f"点阵数据已发送到 {target_ip}:{target_port}")

class VideoWindow(QMainWindow):
    # 定义信号
    data_received_signal = pyqtSignal(str)
    # 定义信号，传递 time_data, freqs, fft_magnitude
    adc_data_signal = pyqtSignal(np.ndarray, np.ndarray, np.ndarray)

    def __init__(self):
        super().__init__()
        self.setWindowTitle("UDP 视频流")
        self.setGeometry(100, 100, 1200, 800)

        # 创建主部件和布局
        main_widget = QWidget()
        main_layout = QHBoxLayout(main_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)

        # 创建菜单栏
        menu_bar = self.menuBar()
        file_menu = menu_bar.addMenu("文件")
        help_menu = menu_bar.addMenu("帮助")

        # 左侧布局 - 视频显示区
        left_layout = QVBoxLayout()
        left_layout.setContentsMargins(10, 10, 10, 10)

        image_box = QGroupBox("视频显示")
        image_layout = QVBoxLayout()
        self.image_label = QLabel(self)
        self.image_label.setSizePolicy(QSizePolicy.Expanding,
                                       QSizePolicy.Expanding)
        self.image_label.setAlignment(Qt.AlignCenter)
        self.image_label.setScaledContents(True)
        self.fps_label = QLabel("FPS: 0")
        self.latency_label = QLabel("延迟: 0 ms")
        image_layout.addWidget(self.image_label)
        image_layout.addWidget(self.fps_label, alignment=Qt.AlignCenter)
        image_layout.addWidget(self.latency_label, alignment=Qt.AlignCenter)
        image_box.setLayout(image_layout)
        left_layout.addWidget(image_box)

        # 右侧布局 - 控制区
        right_layout = QVBoxLayout()
        right_layout.setContentsMargins(10, 10, 10, 10)

        # 模式切换按钮并列放置
        mode_buttons_layout = QHBoxLayout()
        self.video_capture_button = QPushButton("视频采集模式")
        self.video_capture_button.clicked.connect(self.on_video_capture_mode)
        self.network_capture_button = QPushButton("网络数据采集模式")
        self.network_capture_button.clicked.connect(
            self.on_network_capture_mode)
        self.adc_capture_button = QPushButton("ADC数据采集模式")
        self.adc_capture_button.clicked.connect(self.on_adc_capture_mode)
        mode_buttons_layout.addWidget(self.video_capture_button)
        mode_buttons_layout.addWidget(self.network_capture_button)
        mode_buttons_layout.addWidget(self.adc_capture_button)
        right_layout.addLayout(mode_buttons_layout)

        # 功能区
        self.function_stack = QStackedWidget()
        self.init_video_tab()
        self.init_network_tab()
        self.init_adc_tab()
        right_layout.addWidget(self.function_stack)

        # 数据显示区域
        data_box = QGroupBox("解析数据")
        data_layout = QVBoxLayout()
        self.data_display = QTextEdit()
        self.data_display.setReadOnly(True)
        data_layout.addWidget(self.data_display)
        data_box.setLayout(data_layout)
        right_layout.addWidget(data_box)

        # 设置右侧布局的伸缩策略
        right_layout.addStretch()

        # 将左侧和右侧布局添加到主布局
        main_layout.addLayout(left_layout, stretch=3)
        main_layout.addLayout(right_layout, stretch=2)

        # 设置中央部件
        self.setCentralWidget(main_widget)

        # 初始化图像数据
        self.image = np.zeros((IMAGE_HEIGHT, IMAGE_WIDTH, 3),
                              dtype=np.uint8)
        self.frame_times = deque(maxlen=1000)
        self.current_latency = 0

        # 控制变量
        self.is_running = True  # 添加控制变量
        self.is_network_capture_mode = False
        self.is_adc_mode = False
        self.is_sniffing = False
        self.ethernet_thread = None
        self.adc_thread = None

        # 连接信号到槽函数
        self.data_received_signal.connect(self.display_parsed_data)
        self.adc_data_signal.connect(self.update_adc_data)

        # 启动接收线程
        self.udp_thread = threading.Thread(target=receive_data, args=(self,))
        self.udp_thread.daemon = True
        self.udp_thread.start()

        # 启动定时器用于更新 FPS 和延迟
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_metrics)
        self.timer.start(1000)

        # 初始化为视频采集模式
        self.on_video_capture_mode()

    # 初始化视频采集功能区
    def init_video_tab(self):
        self.video_tab = QWidget()
        video_layout = QVBoxLayout(self.video_tab)

        # 模式选择选项卡
        mode_group = QGroupBox("模式选择")
        mode_layout = QGridLayout()
        button_labels = [
            "预览模式", "显示视频1", "显示视频2", "显示视频3", "显示视频4",
            "视频1+视频2", "视频1+视频3", "视频1+视频4",
            "视频2+视频3", "视频2+视频4", "视频3+视频4"
        ]

        for i in range(11):
            button = QPushButton(button_labels[i])
            button.clicked.connect(partial(self.on_button_click, i + 1))
            mode_layout.addWidget(button, i // 2, i % 2)
        mode_group.setLayout(mode_layout)

        # 分辨率设置选项卡
        resolution_group = QGroupBox("分辨率设置")
        resolution_layout = QVBoxLayout()

        self.resolution_label = QLabel("选择分辨率:")
        self.resolution_combo = QComboBox()
        self.resolution_combo.addItems([
            "1920x1080", "1024x768", "640x480", "960x540"
        ])
        self.set_resolution_button = QPushButton("设置分辨率")
        self.set_resolution_button.clicked.connect(self.set_resolution)

        resolution_layout.addWidget(self.resolution_label)
        resolution_layout.addWidget(self.resolution_combo)
        resolution_layout.addWidget(self.set_resolution_button)
        resolution_group.setLayout(resolution_layout)

        # 图像调整选项卡
        adjustment_group = QGroupBox("图像调整")
        adjustment_layout = QVBoxLayout()

        # 亮度滑块
        brightness_layout = QHBoxLayout()
        self.brightness_label = QLabel("亮度: 100")
        self.slider1 = QSlider(Qt.Horizontal)
        self.slider1.setRange(0, 200)
        self.slider1.setValue(100)
        self.slider1.setMinimumWidth(200)
        self.slider1.valueChanged.connect(
            lambda: self.on_slider_change(
                1, self.slider1.value(), self.brightness_label
            )
        )
        brightness_reset_button = QPushButton("重置亮度")
        brightness_reset_button.clicked.connect(
            lambda: self.reset_slider(
                self.slider1, 1, self.brightness_label
            )
        )
        brightness_layout.addWidget(self.brightness_label)
        brightness_layout.addWidget(self.slider1)
        brightness_layout.addWidget(brightness_reset_button)

        # 色度滑块
        chroma_layout = QHBoxLayout()
        self.chroma_label = QLabel("色度: 100")
        self.slider2 = QSlider(Qt.Horizontal)
        self.slider2.setRange(0, 200)
        self.slider2.setValue(100)
        self.slider2.setMinimumWidth(200)
        self.slider2.valueChanged.connect(
            lambda: self.on_slider_change(
                2, self.slider2.value(), self.chroma_label
            )
        )
        chroma_reset_button = QPushButton("重置色度")
        chroma_reset_button.clicked.connect(
            lambda: self.reset_slider(
                self.slider2, 2, self.chroma_label
            )
        )
        chroma_layout.addWidget(self.chroma_label)
        chroma_layout.addWidget(self.slider2)
        chroma_layout.addWidget(chroma_reset_button)

        # 添加二值化按钮
        self.binarization_button = QPushButton("图像二值化")
        self.binarization_button.clicked.connect(
            self.on_binarization_button_click)
        adjustment_layout.addLayout(brightness_layout)
        adjustment_layout.addLayout(chroma_layout)
        adjustment_layout.addWidget(self.binarization_button)

        adjustment_group.setLayout(adjustment_layout)

        # 文本发送选项卡
        text_group = QGroupBox("文本发送")
        text_layout = QVBoxLayout()

        self.text_input = QLineEdit(self)
        self.text_input.setPlaceholderText("请输入文本内容")

        button_layout = QHBoxLayout()
        self.send_button = QPushButton("发送")
        self.reset_button = QPushButton("复位文本")
        self.send_button.clicked.connect(self.send_text)
        self.reset_button.clicked.connect(self.reset_text)

        button_layout.addWidget(self.send_button)
        button_layout.addWidget(self.reset_button)

        text_layout.addWidget(self.text_input)
        text_layout.addLayout(button_layout)
        text_group.setLayout(text_layout)

        # 添加所有功能到视频采集布局
        video_layout.addWidget(mode_group)
        video_layout.addWidget(resolution_group)
        video_layout.addWidget(adjustment_group)
        video_layout.addWidget(text_group)

        # 将视频采集功能区添加到功能堆栈
        self.function_stack.addWidget(self.video_tab)

    # 初始化网络数据采集功能区
    def init_network_tab(self):
        self.network_tab = QWidget()
        network_layout = QVBoxLayout(self.network_tab)

        self.ip_input = QLineEdit(self)
        self.ip_input.setPlaceholderText("请输入目标 IP 地址 (例如: 192.168.0.5)")

        self.ip_send_button = QPushButton("发送 IP")
        self.ip_send_button.clicked.connect(self.send_ip_command)

        network_layout.addWidget(self.ip_input)
        network_layout.addWidget(self.ip_send_button)

        # 将网络数据采集功能区添加到功能堆栈
        self.function_stack.addWidget(self.network_tab)

    # 初始化ADC数据采集功能区
    def init_adc_tab(self):
        self.adc_tab = QWidget()
        adc_layout = QVBoxLayout(self.adc_tab)

        # 创建PyQtGraph绘图部件
        self.adc_plot_widget = pg.GraphicsLayoutWidget()
        adc_layout.addWidget(self.adc_plot_widget)

        # 创建时域和频域图形
        self.time_plot = self.adc_plot_widget.addPlot(title="时域波形")
        self.time_curve = self.time_plot.plot(pen='y')
        self.time_plot.setYRange(0, 255)
        self.time_plot.setXRange(0, 1024)

        self.adc_plot_widget.nextRow()  # 新建一行

        self.freq_plot = self.adc_plot_widget.addPlot(title="频域波形")
        self.freq_curve = self.freq_plot.plot(pen='g')
        self.freq_plot.setLogMode(x=False, y=True)
        self.freq_plot.setYRange(0, 5)
        self.freq_plot.setXRange(0, 500)  # 根据采样率的一半调整

        # 将ADC数据采集功能区添加到功能堆栈
        self.function_stack.addWidget(self.adc_tab)

    # 重写 closeEvent 方法，确保在窗口关闭时正确释放资源
    def closeEvent(self, event):
        # 停止视频接收线程
        self.is_running = False
        if self.udp_thread is not None:
            self.udp_thread.join()
            self.udp_thread = None
        # 停止以太网数据接收线程
        self.is_network_capture_mode = False
        self.is_sniffing = False
        if self.ethernet_thread is not None:
            self.ethernet_thread.join()
            self.ethernet_thread = None
        # 停止ADC数据接收线程
        self.is_adc_mode = False
        if self.adc_thread is not None:
            self.adc_thread.join()
            self.adc_thread = None
        # 关闭套接字
        sock.close()
        udp_sock.close()
        adc_udp_socket.close()
        event.accept()

    def on_video_capture_mode(self):
        global TARGET_IP, TARGET_PORT
        module_id = 4
        value = 1
        self.send_udp_data(module_id, value)
        print("已切换到视频采集模式")
        TARGET_IP = "192.168.0.2"
        TARGET_PORT = 8080

        # 切换功能区到视频采集功能
        self.function_stack.setCurrentWidget(self.video_tab)

        # 停止以太网数据接收线程
        self.stop_ethernet_reception()
        # 停止ADC数据接收线程
        self.stop_adc_reception()

        # 确保 is_adc_mode 被设置为 False
        self.is_adc_mode = False

        # 检查视频接收线程是否在运行，如果未运行则重新启动
        if not self.udp_thread.is_alive():
            print("视频接收线程未运行，正在重新启动...")
            self.is_running = True  # 设置 is_running 为 True
            self.udp_thread = threading.Thread(target=receive_data, args=(self,))
            self.udp_thread.daemon = True
            self.udp_thread.start()

    def on_network_capture_mode(self):
        global TARGET_IP, TARGET_PORT
        # 发送开启网络数据采集模式的指令
        self.send_udp_data(4, 1)
        print("已切换到网络数据采集模式")
        # 切换功能区到网络数据采集功能
        self.function_stack.setCurrentWidget(self.network_tab)

        # 启用 IP 输入框和发送按钮
        self.ip_input.setEnabled(True)
        self.ip_send_button.setEnabled(True)

        # 停止ADC数据接收线程
        self.stop_adc_reception()

    def on_adc_capture_mode(self):
        # 发送模块ID 4，值为6
        self.send_udp_data(4, 6)
        print("已切换到ADC数据采集模式")
        # 切换功能区到ADC数据采集功能
        self.function_stack.setCurrentWidget(self.adc_tab)

        # 停止以太网数据接收线程
        self.stop_ethernet_reception()

        # 延迟一段时间再开始ADC数据接收
        delay_seconds = 1  # 可以根据需要调整延迟时间
        print(f"等待 {delay_seconds} 秒后开始数据采集...")
        QTimer.singleShot(delay_seconds * 1000, self.start_adc_data_reception)

    def start_adc_data_reception(self):
        # 开启ADC数据接收线程
        if not self.is_adc_mode:
            self.is_adc_mode = True
            self.adc_thread = threading.Thread(target=self.receive_adc_data)
            self.adc_thread.daemon = True
            self.adc_thread.start()
            print("ADC数据接收已开始。")

    def send_ip_command(self):
        global TARGET_IP, TARGET_PORT
        ip_address = self.ip_input.text().strip()

        if not ip_address:
            print("请输入有效的 IP 地址")
            return

        # 根据输入的 IP 地址发送不同的模块 ID 和 value
        if ip_address == "192.168.0.5":
            module_id = 4
            value = 2
        elif ip_address == "192.168.0.6":
            module_id = 4
            value = 3
        elif ip_address == "192.168.0.7":
            module_id = 4
            value = 4
        elif ip_address == "192.168.0.8":
            module_id = 4
            value = 5
        else:
            print("未识别的 IP 地址，请输入 192.168.0.5 到 192.168.0.8 之间的 IP")
            return

        # 调用发送 UDP 数据函数
        self.send_udp_data(module_id, value)
        print(f"发送指令: 模块 ID = {module_id}, 值 = {value} 到 IP 地址 {ip_address}")
        TARGET_IP = ip_address
        TARGET_PORT = 8080

        # 启动以太网数据接收线程
        if not self.is_network_capture_mode:
            self.is_network_capture_mode = True
            if self.ethernet_thread is None or not self.ethernet_thread.is_alive():
                self.ethernet_thread = threading.Thread(
                    target=receive_ethernet_data, args=(self,))
                self.ethernet_thread.daemon = True
                self.ethernet_thread.start()

        # 停止ADC数据接收线程
        self.stop_adc_reception()

    def stop_ethernet_reception(self):
        # 停止以太网数据接收线程
        self.is_network_capture_mode = False
        self.is_sniffing = False
        if self.ethernet_thread is not None:
            self.ethernet_thread.join()
            self.ethernet_thread = None
        print("以太网数据接收已停止。")

    def stop_adc_reception(self):
        # 停止ADC数据接收线程
        self.is_adc_mode = False
        if self.adc_thread is not None:
            self.adc_thread.join()
            self.adc_thread = None
        print("ADC数据接收已停止。")

    def on_button_click(self, value):
        self.send_udp_data(0, value)
        self.set_resolution_button.setEnabled(value in [2, 3, 4, 5])
        self.resolution_combo.setCurrentText("960x540")

    def on_binarization_button_click(self):
        module_id = 7
        value = 0
        self.send_udp_data(module_id, value)
        print("已发送图像二值化指令")

    def add_frame_time(self):
        self.frame_times.append(time.time())

    def update_image(self):
        qimage = QImage(self.image.data, IMAGE_WIDTH, IMAGE_HEIGHT,
                        QImage.Format_RGB888)
        pixmap = QPixmap.fromImage(qimage)
        self.image_label.setPixmap(pixmap)

    def update_line(self, line_number, rgb_row):
        self.image[line_number, :, :] = rgb_row

    def update_metrics(self):
        current_time = time.time()
        self.frame_times.append(current_time)

        if len(self.frame_times) > 1:
            fps = len(self.frame_times) / (
                self.frame_times[-1] - self.frame_times[0])
            self.fps_label.setText(f"FPS: {fps:.2f}")

        self.latency_label.setText(f"延迟: {self.current_latency:.2f} ms")

    def send_udp_data(self, module_id, value):
        try:
            data = struct.pack('!BB', module_id, value)
            udp_sock.sendto(data, (TARGET_IP, TARGET_PORT))
            print(f"已发送: 模块 {module_id}, 值 {value} 到 "
                  f"{TARGET_IP}:{TARGET_PORT}")
        except Exception as e:
            print(f"发送数据出错: {e}")

    def on_slider_change(self, module_id, value, label):
        label.setText(f"{label.text().split(':')[0]}: {value}")
        self.send_udp_data(module_id, value)

    def reset_slider(self, slider, module_id, label):
        slider.setValue(100)
        label.setText(f"{label.text().split(':')[0]}: 100")
        self.send_udp_data(module_id, 100)

    def set_resolution(self):
        resolution_map = {
            "1024x768": 1,
            "640x480": 2,
            "960x540": 3,
            "1920x1080": 4
        }
        resolution_text = self.resolution_combo.currentText()
        module_value = resolution_map.get(resolution_text, 1)
        self.send_udp_data(3, module_value)
        print(f"设置分辨率: {resolution_text}，发送模块3的值: {module_value}")

    def send_text(self):
        text = self.text_input.text()
        if text:
            font_path = "C:/Windows/Fonts/simsun.ttc"
            font_size = 32
            output_width = 152
            output_height = 33
            send_text_data(text, font_path, font_size, output_width,
                           output_height, TARGET_IP, TARGET_PORT)
            print(f"发送的文本内容: {text}")

    def reset_text(self):
        self.text_input.clear()
        font_path = "C:/Windows/Fonts/simsun.ttc"
        font_size = 32
        output_width = 152
        output_height = 33
        send_text_data("", font_path, font_size, output_width,
                       output_height, TARGET_IP, TARGET_PORT)
        print("发送了空文本进行复位")

    # 新增的槽函数，用于显示解析数据
    def display_parsed_data(self, data):
        print(f"Received data: {data}")  # 添加调试信息
        self.data_display.append(data)

    # 新增槽函数，用于更新ADC绘图
    def update_adc_data(self, time_data, freqs, fft_magnitude):
        self.time_curve.setData(time_data)
        self.freq_curve.setData(freqs, fft_magnitude)

    # 修改 receive_adc_data 函数
    def receive_adc_data(self):
        sampling_rate = 1000  # 修改为你的实际采样率
        buffer_size = 1024  # 保持固定的缓冲区大小
        data_buffer = np.zeros(buffer_size, dtype=np.uint8)
        packet_count = 0
        start_time = time.time()
        skip_count = 19  # 每接收 20 个包只处理 1 个
        packet_index = 0

        while self.is_adc_mode:
            try:
                data, addr = adc_udp_socket.recvfrom(65535)  # 接收数据
                data_length = len(data)
                print(f"Received ADC data of length: {data_length} bytes")

                # 如果接收到的数据长度大于1024字节，则不处理该数据包
                if data_length > buffer_size:
                    print(f"数据长度大于 {buffer_size} 字节，丢弃该数据包。")
                    continue

                packet_index += 1

                # 只处理每隔 skip_count 个包
                if packet_index % skip_count != 0:
                    continue

                packet_count += 1
                if time.time() - start_time >= 1:
                    packet_count = 0
                    start_time = time.time()

                # 更新时域数据
                new_data = np.frombuffer(data, dtype=np.uint8)
                roll_amount = len(new_data)

                # 滚动数组并插入新数据
                data_buffer = np.roll(data_buffer, -roll_amount)
                data_buffer[-roll_amount:] = new_data

                # 对信号加窗处理（使用汉宁窗）
                window_func = np.hanning(len(data_buffer))
                data_windowed = data_buffer * window_func

                # 进行 FFT 分析，取正频率部分
                fft_result = np.fft.fft(data_windowed)
                fft_magnitude = np.abs(fft_result[:len(data_buffer) // 2])

                # 计算频率轴
                freqs = np.fft.fftfreq(len(data_buffer),
                                       d=1 / sampling_rate)[:len(data_buffer) // 2]

                # 发射信号，传递数据
                self.adc_data_signal.emit(
                    data_buffer.copy(), freqs.copy(), fft_magnitude.copy()
                )

            except socket.error as e:
                print(f"Socket error: {e}")
                break

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = VideoWindow()
    window.show()
    sys.exit(app.exec_())
