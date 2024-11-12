//565数据太小，所有先转化成888数据，再处理，再转化成565数据输出
module image_brightness
(
	input	wire			clk			, //时钟输入
	input	wire			rst_n			, //复位
	

	input	wire			i_vs			, //垂直同步信号
	input	wire			i_de			, //图像有效显示区域
	input	wire	[23:0]	i_data			, //输入RGB565图像
	
	input	wire	[7:0]	brightness_cnt, 


	output	wire			o_vs			, //输出垂直同步信号
	output	wire			o_de			, //输出有效显示区域 
	output	wire	[23:0]	o_data			//输出调节亮度后的RGB565图像
);

//定义变量
reg		[23:0]		enhance_data		; //亮度增强后的数据

//延时相关变量

reg			vs_r		;
reg			de_r		;
reg			[23:0]	data_r;

wire [7:0] r_in;
wire [7:0] g_in;
wire [7:0] b_in;
wire [23:0] pos_data;



assign pos_data =i_data;


// 增强后的红、绿、蓝分量
reg [8:0] r_out;
reg [8:0] g_out;
reg [8:0] b_out;

always@(posedge clk)
begin
		if (brightness_cnt >= 'd100) begin
            r_out <= pos_data[23:16]+brightness_cnt-'d100;
            g_out <= pos_data[15:8]+brightness_cnt-'d100;
            b_out <= pos_data[7:0]+brightness_cnt-'d100; 
		   end
	    else if (brightness_cnt < 'd100) begin
            r_out <= (pos_data[23:16]<(8'd100-brightness_cnt))?8'd0:pos_data[23:16]+brightness_cnt-'d100;
            g_out <= (pos_data[15:8]<(8'd100-brightness_cnt))?8'd0:pos_data[15:8]+brightness_cnt-'d100;
            b_out <= (pos_data[7:0]<(8'd100-brightness_cnt))?8'd0:pos_data[7:0]+brightness_cnt-'d100;  
	      end 
	   	else begin
	        r_out <= pos_data[23:16];
            g_out <= pos_data[15:8];
            b_out <= pos_data[7:0];
	     end  
end

wire [7:0] r_data_reg;
wire [7:0] g_data_reg;
wire [7:0] b_data_reg;

assign r_data_reg = (r_out <= 8'd255) ? r_out[7:0]:'d255;//亮度溢出处理
assign g_data_reg = (g_out <= 8'd255) ? g_out[7:0]:'d255; 
assign b_data_reg = (b_out <= 8'd255) ? b_out[7:0]:'d255; 

//将增强后的 RGB 分量组合成 RGB565 格式
always @(*) begin
	// enhance_data = {r_data_reg[7:3], g_data_reg[7:2], b_data_reg[7:3]};
	enhance_data = {r_data_reg, g_data_reg, b_data_reg};

end

//视频时序信号的延迟处理
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin 
		vs_r   <= 1'b0;
		de_r   <= 1'b0;
		data_r <= 16'd0;
	end else begin 
		vs_r   <= i_vs;
		de_r   <= i_de;
		data_r <= i_data;
	end 
end 

//输出视频时序和增强后的数据

assign o_vs = vs_r;
assign o_de = de_r;
assign o_data = de_r ? enhance_data : data_r; // 在有效显示区域输出增强后的数据

endmodule
