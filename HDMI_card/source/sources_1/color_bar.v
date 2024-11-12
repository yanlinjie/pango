module color_bar(
    input                 clk,           // pixel clock
    input                 rst,           // reset signal high active
    input  [3:0]          resolution_sel,// 分辨率选择输入
    output                hs,            // horizontal synchronization
    output                vs,            // vertical synchronization
    output                de,            // video valid
    output [7:0]          rgb_r,         // video red data
    output [7:0]          rgb_g,         // video green data
    output [7:0]          rgb_b          // video blue data
);

// 定义视频时序参数寄存器
reg [15:0] H_ACTIVE, H_FP, H_SYNC, H_BP;
reg [15:0] V_ACTIVE, V_FP, V_SYNC, V_BP;
reg HS_POL, VS_POL;

// 根据 `resolution_sel` 选择分辨率参数
always @(*) begin
    case (resolution_sel)
        4'd0: begin // 1280x720  74.25MHz
            H_ACTIVE = 16'd1280;
            H_FP     = 16'd110;
            H_SYNC   = 16'd40;
            H_BP     = 16'd220;
            V_ACTIVE = 16'd720;
            V_FP     = 16'd5;
            V_SYNC   = 16'd5;
            V_BP     = 16'd20;
            HS_POL   = 1'b1;
            VS_POL   = 1'b1;
        end
        4'd1: begin // 480x272  9MHz
            H_ACTIVE = 16'd480;
            H_FP     = 16'd2;
            H_SYNC   = 16'd41;
            H_BP     = 16'd2;
            V_ACTIVE = 16'd272;
            V_FP     = 16'd2;
            V_SYNC   = 16'd10;
            V_BP     = 16'd2;
            HS_POL   = 1'b0;
            VS_POL   = 1'b0;
        end
        4'd2: begin // 640x480  25.175MHz
            H_ACTIVE = 16'd640;
            H_FP     = 16'd16;
            H_SYNC   = 16'd96;
            H_BP     = 16'd48;
            V_ACTIVE = 16'd480;
            V_FP     = 16'd10;
            V_SYNC   = 16'd2;
            V_BP     = 16'd33;
            HS_POL   = 1'b0;
            VS_POL   = 1'b0;
        end
        4'd3: begin // 800x480  33MHz
            H_ACTIVE = 16'd800;
            H_FP     = 16'd40;
            H_SYNC   = 16'd128;
            H_BP     = 16'd88;
            V_ACTIVE = 16'd480;
            V_FP     = 16'd1;
            V_SYNC   = 16'd3;
            V_BP     = 16'd21;
            HS_POL   = 1'b0;
            VS_POL   = 1'b0;
        end
        4'd4: begin // 800x600  40MHz
            H_ACTIVE = 16'd800;
            H_FP     = 16'd40;
            H_SYNC   = 16'd128;
            H_BP     = 16'd88;
            V_ACTIVE = 16'd600;
            V_FP     = 16'd1;
            V_SYNC   = 16'd4;
            V_BP     = 16'd23;
            HS_POL   = 1'b1;
            VS_POL   = 1'b1;
        end
        4'd5: begin // 1024x768  65MHz
            H_ACTIVE = 16'd1024;
            H_FP     = 16'd24;
            H_SYNC   = 16'd136;
            H_BP     = 16'd160;
            V_ACTIVE = 16'd768;
            V_FP     = 16'd3;
            V_SYNC   = 16'd6;
            V_BP     = 16'd29;
            HS_POL   = 1'b0;
            VS_POL   = 1'b0;
        end
        4'd6: begin // 1920x1080  148.5MHz
            H_ACTIVE = 16'd1920;
            H_FP     = 16'd88;
            H_SYNC   = 16'd44;
            H_BP     = 16'd148;
            V_ACTIVE = 16'd1080;
            V_FP     = 16'd4;
            V_SYNC   = 16'd5;
            V_BP     = 16'd36;
            HS_POL   = 1'b1;
            VS_POL   = 1'b1;
        end
        default: begin // 默认值
            H_ACTIVE = 16'd640;
            H_FP     = 16'd16;
            H_SYNC   = 16'd96;
            H_BP     = 16'd48;
            V_ACTIVE = 16'd480;
            V_FP     = 16'd10;
            V_SYNC   = 16'd2;
            V_BP     = 16'd33;
            HS_POL   = 1'b0;
            VS_POL   = 1'b0;
        end
    endcase
