module fft_display(
	input                       rst_n,   
	input                       pclk,
	input[23:0]                 spectrum_color, // 频谱颜色
	input                       adc_clk,
	input                       fft_buf_wr/* synthesis PAP_MARK_DEBUG="1" */,     // FFT 数据写使能信号
	input[9:0]                  fft_buf_addr,   // FFT 数据地址
	input[7:0]                 fft_buf_data/* synthesis PAP_MARK_DEBUG="1" */,   // FFT 幅度数据
	input                       i_hs,    
	input                       i_vs,    
	input                       i_de,	
	input[23:0]                 i_data,  
	output                      o_hs,    
	output                      o_vs,    
	output                      o_de,    
	output[23:0]                o_data
);

// 内部信号定义
wire[11:0] pos_x;
wire[11:0] pos_y;
wire       pos_hs;
wire       pos_vs;
wire       pos_de;
wire[23:0] pos_data;
reg[23:0]  v_data;
reg[9:0]   rdaddress;
wire[7:0] q; 
reg        region_active;

assign o_data = v_data;
assign o_hs = pos_hs;
assign o_vs = pos_vs;
assign o_de = pos_de;

// 确定显示频谱的有效区域
always@(posedge pclk)
begin
	if(pos_y >= 12'd308 && pos_y <= 12'd768 && pos_x >= 12'd0 && pos_x  <= 12'd1023)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
end

// 读地址控制，显示区域内时递增地址
always@(posedge pclk)
begin
	if(region_active == 1'b1 && pos_de == 1'b1)
		rdaddress <= rdaddress + 10'd1;
	else
		rdaddress <= 10'd0;
end

// 根据频谱幅度映射 Y 轴，显示频谱颜色
always@(posedge pclk)
begin
	if(region_active == 1'b1)
		if(12'd768 - pos_y <= q)    // 根据 FFT 数据决定 Y 坐标位置
			v_data <= spectrum_color; // 频谱数据颜色
		else
			v_data <= pos_data;       // 背景颜色
	else
		v_data <= pos_data;
end

//双端口 RAM 实例化，用于存储和读取 FFT 幅度数据
dpram1024x8 fft_buffer(
    .wr_data                           (fft_buf_data              ),// FFT 幅度数据
    .wr_addr                           (fft_buf_addr              ),// FFT 数据地址
    .wr_en                             (fft_buf_wr                ),// FFT 数据写使能信号
    .wr_clk                            (adc_clk                   ),// 写时钟
    .wr_rst                            (~rst_n                    ),// 写复位（低电平有效）
    .rd_addr                           (rdaddress                 ),// 读地址
    .rd_data                           (q                         ),// 读取的 FFT 幅度数据
    .rd_clk                            (pclk                      ),// 读时钟
    .rd_rst                            (~rst_n                    ) // 读复位（低电平有效）
);

// 时序生成模块实例化，用于生成当前像素的坐标和同步信号
timing_gen_xy timing_gen_xy_m0(
	.rst_n    (rst_n),              // 复位信号（低电平有效）
	.clk      (pclk),               // 像素时钟
	.i_hs     (i_hs),               // 输入行同步信号
	.i_vs     (i_vs),               // 输入场同步信号
	.i_de     (i_de),               // 输入数据有效信号
	.i_data   (i_data),             // 输入数据
	.o_hs     (pos_hs),             // 输出行同步信号
	.o_vs     (pos_vs),             // 输出场同步信号
	.o_de     (pos_de),             // 输出数据有效信号
	.o_data   (pos_data),           // 输出像素数据
	.x        (pos_x),              // 当前像素的 X 坐标
	.y        (pos_y)               // 当前像素的 Y 坐标
);

endmodule
