module video_scale_down_near	
(
    input                   vin_clk,
    input                   rst_n,
    input                   frame_vs, // 输入视频帧同步复位
    input       [24:0]      vin_dat,      // 输入视频数据
    input                   vin_valid,    // 输入视频数据有效
    output                  vin_ready,    // 输入准备好
    output  reg [24:0]      vout_dat,     // 输出视频数据
    output  reg             vout_valid,   // 输出视频数据有效

    input                   vout_ready,   // 输出准备好
    input       [15:0]      vin_xres,     // 输入视频水平分辨率
    input       [15:0]      vin_yres,     // 输入视频垂直分辨率
    input       [15:0]      vout_xres,    // 输出视频水平分辨率
    input       [15:0]      vout_yres     // 输出视频垂直分辨率
);

    reg     [31:0]  scaler_height;  // 垂直缩放系数
    reg     [31:0]  scaler_width;   // 水平缩放系数
    reg     [15:0]  vin_x = 0;      // 输入视频水平计数
    reg     [15:0]  vin_y = 0;      // 输入视频垂直计数
    reg     [31:0]  vout_x = 0;     // 输出视频水平计数
    reg     [31:0]  vout_y = 0;     // 输出视频垂直计数

    assign vin_ready = vout_ready;  // 流控信号

// 预定义缩放比例
// 对于 1920x1080 输入分辨率
localparam [31:0] SCALER_1920_WIDTH_1024 = ((1920 << 16) / 1024) + 1;
localparam [31:0] SCALER_1920_HEIGHT_768 = ((1080 << 16) / 768) + 1;
localparam [31:0] SCALER_1920_WIDTH_640  = ((1920 << 16) / 640) + 1;
localparam [31:0] SCALER_1920_HEIGHT_480 = ((1080 << 16) / 480) + 1;
localparam [31:0] SCALER_1920_WIDTH_960  = ((1920 << 16) / 960) + 1;
localparam [31:0] SCALER_1920_HEIGHT_540 = ((1080 << 16) / 540) + 1;
localparam [31:0] SCALER_1920_WIDTH_1280 = ((1920 << 16) / 1280) + 1;
localparam [31:0] SCALER_1920_HEIGHT_720 = ((1080 << 16) / 720) + 1;



// 使用参数选择固定的缩放比例
always @(posedge vin_clk or negedge rst_n) begin
    if (!rst_n) begin
        scaler_width  <= 0;
        scaler_height <= 0;
    end else begin
        case ({vin_xres, vin_yres, vout_xres, vout_yres})
            // 1920x1080输入，1920x1080输出 (No scaling needed)
            {16'd1920, 16'd1080, 16'd1920, 16'd1080}: begin
                scaler_width  <= (1 << 16);  // No scaling, factor = 1
                scaler_height <= (1 << 16);
            end
            // 1920x1080输入，1024x768输出
            {16'd1920, 16'd1080, 16'd1024, 16'd768}: begin
                scaler_width  <= SCALER_1920_WIDTH_1024;
                scaler_height <= SCALER_1920_HEIGHT_768;
            end
            // 1920x1080输入，640x480输出
            {16'd1920, 16'd1080, 16'd640, 16'd480}: begin
                scaler_width  <= SCALER_1920_WIDTH_640;
                scaler_height <= SCALER_1920_HEIGHT_480;
            end
            // 1920x1080输入，960x540输出
            {16'd1920, 16'd1080, 16'd960, 16'd540}: begin
                scaler_width  <= SCALER_1920_WIDTH_960;
                scaler_height <= SCALER_1920_HEIGHT_540;
            end
            // 1920x1080输入，1280x720输出
            {16'd1920, 16'd1080, 16'd1280, 16'd720}: begin
                scaler_width  <= SCALER_1920_WIDTH_1280;
                scaler_height <= SCALER_1920_HEIGHT_720;
            end
            default: begin
                scaler_width  <= 0;
                scaler_height <= 0;
            end
        endcase
    end
end


reg frame_vs_prev;      // 用于存储frame_vs的上一个状态
wire frame_vs_rising;   // 用于表示frame_vs的上升沿检测结果

// 在时钟的上升沿进行检测
always @(posedge vin_clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_vs_prev <= 0;       // 复位时将之前状态设为0
    end else begin
        frame_vs_prev <= frame_vs; // 保存当前frame_vs的状态到frame_vs_prev
    end
end

// 检测上升沿：当前frame_vs为1且上一个状态为0时，上升沿有效
assign frame_vs_rising = frame_vs & ~frame_vs_prev;


// 更新输入视频的水平和垂直计数器
always @(posedge vin_clk or negedge rst_n) begin
    if (!rst_n || frame_vs_rising) begin
        vin_x <= 0;
        vin_y <= 0;
    end else if (vin_valid && vout_ready) begin
        if (vin_x < vin_xres - 1)
            vin_x <= vin_x + 1;
        else begin
            vin_x <= 0;
            vin_y <= vin_y + 1;
        end
    end
end

// 更新输出视频的缩放坐标
always @(posedge vin_clk or negedge rst_n) begin
    if (!rst_n || frame_vs_rising) begin
        vout_x <= 0;
        vout_y <= 0;
    end else if (vin_valid && vout_ready) begin
        if (vin_x < vin_xres - 1) begin
            if (vout_x[31:16] <= vin_x)
                vout_x <= vout_x + scaler_width;
        end else begin
            vout_x <= 0;
            if (vout_y[31:16] <= vin_y)
                vout_y <= vout_y + scaler_height;
        end
    end
end

// 临近缩小算法：判断保留像素并输出
always @(posedge vin_clk or negedge rst_n) begin
    if (!rst_n || frame_vs_rising) begin
        vout_dat   <= 0;
        vout_valid <= 0;
    end else if (vout_ready) begin
        if (vout_x[31:16] == vin_x && vout_y[31:16] == vin_y) begin
            vout_valid <= vin_valid; // 设置输出有效
            vout_dat   <= vin_dat;   // 保留该点像素输出
        end else begin
            vout_valid <= 0;         // 置输出无效，舍弃该像素
        end
    end
end

endmodule
