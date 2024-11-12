module video_scale_near_v2
(
    input               vout_clk,
    input               vin_clk,
    input               rst_n,
    input               frame_sync_n,        // 输入视频帧同步复位，低有效
    input       [23:0] vin_dat,             // 输入视频数据
    input               vin_valid,            // 输入视频数据有效
    output reg  [23:0] vout_dat,             // 输出视频数据
    output reg         vout_valid,           // 输出视频数据有效

    input       [15:0] vin_xres,            // 输入视频水平分辨率
    input       [15:0] vin_yres,            // 输入视频垂直分辨率
    input       [15:0] vout_xres,           // 输出视频水平分辨率
    input       [15:0] vout_yres,           // 输出视频垂直分辨率
    output              vin_ready,           // 输入准备好
    input               vout_ready            // 输出准备好
);

    parameter MAX_SCAN_INTERVAL = 2;
    parameter MAX_VIN_INTERVAL = 2;

    reg [31:0] scaler_height;     // 垂直缩放系数，[31:16]高16位是整数，低16位是小数
    reg [31:0] scaler_width;      // 水平缩放系数，[31:16]高16位是整数，低16位是小数
    reg [15:0] scan_cnt_sx;       // 水平扫描计数器，按像素位单位，步长 1 
    reg [15:0] scan_cnt_sy;       // 垂直扫描计数器，按像素位单位，步长 1 
    reg scan_cnt_state;           // 水平扫描状态，1 正在扫描，0 结束扫描
    reg [31:0] scan_sy;           // 垂直扫描计数器，定浮点，按比列因子计数，步长为 scaler_height
    reg [15:0] scan_sy_int;       // 垂直扫描计数器，是 scan_sy 的整数部分 scan_sy_int = scan_sy[31:16]
    reg [31:0] scan_sx;           // 水平扫描计数器，定浮点，按比列因子计数，步长为 scaler_width
    reg [15:0] scan_sx_int;       // 水平扫描计数器，是 scan_sx 的整数部分 scan_sx_int = scan_sx[31:16]
    reg [15:0] scan_sx_int_dx;    // scan_sx_int 延时对齐
    reg [7:0][15:0] scan_sx_int_dly; // scan_sx_int 延时对齐中间寄存器
    reg scan_cnt_state_dx;        // scan_cnt_state 延时对齐
    reg [7:0] scan_cnt_state_dly; // scan_cnt_state 延时对齐中间寄存器
    reg [15:0] scan_cnt_sx_dx;    // scan_cnt_sx 延时对齐
    reg [7:0][15:0] scan_cnt_sx_dly; // scan_cnt_sx 延时对齐中间寄存器
    reg [23:0] fifo_rd_dat;       // FIFO 读数据
    reg fifo_rd_en;               // FIFO 读使能
    reg fifo_rd_empty;            // FIFO 空状态
    reg fifo_rd_valid;            // FIFO 读数据有效
    reg fifo_full;                // FIFO 满
    reg fifo_wr_en;               // FIFO 写使能

    reg [15:0] line_buf_wr_addr;  // LINER_BUF 写地址
    reg [15:0] line_buf_rd_addr;  // LINER_BUF 读地址
    reg line_buf_wen;             // LINER_BUF 写使能
    reg [23:0] line_buf_wr_dat;   // LINER_BUF 写数据
    reg [23:0] line_buf_rd_dat;   // LINER_BUF 读数据

    reg [7:0] line_buf_rd_interval = 0; // LINER_BUF 读扫描间隙
    reg [7:0] line_buf_wr_interval = 0; // LINER_BUF 写扫描间隙
    reg [15:0] vin_sx = 0;        // 视频输入水平计数
    reg [15:0] vin_sy = 0;        // 视频输入垂直计数

    assign vin_ready = ~fifo_full; // fifo_prog_full;

    always @(posedge frame_sync_n) begin
        scaler_height <= ((vin_yres << 16) / vout_yres) + 1; // 视频垂直缩放比例
        scaler_width <= ((vin_xres << 16) / vout_xres) + 1; // 视频水平缩放比例
    end

    // 视频输入 FIFO IP 例化
    assign fifo_wr_en = vin_valid & ~fifo_full;
    assign fifo_rd_en = (line_buf_wr_interval == 0) & (~fifo_rd_empty);    
    assign fifo_rd_valid = fifo_rd_en & (~fifo_rd_empty);

    AFIFO_24_FIRST vin_fifo_u1 ( // vivado IP
        .wr_clk(vin_clk),        // 根据需要，读写时钟可以不同，也可以相同
        .rd_clk(vout_clk),
        .rst(~frame_sync_n | ~rst_n),
        .din(vin_dat),
        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),
        .dout(fifo_rd_dat),
        .full(fifo_full),
        .empty(fifo_rd_empty)
    );

    // LINER_BUF 读写间隙的逻辑控制
    always @(posedge vout_clk) begin
        if (frame_sync_n == 0 || rst_n == 0)
            line_buf_wr_interval <= 0;
        else if (line_buf_wr_interval == 0 && fifo_rd_valid == 1 && vin_sx >= vin_xres - 1)
            line_buf_wr_interval <= MAX_VIN_INTERVAL;
        else if (line_buf_wr_interval != 0 && line_buf_rd_interval != 0 && vin_sy < scan_sy_int)
            line_buf_wr_interval <= line_buf_wr_interval - 1;
        else if (line_buf_wr_interval < MAX_VIN_INTERVAL && line_buf_wr_interval != 0)
            line_buf_wr_interval <= line_buf_wr_interval - 1;
    end

    always @(posedge vout_clk) begin
        if (frame_sync_n == 0 || rst_n == 0)
            line_buf_rd_interval <= 0;
        else if (vout_ready == 1 && line_buf_wr_interval != 0 && scan_cnt_sx >= vin_xres - 1 && scan_cnt_sx >= vout_xres - 1 && scan_cnt_sy < vout_yres)
            line_buf_rd_interval <= MAX_SCAN_INTERVAL;
        else if (vout_ready == 1 && line_buf_rd_interval != 0 && vin_sy >= scan_sy_int)
            line_buf_rd_interval <= line_buf_rd_interval - 1;
        else if (vout_ready == 1 && line_buf_rd_interval < MAX_SCAN_INTERVAL && line_buf_rd_interval != 0)
            line_buf_rd_interval <= line_buf_rd_interval - 1;
    end

    // LINER_BUF 写扫描地址计数
    always @(posedge vout_clk) begin
        if (frame_sync_n == 0 || rst_n == 0)
            vin_sx <= 0;
        else if (fifo_rd_valid == 1) begin
            if (vin_sx < vin_xres - 1)
                vin_sx <= vin_sx + 1;
            else
                vin_sx <= 0;
        end
    end

    always @(posedge vout_clk) begin
        if (frame_sync_n == 0 || rst_n == 0)
            vin_sy <= 0;
        else if (line_buf_wr_interval == 1)
            vin_sy <= vin_sy + 1;
    end

    // 地址扫描部分，这部分是视频缩放的核心部分
    always @(posedge vout_clk) begin
        if (frame_sync_n == 0 || rst_n == 0) begin
            scan_cnt_state <= 0;
            scan_cnt_sx <= 0;
            scan_cnt_sy <= 0;
            scan_sx <= 0;
            scan_sy <= 0;
        end else if (vout_ready == 1) begin
            if (line_buf_rd_interval == 0 && (scan_sx_int + 2 < vin_sx || line_buf_wr_interval != 0) &&
                scan_cnt_sy < vout_yres && (scan_sy_int <= vin_sy || vin_sy >= vin_yres - 1)) begin
                scan_cnt_state <= 1;
                if (scan_cnt_sx < vout_xres - 1 || scan_cnt_sx < vin_xres - 1) begin
                    scan_cnt_sx <= scan_cnt_sx + 1;
                    if (scan_sx_int <= scan_cnt_sx)
                        scan_sx <= scan_sx + scaler_width;
                end else begin
                    scan_cnt_sx <= 0;
                    scan_sx <= 0;
                    scan_cnt_sy <= scan_cnt_sy + 1;
                    scan_sy <= scan_sy + scaler_height;
                end
            end else if (scan_cnt_state == 1 && scan_cnt_sx >= vout_xres - 1 && vin_sy < scan_sy_int) begin
                scan_cnt_state <= 0;
                scan_cnt_sx <= 0;
                scan_cnt_sy <= 0;
                scan_sy <= 0;
                vout_valid <= 0;
            end else if (scan_cnt_state == 0) begin
                scan_cnt_sx <= 0;
                scan_cnt_sy <= 0;
                scan_sy <= 0;
                vout_valid <= 0;
            end
        end
    end

    // LINER_BUF 数据读写
    always @(posedge vout_clk) begin
        if (line_buf_wen == 1) begin
            line_buf_wr_dat <= fifo_rd_dat;
            line_buf_wr_addr <= vin_sx;
        end
    end

    always @(posedge vout_clk) begin
        if (line_buf_rd_interval == 0 && scan_cnt_sx < vout_xres && scan_cnt_sy < vout_yres) begin
            line_buf_rd_addr <= scan_cnt_sx;
            line_buf_rd_dat <= /* 读取 LINER_BUF 数据 */;
            vout_dat <= line_buf_rd_dat;
            vout_valid <= 1;
        end else begin
            vout_valid <= 0;
        end
    end

endmodule
