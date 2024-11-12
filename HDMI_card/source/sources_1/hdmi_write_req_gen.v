module hdmi_write_req_gen(
	input              rst,
	input              pclk,
	input              hdmi_vsync,
	output reg         write_req,
	output reg[1:0]    write_addr_index,
	output reg[1:0]    read_addr_index,
	input              write_req_ack
);
reg hdmi_vsync_d0;
reg hdmi_vsync_d1;
always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		hdmi_vsync_d0 <= 1'b0;
		hdmi_vsync_d1 <= 1'b0;
	end
	else
	begin
		hdmi_vsync_d0 <= hdmi_vsync;
		hdmi_vsync_d1 <= hdmi_vsync_d0;
	end
end
always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		write_req <= 1'b0;
	else if(hdmi_vsync_d0 == 1'b1 && hdmi_vsync_d1 == 1'b0)
		write_req <= 1'b1;
	else if(write_req_ack == 1'b1)
		write_req <= 1'b0;
end
always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		write_addr_index <= 2'b0;
	else if(hdmi_vsync_d0 == 1'b1 && hdmi_vsync_d1 == 1'b0)
		write_addr_index <= write_addr_index + 2'd1;
end

always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		read_addr_index <= 2'b0;
	else if(hdmi_vsync_d0 == 1'b1 && hdmi_vsync_d1 == 1'b0)
		read_addr_index <= write_addr_index;
end
endmodule 