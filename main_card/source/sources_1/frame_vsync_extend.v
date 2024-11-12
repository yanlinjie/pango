module frame_vsync_extend
(
    input  wire                 clk                 ,
    input  wire                 rst_n               ,
    
    input  wire                 per_img_vsync       ,
    input  wire                 per_img_href        ,
    input  wire     [15:0]      per_img_gray        ,
    
    output reg                  post_img_vsync      ,
    output wire                 post_img_href       ,
    output wire     [15:0]      post_img_gray
);
//----------------------------------------------------------------------
// 延迟 per_img_vsync 信号
reg                             per_img_vsync_dly;

always @(posedge clk)
begin
    if(rst_n == 1'b0)
        per_img_vsync_dly <= 1'b0;
    else
        per_img_vsync_dly <= per_img_vsync;
end

// 定义延迟计数器
reg             [6:0]           delay_cnt;

always @(posedge clk)
begin
    if(rst_n == 1'b0)
        delay_cnt <= 7'b0;
    else
    begin
        if((per_img_vsync_dly == 1'b1)&&(per_img_vsync == 1'b0))
            delay_cnt <= 7'd127;
        else if(delay_cnt > 7'b0)
            delay_cnt <= delay_cnt - 1'b1;
        else
            delay_cnt <= 7'b0;
    end
end

// 控制 post_img_vsync 输出
always @(posedge clk)
begin
    if(rst_n == 1'b0)
        post_img_vsync <= 1'b0;
    else
    begin
        if((per_img_vsync_dly == 1'b1)||(delay_cnt > 7'b0))
            post_img_vsync <= 1'b1;
        else
            post_img_vsync <= 1'b0;
    end
end

// 实现9位宽度、64位深度的移位寄存器
reg [16:0] shift_reg [63:0];  // 定义64级的17位移位寄存器 (1位href + 16位gray)
integer i;

always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        // 复位时清空移位寄存器
        for (i = 0; i < 64; i = i + 1) begin
            shift_reg[i] <= 17'b0;
        end
    end else begin
        // 移位操作
        for (i = 63; i > 0; i = i - 1) begin
            shift_reg[i] <= shift_reg[i-1];
        end
        // shift_reg[0]存入当前的输入信号
        shift_reg[0] <= {per_img_href, per_img_gray};
    end
end

// 输出信号
assign {post_img_href, post_img_gray} = shift_reg[63];

endmodule
