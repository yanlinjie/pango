module video_packet_send(
    input                               rst                        ,
    input                               tx_clk                     ,
	
    input                               pclk                       ,
    input                               vs /*synthesis PAP_MARK_DEBUG="1"*/                        ,
    input                               de                         ,
    input              [  15:0]         vin_data                   ,
    input              [  15:0]         vin_width                  ,
	
    output reg         [  31:0]         gt_tx_data                 ,
    output reg         [   3:0]         gt_tx_ctrl                  
);
localparam SEND_FRAME_SYNC0 = 0;
localparam SEND_FRAME_SYNC1 = 1;
localparam SEND_LINE_START  = 2;
localparam SEND_LINE_DATA   = 3;
localparam SEND_LINE_END    = 4;
localparam SEND_OTHER0      = 5;
localparam SEND_OTHER1      = 6;

 reg[31:0] gt_tx_data_d0;
 reg[3:0] gt_tx_ctrl_d0;
reg[2:0] state;
reg[15:0] data_cnt/*synthesis PAP_MARK_DEBUG="1"*/;
reg [15:0] line_cnt/*synthesis PAP_MARK_DEBUG="1"*/;

reg vs_tx_clk_d0;
reg vs_tx_clk_d1;
reg vs_tx_clk_d2;

reg vs_pclk_d0;
reg vs_pclk_d1;
reg vs_pclk_d2;

wire                                    video_frame_sync/*synthesis PAP_MARK_DEBUG="1"*/;
assign video_frame_sync = vs_tx_clk_d1 & ~vs_tx_clk_d2;       //判断ov5640视频图像的列同步信号vs的上升沿

wire                   [  10:0]         rd_data_count/*synthesis PAP_MARK_DEBUG="1"*/;
wire                   [  15:0]         buffer_cnt/*synthesis PAP_MARK_DEBUG="1"*/;
wire                   [  31:0]         buffer_dout/*synthesis PAP_MARK_DEBUG="1"*/;
reg                                     buffer_rd_en/*synthesis PAP_MARK_DEBUG="1"*/;
always@(posedge tx_clk)
begin
	vs_tx_clk_d0 <= vs;
	vs_tx_clk_d1 <= vs_tx_clk_d0;
	vs_tx_clk_d2 <= vs_tx_clk_d1;
end

always@(posedge pclk)
begin
	vs_pclk_d0 <= vs;
	vs_pclk_d1 <= vs_pclk_d0;
	vs_pclk_d2 <= vs_pclk_d1;
end

assign buffer_cnt = {4'd0,rd_data_count[10:0],1'b0};
afifo_4096_16i_32o afifo_4096_16i_32o_m0(
    .wr_clk                            (pclk                      ),
    .wr_rst                            (vs_pclk_d1 & ~vs_pclk_d2  ),
    .wr_en                             (de                        ),
    .wr_data                           (vin_data                  ),
    .wr_full                           (                          ),
    .wr_water_level                    (                          ),
    .almost_full                       (                          ),
    .rd_clk                            (tx_clk                    ),
    .rd_rst                            (vs_pclk_d1 & ~vs_pclk_d2  ),
    .rd_en                             (buffer_rd_en              ),
    .rd_data                           (buffer_dout               ),
    .rd_empty                          (                          ),
    .rd_water_level                    (rd_data_count             ),
    .almost_empty                      (                          ) 
    );

always@(posedge tx_clk or posedge rst)
begin
	if(rst)
	begin
		data_cnt <= 16'd0;
	end
	else if(buffer_rd_en)
		data_cnt <= data_cnt + 16'd1;
	else
		data_cnt <= 16'd0;
end

// 计数器和帧间隔寄存器
reg [127:0] clock_counter/*synthesis PAP_MARK_DEBUG="1"*/ ;      // 用于计数的时钟周期计数器
reg [127:0] last_frame_interval/*synthesis PAP_MARK_DEBUG="1"*/ ; // 用于保存上一次帧间隔的时钟周期数
// reg frame_sync1_detected/*synthesis PAP_MARK_DEBUG="1"*/ ;       // 检测到SEND_FRAME_SYNC1的标志

