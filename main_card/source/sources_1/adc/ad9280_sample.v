module ad9280_sample(
	input                       adc_clk,
	input                       rst,
	input[7:0]                  adc_data,
	input                       adc_data_valid,
	output                      adc_buf_wr,    // 作为输入有效信号
	output[11:0]                adc_buf_addr,
	output[7:0]                 adc_buf_data,  // 输出数据
	output                      last_data_flag // 最后一个数据输出指示信号

	// input wire s_axis_data_tready  
);

//`define TRIGGER

localparam       S_IDLE    = 0;
localparam       S_SAMPLE  = 1;
localparam       S_WAIT    = 2;

reg[7:0] adc_data_d0;
reg[7:0] adc_data_d1;
reg[10:0] sample_cnt/* synthesis PAP_MARK_DEBUG="1" */;
reg[31:0] wait_cnt/* synthesis PAP_MARK_DEBUG="1" */;
reg[2:0] state/* synthesis PAP_MARK_DEBUG="1" */;
reg last_data_flag_reg;   // 用来存储最后一个数据标志信号

assign adc_buf_addr = sample_cnt;
assign adc_buf_data = adc_data_d0;
assign adc_buf_wr = (state == S_SAMPLE && adc_data_valid == 1'b1) ? 1'b1 : 1'b0;
assign last_data_flag = last_data_flag_reg;  // 将寄存器输出给端口

always@(posedge adc_clk or posedge rst)
begin
	if(rst == 1'b1)
		adc_data_d0 <= 8'd0;
	else if(adc_data_valid == 1'b1)
		adc_data_d0 <= adc_data;
end

always@(posedge adc_clk or posedge rst)
begin
	if(rst == 1'b1)
		adc_data_d1 <= 8'd0;
	else if(adc_data_valid == 1'b1)
		adc_data_d1 <= adc_data_d0;
end

always@(posedge adc_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		wait_cnt <= 32'd0;
		sample_cnt <= 11'd0;
		last_data_flag_reg <= 1'b0;  // 重置最后数据标志
        state <= S_IDLE;
	end
	else
		case(state)
			S_IDLE:
			begin
				last_data_flag_reg <= 1'b0;  // 进入采样时重置标志
                state <= S_SAMPLE;
			end
			S_SAMPLE:
			begin
				if(adc_data_valid == 1'b1)
				begin
					if(sample_cnt == 11'd1023)
					begin
						sample_cnt <= 11'd0;
						last_data_flag_reg <= 1'b1;  // 设置最后数据标志
                        state <= S_WAIT;
					end
					else
					begin
						sample_cnt <= sample_cnt + 11'd1;
						last_data_flag_reg <= 1'b0;  // 其他数据时标志为 0
					end
				end
			end		
			S_WAIT:
			begin
				last_data_flag_reg <= 1'b0;  // 其他数据时标志为 0
				sample_cnt <= 11'd0;
				if(wait_cnt == 32'd25_000_000)
				begin
					state <= S_SAMPLE;
					wait_cnt <= 32'd0;
				end
				else
				begin
					wait_cnt <= wait_cnt + 32'd1;
				end				
			end	
			default:
				state <= S_IDLE;
		endcase
end

endmodule
