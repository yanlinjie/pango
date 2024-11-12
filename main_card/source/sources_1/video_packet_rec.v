module video_packet_rec(
	input rst,
	input rx_clk,
	input[31:0] gt_rx_data/*synthesis PAP_MARK_DEBUG="1"*/,
	input[3:0] gt_rx_ctrl,
	input[15:0] vout_width,
	
	output vs,
	output reg de,
	output[15:0] vout_data
);
reg                    [  31:0]         gt_rx_data_d0              ;
reg                    [   3:0]         gt_rx_ctrl_d0              ;
reg                    [  31:0]         gt_rx_data_d1              ;
reg                    [   3:0]         gt_rx_ctrl_d1              ;
reg                    [  31:0]         gt_rx_data_d2              ;
reg                    [   3:0]         gt_rx_ctrl_d2              ;
reg                                     vs_r/*synthesis PAP_MARK_DEBUG="1"*/                       ;
reg                    [  15:0]         vs_cnt/*synthesis PAP_MARK_DEBUG="1"*/;
always@(posedge rx_clk )
begin
gt_rx_data_d2<=gt_rx_data_d1;
gt_rx_ctrl_d2<=gt_rx_ctrl_d1;
gt_rx_data_d1<=gt_rx_data_d0;
gt_rx_ctrl_d1<=gt_rx_ctrl_d0;
gt_rx_data_d0<=gt_rx_data;
gt_rx_ctrl_d0<=gt_rx_ctrl;
end

always@(posedge rx_clk or posedge rst)
begin
    if(rst)
        vs_cnt <= 16'd0;
    else if(vs_r)
        vs_cnt <= vs_cnt + 16'd1;
    else
        vs_cnt <= 16'd0;
end

//恢复帧同步信号
always@(posedge rx_clk or posedge rst)
begin
	if(rst)
			vs_r <= 1'b0;
	else if(gt_rx_ctrl == 4'b0001 && gt_rx_data == 32'hff_00_01_bc )
	begin
			vs_r <= 1'b1;	
	end    
		else if(vs_cnt > 16'd50)
			vs_r <= 1'b0;
end

reg [127:0] clock_counter/*synthesis PAP_MARK_DEBUG="1"*/ ;     // 用于计时的计数器
reg [127:0] last_interval/*synthesis PAP_MARK_DEBUG="1"*/ ;     // 保存上一次的间隔时钟周期数

always @(posedge rx_clk or posedge rst) 
begin
	if (rst) 
	begin
		// vs_r <= 1'b0;
		clock_counter <= 16'd0;
		last_interval <= 16'd0;
	end 
	else if (gt_rx_ctrl == 4'b0001 && gt_rx_data == 32'hff_00_01_bc) 
	begin
		// vs_r <= 1'b1;
		last_interval <= clock_counter; // 保存当前计数值
		clock_counter <= 16'd0;         // 计数器重置，开始新的周期计数
	end 
	else 
	begin
		// vs_r <= 1'b0;
		clock_counter <= clock_counter + 1; // 增加计数
	end
end


localparam IDLE           = 0;
localparam READ_LINE      = 1;
localparam SEND_LINE_END  = 2;

reg[2:0] state;
reg[15:0] data_cnt/*synthesis PAP_MARK_DEBUG="1"*/;
reg[15:0] wr_cnt;//write data cnt


wire                                    buffer_rd_en/*synthesis PAP_MARK_DEBUG="1"*/;
reg                                     wr_en/*synthesis PAP_MARK_DEBUG="1"*/;
wire                   [  12:0]         rd_data_count/*synthesis PAP_MARK_DEBUG="1"*/;

assign buffer_rd_en = (state == READ_LINE);
assign vs = vs_r;

wire                                    wr_full/*synthesis PAP_MARK_DEBUG="1"*/;
wire                                    rd_empty/*synthesis PAP_MARK_DEBUG="1"*/;

afifo_2048_32i_16o afifo_2048_32i_16o_m0(     
    .wr_clk                            (rx_clk                    ),
    .wr_rst                            (vs_r                      ),
    .wr_en                             (wr_en                     ),
    .wr_data                           (gt_rx_data                ),
    .wr_full                           (wr_full                   ),
    .wr_water_level                    (                          ),
    .almost_full                       (                          ),
    .rd_clk                            (rx_clk                    ),
    .rd_rst                            (vs_r                      ),
    .rd_en                             (buffer_rd_en              ),
    .rd_data                           (vout_data                 ),
    .rd_empty                          (rd_empty                  ),
    .rd_water_level                    (rd_data_count             ),
    .almost_empty                      (                          ) 
	 );

always@(posedge rx_clk)
begin
	de <= buffer_rd_en;
end

//解析行同步信号
always@(posedge rx_clk or posedge rst)
begin
	if(rst)
		wr_en <= 1'b0;
	else if(gt_rx_ctrl == 4'b0001 && gt_rx_data == 32'hff_00_02_bc)
	begin
		wr_en <= 1'b1;
		line_cnt <= line_cnt+1;		
	end
	else if (vs_r) begin
		line_cnt <= 1'b0;
	end
	else if(wr_cnt == ({1'b0,vout_width[15:1]} - 16'd1))
		wr_en <= 1'b0;
		
end

always@(posedge rx_clk or posedge rst)
begin
	if(rst)
		wr_cnt <= 16'd0;
	else if(wr_en) begin
		wr_cnt <= wr_cnt + 16'd1;
		// no_data_cnt <= 16'd0;			
	end
	else begin
		wr_cnt <= 16'd0;
		// no_data_cnt <= no_data_cnt + 16'd1;			
	end

end

always@(posedge rx_clk or posedge rst)
begin
	if(rst) 
		no_data_cnt <= 16'd0;
	else if(wr_en || line_cnt == 15'd1080 || line_cnt == 15'd0) begin
		no_data_cnt <= 16'd0;			
	end
	else begin
		no_data_cnt <= no_data_cnt + 16'd1;			
	end
end

reg[15:0] no_data_cnt/*synthesis PAP_MARK_DEBUG="1"*/;
always@(posedge rx_clk or posedge rst)
begin
	if(rst)
		data_cnt <= 16'd0;
	else if(buffer_rd_en)begin
		data_cnt <= data_cnt + 16'd1;	

	end

	else begin
		data_cnt <= 16'd0;
	
	end

end
reg [15:0]line_cnt/*synthesis PAP_MARK_DEBUG="1"*/;

always@(posedge rx_clk or posedge rst)
begin
	if(rst)
	begin
		state <= IDLE;
		// line_cnt <= 1'b0;
	end
	else
	begin
		case(state)
			IDLE:
			begin
				//if(rd_data_count >= {vout_width[14:0],1'b0})
				if(rd_data_count >= vout_width[15:0])
				// if(~rd_empty)
				begin
					state <= READ_LINE;
					// line_cnt <= line_cnt+1;					
				end

				// else if (vs_r) begin
				// 		line_cnt <= 1'b0;
				// 	end
				else
					state <= IDLE;
			end
			READ_LINE:
			begin
				if(data_cnt == (vout_width[15:0]- 16'd1))
					state <= IDLE;
				else
					state <= READ_LINE;
			end
			
		endcase
	end
end

endmodule 