// reg [15:0] clock_counter;        // 用于计数的时钟周期计数器
// reg [15:0] last_frame_interval;  // 用于保存上一次帧间隔的时钟周期数
reg send_frame_sync1;            // 状态机内的标志，用于指示当前为SEND_FRAME_SYNC1

// 状态机代码
always @(posedge tx_clk or posedge rst)
begin
	if (rst)
	begin
		buffer_rd_en <= 1'b0;
		state <= SEND_OTHER0;
		gt_tx_data <= 32'd0;
		gt_tx_ctrl <= 4'd0;
		send_frame_sync1 <= 1'b0;
	end
	else if (video_frame_sync)
	begin
		line_cnt <= 1'b0;
		state <= SEND_FRAME_SYNC0;
		buffer_rd_en <= 1'b0;
		send_frame_sync1 <= 1'b0;
	end
	else
	begin
		case (state)
			SEND_FRAME_SYNC0:                    //发送视频的帧同步信号0
			begin
				state <= SEND_FRAME_SYNC1;
				gt_tx_data <= 32'hff_00_00_bc;
				gt_tx_ctrl <= 4'b0001;
				send_frame_sync1 <= 1'b0;
			end
			SEND_FRAME_SYNC1:                    //发送视频的帧同步信号1
			begin
				state <= SEND_OTHER0;
				gt_tx_data <= 32'hff_00_01_bc;
				gt_tx_ctrl <= 4'b0001;
				send_frame_sync1 <= 1'b1; // 设置标志，指示进入SEND_FRAME_SYNC1状态
			end
			SEND_OTHER0:                        //发送视频的无用的信号ff_55_55_bc
			begin
				state <= SEND_OTHER1;
				gt_tx_data <= 32'hff_55_55_bc;
				gt_tx_ctrl <= 4'b0001;
				send_frame_sync1 <= 1'b0;
			end
			SEND_OTHER1:                       //发送视频的无用的信号ff_aa_aa_bc
			begin
				if (buffer_cnt >= vin_width)   //判断FIFO中是否有一行的视频图像数据
				begin
					state <= SEND_LINE_START;
					buffer_rd_en <= 1'b1;
					line_cnt <= line_cnt + 1'b1;
				end
				else
				begin
					state <= SEND_OTHER0;
					buffer_rd_en <= 1'b0;
				end
				gt_tx_data <= 32'hbc_aa_aa_bc;
				gt_tx_ctrl <= 4'b1001;
			end
			SEND_LINE_START:               //发送一行数据开始传输信号
			begin
				state <= SEND_LINE_DATA;
				gt_tx_data <= 32'hff_00_02_bc;
				gt_tx_ctrl <= 4'b0001;
				send_frame_sync1 <= 1'b0;
			end
			SEND_LINE_DATA:               //发送FIFO中的一行视频图像数据
			begin
				if (data_cnt == ({1'b0, vin_width[15:1]} - 16'd1))
					buffer_rd_en <= 1'b0;
				if (buffer_rd_en)
				begin
					state <= SEND_LINE_DATA;
					gt_tx_data <= buffer_dout;
					gt_tx_ctrl <= 4'b0000;
				end
				else
				begin
					state <= SEND_LINE_END;
					gt_tx_data <= buffer_dout;
					gt_tx_ctrl <= 4'b0000;
				end				
			end
			SEND_LINE_END:                //发送一行视频图像数据接收信号
			begin
				state <= SEND_OTHER0;
				gt_tx_data <= 32'hff_00_03_bc;
				gt_tx_ctrl <= 4'b0001;
				send_frame_sync1 <= 1'b0;
			end				
		endcase
	end
end

// 计数器逻辑，独立于状态机
always @(posedge tx_clk or posedge rst)
begin
	if (rst)
	begin
		clock_counter <= 16'd0;
		last_frame_interval <= 16'd0;
	end
	else
	begin
		if (send_frame_sync1) // 检测到SEND_FRAME_SYNC1状态
		begin
			last_frame_interval <= clock_counter; // 保存当前计数值为帧间隔
			clock_counter <= 16'd0;               // 重置计数器
		end
		else
		begin
			clock_counter <= clock_counter + 1; // 每个时钟周期递增计数器
		end
	end
end




// always@(posedge tx_clk or posedge rst)
// begin
// 	if(rst)
// 	begin
// 		buffer_rd_en <= 1'b0;
// 		state <= SEND_OTHER0;
// 		gt_tx_data <= 32'd0;
// 		gt_tx_ctrl <= 4'd0;
// 	end
// 	else if(video_frame_sync)
// 	begin
// 		line_cnt <= 1'b0;
// 		state <= SEND_FRAME_SYNC0;
// 		buffer_rd_en <= 1'b0;
// 	end
// 	else
// 	begin
// 		case(state)
// 			SEND_FRAME_SYNC0:                    //发送视频的帧同步信号0
// 			begin
// 				state <= SEND_FRAME_SYNC1;
// 				gt_tx_data <= 32'hff_00_00_bc;
// 				gt_tx_ctrl <= 4'b0001;
// 			end
// 			SEND_FRAME_SYNC1:                    //发送视频的帧同步信号1
// 			begin
// 				state <= SEND_OTHER0;
// 				gt_tx_data <= 32'hff_00_01_bc;
// 				gt_tx_ctrl <= 4'b0001;
// 			end
// 			SEND_OTHER0:                        //发送视频的无用的信号ff_55_55_bc
// 			begin
// 				state <= SEND_OTHER1;
// 				gt_tx_data <= 32'hff_55_55_bc;
// 				gt_tx_ctrl <= 4'b0001;
// 			end
// 			SEND_OTHER1:                       //发送视频的无用的信号ff_aa_aa_bc
// 			begin
// 				if(buffer_cnt >= vin_width)   //判断FIFO中是否有一行的视频图像数据
// 				begin
// 					state <= SEND_LINE_START;
// 					buffer_rd_en <= 1'b1;
// 					line_cnt <= line_cnt + 1'b1;
// 				end
// 				else
// 				begin
// 					state <= SEND_OTHER0;
// 					buffer_rd_en <= 1'b0;
// 				end
// 				gt_tx_data <= 32'hff_aa_aa_bc;
// 				gt_tx_ctrl <= 4'b0000;
// 			end
// 			SEND_LINE_START:               //发送一行数据开始传输信号
// 			begin
// 				state <= SEND_LINE_DATA;
// 				gt_tx_data <= 32'hff_00_02_bc;
// 				gt_tx_ctrl <= 4'b0001;
// 			end
// 			SEND_LINE_DATA:               //发送FIFO中的一行视频图像数据
// 			begin
// 				if(data_cnt == ({1'b0,vin_width[15:1]} - 16'd1))
// 					buffer_rd_en <= 1'b0;
// 				if(buffer_rd_en)
// 				begin
// 					state <= SEND_LINE_DATA;
// 					gt_tx_data <= buffer_dout;
// 					gt_tx_ctrl <= 4'b0000;
// 				end
// 				else
// 				begin
// 					state <= SEND_LINE_END;
// 					gt_tx_data <= buffer_dout;
// 					gt_tx_ctrl <= 4'b0000;
// 				end				
// 			end
// 			SEND_LINE_END:                //发送一行视频图像数据接收信号
// 			begin
// 				state <= SEND_OTHER0;
// 				gt_tx_data <= 32'hff_00_03_bc;
// 				gt_tx_ctrl <= 4'b0001;
// 			end				
// 		endcase
// 	end
// end
endmodule 