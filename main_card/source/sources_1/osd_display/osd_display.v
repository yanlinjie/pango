//显示分辨率，和字符字模分辨率为8倍的关系。
module osd_display
#(
	parameter DATA_WIDTH = 16                       // Video data one clock data width
)
(
	input                       rst_n,           // 复位信号，低电平有效
	input                       pclk,            // 像素时钟
	input                       i_hs,            // 输入水平同步信号
	input                       i_vs,            // 输入垂直同步信号
	input                       i_de,            // 输入数据使能信号
	input[15:0]                 i_data,          // 输入视频数据

    input                               wr_clk                     ,
    input                               wr_en                      ,
    input              [  10:0]         wr_addr                    ,
    input              [   7:0]         wr_data                    ,

	output                      o_hs,            // 输出水平同步信号
	output                      o_vs,            // 输出垂直同步信号
	output                      o_de,            // 输出数据使能信号
	output[15:0]                o_data           // 输出视频数据
);

parameter OSD_WIDTH   =  12'd152; // OSD显示区域的宽度
parameter OSD_HEGIHT  =  12'd33;  // OSD显示区域的高度

// 定义信号线和寄存器
wire[11:0] pos_x;                  // 当前像素的X坐标
wire[11:0] pos_y;                  // 当前像素的Y坐标
wire       pos_hs;                 // 当前的水平同步信号
wire       pos_vs;                 // 当前的垂直同步信号
wire       pos_de;                 // 当前的数据使能信号
wire[15:0] pos_data;               // 当前像素的数据
reg[15:0]  v_data;                 // 最终输出的视频数据
reg[11:0]  osd_x;                  // OSD区域的X坐标
reg[11:0]  osd_y;                  // OSD区域的Y坐标
reg[15:0]  osd_ram_addr;           // OSD ROM的地址
wire[7:0]  q;                      // 从OSD ROM读取的字模数据
reg        region_active;          // 标记当前像素是否在OSD区域
reg        region_active_d0;       // OSD区域活动信号的延迟
reg        region_active_d1;
reg        region_active_d2;

reg        pos_vs_d0;              // 垂直同步信号的延迟
reg        pos_vs_d1;

// 将信号分配给输出
assign o_data = v_data;
assign o_hs = pos_hs;
assign o_vs = pos_vs;
assign o_de = pos_de;

// 1个时钟延迟计算OSD区域是否活动
always@(posedge pclk)
begin
	if(pos_y >= 12'd9 && pos_y <= 12'd9 + OSD_HEGIHT - 12'd1 && pos_x >= 12'd9 && pos_x  <= 12'd9 + OSD_WIDTH - 12'd1)
		region_active <= 1'b1;       // 如果在OSD区域内，则region_active为1
	else
		region_active <= 1'b0;       // 否则region_active为0
end

// 延迟OSD区域的活动信号
always@(posedge pclk)
begin
	region_active_d0 <= region_active;
	region_active_d1 <= region_active_d0;
	region_active_d2 <= region_active_d1;
end

// 垂直同步信号延迟
always@(posedge pclk)
begin
	pos_vs_d0 <= pos_vs;
	pos_vs_d1 <= pos_vs_d0;
end

// 控制osd_x计数，用于在OSD区域内横向递增
always@(posedge pclk)
begin
	if(region_active_d0 == 1'b1)
		osd_x <= osd_x + 12'd1;      // 如果在OSD区域内，osd_x递增
	else
		osd_x <= 12'd0;              // 否则重置为0
end

// 控制osd_ram_addr计数，用于访问OSD ROM
always@(posedge pclk)
begin
	if(pos_vs_d1 == 1'b1 && pos_vs_d0 == 1'b0)
		osd_ram_addr <= 16'd0;       // 在新的一帧开始时重置地址
	else if(region_active == 1'b1)
		osd_ram_addr <= osd_ram_addr + 16'd1; // 如果在OSD区域内，osd_ram_addr递增
end

// 设置输出视频数据
always@(posedge pclk)
begin
	if(region_active_d0 == 1'b1)               // 如果在OSD区域
		if(q[osd_x[2:0]] == 1'b1)              // 如果字模数据为1，则显示红色
			v_data <= 16'hF800;
		else
			v_data <= pos_data;                // 否则显示原始视频数据
	else
		v_data <= pos_data;                    // 如果不在OSD区域，显示原始视频数据
end

// // 实例化OSD ROM，存储字模数据
// osd_rom osd_rom_m0 (
//     .addr(osd_ram_addr[15:3]),               // 地址，按位移来读取
//     .clk(pclk),
//     .rst(1'b0),
//     .rd_data(q));                            // 输出读取的字模数据


osd_ram u_osd_ram (
    .wr_data                           (wr_data                   ),// input [7:0]
    .wr_addr                           (wr_addr                   ),// input [10:0]
    .wr_en                             (wr_en                     ),// input
    .wr_clk                            (wr_clk                    ),// input
    .wr_rst                            (1'b0                      ),// input

    .rd_addr                           (osd_ram_addr[15:3]        ),// input [10:0]
    .rd_data                           (q                         ),// output [7:0]
    .rd_clk                            (pclk                      ),// input
    .rd_rst                            (1'b0                      ) // input
);

// 实例化定时生成模块，用于生成X、Y坐标和同步信号
timing_gen_xy#(.DATA_WIDTH(DATA_WIDTH)) timing_gen_xy_m0(
	.rst_n    (rst_n    ),
	.clk      (pclk     ),
	.i_hs     (i_hs     ),
	.i_vs     (i_vs     ),
	.i_de     (i_de     ),
	.i_data   (i_data   ),
	.o_hs     (pos_hs   ),
	.o_vs     (pos_vs   ),
	.o_de     (pos_de   ),
	.o_data   (pos_data ),
	.x        (pos_x    ),
	.y        (pos_y    )
);
endmodule
