module top#(
   parameter MEM_ROW_ADDR_WIDTH   = 15  , //@IPC int 13,16
   parameter MEM_COL_ADDR_WIDTH   = 10  , //@IPC int 10,11
   parameter MEM_BADDR_WIDTH      = 3   ,
   parameter MEM_DQ_WIDTH         = 32  ,
   parameter MEM_DM_WIDTH         = MEM_DQ_WIDTH/8,
   parameter MEM_DQS_WIDTH        = MEM_DQ_WIDTH/8,
   parameter CTRL_ADDR_WIDTH      = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH
)(
input                                sys_clk,
input                                rst_n,

   //ADDA
   input    wire  [7:0]ad_data_in/* synthesis PAP_MARK_DEBUG="1" */   ,
   output   wire  ad_clk            ,
   output   wire  da_clk            ,
   output   wire  [7:0]da_data_out/* synthesis PAP_MARK_DEBUG="1" */  , 


//hsst en
    output             [   1:0]         tx_disable     ,

//iic config in3 & out
    output                              iic_scl                    ,
    inout                               iic_sda                    ,
    output                              rstn_out3                  ,

//iic config in1 & in2
    output                              iic_rx_scl                 ,
    inout                               iic_rx_sda                 ,

//ddr 
    output                                 mem_rst_n     ,                       
    output                                 mem_ck        ,
    output                                 mem_ck_n      ,
    output                                 mem_cke       ,
    output                                 mem_cs_n      ,
    output                                 mem_ras_n     ,
    output                                 mem_cas_n     ,
    output                                 mem_we_n      , 
    output                                 mem_odt       ,
    output     [MEM_ROW_ADDR_WIDTH-1:0]    mem_a         ,   
    output     [   MEM_BADDR_WIDTH-1:0]    mem_ba        ,   
    inout      [     MEM_DQS_WIDTH-1:0]    mem_dqs       ,
    inout      [     MEM_DQS_WIDTH-1:0]    mem_dqs_n     ,
    inout      [      MEM_DQ_WIDTH-1:0]    mem_dq        ,
    output     [      MEM_DM_WIDTH-1:0]    mem_dm        ,
    output reg                          heart_beat_led             ,
    output                              ddr_init_done              ,

// //hdmi in
//     input                               pixclk_1_in                ,
//     input                               vs_1_in/* synthesis PAP_MARK_DEBUG="1" */                    ,
//     input                               hs_1_in/* synthesis PAP_MARK_DEBUG="1" */                    ,
//     input                               de_1_in/* synthesis PAP_MARK_DEBUG="1" */                    ,
//     input              [   7:0]         r_1_in                     ,
//     input              [   7:0]         g_1_in                     ,
//     input              [   7:0]         b_1_in                     ,

// //hdmi in
//     input                               pixclk_2_in                ,
//     input                               vs_2_in/* synthesis PAP_MARK_DEBUG="1" */                    ,
//     input                               hs_2_in/* synthesis PAP_MARK_DEBUG="1" */                    ,
//     input                               de_2_in/* synthesis PAP_MARK_DEBUG="1" */                    ,
//     input              [   7:0]         r_2_in                     ,
//     input              [   7:0]         g_2_in                     ,
//     input              [   7:0]         b_2_in                     ,


//hdmi in
    input                               pixclk_3_in                ,
    input                               vs_3_in/* synthesis PAP_MARK_DEBUG="1" */                    ,
    input                               hs_3_in/* synthesis PAP_MARK_DEBUG="1" */                    ,
    input                               de_3_in/* synthesis PAP_MARK_DEBUG="1" */                    ,
    input              [   7:0]         r_3_in                     ,
    input              [   7:0]         g_3_in                     ,
    input              [   7:0]         b_3_in                     ,
//hdmi out
    output                              pixclk_out                 ,
    output                              vs_out/* synthesis PAP_MARK_DEBUG="1" */                     ,
    output                              hs_out/* synthesis PAP_MARK_DEBUG="1" */                     ,
    output                              de_out/* synthesis PAP_MARK_DEBUG="1" */                     ,
    output             [   7:0]         r_out                      ,
    output             [   7:0]         g_out                      ,
    output             [   7:0]         b_out                      ,
    output                              led_int                     
                
);

//hsst en
assign        tx_disable           = 2'b0 ; 
wire [15:0] img_data;
assign img_data = {r_3_in[7:3], g_3_in[7:2], b_3_in[7:3]};
///////////*************模拟一路输入************////////
wire                                    vs_1_in                    ;
wire                                    pixclk_1_in                ;
wire                                    vs_1_in                    ;
wire                                    hs_1_in                    ;
wire                                    de_1_in                    ;
wire            [   7:0]                        r_1_in                     ;
wire             [   7:0]                       g_1_in                     ;
wire            [   7:0]                        b_1_in                     ;

assign pixclk_1_in=pixclk_3_in;
assign vs_1_in = vs_3_in;
assign hs_1_in = hs_3_in;
assign de_1_in = de_3_in;
assign r_1_in = r_3_in;
assign g_1_in = g_3_in;
assign b_1_in = b_3_in;
//////////****************************///////////

///////////*************模拟二路输入************////////
wire                                    vs_2_in                    ;
wire                                    pixclk_2_in                ;
wire                                    vs_2_in                    ;
wire                                    hs_2_in                    ;
wire                                    de_2_in                    ;
wire            [   7:0]                        r_2_in                     ;
wire             [   7:0]                       g_2_in                     ;
wire            [   7:0]                        b_2_in                     ;

assign pixclk_2_in=pixclk_3_in;
assign vs_2_in = vs_3_in;
assign hs_2_in = hs_3_in;
assign de_2_in = de_3_in;
assign r_2_in = r_3_in;
assign g_2_in = g_3_in;
assign b_2_in = b_3_in;
//////////****************************///////////


//////////********模拟四路输入**********///////////
wire                                    vs_4_in                    ;
wire                                    pixclk_4_in                ;
wire                                    vs_4_in                    ;
wire                                    hs_4_in                    ;
wire                                    de_4_in                    ;
wire            [   7:0]                        r_4_in                     ;
wire             [   7:0]                       g_4_in                     ;
wire            [   7:0]                        b_4_in                     ;

assign pixclk_4_in=pixclk_3_in;
assign vs_4_in = vs_3_in;
assign hs_4_in = hs_3_in;
assign de_4_in = de_3_in;
assign r_4_in = r_3_in;
assign g_4_in = g_3_in;
assign b_4_in = b_3_in;

/////////********************////////////






parameter MEM_DATA_BITS          = 256;             //external memory user interface data width
parameter ADDR_BITS              = 25;             //external memory user interface address width
parameter BUSRT_BITS             = 10;             //external memory user interface burst width

wire                            wr_burst_data_req;
wire                            wr_burst_finish;
wire                            rd_burst_finish;
wire                            rd_burst_req;
wire                            wr_burst_req;
wire[BUSRT_BITS - 1:0]          rd_burst_len;
wire[BUSRT_BITS - 1:0]          wr_burst_len;
wire[ADDR_BITS - 1:0]           rd_burst_addr;
wire[ADDR_BITS - 1:0]           wr_burst_addr;
wire                            rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data;



wire                            ch1_wr_burst_data_req;
wire                            ch1_wr_burst_finish;
wire                            ch1_rd_burst_finish;
wire                            ch1_rd_burst_req;
wire                            ch1_wr_burst_req;
wire[BUSRT_BITS - 1:0]          ch1_rd_burst_len;
wire[BUSRT_BITS - 1:0]          ch1_wr_burst_len;
wire[ADDR_BITS - 1:0]           ch1_rd_burst_addr;
wire[ADDR_BITS - 1:0]           ch1_wr_burst_addr;
wire                            ch1_rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     ch1_rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     ch1_wr_burst_data;
wire                            ch1_read_req;
wire                            ch1_read_req_ack;
wire                            ch1_read_en/*synthesis PAP_MARK_DEBUG="1"*/;
wire[15:0]                      ch1_read_data/*synthesis PAP_MARK_DEBUG="1"*/;
wire                            ch1_write_en;
wire[15:0]                      ch1_write_data;
wire                            ch1_write_req;
wire                            ch1_write_req_ack;
wire[1:0]                       ch1_write_addr_index;
wire[1:0]                       ch1_read_addr_index;

wire                            ch2_wr_burst_data_req;
wire                            ch2_wr_burst_finish;
wire                            ch2_rd_burst_finish;
wire                            ch2_rd_burst_req;
wire                            ch2_wr_burst_req;
wire[BUSRT_BITS - 1:0]          ch2_rd_burst_len;
wire[BUSRT_BITS - 1:0]          ch2_wr_burst_len;
wire[ADDR_BITS - 1:0]           ch2_rd_burst_addr;
wire[ADDR_BITS - 1:0]           ch2_wr_burst_addr;
wire                            ch2_rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     ch2_rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     ch2_wr_burst_data;
wire                            ch2_read_req;
wire                            ch2_read_req_ack;
wire                            ch2_read_en/*synthesis PAP_MARK_DEBUG="1"*/;
wire[15:0]                      ch2_read_data/*synthesis PAP_MARK_DEBUG="1"*/;
wire                            ch2_write_en;
wire[15:0]                      ch2_write_data;
wire                            ch2_write_req;
wire                            ch2_write_req_ack;
wire[1:0]                       ch2_write_addr_index;
wire[1:0]                       ch2_read_addr_index;

wire                            ch3_wr_burst_data_req;
wire                            ch3_wr_burst_finish;
wire                            ch3_rd_burst_finish;
wire                            ch3_rd_burst_req;
wire                            ch3_wr_burst_req;
wire[BUSRT_BITS - 1:0]          ch3_rd_burst_len;
wire[BUSRT_BITS - 1:0]          ch3_wr_burst_len;
wire[ADDR_BITS - 1:0]           ch3_rd_burst_addr;
wire[ADDR_BITS - 1:0]           ch3_wr_burst_addr;
wire                            ch3_rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     ch3_rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     ch3_wr_burst_data;
wire                            ch3_read_req;
wire                            ch3_read_req_ack;
wire                            ch3_read_en;
wire[15:0]                      ch3_read_data;
wire                            ch3_write_en;
wire[15:0]                      ch3_write_data;
wire                            ch3_write_req;
wire                            ch3_write_req_ack;
wire[1:0]                       ch3_write_addr_index;
wire[1:0]                       ch3_read_addr_index;

