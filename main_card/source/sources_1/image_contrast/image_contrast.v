//565数据太小，所有先转化成888数据，再处理，再转化成565数据输出
module image_contrast
(
	input	wire			i_clk			, //时钟输入
	input	wire			i_rst_n			, //复位
	
    input  [7:0] hue_cnt,  
	input	wire			i_vs			,
	input	wire			i_de			, //图像有效显示区域
	input	wire	[23:0]	i_data			, //输入RGB图像
	
	output	wire			o_vs			,
	output	wire			o_de			, //图像有效显示区域 
	output	wire	[23:0]	o_data			  //输出8bits的灰度图像
);

//wire or reg define
reg		[23:0]		enhance_data		;


//延时相关变量

reg			vs_r		;
reg			de_r		;
reg			[23:0]	data_r;





reg[8:0]   r_data_d1/*synthesis PAP_MARK_DEBUG="1"*/; ////设定成9位，可以通过判断值是否大于255进行溢出检测
reg[8:0]   g_data_d1/*synthesis PAP_MARK_DEBUG="1"*/;
reg[8:0]   b_data_d1/*synthesis PAP_MARK_DEBUG="1"*/;

wire[7:0]  r_data_reg/*synthesis PAP_MARK_DEBUG="1"*/;
wire[7:0]  g_data_reg/*synthesis PAP_MARK_DEBUG="1"*/;
wire[7:0]  b_data_reg/*synthesis PAP_MARK_DEBUG="1"*/;

// 将RGB565格式的5位红色通道扩展为8位，低位补3个零
// assign r_data_reg = {i_data[15:11], 3'd0}; // 红色扩展至8位
assign r_data_reg = i_data[23:16]; // 红色扩展至8位


// 将RGB565格式的6位绿色通道扩展为8位，低位补2个零
// assign g_data_reg = {i_data[10:5], 2'd0};  // 绿色扩展至8位
assign g_data_reg = i_data[15:8];  // 绿色扩展至8位


// 将RGB565格式的5位蓝色通道扩展为8位，低位补3个零
// assign b_data_reg = {i_data[4:0], 3'd0};   // 蓝色扩展至8位
assign b_data_reg = i_data[7:0];   // 蓝色扩展至8位


// assign pos_data ={r_in,g_in,b_in};

wire [7:0] r_data_hue;
wire [7:0] g_data_hue;
wire [7:0] b_data_hue;


//data_hue作为最后output
assign r_data_hue = (r_data_d1 <= 8'd255) ? r_data_d1[7:0]:'d255;//色相溢出处理
assign g_data_hue = (g_data_d1 <= 8'd255) ? g_data_d1[7:0]:'d255; 
assign b_data_hue = (b_data_d1 <= 8'd255) ? b_data_d1[7:0]:'d255; 

//色相调节，对次高的通道进行调节,在亮度调节后的图像数据进行处理
always @(posedge i_clk) begin

		if ((r_data_reg > g_data_reg) && (g_data_reg > b_data_reg)) begin     //色相调高，对g分量进行+操作
			if ( hue_cnt < 'd100) begin
			    g_data_d1 <= (g_data_reg < ('d100 - hue_cnt)) ? 'd0 : g_data_reg + hue_cnt - 'd100;
	      		r_data_d1 <= r_data_reg ;
		        b_data_d1 <= b_data_reg ;
			end
			else begin
				g_data_d1 <= g_data_reg + hue_cnt - 'd100 ;
	      		r_data_d1 <= r_data_reg ;
		        b_data_d1 <= b_data_reg ;
			end
		end
		else if ((r_data_reg > b_data_reg) && (g_data_reg < b_data_reg)) begin     //色相调高，对b分量进行-操作
			if ( hue_cnt > 'd100) begin
			    b_data_d1 <= (b_data_reg < (hue_cnt - 'b100)) ? 'd0 : b_data_reg - hue_cnt + 'd100;
	      		r_data_d1 <= r_data_reg ;
		        g_data_d1 <= g_data_reg ;

			end
			else begin
				b_data_d1 <= b_data_reg - hue_cnt + 'd100;
	      		r_data_d1 <= r_data_reg ;
		        g_data_d1 <= g_data_reg ;
			end
		end
		else if ((b_data_reg > r_data_reg) && (g_data_reg > b_data_reg)) begin     //色相调高，对b分量进行+操作
			if ( hue_cnt < 'd100) begin
			    b_data_d1 <= (b_data_reg < ('d100 - hue_cnt)) ? 'd0 : b_data_reg + hue_cnt - 'd100;
	      		r_data_d1 <= r_data_reg ;
		        g_data_d1 <= g_data_reg ;
			end
			else begin
				b_data_d1 <= b_data_reg + hue_cnt - 'd100 ;
	      		r_data_d1 <= r_data_reg ;
		        g_data_d1 <= g_data_reg ;
			end
		end
		else if ((b_data_reg > r_data_reg) && (r_data_reg > g_data_reg)) begin     //色相调高，对r分量进行+操作
			if ( hue_cnt < 'd100) begin
			    r_data_d1 <= (r_data_reg < ('d100 - hue_cnt)) ? 'd0 : r_data_reg + hue_cnt - 'd100;
	      		g_data_d1 <= g_data_reg ;
		        b_data_d1 <= b_data_reg ;
			end
			else begin
				r_data_d1 <= r_data_reg + hue_cnt - 'd100 ;
	      		g_data_d1 <= g_data_reg ;
		        b_data_d1 <= b_data_reg ;
			end
		end
		else if ((r_data_reg > b_data_reg) && (r_data_reg < g_data_reg)) begin     //色相调高，对r分量进行-操作
			if ( hue_cnt > 'd100) begin
			    r_data_d1 <= (r_data_reg < (hue_cnt - 'b100)) ? 'd0 : r_data_reg - hue_cnt + 'd100;
	      		g_data_d1 <= g_data_reg ;
		        b_data_d1 <= b_data_reg ;
			end
			else begin
				r_data_d1 <= r_data_reg - hue_cnt + 'd100;
	      		g_data_d1 <= g_data_reg ;
		        b_data_d1 <= b_data_reg ;
			end
		end
		else if ((g_data_reg > r_data_reg) && (g_data_reg < b_data_reg)) begin     //色相调高，对g分量进行-操作
			if ( hue_cnt > 'd100) begin
			    g_data_d1 <= (g_data_reg < (hue_cnt - 'b100)) ? 'd0 : g_data_reg - hue_cnt + 'd100;
	      		r_data_d1 <= r_data_reg ;
		        b_data_d1 <= b_data_reg ;
			end
			else begin
				g_data_d1 <= g_data_reg - hue_cnt + 'd100;
	      		r_data_d1 <= r_data_reg ;
		        b_data_d1 <= b_data_reg ;
			end
		end
		else begin
		    r_data_d1 <= r_data_reg ;
		    g_data_d1 <= g_data_reg ;
		    b_data_d1 <= b_data_reg ;			
		end


end

//视频时序延时
always @(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin 

		vs_r<=1'b0;
		de_r<=1'b0;
		data_r<=23'd0;
	end 
	else begin 
		vs_r<=i_vs;
		de_r<=i_de;
		data_r<=i_data;
	end 
end 

//输出视频时序
//将增强后的 RGB 分量组合成 RGB565 格式
always @(*) begin
	// enhance_data = {r_data_d1[7:3], g_data_d1[7:2], b_data_d1[7:3]};
	enhance_data = {r_data_hue, g_data_hue, b_data_hue};
end
assign o_vs = vs_r;
assign o_de = de_r ;
assign o_data = de_r ? enhance_data : data_r ;

endmodule