end

wire [15:0] H_TOTAL ;
assign H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;
wire [15:0] V_TOTAL ;
assign V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;

//define the RGB values for 8 colors
parameter WHITE_R       = 8'hff;
parameter WHITE_G       = 8'hff;
parameter WHITE_B       = 8'hff;
parameter YELLOW_R      = 8'hff;
parameter YELLOW_G      = 8'hff;
parameter YELLOW_B      = 8'h00;                                
parameter CYAN_R        = 8'h00;
parameter CYAN_G        = 8'hff;
parameter CYAN_B        = 8'hff;                                
parameter GREEN_R       = 8'h00;
parameter GREEN_G       = 8'hff;
parameter GREEN_B       = 8'h00;
parameter MAGENTA_R     = 8'hff;
parameter MAGENTA_G     = 8'h00;
parameter MAGENTA_B     = 8'hff;
parameter RED_R         = 8'hff;
parameter RED_G         = 8'h00;
parameter RED_B         = 8'h00;
parameter BLUE_R        = 8'h00;
parameter BLUE_G        = 8'h00;
parameter BLUE_B        = 8'hff;
parameter BLACK_R       = 8'h00;
parameter BLACK_G       = 8'h00;
parameter BLACK_B       = 8'h00;
reg hs_reg;                      //horizontal sync register
reg vs_reg;                      //vertical sync register
reg hs_reg_d0;                   //delay 1 clock of 'hs_reg'
reg vs_reg_d0;                   //delay 1 clock of 'vs_reg'
reg[11:0] h_cnt;                 //horizontal counter
reg[11:0] v_cnt;                 //vertical counter
reg[11:0] active_x;              //video x position 
reg[11:0] active_y;              //video y position 
reg[7:0] rgb_r_reg;              //video red data register
reg[7:0] rgb_g_reg;              //video green data register
reg[7:0] rgb_b_reg;              //video blue data register
reg h_active;                    //horizontal video active
reg v_active;                    //vertical video active
wire video_active;               //video active(horizontal active and vertical active)
reg video_active_d0;             //delay 1 clock of video_active
assign hs = hs_reg_d0;
assign vs = vs_reg_d0;
assign video_active = h_active & v_active;
assign de = video_active_d0;
assign rgb_r = rgb_r_reg;
assign rgb_g = rgb_g_reg;
assign rgb_b = rgb_b_reg;
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		begin
			hs_reg_d0 <= 1'b0;
			vs_reg_d0 <= 1'b0;
			video_active_d0 <= 1'b0;
		end
	else
		begin
			hs_reg_d0 <= hs_reg;
			vs_reg_d0 <= vs_reg;
			video_active_d0 <= video_active;
		end
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		h_cnt <= 12'd0;
	else if(h_cnt == H_TOTAL - 1)//horizontal counter maximum value
		h_cnt <= 12'd0;
	else
		h_cnt <= h_cnt + 12'd1;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		active_x <= 12'd0;
	else if(h_cnt >= H_FP + H_SYNC + H_BP - 1)//horizontal video active
		active_x <= h_cnt - (H_FP[11:0] + H_SYNC[11:0] + H_BP[11:0] - 12'd1);
	else
		active_x <= active_x;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		v_cnt <= 12'd0;
	else if(h_cnt == H_FP  - 1)//horizontal sync time
		if(v_cnt == V_TOTAL - 1)//vertical counter maximum value
			v_cnt <= 12'd0;
		else
			v_cnt <= v_cnt + 12'd1;
	else
		v_cnt <= v_cnt;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		hs_reg <= 1'b0;
	else if(h_cnt == H_FP - 1)//horizontal sync begin
		hs_reg <= HS_POL;
	else if(h_cnt == H_FP + H_SYNC - 1)//horizontal sync end
		hs_reg <= ~hs_reg;
	else
		hs_reg <= hs_reg;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		h_active <= 1'b0;
	else if(h_cnt == H_FP + H_SYNC + H_BP - 1)//horizontal active begin
		h_active <= 1'b1;
	else if(h_cnt == H_TOTAL - 1)//horizontal active end
		h_active <= 1'b0;
	else
		h_active <= h_active;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		vs_reg <= 1'd0;
	else if((v_cnt == V_FP - 1) && (h_cnt == H_FP - 1))//vertical sync begin
		vs_reg <= HS_POL;
	else if((v_cnt == V_FP + V_SYNC - 1) && (h_cnt == H_FP - 1))//vertical sync end
		vs_reg <= ~vs_reg;  
	else
		vs_reg <= vs_reg;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		v_active <= 1'd0;
	else if((v_cnt == V_FP + V_SYNC + V_BP - 1) && (h_cnt == H_FP - 1))//vertical active begin
		v_active <= 1'b1;
	else if((v_cnt == V_TOTAL - 1) && (h_cnt == H_FP - 1)) //vertical active end
		v_active <= 1'b0;   
	else
		v_active <= v_active;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		begin
			rgb_r_reg <= 8'h00;
			rgb_g_reg <= 8'h00;
			rgb_b_reg <= 8'h00;
		end
	else if(video_active)
		if(active_x == 12'd0)
			begin
				rgb_r_reg <= BLACK_R;
				rgb_g_reg <= BLACK_G;
				rgb_b_reg <= BLACK_B;
			end
		else if(active_x == (H_ACTIVE/8) * 1)
			begin
				rgb_r_reg <= BLACK_R;
				rgb_g_reg <= BLACK_G;
				rgb_b_reg <= BLACK_B;
			end         
		else if(active_x == (H_ACTIVE/8) * 2)
			begin
				rgb_r_reg <= BLACK_R;
				rgb_g_reg <= BLACK_G;
				rgb_b_reg <= BLACK_B;
			end
		else if(active_x == (H_ACTIVE/8) * 3)
			begin
				rgb_r_reg <= BLACK_R;
				rgb_g_reg <= BLACK_G;
				rgb_b_reg <= BLACK_B;
			end
		else if(active_x == (H_ACTIVE/8) * 4)
			begin
				rgb_r_reg <= BLACK_R;
				rgb_g_reg <= BLACK_G;
				rgb_b_reg <= BLACK_B;
			end
		else if(active_x == (H_ACTIVE/8) * 5)
			begin
				rgb_r_reg <= BLACK_R;
				rgb_g_reg <= BLACK_G;
				rgb_b_reg <= BLACK_B;
			end
		else if(active_x == (H_ACTIVE/8) * 6)
			begin
				rgb_r_reg <= BLACK_R;
				rgb_g_reg <= BLACK_G;
				rgb_b_reg <= BLACK_B;
			end 
		else if(active_x == (H_ACTIVE/8) * 7)
			begin
				rgb_r_reg <= BLACK_R;
				rgb_g_reg <= BLACK_G;
				rgb_b_reg <= BLACK_B;
			end
		else
			begin
				rgb_r_reg <= rgb_r_reg;
				rgb_g_reg <= rgb_g_reg;
				rgb_b_reg <= rgb_b_reg;
			end         
	else
		begin
			rgb_r_reg <= 8'h00;
			rgb_g_reg <= 8'h00;
			rgb_b_reg <= 8'h00;
		end
end

endmodule 