wire                            ch4_wr_burst_data_req;
wire                            ch4_wr_burst_finish;
wire                            ch4_rd_burst_finish;
wire                            ch4_rd_burst_req;
wire                            ch4_wr_burst_req;
wire[BUSRT_BITS - 1:0]          ch4_rd_burst_len;
wire[BUSRT_BITS - 1:0]          ch4_wr_burst_len;
wire[ADDR_BITS - 1:0]           ch4_rd_burst_addr;
wire[ADDR_BITS - 1:0]           ch4_wr_burst_addr;
wire                            ch4_rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     ch4_rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     ch4_wr_burst_data;
wire                            ch4_read_req;
wire                            ch4_read_req_ack;
wire                            ch4_read_en;
wire[15:0]                      ch4_read_data;
wire                            ch4_write_en;
wire[15:0]                      ch4_write_data;
wire                            ch4_write_req;
wire                            ch4_write_req_ack;
wire[1:0]                       ch4_write_addr_index;
wire[1:0]                       ch4_read_addr_index;

wire resize_out;

//HDMI输出
wire                            video_clk;                 //video pixel clock
wire                            hs;
wire                            vs;
wire                            de;
wire[15:0]                      vout_data;



//***************ddr3不需要改动*************//
wire                            ui_clk;
// Master Write Address
wire [3:0]                      s00_axi_awid;
wire [63:0]                     s00_axi_awaddr;
wire [7:0]                      s00_axi_awlen;    // burst length: 0-255
wire [2:0]                      s00_axi_awsize;   // burst size: fixed 2'b011
wire [1:0]                      s00_axi_awburst;  // burst type: fixed 2'b01(incremental burst)
wire                            s00_axi_awlock;   // lock: fixed 2'b00
wire [3:0]                      s00_axi_awcache;  // cache: fiex 2'b0011
wire [2:0]                      s00_axi_awprot;   // protect: fixed 2'b000
wire [3:0]                      s00_axi_awqos;    // qos: fixed 2'b0000
wire [0:0]                      s00_axi_awuser;   // user: fixed 32'd0
wire                            s00_axi_awvalid;
wire                            s00_axi_awready;
// master write data
wire [MEM_DATA_BITS - 1 : 0]    s00_axi_wdata;
wire [MEM_DATA_BITS/8 - 1:0]    s00_axi_wstrb;
wire                            s00_axi_wlast;
wire [0:0]                      s00_axi_wuser;
wire                            s00_axi_wvalid;
wire                            s00_axi_wready;
// master write response
wire [3:0]                      s00_axi_bid;
wire [1:0]                      s00_axi_bresp;
wire [0:0]                      s00_axi_buser;
wire                            s00_axi_bvalid;
wire                            s00_axi_bready;
// master read address
wire [3:0]                      s00_axi_arid;
wire [63:0]                     s00_axi_araddr;
wire [7:0]                      s00_axi_arlen;
wire [2:0]                      s00_axi_arsize;
wire [1:0]                      s00_axi_arburst;
wire [1:0]                      s00_axi_arlock;
wire [3:0]                      s00_axi_arcache;
wire [2:0]                      s00_axi_arprot;
wire [3:0]                      s00_axi_arqos;
wire [0:0]                      s00_axi_aruser;
wire                            s00_axi_arvalid;
wire                            s00_axi_arready;
// master read data
wire [3:0]                      s00_axi_rid;
wire [MEM_DATA_BITS - 1 : 0]    s00_axi_rdata;
wire [1:0]                      s00_axi_rresp;
wire                            s00_axi_rlast;
wire [0:0]                      s00_axi_ruser;
wire                            s00_axi_rvalid;
wire                            s00_axi_rready;
/////////********************//////////


//最后的输出
// assign pixclk_out =video_clk;//输出视频时钟
// assign  hs_out    = hs;
// assign  vs_out     = vs;
// assign  de_out    = de;
// assign r_out      = {vout_data[15:11], vout_data[15:13]};
// assign g_out      = {vout_data[10:5], vout_data[10:9]};  
// assign b_out      = {vout_data[4:0], vout_data[4:2]};    


wire hdmi_de_4/*synthesis PAP_MARK_DEBUG="1"*/;
wire [15:0] rgb565_data_4/*synthesis PAP_MARK_DEBUG="1"*/;
assign ch4_write_en = hdmi_de_4;
assign ch4_write_data = rgb565_data_4;

wire hdmi_de_3/*synthesis PAP_MARK_DEBUG="1"*/;
wire [15:0] rgb565_data_3/*synthesis PAP_MARK_DEBUG="1"*/;
assign ch3_write_en = hdmi_de_3;
assign ch3_write_data = rgb565_data_3;


wire hdmi_de_2/*synthesis PAP_MARK_DEBUG="1"*/;
wire [15:0] rgb565_data_2/*synthesis PAP_MARK_DEBUG="1"*/;
assign ch2_write_en = hdmi_de_2;
assign ch2_write_data = rgb565_data_2;

wire hdmi_de_1/*synthesis PAP_MARK_DEBUG="1"*/;
wire [15:0] rgb565_data_1/*synthesis PAP_MARK_DEBUG="1"*/;
assign ch1_write_en = hdmi_de_1;
assign ch1_write_data = rgb565_data_1;




