module video_scale_down_near	
(
    input                   vin_clk,
    input                   rst_n,
    input                   frame_sync_n, // 输入视频帧同步复位，低有效
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

//     // 计算缩放比例
// always @(posedge frame_sync_n or negedge rst_n) begin
//     if (!rst_n) begin
//         scaler_width  <= 0;
//         scaler_height <= 0;
//     end else begin
//         scaler_width  <= ((vin_xres * 65536) / vout_xres) + 1;
//         scaler_height <= ((vin_yres * 65536) / vout_yres) + 1;
//     end
// end
// 预定义缩放比例，根据 vin_xres 和 vin_yres 固定为 1024x768
localparam [31:0] SCALER_WIDTH_1024 = ((1024 << 16) / 1024) + 1;
localparam [31:0] SCALER_HEIGHT_768 = ((768 << 16) / 768) + 1;
localparam [31:0] SCALER_WIDTH_640  = ((1024 << 16) / 640) + 1;
localparam [31:0] SCALER_HEIGHT_480 = ((768 << 16) / 480) + 1;
localparam [31:0] SCALER_WIDTH_960  = ((1024 << 16) / 960) + 1;
localparam [31:0] SCALER_HEIGHT_540 = ((768 << 16) / 540) + 1;
localparam [31:0] SCALER_WIDTH_1280 = ((1280 << 16) / 1280) + 1;
localparam [31:0] SCALER_HEIGHT_720 = ((720 << 16) / 720) + 1;

// 使用参数选择固定的缩放比例
always @(posedge frame_sync_n or negedge rst_n) begin
    if (!rst_n) begin
        scaler_width  <= 0;
        scaler_height <= 0;
    end else begin
        case ({vout_xres, vout_yres})
            {16'd1024, 16'd768}: begin
                scaler_width  <= SCALER_WIDTH_1024;
                scaler_height <= SCALER_HEIGHT_768;
            end
            {16'd640, 16'd480}: begin
                scaler_width  <= SCALER_WIDTH_640;
                scaler_height <= SCALER_HEIGHT_480;
            end
            {16'd960, 16'd540}: begin
                scaler_width  <= SCALER_WIDTH_960;
                scaler_height <= SCALER_HEIGHT_540;
            end
            {16'd1280, 16'd720}: begin // 新增对 1280x720 的支持
                scaler_width  <= SCALER_WIDTH_1280;
                scaler_height <= SCALER_HEIGHT_720;
            end
            default: begin
                scaler_width  <= 0;
                scaler_height <= 0;
            end
        endcase
    end
end


    // 更新输入视频的水平和垂直计数器
    always @(posedge vin_clk or negedge rst_n) begin
        if (!rst_n || !frame_sync_n) begin
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
        if (!rst_n || !frame_sync_n) begin
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
        if (!rst_n || !frame_sync_n) begin
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