video_pll video_pll_m0
(
    .clkin1                            (sys_clk                   ),
    .clkout0                           (cfg_clk                   ),
    .clkout1                           (video_clk                 ),//作为输出视频时钟
    .clkout2                           (resize_out                ),
    .pll_rst                           (1'b0                      ),
    .pll_lock                          (locked                    ) 
);




wire vs_4;
wire clk_out_4;
reg [7:0] brightness_ctr_4 = 8'd100;
reg [7:0] hue_ctr_4 = 8'd100;
reg ctr_4 = 1'b0;
reg [15:0] Width_in_4 = 15'd1920;//输入视频分辨率
reg [15:0] Height_in_4 = 15'd1080;
wire [15:0] Width_out_4;//输出视频分辨率
wire [15:0] Height_out_4;

assign Width_out_4 = width_m4;
assign Height_out_4 = height_m4;

//视频4输入（右下）
hdmi_data_in u_hdmi_data_in_4(

    .pix_clk                           (pixclk_4_in               ),// input                                pix_clk,        // 输入像素时钟信号
    .rst_n                             (rst_n                     ),
    .resize_out                        (resize_out                ),

    .ctr                               (1'b0                      ),
    .brightness_ctr                    (brightness_ctr_4          ),
    .hue_ctr                           (hue_ctr_4                 ),
    .vs_in                             (vs_4_in                   ),// input                                vs_in,          // 输入垂直同步信号
    .hs_in                             (hs_4_in                   ),// input                                hs_in,          // 输入水平同步信号
    .de_in                             (de_4_in                   ),// input                                de_in,          // 输入数据使能信号
    .r_in                              (r_4_in                    ),// input     [7:0]                      r_in, 
    .g_in                              (g_4_in                    ),// input     [7:0]                      g_in, 
    .b_in                              (b_4_in                    ),// input     [7:0]                      b_in, 


    .clk_out                           (clk_out_4                 ),
    .vs_out                            (vs_4                      ),// output reg                           vs_out,         // 输出垂直同步信号
    .de_out                            (hdmi_de_4                 ),// output reg                           de_out,         // 输出数据使能信号
    .rgb565_out                        (rgb565_data_4             ),
    .Width_in                          (Width_in_4                ),
    .Height_in                         (Height_in_4               ),

    .Width_out                         (Width_out_4               ),
    .Height_out                        (Height_out_4              ) 
);

// reg timer_done;
//     // 计数器寄存器定义
// reg [26:0] counter;
// reg [2:0]flag;
//     // 参数定义，2秒对应的计数值
//     localparam COUNT_2S = 27'd100_000_000;

//     always @(posedge sys_clk   ) begin
// 		if (counter == COUNT_2S) begin
//             // 当计数器达到 100,000,000 时，将完成标志置1，表示定时结束
//             timer_done <= 1'b1;
//             counter <= 27'd0; // 重置计数器以便下次计时
// 			flag = flag + 1;
//         end else begin
//             // 每个时钟周期计数器加1
//             counter <= counter + 1;
//             timer_done <= 1'b0;
//         end
//     end

// reg [15:0]width_m33 ;
// reg [15:0]height_m33 ;
// always @(posedge sys_clk) begin
// 	if (flag == 1) begin
// 		width_m33<= 15'd640;
// 		height_m33<=15'd480;
// 	end else if (flag == 2) begin
// 		width_m33<= 15'd1024;
// 		height_m33<=15'd768;
// 	end else if (flag == 3) begin
// 		width_m33<= 15'd960;
// 		height_m33<=15'd540;
// 	end else if (flag == 4) begin
// 		width_m33<= 15'd0;
// 		height_m33<=15'd0;
// 	end 
// 	else begin
// 		width_m33 <= 15'd1920;
// 		height_m33<=15'd1080;
// 	end
// end

wire vs_3;
wire clk_out_3;
reg [7:0] brightness_ctr_3 = 8'd100;
reg [7:0] hue_ctr_3 = 8'd100;
reg ctr_3 = 1'b0;
reg [15:0] Width_in_3 = 15'd1920;//输入视频分辨率
reg [15:0] Height_in_3 = 15'd1080;
wire [15:0] Width_out_3;//输出视频分辨率
wire [15:0] Height_out_3;

assign Width_out_3 = width_m3;
assign Height_out_3 = height_m3;

//视频3输入（左上）
hdmi_data_in u_hdmi_data_in_3(

    .pix_clk                           (pixclk_3_in               ),// input                                pix_clk,        // 输入像素时钟信号
    .rst_n                             (rst_n                     ),
    .resize_out                        (resize_out                ),


    .ctr                               (1'b0                      ),
    .brightness_ctr                    (brightness_ctr_3          ),
    .hue_ctr                           (hue_ctr_3                 ),
    .vs_in                             (vs_3_in                   ),// input                                vs_in,          // 输入垂直同步信号
    .hs_in                             (hs_3_in                   ),// input                                hs_in,          // 输入水平同步信号
    .de_in                             (de_3_in                   ),// input                                de_in,          // 输入数据使能信号
    .r_in                              (r_3_in                    ),// input     [7:0]                      r_in, 
    .g_in                              (g_3_in                    ),// input     [7:0]                      g_in, 
    .b_in                              (b_3_in                    ),// input     [7:0]                      b_in, 
    
    .clk_out                           (clk_out_3                 ),
    .vs_out                            (vs_3                      ),
    .de_out                            (hdmi_de_3                 ),// output reg                           de_out,         // 输出数据使能信号
    .rgb565_out                        (rgb565_data_3             ),
    .Width_in                          (Width_in_3                ),
    .Height_in                         (Height_in_3               ),

    .Width_out                         (Width_out_3               ),
    .Height_out                        (Height_out_3              ) 
);


wire vs_2;
wire clk_out_2;
reg [7:0] brightness_ctr_2 = 8'd100;
reg [7:0] hue_ctr_2 = 8'd100;
reg ctr_2 = 1'b0;
reg [15:0] Width_in_2 = 15'd1920;//输入视频分辨率
reg [15:0] Height_in_2 = 15'd1080;
wire [15:0] Width_out_2;//输出视频分辨率
wire [15:0] Height_out_2;

assign Width_out_2 = width_m2;
assign Height_out_2 = height_m2;
//视频2输入(左下)
hdmi_data_in u_hdmi_data_in_2(

    .pix_clk                           (pixclk_2_in               ),// input 
    .rst_n                             (rst_n                     ),
    .resize_out                        (resize_out                ),

    .ctr                               (1'b0                      ),
    .brightness_ctr                    (brightness_ctr_2          ),
    .hue_ctr                           (hue_ctr_2                 ),
    .vs_in                             (vs_2_in                   ),// input                                vs_in,          // 输入垂直同步信号
    .hs_in                             (hs_2_in                   ),// input                                hs_in,          // 输入水平同步信号
    .de_in                             (de_2_in                   ),// input                                de_in,          // 输入数据使能信号
    .r_in                              (r_2_in                    ),// input     [7:0]                      r_in, 
    .g_in                              (g_2_in                    ),// input     [7:0]                      g_in, 
    .b_in                              (b_2_in                    ),// input     [7:0]                      b_in, 
    
    .clk_out                           (clk_out_2                 ),
    .vs_out                            (vs_2                      ),
    .de_out                            (hdmi_de_2                 ),// output reg                           de_out,         // 输出数据使能信号
    .rgb565_out                        (rgb565_data_2             ),
	
    .Width_in                          (Width_in_2                ),
    .Height_in                         (Height_in_2               ),

    .Width_out                         (Width_out_2               ),
    .Height_out                        (Height_out_2              ) 
);


wire vs_1;
wire clk_out_1;
reg [7:0] brightness_ctr_1 = 8'd100;
reg [7:0] hue_ctr_1 = 8'd100;
reg ctr_1 = 1'b0;
reg [15:0] Width_in_1 = 15'd1920;//输入视频分辨率
reg [15:0] Height_in_1 = 15'd1080;
wire [15:0] Width_out_1;//输出视频分辨率
wire [15:0] Height_out_1;

assign Width_out_1 = width_m1;
assign Height_out_1 = height_m1;
//视频1输入(右上)
hdmi_data_in u_hdmi_data_in_1(

    .pix_clk                           (pixclk_1_in               ),// input
    .rst_n                             (rst_n                     ),
    .resize_out                        (resize_out                ),

    .ctr                               (1'b0                      ),
    .brightness_ctr                    (brightness_ctr_1          ),
    .hue_ctr                           (hue_ctr_1                 ),
    .vs_in                             (vs_1_in                   ),// input                                vs_in,          // 输入垂直同步信号
    .hs_in                             (hs_1_in                   ),// input                                hs_in,          // 输入水平同步信号
    .de_in                             (de_1_in                   ),// input                                de_in,          // 输入数据使能信号
    .r_in                              (r_1_in                    ),// input     [7:0]                      r_in, 
    .g_in                              (g_1_in                    ),// input     [7:0]                      g_in, 
    .b_in                              (b_1_in                    ),// input     [7:0]                      b_in, 
    
    .clk_out                           (clk_out_1                 ),
    .vs_out                            (vs_1                      ),// output reg                           vs_out,         // 输出垂直同步信号
    .de_out                            (hdmi_de_1                 ),// output reg                           de_out,         // 输出数据使能信号
    .rgb565_out                        (rgb565_data_1             ),

    .Width_in                          (Width_in_1                ),
    .Height_in                         (Height_in_1               ),

    .Width_out                         (Width_out_1               ),
    .Height_out                        (Height_out_1              ) 
);

hdmi_write_req_gen hdmi_write_req_gen_m4(
    .rst                               (~rst_n                    ),
    .pclk                              (clk_out_4               ),
    .hdmi_vsync                        (vs_4                   ),
    .write_req                         (ch4_write_req             ),
    .write_addr_index                  (ch4_write_addr_index      ),
    .read_addr_index                   (ch4_read_addr_index       ),
    .write_req_ack                     (ch4_write_req_ack         ) 
);

hdmi_write_req_gen hdmi_write_req_gen_m3(
    .rst                               (~rst_n                    ),
    .pclk                              (clk_out_3                ),
    .hdmi_vsync                        (vs_3                      ),
    .write_req                         (ch3_write_req             ),
    .write_addr_index                  (ch3_write_addr_index      ),
    .read_addr_index                   (ch3_read_addr_index       ),
    .write_req_ack                     (ch3_write_req_ack         ) 
);

hdmi_write_req_gen hdmi_write_req_gen_m2(
    .rst                               (~rst_n                    ),
    .pclk                              (clk_out_2               ),
    .hdmi_vsync                        (vs_2                   ),
    .write_req                         (ch2_write_req             ),
    .write_addr_index                  (ch2_write_addr_index      ),
    .read_addr_index                   (ch2_read_addr_index       ),
    .write_req_ack                     (ch2_write_req_ack         ) 
);

hdmi_write_req_gen hdmi_write_req_gen_m1(
    .rst                               (~rst_n                    ),
    .pclk                              (clk_out_1               ),
    .hdmi_vsync                        (vs_1                   ),
    .write_req                         (ch1_write_req             ),
    .write_addr_index                  (ch1_write_addr_index      ),
    .read_addr_index                   (ch1_read_addr_index       ),
    .write_req_ack                     (ch1_write_req_ack         ) 
);

wire                        color_bar_hs;
wire                        color_bar_vs;
wire                        color_bar_de;
wire[7:0]                   color_bar_r;
wire[7:0]                   color_bar_g;
wire[7:0]                   color_bar_b;


wire                        v2_hs;
wire                        v2_vs;
wire                        v2_de;
wire[23:0]                  v2_data;

wire                        v3_hs;
wire                        v3_vs;
wire                        v3_de;
wire[23:0]                  v3_data;

wire                        v4_hs;
wire                        v4_vs;
wire                        v4_de;
wire[23:0]                  v4_data;


///////****************hsst data send  video***********/////////
wire [15:0] rgb565_data;
assign rgb565_data = vout_data;  // 将8位的RGB转换为RGB565格式

wire                                    tx_clk                     ;
// wire                                    o_p_clk2core_tx_2          ;
wire                   [   3:0]         i_txk_3                    ;
wire                   [  31:0]         i_txd_3                    ;
wire                   [  31:0]         gt_tx_data /*synthesis PAP_MARK_DEBUG="1"*/                ;//send sfp3  
wire                   [   3:0]         gt_tx_ctrl /*synthesis PAP_MARK_DEBUG="1"*/                ;

assign tx_clk = o_p_clk2core_tx_3;

video_packet_send video_packet_send_m0
(
    .rst                               (~rst_n                    ),
    .tx_clk                            (tx_clk                    ),
	
    .pclk                              (video_clk                 ),
    .vs                                (vs                     ),
    .de                                (de                     ),
    .vin_data                          (rgb565_data               ),
    .vin_width                         (16'd1920                  ),//16'd1280,16'd1920
	
    .gt_tx_data                        (gt_tx_data                ),
    .gt_tx_ctrl                        (gt_tx_ctrl                ) 
);


assign i_txd_3 = gt_tx_data;
assign i_txk_3 = gt_tx_ctrl;


///////****************hsst data receive to control video***********/////////
//左上
reg [15:0] width_m3 = 15'd960; 
reg [15:0] height_m3= 15'd540;


//左下
reg [15:0] width_m2= 15'd960; 
reg [15:0] height_m2 = 15'd540;
//右上
reg [15:0] width_m1= 15'd960;  
reg [15:0] height_m1 = 15'd540; 
//右下
reg [15:0] width_m4= 15'd960; 
reg [15:0] height_m4 = 15'd540; 

//32位数据对齐模块
wire rx3_clk;
// wire o_p_clk2core_tx_2;

wire [31:0] o_rxd_3/* synthesis PAP_MARK_DEBUG="true" */;
wire [3:0]o_rxk_3/* synthesis PAP_MARK_DEBUG="true" */;

wire[31:0] rx_data_align/* synthesis PAP_MARK_DEBUG="true" */ ;
wire[3:0] rx_ctrl_align/* synthesis PAP_MARK_DEBUG="true" */ ;

reg [4:0] show_flag;

assign rx3_clk = o_p_clk2core_rx_3;

word_align word_align_m0
(
    .rst                        (1'b0                    ),
    .rx_clk                     (rx3_clk                  ),
    .gt_rx_data                 (o_rxd_3                 ),
    .gt_rx_ctrl                 (o_rxk_3                ),
    .rx_data_align              (rx_data_align           ),
    .rx_ctrl_align              (rx_ctrl_align           )
);

wire select_wave0;
assign select_wave0 = (rx_data_align[7:0] == 8'd6 && rx_data_align[15:8] == 8'd4);


// assign hs_out = wave0_hs;
// assign vs_out = wave0_vs;
// assign de_out = wave0_de;
// assign r_out  = wave0_r;
// assign g_out  = wave0_g;
// assign b_out  = wave0_b;
// assign pixclk_out = video_clk_adc;

// 根据条件选择 pixclk_out 输出时钟
assign pixclk_out = (select_wave0) ? video_clk_adc : video_clk;

// 根据条件选择 RGB 数据输出
assign r_out = (select_wave0) ? wave0_r : {vout_data[15:11], vout_data[15:13]};
assign g_out = (select_wave0) ? wave0_g : {vout_data[10:5], vout_data[10:9]};  
assign b_out = (select_wave0) ? wave0_b : {vout_data[4:0], vout_data[4:2]}; 

assign hs_out = (select_wave0) ? wave0_hs : hs;
assign vs_out = (select_wave0) ? wave0_vs : vs;
assign de_out = (select_wave0) ? wave0_de : de;


always @(posedge rx3_clk) begin
	if (rx_ctrl_align == 4'd0 && rx_data_align[15:8] == 8'd1) begin
		brightness_ctr_1 <= rx_data_align[7:0];
		brightness_ctr_2 <= rx_data_align[7:0];
		brightness_ctr_3 <= rx_data_align[7:0];
		brightness_ctr_4 <= rx_data_align[7:0];
	end
end

always @(posedge rx3_clk) begin
	if (rx_ctrl_align == 4'd0 && rx_data_align[15:8] == 8'd2) begin
		hue_ctr_1 <= rx_data_align[7:0];
		hue_ctr_2 <= rx_data_align[7:0];
		hue_ctr_3 <= rx_data_align[7:0];
		hue_ctr_4 <= rx_data_align[7:0];
	end
end

reg [15:0] Width_show = 15'd960;
reg [15:0] Height_show = 15'd540;
always @(posedge rx3_clk) begin
    if (rx_ctrl_align == 4'd0 && rx_data_align[15:8] == 8'd3) begin
		case (rx_data_align[7:0])
			8'd1: begin
				Width_show <= 15'd1024;
				Height_show <= 15'd768;
			end
			8'd2: begin
				Width_show <= 15'd640;
				Height_show <= 15'd480;
			end
			8'd3: begin
				Width_show <= 15'd960;
				Height_show <= 15'd540;
			end
			8'd4: begin
				Width_show <= 15'd1920;
				Height_show <= 15'd1080;
			end
			default: begin
				Width_show <= Width_show; // 保持当前分辨率
				Height_show <= Height_show;
			end
		endcase
	end
	// else if (rx_ctrl_align == 4'd0 && rx_data_align[15:8]== 8'd0) begin
	// 		Width_show <= 15'd960; // 保持当前分辨率
	// 		Height_show <= 15'd540;
	// end
end

reg [7:0] update_flag;

always @(posedge rx3_clk) begin
	if (rx_ctrl_align == 4'd0 && rx_data_align[15:8]== 8'd0) begin
		case (rx_data_align[7:0])
			8'd1: begin
				// 预览模式，所有窗口相同分辨率
				width_m1 <= 12'd960;
				height_m1 <= 12'd540;
				width_m2 <= 12'd960;
				height_m2 <= 12'd540;
				width_m3 <= 12'd960;
				height_m3 <= 12'd540;
				update_flag <= 8'd0;
				// width_m4 <= 12'd960;
				// height_m4 <= 12'd540;
			end
			8'd2: begin   //show 左上
				width_m1 <= 12'd0;
				height_m1 <= 12'd0;
				width_m2 <= 12'd0;
				height_m2 <= 12'd0;
				width_m3 <= Width_show;
				height_m3 <= Height_show;
				// width_m4 <= 12'd0;
				// height_m4 <= 12'd0;

				update_flag <= 8'd3;
			end
			8'd3: begin
				width_m1 <= Width_show;
				height_m1 <= Height_show;
				width_m2 <= 12'd0;
				height_m2 <= 12'd0;
				width_m3 <= 12'd0;
				height_m3 <= 12'd0;
				// width_m4 <= 12'd0;
				// height_m4 <= 12'd0;

				update_flag <= 8'd1;
			end
			8'd4: begin
				width_m1 <= 12'd0;
				height_m1 <= 12'd0;
				width_m2 <= Width_show;
				height_m2 <= Height_show;
				width_m3 <= 12'd0;
				height_m3 <= 12'd0;
				// width_m4 <= 12'd0;
				// height_m4 <= 12'd0;

				update_flag <= 8'd2;
			end
			8'd5: begin
				width_m1 <= 12'd0;
				height_m1 <= 12'd0;
				width_m2 <= 12'd0;
				height_m2 <= 12'd0;
				width_m3 <= 12'd0;
				height_m3 <= 12'd0;
				width_m4 <= 12'd960;
				height_m4 <= 12'd540;
				update_flag <= 8'd0;
			end
			8'd6: begin           //拼接部分(左上，和右上)
				width_m1 <= 12'd960;
				height_m1 <= 12'd540;
				width_m2 <= 12'd0;
				height_m2 <= 12'd0;
				width_m3 <= 12'd960;
				height_m3 <= 12'd540;

				update_flag <= 8'd0;
				// width_m4 <= 12'd0;
				// height_m4 <= 12'd0;	
			end
			8'd7: begin           //拼接部分
				width_m1 <= 12'd0;
				height_m1 <= 12'd0;
				width_m2 <= 12'd960;
				height_m2 <= 12'd540;
				width_m3 <= 12'd960;
				height_m3 <= 12'd540;

				update_flag <= 8'd0;
				// width_m4 <= 12'd0;
				// height_m4 <= 12'd0;	
			end	
			8'd8: begin           //拼接部分
				width_m1 <= 12'd0;
				height_m1 <= 12'd0;
				width_m2 <= 12'd0;
				height_m2 <= 12'd0;
				width_m3 <= 12'd960;
				height_m3 <= 12'd540;

				update_flag <= 8'd0;
				// width_m4 <= 12'd960;
				// height_m4 <= 12'd540;	
			end	
			8'd9: begin           //拼接部分
				width_m1 <= 12'd960;
				height_m1 <= 12'd540;
				width_m2 <= 12'd960;
				height_m2 <= 12'd540;
				width_m3 <= 12'd0;
				height_m3 <= 12'd0;

				update_flag <= 8'd0;
				// width_m4 <= 12'd0;
				// height_m4 <= 12'd0;	
			end	
			8'd10: begin           //拼接部分
				width_m1 <= 12'd960;
				height_m1 <= 12'd540;
				width_m2 <= 12'd0;
				height_m2 <= 12'd0;
				width_m3 <= 12'd0;
				height_m3 <= 12'd0;
				update_flag <= 8'd0;
				// width_m4 <= 12'd960;
				// height_m4 <= 12'd540;	
			end	
			8'd11: begin           //拼接部分
				width_m1 <= 12'd0;
				height_m1 <= 12'd0;
				width_m2 <= 12'd960;
				height_m2 <= 12'd540;
				width_m3 <= 12'd0;
				height_m3 <= 12'd0;
				update_flag <= 8'd0;
				// width_m4 <= 12'd960;
				// height_m4 <= 12'd540;	
			end
			default: begin
					// 保持当前窗口尺寸
					width_m1 <= width_m1;
					height_m1 <= height_m1;
					width_m2 <= width_m2;
					height_m2 <= height_m2;
					width_m3 <= width_m3;
					height_m3 <= height_m3;
					// width_m4 <= width_m4;
					// height_m4 <= height_m4;
				end				
	endcase
	end
	    else if (update_flag == 1) begin
			width_m1 <= Width_show;
			height_m1 <= Height_show;

    end
	    else if (update_flag == 2) begin

			width_m2 <= Width_show;
			height_m2 <= Height_show;

    end
	    else if (update_flag == 3) begin

			width_m3 <= Width_show;
			height_m3 <= Height_show;

		end	else begin
					width_m1 <= width_m1;
					height_m1 <= height_m1;
					width_m2 <= width_m2;
					height_m2 <= height_m2;
					width_m3 <= width_m3;
					height_m3 <= height_m3;
		
		end	
end














///////////////*************hsst core *********///////////

wire o_p_clk2core_tx_2;
wire o_p_clk2core_tx_3;
wire o_p_clk2core_rx_2;
wire o_p_clk2core_rx_3;

hsst_test the_instance_name (
    .i_free_clk                        (sys_clk                ),// input
    .i_pll_rst_0                       (~rst_n                    ),// input
    .i_wtchdg_clr_0                    (~rst_n            ),// input
    .o_wtchdg_st_0                     (o_wtchdg_st_0             ),// output [1:0]
    .o_pll_done_0                      (o_pll_done_0              ),// output
    .o_txlane_done_2                   (o_txlane_done_2           ),// output
    .o_txlane_done_3                   (o_txlane_done_3           ),// output
    .o_rxlane_done_2                   (o_rxlane_done_2           ),// output
    .o_rxlane_done_3                   (o_rxlane_done_3           ),// output

    .i_p_refckn_0                      (                          ),// input //don't care
    .i_p_refckp_0                      (                          ),// input //don't care

    .o_p_clk2core_tx_2                 (o_p_clk2core_tx_2         ),// output
    .o_p_clk2core_tx_3                 (o_p_clk2core_tx_3         ),

    .o_p_clk2core_rx_2                 (o_p_clk2core_rx_2         ),
    .o_p_clk2core_rx_3                 (o_p_clk2core_rx_3         ),

    .i_p_tx2_clk_fr_core               (o_p_clk2core_tx_2         ),// input  //tx2_clk
    .i_p_tx3_clk_fr_core               (o_p_clk2core_tx_3         ),// input  //tx3_clk

    .i_p_rx2_clk_fr_core               (o_p_clk2core_rx_2         ),// input  //rx2_clk
    .i_p_rx3_clk_fr_core               (o_p_clk2core_rx_3         ),// input  //rx3_clk

    .o_p_pll_lock_0                    (o_p_pll_lock_0            ),// output
    .o_p_rx_sigdet_sta_2               (o_p_rx_sigdet_sta_2       ),// output
    .o_p_rx_sigdet_sta_3               (o_p_rx_sigdet_sta_3       ),// output
    .o_p_lx_cdr_align_2                (o_p_lx_cdr_align_2        ),// output
    .o_p_lx_cdr_align_3                (o_p_lx_cdr_align_3        ),// output
    .o_p_pcs_lsm_synced_2              (o_p_pcs_lsm_synced_2      ),// output
    .o_p_pcs_lsm_synced_3              (o_p_pcs_lsm_synced_3      ),// output
    .i_p_l2rxn                         (                          ),// input  //don't care
    .i_p_l2rxp                         (                          ),// input  //don't care
    .i_p_l3rxn                         (                          ),// input  //don't care
    .i_p_l3rxp                         (                          ),// input  //don't care
    .o_p_l2txn                         (o_p_l2txn                 ),// output
    .o_p_l2txp                         (o_p_l2txp                 ),// output
    .o_p_l3txn                         (o_p_l3txn                 ),// output
    .o_p_l3txp                         (o_p_l3txp                 ),// output

//user 接口

//channel 2 tx
    .i_txd_2                           (i_txd_2                   ),// input [31:0]
    .i_tdispsel_2                      (4'b0              ),// input [3:0]
    .i_tdispctrl_2                     (4'b0             ),// input [3:0]
    .i_txk_2                           (i_txk_2                   ),// input [3:0]
//channel 3 tx    sfp3
    .i_txd_3                           (i_txd_3                   ),// input [31:0]
    .i_tdispsel_3                      (4'b0              ),// input [3:0]
    .i_tdispctrl_3                     (4'b0             ),// input [3:0]
    .i_txk_3                           (i_txk_3                   ),// input [3:0]
//channel 2 rx
    .o_rxstatus_2                      (o_rxstatus_2              ),// output [2:0]
    .o_rxd_2                           (o_rxd_2                   ),// output [31:0]
    .o_rdisper_2                       (o_rdisper_2               ),// output [3:0]
    .o_rdecer_2                        (o_rdecer_2                ),// output [3:0]
    .o_rxk_2                           (o_rxk_2                   ),// output [3:0]
//channel 3 rx  sfp3
    .o_rxstatus_3                      (o_rxstatus_3              ),// output [2:0]
    .o_rxd_3                           (o_rxd_3                   ),// output [31:0]
    .o_rdisper_3                       (o_rdisper_3               ),// output [3:0]
    .o_rdecer_3                        (o_rdecer_3                ),// output [3:0]
    .o_rxk_3                           (o_rxk_3                   )// output [3:0]

);


//video output timing generator
//1920x1080 
color_bar color_bar_m0(
    .clk                               (video_clk                 ),
    .rst                               (~rst_n                    ),
    .resolution_sel                    (4'd6                      ),
    .hs                                (color_bar_hs              ),
    .vs                                (color_bar_vs              ),
    .de                                (color_bar_de              ),
    .rgb_r                             (color_bar_r               ),
    .rgb_g                             (color_bar_g               ),
    .rgb_b                             (color_bar_b               ) 
);



//generate a frame read data request(左上)
video_rect_read_data video_rect_read_data_m3
(
    .video_clk                         (video_clk                 ),
    .rst                               (~rst_n                    ),
    .video_left_offset                 (12'd0                     ),//横坐标偏移量
    .video_top_offset                  (12'd0                     ),//纵坐标偏移量
    .video_width                       (width_m3                  ),//显示分辨率
    .video_height                      (height_m3                 ),
    .read_req                          (ch3_read_req              ),
    .read_req_ack                      (ch3_read_req_ack          ),
    .read_en                           (ch3_read_en               ),
    .read_data                         (ch3_read_data             ),
    .timing_hs                         (color_bar_hs              ),
    .timing_vs                         (color_bar_vs              ),
    .timing_de                         (color_bar_de              ),
    .timing_data                       ({color_bar_r[4:0],color_bar_g[5:0],color_bar_b[4:0]}),
    .hs                                (v3_hs                     ),
    .vs                                (v3_vs                     ),
    .de                                (v3_de                     ),
    .vout_data                         (v3_data                   ) 
);

//generate a frame read data request(左下)
//坐标偏移0x540
video_rect_read_data video_rect_read_data_m2
(
    .video_clk                         (video_clk                 ),
    .rst                               (~rst_n                    ),
    .video_left_offset                 (12'd0                     ),
    .video_top_offset                  ((12'd1080 - height_m2)                  ),
    .video_width                       (width_m2                  ),
    .video_height                      (height_m2                 ),
    .read_req                          (ch2_read_req              ),
    .read_req_ack                      (ch2_read_req_ack          ),
    .read_en                           (ch2_read_en               ),
    .read_data                         (ch2_read_data             ),
    .timing_hs                         (v3_hs                     ),
    .timing_vs                         (v3_vs                     ),
    .timing_de                         (v3_de                     ),
    .timing_data                       (v3_data                   ),
    .hs                                (v2_hs                     ),
    .vs                                (v2_vs                     ),
    .de                                (v2_de                     ),
    .vout_data                         (v2_data                   ) 
);

//generate a frame read data request(右下)
//坐标偏移960x540
video_rect_read_data video_rect_read_data_m4
(
    .video_clk                         (video_clk                 ),
    .rst                               (~rst_n                    ),
    .video_left_offset                 (12'd960                   ),
    .video_top_offset                  (12'd540                   ),
    .video_width                       (15'd0                     ),//width_m4
    .video_height                      (15'd0                     ),//height_m4
    .read_req                          (ch4_read_req              ),
    .read_req_ack                      (ch4_read_req_ack          ),
    .read_en                           (ch4_read_en               ),
    .read_data                         (ch4_read_data             ),
    .timing_hs                         (v2_hs                     ),
    .timing_vs                         (v2_vs                     ),
    .timing_de                         (v2_de                     ),
    .timing_data                       (v2_data                   ),
    .hs                                (v4_hs                     ),
    .vs                                (v4_vs                     ),
    .de                                (v4_de                     ),
    .vout_data                         (v4_data                   ) 
);

//(右上)
//坐标偏移960x0
video_rect_read_data video_rect_read_data_m1
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n               ),
	.video_left_offset          ((12'd1920 - width_m1)                  ),
	.video_top_offset           (12'd0                    ),
	.video_width                (width_m1                  ),
	.video_height	            (height_m1                  ),
	.read_req                   (ch1_read_req             ),
	.read_req_ack               (ch1_read_req_ack         ),
	.read_en                    (ch1_read_en              ),
	.read_data                  (ch1_read_data            ),
	.timing_hs                  (v4_hs                    ),
	.timing_vs                  (v4_vs                    ),
	.timing_de                  (v4_de                    ),
	.timing_data 	            (v4_data                  ),
	.hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                       ),
	.vout_data                  (vout_data                )
);

//video frame data read-write control
frame_read_write#(
	.MEM_DATA_BITS              (256                      ),
	.READ_DATA_BITS             (16                       ),
	.WRITE_DATA_BITS            (16                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (16                       ) //?
)frame_read_write_m4 (
	.rst                        (~rst_n               ),
	.mem_clk                    (ui_clk                   ),
	.rd_burst_req               (ch4_rd_burst_req         ),
	.rd_burst_len               (ch4_rd_burst_len         ),
	.rd_burst_addr              (ch4_rd_burst_addr        ),
	.rd_burst_data_valid        (ch4_rd_burst_data_valid  ),
	.rd_burst_data              (ch4_rd_burst_data        ),
	.rd_burst_finish            (ch4_rd_burst_finish      ),
	.read_clk                   (video_clk                ),
	.read_req                   (ch4_read_req             ),
	.read_req_ack               (ch4_read_req_ack         ),
	.read_finish                (                         ),
	.read_addr_0                (25'd9331200             ), //The first frame address is 0
	.read_addr_1                (25'd11404800             ), //The second frame address is 25'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (25'd13478400             ),
	.read_addr_3                (25'd15552000              ),
	.read_addr_index            (ch4_read_addr_index      ),
	.read_len                   (Width_out_4 * Height_out_4 / 16              ),//frame size  
	.read_en                    (ch4_read_en              ),
	.read_data                  (ch4_read_data            ),

	.wr_burst_req               (ch4_wr_burst_req         ),
	.wr_burst_len               (ch4_wr_burst_len         ),
	.wr_burst_addr              (ch4_wr_burst_addr        ),
	.wr_burst_data_req          (ch4_wr_burst_data_req    ),
	.wr_burst_data              (ch4_wr_burst_data        ),
	.wr_burst_finish            (ch4_wr_burst_finish      ),
	.write_clk                  (clk_out_4               ),
	.write_req                  (ch4_write_req            ),
	.write_req_ack              (ch4_write_req_ack        ),
	.write_finish               (                         ),
	.write_addr_0               (25'd9331200               ),
	.write_addr_1               (25'd11404800              ),
	.write_addr_2               (25'd13478400              ),
	.write_addr_3               (25'd15552000              ),
	.write_addr_index           (ch4_write_addr_index     ),
	.write_len                  (Width_out_4 * Height_out_4 / 16               ),
	.write_en                   (ch4_write_en             ),
	.write_data                 (ch4_write_data           )
);


//video frame data read-write control
frame_read_write#(
	.MEM_DATA_BITS              (256                      ),
	.READ_DATA_BITS             (16                       ),
	.WRITE_DATA_BITS            (16                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (16                       ) //?
)frame_read_write_m3 (
	.rst                        (~rst_n               ),
	.mem_clk                    (ui_clk                   ),
	.rd_burst_req               (ch3_rd_burst_req         ),
	.rd_burst_len               (ch3_rd_burst_len         ),
	.rd_burst_addr              (ch3_rd_burst_addr        ),
	.rd_burst_data_valid        (ch3_rd_burst_data_valid  ),
	.rd_burst_data              (ch3_rd_burst_data        ),
	.rd_burst_finish            (ch3_rd_burst_finish      ),
	.read_clk                   (video_clk                ),
	.read_req                   (ch3_read_req             ),
	.read_req_ack               (ch3_read_req_ack         ),
	.read_finish                (                         ),
	.read_addr_0                (25'd0                    ), //The first frame address is 0
	.read_addr_1                (25'd2073600              ), //The second frame address is 25'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (25'd4147200              ),
	.read_addr_3                (25'd6220800              ),
	.read_addr_index            (ch3_read_addr_index      ),
	.read_len                   (Width_out_3 * Height_out_3 / 16             ),//frame size  1920x1080x16/256 //640x480,
	.read_en                    (ch3_read_en              ),
	.read_data                  (ch3_read_data            ),

	.wr_burst_req               (ch3_wr_burst_req         ),
	.wr_burst_len               (ch3_wr_burst_len         ),
	.wr_burst_addr              (ch3_wr_burst_addr        ),
	.wr_burst_data_req          (ch3_wr_burst_data_req    ),
	.wr_burst_data              (ch3_wr_burst_data        ),
	.wr_burst_finish            (ch3_wr_burst_finish      ),
	.write_clk                  (clk_out_3               ),
	.write_req                  (ch3_write_req            ),
	.write_req_ack              (ch3_write_req_ack        ),
	.write_finish               (                         ),
	.write_addr_0               (25'd0                    ),
	.write_addr_1               (25'd2073600              ),
	.write_addr_2               (25'd4147200              ),
	.write_addr_3               (25'd6220800              ),
	.write_addr_index           (ch3_write_addr_index     ),
	.write_len                  (Width_out_3 * Height_out_3 / 16               ),
	.write_en                   (ch3_write_en             ),
	.write_data                 (ch3_write_data           )
);

//video frame data read-write control
frame_read_write#(
	.MEM_DATA_BITS              (256                      ),
	.READ_DATA_BITS             (16                       ),
	.WRITE_DATA_BITS            (16                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (16                       ) //?
)frame_read_write_m2 (
	.rst                        (~rst_n               ),
	.mem_clk                    (ui_clk                   ),
	.rd_burst_req               (ch2_rd_burst_req         ),
	.rd_burst_len               (ch2_rd_burst_len         ),
	.rd_burst_addr              (ch2_rd_burst_addr        ),
	.rd_burst_data_valid        (ch2_rd_burst_data_valid  ),
	.rd_burst_data              (ch2_rd_burst_data        ),
	.rd_burst_finish            (ch2_rd_burst_finish      ),
	.read_clk                   (video_clk                ),
	.read_req                   (ch2_read_req             ),
	.read_req_ack               (ch2_read_req_ack         ),
	.read_finish                (                         ),
	.read_addr_0                (25'd1036800                    ), //The first frame address is 0
	.read_addr_1                (25'd3110400              ), //The second frame address is 25'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (25'd5184000              ),
	.read_addr_3                (25'd7257600              ),
	.read_addr_index            (ch2_read_addr_index      ),
	.read_len                   (Width_out_2 * Height_out_2 / 16              ),//frame size  
	.read_en                    (ch2_read_en              ),
	.read_data                  (ch2_read_data            ),

	.wr_burst_req               (ch2_wr_burst_req         ),
	.wr_burst_len               (ch2_wr_burst_len         ),
	.wr_burst_addr              (ch2_wr_burst_addr        ),
	.wr_burst_data_req          (ch2_wr_burst_data_req    ),
	.wr_burst_data              (ch2_wr_burst_data        ),
	.wr_burst_finish            (ch2_wr_burst_finish      ),
	.write_clk                  (clk_out_2               ),
	.write_req                  (ch2_write_req            ),
	.write_req_ack              (ch2_write_req_ack        ),
	.write_finish               (                         ),
	.write_addr_0               (25'd1036800              ),
	.write_addr_1               (25'd3110400              ),
	.write_addr_2               (25'd5184000              ),
	.write_addr_3               (25'd7257600              ),
	.write_addr_index           (ch2_write_addr_index     ),
	.write_len                  (Width_out_2 * Height_out_2 / 16               ),
	.write_en                   (ch2_write_en             ),
	.write_data                 (ch2_write_data           )
);

frame_read_write#(
	.MEM_DATA_BITS              (256                      ),
	.READ_DATA_BITS             (16                       ),
	.WRITE_DATA_BITS            (16                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (16                       ) //?
) frame_read_write_m1
(
	.rst                        (~rst_n               ),
	.mem_clk                    (ui_clk                   ),
	.rd_burst_req               (ch1_rd_burst_req         ),
	.rd_burst_len               (ch1_rd_burst_len         ),
	.rd_burst_addr              (ch1_rd_burst_addr        ),
	.rd_burst_data_valid        (ch1_rd_burst_data_valid  ),
	.rd_burst_data              (ch1_rd_burst_data        ),
	.rd_burst_finish            (ch1_rd_burst_finish      ),
	.read_clk                   (video_clk                ),
	.read_req                   (ch1_read_req             ),
	.read_req_ack               (ch1_read_req_ack         ),
	.read_finish                (                         ),
	.read_addr_0                (25'd8294400              ), //The first frame address is 0
	.read_addr_1                (25'd10368000             ), //The second frame address is 25'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (25'd12441600             ),
	.read_addr_3                (25'd14515200             ),
	.read_addr_index            (ch1_read_addr_index      ),
	.read_len                   (Width_out_1 * Height_out_1 / 16               ),//frame size  1024 * 768 * 16 / 64
	.read_en                    (ch1_read_en              ),
	.read_data                  (ch1_read_data            ),

	.wr_burst_req               (ch1_wr_burst_req         ),
	.wr_burst_len               (ch1_wr_burst_len         ),
	.wr_burst_addr              (ch1_wr_burst_addr        ),
	.wr_burst_data_req          (ch1_wr_burst_data_req    ),
	.wr_burst_data              (ch1_wr_burst_data        ),
	.wr_burst_finish            (ch1_wr_burst_finish      ),
	.write_clk                  (clk_out_1               ),
	.write_req                  (ch1_write_req            ),
	.write_req_ack              (ch1_write_req_ack        ),
	.write_finish               (                         ),
	.write_addr_0               (25'd8294400              ),
	.write_addr_1               (25'd10368000             ),
	.write_addr_2               (25'd12441600             ),
	.write_addr_3               (25'd14515200             ),
	.write_addr_index           (ch1_write_addr_index     ),
	.write_len                  (Width_out_1 * Height_out_1 / 16               ),
	.write_en                   (ch1_write_en             ),
	.write_data                 (ch1_write_data           )
);



mem_read_arbi 
#(
	.MEM_DATA_BITS               (MEM_DATA_BITS),
	.ADDR_BITS                   (ADDR_BITS    ),
	.BUSRT_BITS                  (BUSRT_BITS   )
)
mem_read_arbi_m0
(
	.rst_n                        (rst_n),
	.mem_clk                      (ui_clk),
	.ch0_rd_burst_req             (ch3_rd_burst_req),
	.ch0_rd_burst_len             (ch3_rd_burst_len),
	.ch0_rd_burst_addr            (ch3_rd_burst_addr),
	.ch0_rd_burst_data_valid      (ch3_rd_burst_data_valid),
	.ch0_rd_burst_data            (ch3_rd_burst_data),
	.ch0_rd_burst_finish          (ch3_rd_burst_finish),
	
	.ch1_rd_burst_req             (ch1_rd_burst_req),
	.ch1_rd_burst_len             (ch1_rd_burst_len),
	.ch1_rd_burst_addr            (ch1_rd_burst_addr),
	.ch1_rd_burst_data_valid      (ch1_rd_burst_data_valid),
	.ch1_rd_burst_data            (ch1_rd_burst_data),
	.ch1_rd_burst_finish          (ch1_rd_burst_finish),

    .ch2_rd_burst_req             (ch2_rd_burst_req),
	.ch2_rd_burst_len             (ch2_rd_burst_len),
	.ch2_rd_burst_addr            (ch2_rd_burst_addr),
	.ch2_rd_burst_data_valid      (ch2_rd_burst_data_valid),
	.ch2_rd_burst_data            (ch2_rd_burst_data),
	.ch2_rd_burst_finish          (ch2_rd_burst_finish),

    .ch3_rd_burst_req             (ch4_rd_burst_req),
	.ch3_rd_burst_len             (ch4_rd_burst_len),
	.ch3_rd_burst_addr            (ch4_rd_burst_addr),
	.ch3_rd_burst_data_valid      (ch4_rd_burst_data_valid),
	.ch3_rd_burst_data            (ch4_rd_burst_data),
	.ch3_rd_burst_finish          (ch4_rd_burst_finish),

	
	.rd_burst_req                 (rd_burst_req),
	.rd_burst_len                 (rd_burst_len),
	.rd_burst_addr                (rd_burst_addr),
	.rd_burst_data_valid          (rd_burst_data_valid),
	.rd_burst_data                (rd_burst_data),
	.rd_burst_finish              (rd_burst_finish)	
);

mem_write_arbi
#(
	.MEM_DATA_BITS               (MEM_DATA_BITS),
	.ADDR_BITS                   (ADDR_BITS    ),
	.BUSRT_BITS                  (BUSRT_BITS   )
)
mem_write_arbi_m0(
    .rst_n                             (rst_n                     ),
    .mem_clk                           (ui_clk                    ),
	
    .ch0_wr_burst_req                  (ch3_wr_burst_req          ),
    .ch0_wr_burst_len                  (ch3_wr_burst_len          ),
    .ch0_wr_burst_addr                 (ch3_wr_burst_addr         ),
    .ch0_wr_burst_data_req             (ch3_wr_burst_data_req     ),
    .ch0_wr_burst_data                 (ch3_wr_burst_data         ),
    .ch0_wr_burst_finish               (ch3_wr_burst_finish       ),
	
    .ch1_wr_burst_req                  (ch1_wr_burst_req          ),
    .ch1_wr_burst_len                  (ch1_wr_burst_len          ),
    .ch1_wr_burst_addr                 (ch1_wr_burst_addr         ),
    .ch1_wr_burst_data_req             (ch1_wr_burst_data_req     ),
    .ch1_wr_burst_data                 (ch1_wr_burst_data         ),
    .ch1_wr_burst_finish               (ch1_wr_burst_finish       ),

    .ch2_wr_burst_req                  (ch2_wr_burst_req          ),
    .ch2_wr_burst_len                  (ch2_wr_burst_len          ),
    .ch2_wr_burst_addr                 (ch2_wr_burst_addr         ),
    .ch2_wr_burst_data_req             (ch2_wr_burst_data_req     ),
    .ch2_wr_burst_data                 (ch2_wr_burst_data         ),
    .ch2_wr_burst_finish               (ch2_wr_burst_finish       ),

    .ch3_wr_burst_req                  (ch4_wr_burst_req          ),
    .ch3_wr_burst_len                  (ch4_wr_burst_len          ),
    .ch3_wr_burst_addr                 (ch4_wr_burst_addr         ),
    .ch3_wr_burst_data_req             (ch4_wr_burst_data_req     ),
    .ch3_wr_burst_data                 (ch4_wr_burst_data         ),
    .ch3_wr_burst_finish               (ch4_wr_burst_finish       ),

    .wr_burst_req                      (wr_burst_req              ),
    .wr_burst_len                      (wr_burst_len              ),
    .wr_burst_addr                     (wr_burst_addr             ),
    .wr_burst_data_req                 (wr_burst_data_req         ),
    .wr_burst_data                     (wr_burst_data             ),
    .wr_burst_finish                   (wr_burst_finish           ) 
);


////////////////////////**************ddr3******************////////////////
wire                                 pll_lock               ;
wire                                 ddr_init_done          ;
wire                                 ddrphy_rst_done        ;
wire                                 core_clk        ;
assign core_clk=ui_clk;
    reg  [26:0]                 cnt                        ;// 计数器
    parameter TH_1S = 27'd33000000;         // 1 秒计数器阈值

///////////////////////********************
// 心跳信号，用于指示系统是否正常工作
always@(posedge core_clk) begin
    if (!ddr_init_done)
        cnt <= 27'd0;            // 初始化时将计数器清零
    else if (cnt >= TH_1S)
        cnt <= 27'd0;            // 当计数器达到1秒时清零
    else
        cnt <= cnt + 27'd1;      // 计数器递增
end

always @(posedge core_clk) begin
    if (!ddr_init_done)
        heart_beat_led <= 1'd1;  // 初始化时点亮LED
    else if (cnt >= TH_1S)
        heart_beat_led <= ~heart_beat_led;  // 每1秒翻转一次LED状态
end
////***********************************************************************************
DDR3_50H #(
   .MEM_ROW_WIDTH          (MEM_ROW_ADDR_WIDTH),     
   .MEM_COLUMN_WIDTH       (MEM_COL_ADDR_WIDTH),     
   .MEM_BANK_WIDTH         (MEM_BADDR_WIDTH   ),     
   .MEM_DQ_WIDTH           (MEM_DQ_WIDTH      ),     
   .MEM_DM_WIDTH           (MEM_DM_WIDTH      ),     
   .MEM_DQS_WIDTH          (MEM_DQS_WIDTH     ),     
   .CTRL_ADDR_WIDTH        (CTRL_ADDR_WIDTH   )     
  )I_ips_ddr_top
(
    .ref_clk                    (sys_clk                    ),
    .resetn                     (rst_n                        ),
    .ddrphy_clkin               (ui_clk                       ),
    .pll_lock                   (pll_lock                             ),
    .ddr_init_done              (ddr_init_done                ),


   .axi_awaddr                  (s00_axi_awaddr               ),//I, 写地址
   .axi_awuser_ap               (1'b0                         ),
   .axi_awuser_id               (s00_axi_awid                 ),//固定给0
   .axi_awlen                   (s00_axi_awlen                ),//i,写突发长度
   .axi_awready                 (s00_axi_awready              ),//o,axi_awready与axi_awvalid握手
   .axi_awvalid                 (s00_axi_awvalid              ),//i,

   .axi_wdata                   (s00_axi_wdata                ),//i,写数据s00_axi_wdata
   .axi_wstrb                   (32'hffffffff                ),//i,一般不用(掩码)
   .axi_wready                  (s00_axi_wready               ),//o
   .axi_wusero_id               (                             ),//
   .axi_wusero_last             ( axi_wusero_last             ),//写数据last(写到最后一个数据时会拉高)

   .axi_araddr                  (s00_axi_araddr               ),//i，读地址
   .axi_aruser_ap               (1'b0                         ),
   .axi_aruser_id               (s00_axi_arid                 ),//固定给0
   .axi_arlen                   (s00_axi_arlen                ),//i,读突发长度[3:0]
   .axi_arready                 (s00_axi_arready              ),//o,读ready
   .axi_arvalid                 (s00_axi_arvalid              ),//i,读valid

   .axi_rdata                   (s00_axi_rdata                ),// o,读数据 DQ_WIDTH*8
   .axi_rid                     (s00_axi_rid                  ),//o,id，固定
   .axi_rlast                   (s00_axi_rlast                ),//o,读数据last信号
   .axi_rvalid                  (s00_axi_rvalid               ),//o,读数据valid

    .apb_clk                    (1'b0                         ),
    .apb_rst_n                  (1'b0                         ),
    .apb_sel                    (1'b0                         ),
    .apb_enable                 (1'b0                         ),
    .apb_addr                   (8'd0                         ),
    .apb_write                  (1'b0                         ),
    .apb_ready                  (                             ),
    .apb_wdata                  (16'd0                        ),
    .apb_rdata                  (                             ),
    .apb_int                    (                             ),
    .debug_data                 (                             ),

    .mem_rst_n                  (mem_rst_n                    ),
    .mem_ck                     (mem_ck                       ),
    .mem_ck_n                   (mem_ck_n                     ),
    .mem_cke                    (mem_cke                      ),
    .mem_cs_n                   (mem_cs_n                     ),
    .mem_ras_n                  (mem_ras_n                    ),
    .mem_cas_n                  (mem_cas_n                    ),
    .mem_we_n                   (mem_we_n                     ),
    .mem_odt                    (mem_odt                      ),
    .mem_a                      (mem_a                        ),
    .mem_ba                     (mem_ba                       ),
    .mem_dqs                    (mem_dqs                      ),
    .mem_dqs_n                  (mem_dqs_n                    ),
    .mem_dq                     (mem_dq                       ),
    .mem_dm                     (mem_dm                       )
  );
                                     
assign s00_axi_bvalid =1'b1;
aq_axi_master_256
 u_aq_axi_master
	(
	  .ARESETN                     (rst_n                                     ),
	  .ACLK                        (ui_clk                                    ),

//write ddr address
	  .M_AXI_AWID                  (s00_axi_awid                              ),//固定给0
	  .M_AXI_AWADDR                (s00_axi_awaddr                            ),////o, write ddr address
	  .M_AXI_AWLEN                 (s00_axi_awlen                             ),////o,写突发长度
	  .M_AXI_AWVALID               (s00_axi_awvalid                           ),//o,  write ddr valid address
	  .M_AXI_AWREADY               (s00_axi_awready                           ),//i,axi_awready与axi_awvalid握手

	  .M_AXI_AWSIZE                (s00_axi_awsize                            ),
	  .M_AXI_AWBURST               (s00_axi_awburst                           ),//
	  .M_AXI_AWLOCK                (s00_axi_awlock                            ),
	  .M_AXI_AWCACHE               (s00_axi_awcache                           ),
	  .M_AXI_AWPROT                (s00_axi_awprot                            ),
	  .M_AXI_AWQOS                 (s00_axi_awqos                             ),
	  .M_AXI_AWUSER                (s00_axi_awuser                            ),

	  .M_AXI_WDATA                 (s00_axi_wdata                             ),//o, write data to ddr
	  .M_AXI_WSTRB                 (s00_axi_wstrb                             ),//o,一般不用(掩码)
	  .M_AXI_WLAST                 (s00_axi_wlast                             ),//这个信号好像没连上axi_wusero_last
	  .M_AXI_WREADY                (s00_axi_wready                            ),//i, write data to ddr ready

	  .M_AXI_WUSER                 (s00_axi_wuser                             ),
	  .M_AXI_WVALID                (s00_axi_wvalid                            ),
	  .M_AXI_BID                   (s00_axi_bid                               ),
	  .M_AXI_BRESP                 (s00_axi_bresp                             ),
	  .M_AXI_BUSER                 (s00_axi_buser                             ),
      .M_AXI_BVALID                (s00_axi_bvalid                            ),//be set 1

	  .M_AXI_BREADY                (s00_axi_bready                            ),
	  .M_AXI_ARID                  (s00_axi_arid                              ),// o,0
	  .M_AXI_ARADDR                (s00_axi_araddr                            ),//o,read ddr address
	  .M_AXI_ARLEN                 (s00_axi_arlen                             ),//o,突发长度
	  .M_AXI_ARVALID               (s00_axi_arvalid                           ),//o，read ddr address valid
	  .M_AXI_ARREADY               (s00_axi_arready                           ),//i, read ready
	  .M_AXI_ARSIZE                (s00_axi_arsize                            ),
	  .M_AXI_ARBURST               (s00_axi_arburst                           ),
	  .M_AXI_ARLOCK                (s00_axi_arlock                            ),
	  .M_AXI_ARCACHE               (s00_axi_arcache                           ),
	  .M_AXI_ARPROT                (s00_axi_arprot                            ),
	  .M_AXI_ARQOS                 (s00_axi_arqos                             ),
	  .M_AXI_ARUSER                (s00_axi_aruser                            ),

	  .M_AXI_RID                   (s00_axi_rid                               ),//固定
	  .M_AXI_RDATA                 (s00_axi_rdata                             ),// i, read data
	  .M_AXI_RRESP                 (s00_axi_rresp                             ),
	  .M_AXI_RLAST                 (s00_axi_rlast                             ),//i, read  last data
	  .M_AXI_RUSER                 (s00_axi_ruser                             ),
	  .M_AXI_RVALID                (s00_axi_rvalid                            ),//i ,read data valid
	  .M_AXI_RREADY                (s00_axi_rready                            ),


	  .MASTER_RST                  (1'b0                                      ),
	  .WR_START                    (wr_burst_req                              ),
	  .WR_ADRS                     ({wr_burst_addr,5'd0}                      ),
	  .WR_LEN                      ({wr_burst_len, 5'd0}                      ),
	  .WR_READY                    (                                          ),
	  .WR_FIFO_RE                  (wr_burst_data_req                         ),//o
	  .WR_FIFO_EMPTY               (1'b0                                      ),
	  .WR_FIFO_AEMPTY              (1'b0                                      ),
	  .WR_FIFO_DATA                (wr_burst_data                             ),
	  .WR_DONE                     (wr_burst_finish                           ),
	  .RD_START                    (rd_burst_req                              ),
	  .RD_ADRS                     ({rd_burst_addr,5'd0}                      ),
	  .RD_LEN                      ({rd_burst_len,5'd0}                       ),
	  .RD_READY                    (                                          ),
	  .RD_FIFO_WE                  (rd_burst_data_valid                       ),
	  .RD_FIFO_FULL                (1'b0                                      ),
	  .RD_FIFO_AFULL               (1'b0                                      ),
	  .RD_FIFO_DATA                (rd_burst_data                             ),
	  .RD_DONE                     (rd_burst_finish                           ),
	  .DEBUG                       (                                          )
	);

/////*************hdmi_iic config**********////
    reg [15:0]  rstn_1ms       ;
    wire        cfg_clk        ;
    wire        locked         ;



    ms72xx_ctl ms72xx_ctl_inst1(
        .clk(cfg_clk),              // input
        .rst_n(rstn_out3),          // input
        .init_over(init_over),  // output
        .iic_scl(iic_scl),      // output
        .iic_sda(iic_sda)       // inout
    );


    assign    led_int  =  init_over; 

    always @(posedge cfg_clk)
    begin
    	if(!locked)
    	    rstn_1ms <= 16'd0;
    	else
    	begin
    		if(rstn_1ms == 16'h2710)
    		    rstn_1ms <= rstn_1ms;
    		else
    		    rstn_1ms <= rstn_1ms + 1'b1;
    	end
    end
    
    assign rstn_out3 = (rstn_1ms == 16'h2710);




/////**********adc_hdmi_card*************//////////
wire                            video_clk_adc;
wire                            video_hs;
wire                            video_vs;
wire                            video_de;
wire[7:0]                       video_r;
wire[7:0]                       video_g;
wire[7:0]                       video_b;


wire                            grid_hs;
wire                            grid_vs;
wire                            grid_de;
wire[7:0]                       grid_r;
wire[7:0]                       grid_g;
wire[7:0]                       grid_b;

wire                            wave0_hs;
wire                            wave0_vs;
wire                            wave0_de;
wire[7:0]                       wave0_r;
wire[7:0]                       wave0_g;
wire[7:0]                       wave0_b;


wire                            adc_clk;
wire                            adc0_buf_wr/* synthesis PAP_MARK_DEBUG="1" */;
wire[10:0]                      adc0_buf_addr;
wire[7:0]                       adc0_buf_data/* synthesis PAP_MARK_DEBUG="1" */;
wire                            dac_clk;
wire[7:0]                       dac_data;
reg[9:0]                        rom_addr/* synthesis PAP_MARK_DEBUG="1" */;




assign ad_clk = adc_clk;
assign da_clk = dac_clk;
assign da_data_out = dac_data;

adda_pll adda_pll_m0 (
    .clkin1                            (sys_clk                   ),// input
    .pll_lock                          (pll_lock                  ),// output
    .clkout0                           (video_clk_adc             ),// output
    .clkout1                           (adc_clk                   ),// output
    .clkout2                           (dac_clk                   ) // output
);


//dac 125Mhz/1024 = 
always@(posedge dac_clk)
begin
	rom_addr <= rom_addr + 9'd1;
end

da_rom da_rom_m0 ( 
    .addr(rom_addr),
    .clk(dac_clk ),
    .rst(1'b0),
    .rd_data(dac_data));


color_bar color_bar_m1(
    .clk                               (video_clk_adc                 ),
    .rst                               (~rst_n                    ),
    .resolution_sel                    (4'd5                      ),
    .hs                                (video_hs                  ),
    .vs                                (video_vs                  ),
    .de                                (video_de                  ),
    .rgb_r                             (video_r                   ),
    .rgb_g                             (video_g                   ),
    .rgb_b                             (video_b                   ) 
);


grid_display  grid_display_m0(
	.rst_n                 (rst_n                      ),
	.pclk                  (video_clk_adc                  ),
	.i_hs                  (video_hs                   ),
	.i_vs                  (video_vs                   ),
	.i_de                  (video_de                   ),
	.i_data                ({video_r,video_g,video_b}  ),
	.o_hs                  (grid_hs                    ),
	.o_vs                  (grid_vs                    ),
	.o_de                  (grid_de                    ),
	.o_data                ({grid_r,grid_g,grid_b}     )
);


ad9280_sample ad9280_sample_m0(
	.adc_clk               (adc_clk                    ),
	.rst                   (~rst_n                     ),
	.adc_data              (ad_data_in                ),
	.adc_data_valid        (1'b1                       ),
	.adc_buf_wr            (adc0_buf_wr                ),
	.adc_buf_addr          (adc0_buf_addr              ),
	.adc_buf_data          (adc0_buf_data              )
);

//例化fifo控制模块
fifo_ctrl u_fifo_ctrl(
	.axi_clk			(dac_clk),           //50m时钟
	.sys_rst_n			(rst_n),              //复位信号，低电平有效
    .in_vsync           (vs_out),          //帧同步，高有效

	.ad_clk				(adc_clk),        //相位偏移后的25m时钟 
	.ad_data_in			(ad_data_in),            //AD输入数据 

	.s_axis_data_tready	(s_axis_data_tready), //fft数据通道准备完成信号
	.s_axis_data_tlast	(s_axis_data_tlast),  //fft数据通道接收最后一个数据标志信号

	.ad_data_out		(ad_data_out),        //采集后的adc输出数据
	.ad_data_out_en     (ad_data_out_en)      //采集后的adc输出数据使能
);	

wire [7:0] ad_data_out;
wire ad_data_out_en;

// //将采集后的adc输出数据补0赋给fft的输入数据
assign s_axis_data_tdata = {24'b0,ad_data_out[7:0]};  


// //将采集后的adc输出数据有效使能赋给fft的输入数据有效使能
assign  s_axis_data_tvalid =  ad_data_out_en; 



//display 50khz - 1Mhz
wav_display wav_display_m0(
	.rst_n                 (rst_n                      ),
	.pclk                  (video_clk_adc                  ),
	.wave_color            (24'hff0000                 ),
	.adc_clk               (adc_clk                    ),
	.adc_buf_wr            (adc0_buf_wr                ),
	.adc_buf_addr          (adc0_buf_addr              ),
	.adc_buf_data          (adc0_buf_data              ),
	.i_hs                  (grid_hs                    ),
	.i_vs                  (grid_vs                    ),
	.i_de                  (grid_de                    ),
	.i_data                ({grid_r,grid_g,grid_b}     ),
	.o_hs                  (wave1_hs                   ),
	.o_vs                  (wave1_vs                   ),
	.o_de                  (wave1_de                   ),
	.o_data                ({wave1_r,wave1_g,wave1_b}  )
);

wire                            wave1_hs;
wire                            wave1_vs;
wire                            wave1_de;
wire[7:0]                       wave1_r;
wire[7:0]                       wave1_g;
wire[7:0]                       wave1_b;

//display 50khz - 1Mhz
fft_display fft_display_m0(
    .rst_n                             (rst_n                     ),
    .pclk                              (video_clk_adc                 ),
    .spectrum_color                    (24'h0000ff                ),
    .adc_clk                           (dac_clk                   ),
    .fft_buf_wr                        (m_axis_data_tvalid        ),
    .fft_buf_addr                      (m_axis_data_tuser         ),
    .fft_buf_data                      (fft_abs_2                 ),
    .i_hs                              (wave1_hs                  ),
    .i_vs                              (wave1_vs                  ),
    .i_de                              (wave1_de                  ),
    .i_data                            ({wave1_r,wave1_g,wave1_b} ),
    .o_hs                              (wave0_hs                  ),
    .o_vs                              (wave0_vs                  ),
    .o_de                              (wave0_de                  ),
    .o_data                            ({wave0_r,wave0_g,wave0_b} ) 
);


//////////////// FFT //////////
// FFT模块相关信号
wire  [31:0] s_axis_data_tdata; /* synthesis PAP_MARK_DEBUG="1" */
wire  s_axis_data_tvalid; /* synthesis PAP_MARK_DEBUG="1" */
wire  s_axis_data_tready; /* synthesis PAP_MARK_DEBUG="1" */
wire  s_axis_data_tlast/* synthesis PAP_MARK_DEBUG="1" */;

wire  [63:0] m_axis_data_tdata; 
wire  m_axis_data_tvalid; /* synthesis PAP_MARK_DEBUG="1" */
wire  m_axis_data_tlast; /* synthesis PAP_MARK_DEBUG="1" */
wire  [23:0] m_axis_data_tuser; /* synthesis PAP_MARK_DEBUG="1" */
wire  o_stat; /* synthesis PAP_MARK_DEBUG="1" */
wire  o_alm; /* synthesis PAP_MARK_DEBUG="1" */

reg  [63:0] fft_abs; /* synthesis PAP_MARK_DEBUG="1" */
reg  [31:0] fft_real; /* synthesis PAP_MARK_DEBUG="1" */
reg  [31:0] fft_imag; /* synthesis PAP_MARK_DEBUG="1" */



// 实例化 FFT 模块
ipsxb_fft_demo_pp_1024 u_fft_wrapper ( 
    .i_aclk                 (dac_clk),  // FFT模块的时钟

    .i_axi4s_cfg_tvalid     (1'b1),  // 固定配置有效信号
    .i_axi4s_cfg_tdata      (1'b1),  // 固定配置数据

    .i_axi4s_data_tvalid    (s_axis_data_tvalid),  // 数据有效信号
    .i_axi4s_data_tdata     (s_axis_data_tdata),   // 输入数据
    .i_axi4s_data_tlast     (s_axis_data_tlast),   // 输入数据最后一位
    .o_axi4s_data_tready    (s_axis_data_tready),  // FFT模块准备好接收数据

    .o_axi4s_data_tvalid    (m_axis_data_tvalid),  // 输出数据有效信号
    .o_axi4s_data_tdata     (m_axis_data_tdata),   // FFT结果
    .o_axi4s_data_tlast     (m_axis_data_tlast),   // FFT输出最后一位
    .o_axi4s_data_tuser     (m_axis_data_tuser),   // 用户自定义信号,1024个作为地址写入ram中

    .o_alm                  (o_alm),                    // 错误报警信号
    .o_stat                 (o_stat)                     // 状态信号
);



// 提取FFT结果中的实部和虚部
always @(posedge dac_clk) begin
    if (m_axis_data_tvalid) begin
        // 提取实部和虚部
        if (m_axis_data_tdata[31]) begin
            fft_real <= ~m_axis_data_tdata[31:0] + 1'b1; // 实部（取绝对值）
        end else begin
            fft_real <= m_axis_data_tdata[31:0];
        end

        if (m_axis_data_tdata[63]) begin
            fft_imag <= ~m_axis_data_tdata[63:32] + 1'b1; // 虚部（取绝对值）
        end else begin
            fft_imag <= m_axis_data_tdata[63:32];
        end

        // 计算绝对值的平方和
        fft_abs <= (fft_real * fft_real) + (fft_imag * fft_imag);
    end else begin
        // 在没有有效数据时，将 fft_abs 重置
        fft_real <= 32'd0;
        fft_imag <= 32'd0;
        fft_abs <= 64'd0;
    end
end
wire [63:0]fft_abs_1/* synthesis PAP_MARK_DEBUG="1" */;
wire [7:0]fft_abs_2/* synthesis PAP_MARK_DEBUG="1" */;

assign fft_abs_1 = fft_abs >> 25;
assign fft_abs_2 = fft_abs_1[7:0];



endmodule

