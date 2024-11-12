//send lane1  receive lane0
module top #(   
  parameter MEM_ROW_ADDR_WIDTH   = 15,
  parameter MEM_COL_ADDR_WIDTH   = 10,
  parameter MEM_BADDR_WIDTH      = 3,
  parameter MEM_DQ_WIDTH         = 32,
  parameter MEM_DM_WIDTH         = MEM_DQ_WIDTH/8,
  parameter MEM_DQS_WIDTH        = MEM_DQ_WIDTH/8,
  parameter CTRL_ADDR_WIDTH      = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH
)(

    input                               sys_clk                    ,
    input                               rst_n                      ,

//hsst en
    output             [   1:0]         tx_disable     ,

//ethernet
    output                              phy_rst_n                  ,
    output                              led                        ,                
    output             [   3:0]         rgmii_txd                  ,//RGMII 发?数??
    output                              rgmii_txctl                ,//RGMII 发?数据有效信??
    output                              rgmii_txc                  ,//125Mhz ethernet rgmii tx clock
    input              [   3:0]         rgmii_rxd                  ,//RGMII 接收数据
    input                               rgmii_rxctl                ,//RGMII 接收数据有效信号
    input                               rgmii_rxc                  ,//125Mhz ethernet gmii rx clock

//ddr                                                                                                                                                                                    
    output                              mem_rst_n                  ,
    output                              mem_ck                     ,
    output                              mem_ck_n                   ,
    output                              mem_cke                    ,
    output                              mem_cs_n                   ,
    output                              mem_ras_n                  ,
    output                              mem_cas_n                  ,
    output                              mem_we_n                   ,
    output                              mem_odt                    ,
    output             [MEM_ROW_ADDR_WIDTH-1:0]mem_a                      ,
    output             [   MEM_BADDR_WIDTH-1:0]mem_ba                     ,
    inout              [     MEM_DQS_WIDTH-1:0]mem_dqs                    ,
    inout              [     MEM_DQS_WIDTH-1:0]mem_dqs_n                  ,
    inout              [      MEM_DQ_WIDTH-1:0]mem_dq                     ,
    output             [      MEM_DM_WIDTH-1:0]mem_dm                     ,

    output reg                          heart_beat_led             ,
    output                              ddr_init_done              ,



//iic config
    output                              iic_scl                    ,
    inout                               iic_sda                    ,
    output                              iic_tx_scl                 ,
    inout                               iic_tx_sda                 ,
    output                              rstn_out                   ,

//hdmi in
    input                               pixclk_in                  ,
    input                               vs_in                      ,
    input                               hs_in                      ,
    input                               de_in                      ,
    input              [   7:0]         r_in                       ,
    input              [   7:0]         g_in                       ,
    input              [   7:0]         b_in                       ,
//hdmi out
    output                              pixclk_out                 ,
    output                              vs_out                     ,
    output                              hs_out                     ,
    output                              de_out                     ,
    output             [   7:0]         r_out                      ,
    output             [   7:0]         g_out                      ,
    output             [   7:0]         b_out                      ,
    output                              led_int                     
);

///////************hsst en**********//////////
assign        tx_disable           = 2'b0 ; 

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

wire                            video_clk;         //video pixel clock
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

wire                            hdmi_hs;
wire                            hdmi_vsync;
wire                            hdmi_de;
wire[7:0]                       hdmi_r;
wire[7:0]                       hdmi_g;
wire[7:0]                       hdmi_b;
wire[15:0]rgb565_data/*synthesis PAP_MARK_DEBUG="1"*/;

//最后输出
assign r_out = {vout_data[15:11], vout_data[15:13]};   // 5位红色扩展为8位
assign g_out = {vout_data[10:5], vout_data[10:9]};     // 6位绿色扩展为8位
assign b_out = {vout_data[4:0], vout_data[4:2]};       // 5位蓝色扩展为8位







video_pll video_pll_m0
(
  .clkin1                    (sys_clk                ),
  .clkout0                   (cfg_clk            ),
  .clkout1                   (video_clk              ),//148.5 作为输出视频时钟
  .clkout2                   (              ),//74.25
  .pll_rst                   (1'b0                     ),
  .pll_lock                  ( locked                        )
);

assign pixclk_out =video_clk;//输出视频时钟


//////////////////hdmi_data_in//////////////
wire vs_1;
wire clk_out_1;
reg [7:0] brightness_ctr_1 = 8'd100;
reg [7:0] hue_ctr_1 = 8'd100;
// reg ctr_1 = 1'b0;
reg [15:0] Width_in_1 = 15'd1920;//输入视频分辨率
reg [15:0] Height_in_1 = 15'd1080;
reg [15:0] Width_out_1= 15'd640;//输出视频分辨率
reg [15:0] Height_out_1=15'd480;
//视频1输入(右上)
hdmi_data_in u_hdmi_data_in_1(

    .pix_clk                           (pixclk_in                 ),// input
    .rst_n                             (rst_n                     ),
    .resize_out                        (resize_out                ),

    .ctr                               (1'b0                      ),
    .brightness_ctr                    (brightness_ctr_1          ),
    .hue_ctr                           (hue_ctr_1                 ),
    .vs_in                             (vs_in                     ),// input                                vs_in,          // 输入垂直同步信号
    .hs_in                             (hs_in                     ),// input                                hs_in,          // 输入水平同步信号
    .de_in                             (de_in                     ),// input                                de_in,          // 输入数据使能信号
    .r_in                              (r_in                      ),// input     [7:0]                      r_in, 
    .g_in                              (g_in                      ),// input     [7:0]                      g_in, 
    .b_in                              (b_in                      ),// input     [7:0]                      b_in, 
    
    .clk_out                           (clk_out_1                 ),
    .vs_out                            (vs_1                      ),// output reg                           vs_out,         // 输出垂直同步信号
    .de_out                            (hdmi_de_1                 ),// output reg                           de_out,         // 输出数据使能信号
    .rgb565_out                        (rgb565_data_1             ),

    .Width_in                          (Width_in_1                ),
    .Height_in                         (Height_in_1               ),

    .Width_out                         (Width_out_1               ),
    .Height_out                        (Height_out_1              ) 
);

wire                                    hdmi_de_1/*synthesis PAP_MARK_DEBUG="1"*/;
wire                   [  15:0]         rgb565_data_1/*synthesis PAP_MARK_DEBUG="1"*/;

assign ch1_write_en = hdmi_de_1;
assign ch1_write_data = rgb565_data_1;

/////////////////////////************hsst**************//////////////////////////
// 2bit : high bit model ; low bit param
//0x00 预览; 0x01 亮度; 0x02 色度;  
wire [15:0] rec_data;


reg [31:0] i_txd_2/* synthesis PAP_MARK_DEBUG="true" */;
reg [3:0]i_txk_2/* synthesis PAP_MARK_DEBUG="true" */;




assign rgb565_data = {r_in[7:3], g_in[7:2], b_in[7:3]};  // 将8位的RGB转换为RGB565格式

wire                                    tx_clk                     ;
wire                                    o_p_clk2core_tx_2          ;
wire                   [   3:0]         i_txk_3                    ;
wire                   [  31:0]         i_txd_3                    ;
wire                   [  31:0]         gt_tx_data /*synthesis PAP_MARK_DEBUG="1"*/                ;//send lan1  
wire                   [   3:0]         gt_tx_ctrl /*synthesis PAP_MARK_DEBUG="1"*/                ;

assign tx_clk = o_p_clk2core_tx_2;

video_packet_send video_packet_send_m0
(
    .rst                               (~rst_n                    ),
    .tx_clk                            (tx_clk                    ),
	
    .pclk                              (pixclk_in                 ),
    .vs                                (vs_in                     ),
    .de                                (de_in                     ),
    .vin_data                          (rgb565_data               ),
    .vin_width                         (16'd1920                  ),//16'd1280,16'd1920
	
    .gt_tx_data                        (gt_tx_data                ),
    .gt_tx_ctrl                        (gt_tx_ctrl                ) 
);

assign i_txd_3 = gt_tx_data;
assign i_txk_3 = gt_tx_ctrl;

//-------------------------------------
//32位数据接收,对齐模块
wire rx_clk;
wire                   [   3:0]         o_rxk_2                    ;
wire                   [  31:0]         o_rxd_2                    ;
wire                   [  31:0]         rx_data   /*synthesis PAP_MARK_DEBUG="1"*/              ;//send lan1  
wire                   [   3:0]         rx_kchar   /*synthesis PAP_MARK_DEBUG="1"*/              ;

assign rx_data = o_rxd_2;
assign rx_kchar = o_rxk_2;
assign rx_clk = o_p_clk2core_tx_2;

wire[31:0] rx_data_align /*synthesis PAP_MARK_DEBUG="1"*/;
wire[3:0] rx_ctrl_align /*synthesis PAP_MARK_DEBUG="1"*/;

word_align word_align_m0
(
    .rst                        (1'b0                    ),
    .rx_clk                     (rx_clk                  ),
    .gt_rx_data                 (rx_data                 ),
    .gt_rx_ctrl                 (rx_kchar                ),
    .rx_data_align              (rx_data_align           ),
    .rx_ctrl_align              (rx_ctrl_align           )
);
//-------------------------------------

//-------------------------------------
//GTP视频数据解析模块
wire vs_wr;
wire de_wr;
wire[15:0] vout_data_r;
assign ch2_write_en     =   de_wr;
assign ch2_write_data   =   vout_data_r; 


//光纤接收图像
video_packet_rec video_packet_rec_m0
(
	.rst                        (~rst_n                  ),
	.rx_clk                     (rx_clk                  ),
	.gt_rx_data                 (rx_data_align           ),
	.gt_rx_ctrl                 (rx_ctrl_align           ),
	.vout_width                 (16'd1920                ),
	
	.vs                         (vs_wr                   ),
	.de                         (de_wr                   ),
	.vout_data                  (vout_data_r             )
);


//光纤接收视频板数据
hdmi_write_req_gen hdmi_write_req_gen_m2(
    .rst                               (~rst_n                    ),
    .pclk                              (rx_clk               ),
    .hdmi_vsync                        (vs_wr                   ),
    .write_req                         (ch2_write_req             ),
    .write_addr_index                  (ch2_write_addr_index      ),
    .read_addr_index                   (ch2_read_addr_index       ),
    .write_req_ack                     (ch2_write_req_ack         ) 
);


//主板视频输入
hdmi_write_req_gen hdmi_write_req_gen_m1(
    .rst                               (~rst_n                    ),
    .pclk                              (clk_out_1               ),
    .hdmi_vsync                        (vs_1                   ),
    .write_req                         (ch1_write_req             ),
    .write_addr_index                  (ch1_write_addr_index      ),
    .read_addr_index                   (ch1_read_addr_index       ),
    .write_req_ack                     (ch1_write_req_ack         ) 
);





///////////////////************显示***************/////////////
//video output timing generator
//1920x1080 

wire                        color_bar_hs;
wire                        color_bar_vs;
wire                        color_bar_de;
wire[7:0]                   color_bar_r;
wire[7:0]                   color_bar_g;
wire[7:0]                   color_bar_b;

color_bar color_bar_m0(
	.clk                        (video_clk                ),
	.rst                        (~rst_n               ),
	.hs                         (color_bar_hs             ),
	.vs                         (color_bar_vs             ),
	.de                         (color_bar_de             ),
	.rgb_r                      (color_bar_r              ),
	.rgb_g                      (color_bar_g              ),
	.rgb_b                      (color_bar_b              )
);

//左下
reg [15:0] width_m2= 15'd1920; 
reg [15:0] height_m2 = 15'd1080; 
//右上
reg [15:0] width_m1= Width_out_1; 
reg [15:0] height_m1 = Height_out_1; 

//视频板的视频数据
//坐标偏移0x540
video_rect_read_data video_rect_read_data_m2
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n               ),
	.video_left_offset          (12'd0                    ),
	.video_top_offset           (12'd0                    ),
	.video_width                (width_m2                  ),
	.video_height	            (height_m2                  ),
	.read_req                   (ch2_read_req             ),
	.read_req_ack               (ch2_read_req_ack         ),
	.read_en                    (ch2_read_en              ),
	.read_data                  (ch2_read_data            ),
	.timing_hs                  (color_bar_hs             ),
	.timing_vs                  (color_bar_vs             ),
	.timing_de                  (color_bar_de             ),
	.timing_data 	            ({color_bar_r[4:0],color_bar_g[5:0],color_bar_b[4:0]}),
	.hs                         (v2_hs                    ),
	.vs                         (v2_vs                    ),
	.de                         (v2_de                    ),
	.vout_data                  (v2_data                  )
);

wire                        v2_hs;
wire                        v2_vs;
wire                        v2_de;
wire[15:0]                  v2_data;

//(右下) 主板的HDMI 输入显示
//坐标偏移960x540
video_rect_read_data video_rect_read_data_m1
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n               ),
	.video_left_offset          (12'd960                  ),
	.video_top_offset           (12'd540                    ),
	.video_width                (width_m1                  ),//width_m1
	.video_height	            (height_m1                  ),//height_m1
	.read_req                   (ch1_read_req             ),
	.read_req_ack               (ch1_read_req_ack         ),
	.read_en                    (ch1_read_en              ),
	.read_data                  (ch1_read_data            ),
	.timing_hs                  (v2_hs                    ),
	.timing_vs                  (v2_vs                    ),
	.timing_de                  (v2_de                    ),
	.timing_data 	            (v2_data                  ),
	.hs                         (v3_hs                       ),
	.vs                         (v3_vs                       ),
	.de                         (v3_de                       ),
	.vout_data                  (v3_data                )
);

wire                        v3_hs;
wire                        v3_vs;
wire                        v3_de;
wire[15:0]                  v3_data;

osd_display  osd_display_m0(
    .rst_n                             (rst_n                     ),
    .pclk                              (video_clk                 ),
    .i_hs                              (v3_hs                     ),
    .i_vs                              (v3_vs                     ),
    .i_de                              (v3_de                     ),
    .i_data                            (v3_data                   ),

    .wr_clk                            (gmii_rx_clk               ),
    .wr_en                             (rec_en                    ),
    .wr_addr                           (data_cnt                  ),
    .wr_data                           (rec_data_m1               ),

    .o_hs                              (hs                        ),
    .o_vs                              (vs                        ),
    .o_de                              (de                        ),
    .o_data                            (vout_data                 ) 
);

//HDMI输出
wire                            video_clk;                 //video pixel clock
wire                            hs;
wire                            vs;
wire                            de;
wire[15:0]                      vout_data;

//最后的输出
assign  hs_out    = hs;
assign  vs_out     = vs;
assign  de_out    = de;
assign r_out      = {vout_data[15:11], vout_data[15:13]};
assign g_out      = {vout_data[10:5], vout_data[10:9]};  
assign b_out      = {vout_data[4:0], vout_data[4:2]};    














//////////////////////////****************************//////////////////
//读写控制

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
	.read_len                   (25'd129600              ),//frame size  
	.read_en                    (ch2_read_en              ),
	.read_data                  (ch2_read_data            ),

	.wr_burst_req               (ch2_wr_burst_req         ),
	.wr_burst_len               (ch2_wr_burst_len         ),
	.wr_burst_addr              (ch2_wr_burst_addr        ),
	.wr_burst_data_req          (ch2_wr_burst_data_req    ),
	.wr_burst_data              (ch2_wr_burst_data        ),
	.wr_burst_finish            (ch2_wr_burst_finish      ),
	.write_clk                  (rx_clk               ),
	.write_req                  (ch2_write_req            ),
	.write_req_ack              (ch2_write_req_ack        ),
	.write_finish               (                         ),
	.write_addr_0               (25'd1036800              ),
	.write_addr_1               (25'd3110400              ),
	.write_addr_2               (25'd5184000              ),
	.write_addr_3               (25'd7257600              ),
	.write_addr_index           (ch2_write_addr_index     ),
	.write_len                  (25'd129600               ),//1920x1080/16
	.write_en                   (ch2_write_en             ),
	.write_data                 (ch2_write_data           )
);

///////////////*************hsst core *********///////////

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
    .i_p_tx2_clk_fr_core               (o_p_clk2core_tx_2         ),// input  //tx2_clk
    .i_p_tx3_clk_fr_core               (o_p_clk2core_tx_2         ),// input  //tx3_clk
    .i_p_rx2_clk_fr_core               (o_p_clk2core_tx_2         ),// input  //rx2_clk
    .i_p_rx3_clk_fr_core               (o_p_clk2core_tx_2         ),// input  //rx3_clk

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

//channel 2 tx  lane0
    .i_txd_2                           (i_txd_2                   ),// input [31:0]
    .i_tdispsel_2                      (4'b0              ),// input [3:0]
    .i_tdispctrl_2                     (4'b0             ),// input [3:0]
    .i_txk_2                           (i_txk_2                   ),// input [3:0]
//channel 3 tx   lane1
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
//channel 3 rx
    .o_rxstatus_3                      (o_rxstatus_3              ),// output [2:0]
    .o_rxd_3                           (o_rxd_3                   ),// output [31:0]
    .o_rdisper_3                       (o_rdisper_3               ),// output [3:0]
    .o_rdecer_3                        (o_rdecer_3                ),// output [3:0]
    .o_rxk_3                           (o_rxk_3                   )// output [3:0]

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
	// .ch0_rd_burst_req             (ch3_rd_burst_req),
	// .ch0_rd_burst_len             (ch3_rd_burst_len),
	// .ch0_rd_burst_addr            (ch3_rd_burst_addr),
	// .ch0_rd_burst_data_valid      (ch3_rd_burst_data_valid),
	// .ch0_rd_burst_data            (ch3_rd_burst_data),
	// .ch0_rd_burst_finish          (ch3_rd_burst_finish),
	
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

    // .ch3_rd_burst_req             (ch4_rd_burst_req),
	// .ch3_rd_burst_len             (ch4_rd_burst_len),
	// .ch3_rd_burst_addr            (ch4_rd_burst_addr),
	// .ch3_rd_burst_data_valid      (ch4_rd_burst_data_valid),
	// .ch3_rd_burst_data            (ch4_rd_burst_data),
	// .ch3_rd_burst_finish          (ch4_rd_burst_finish),

	
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
	
    // .ch0_wr_burst_req                  (ch3_wr_burst_req          ),
    // .ch0_wr_burst_len                  (ch3_wr_burst_len          ),
    // .ch0_wr_burst_addr                 (ch3_wr_burst_addr         ),
    // .ch0_wr_burst_data_req             (ch3_wr_burst_data_req     ),
    // .ch0_wr_burst_data                 (ch3_wr_burst_data         ),
    // .ch0_wr_burst_finish               (ch3_wr_burst_finish       ),
	
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

    // .ch3_wr_burst_req                  (ch4_wr_burst_req          ),
    // .ch3_wr_burst_len                  (ch4_wr_burst_len          ),
    // .ch3_wr_burst_addr                 (ch4_wr_burst_addr         ),
    // .ch3_wr_burst_data_req             (ch4_wr_burst_data_req     ),
    // .ch3_wr_burst_data                 (ch4_wr_burst_data         ),
    // .ch3_wr_burst_finish               (ch4_wr_burst_finish       ),

    .wr_burst_req                      (wr_burst_req              ),
    .wr_burst_len                      (wr_burst_len              ),
    .wr_burst_addr                     (wr_burst_addr             ),
    .wr_burst_data_req                 (wr_burst_data_req         ),
    .wr_burst_data                     (wr_burst_data             ),
    .wr_burst_finish                   (wr_burst_finish           ) 
);





///////////////////////********************ddr**************////////////////
// 心跳信号，用于指示系统是否正常工作
wire                                    pll_lock                   ;
wire                                    ddr_init_done              ;
wire                                    ddrphy_rst_done            ;
wire                                    core_clk                   ;
assign core_clk=ui_clk;
    reg  [26:0]                 cnt                        ;// 计数器
    parameter TH_1S = 27'd33000000;         // 1 秒计数器阈值
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



/////*************iic config*********//////

    reg [15:0]  rstn_1ms       ;
    wire        cfg_clk        ;
    wire        locked         ;



    ms72xx_ctl ms72xx_ctl(
        .clk         (  cfg_clk    ), //input       clk,
        .rst_n       (  rstn_out   ), //input       rstn,
                                
        .init_over   (  init_over  ), //output      init_over,
        .iic_tx_scl  (  iic_tx_scl ), //output      iic_scl,
        .iic_tx_sda  (  iic_tx_sda ), //inout       iic_sda
        .iic_scl     (  iic_scl    ), //output      iic_scl,
        .iic_sda     (  iic_sda    )  //inout       iic_sda
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
    
    assign rstn_out = (rstn_1ms == 16'h2710);
////////*******************************///////////////





/////ethernet****************
wire                   [   7:0]         gmii_txd                   ;
wire                                    gmii_tx_en                 ;
wire                                    gmii_tx_clk                ;
wire                   [   7:0]         gmii_rxd                   ;
wire                                    gmii_rx_dv                 ;
wire                                    gmii_rx_clk                ;
//////

wire                   [   7:0]         rec_data_m1                ;
wire                   [   15:0]         rec_data_m2                ;
wire                   [  15:0]         data_cnt                   ;
wire                                    rec_en                     ;
wire [15:0]  rec_byte_num;
//以太网接收模块    
udp_rx_real u_udp_rx(
    .clk                               (gmii_rx_clk               ),
    .rst_n                             (rst_n                     ),
    .gmii_rx_dv                        (gmii_rx_dv                ),
    .gmii_rxd                          (gmii_rxd                  ),
    .rec_pkt_done                      (rec_pkt_done              ),
    .rec_data                          (rec_data                  ),//o          
    .rec_byte_num                      (rec_byte_num              ),//o 
    .rec_data_m2                       (rec_data_m2               ),

    .rec_en                            (rec_en                    ),//o  
    .rec_data_m1                       (rec_data_m1               ),
    .data_cnt                          (data_cnt                  ) 
    );  


///////////**********hsst tx 给视频板**********//////////////

reg toggle; // 用于在两个状态间切换

always @(posedge tx_clk) begin
    // 使用 toggle 信号切换 i_txk_2 的值
    if (toggle) begin
        i_txd_2 <= 32'hff_55_55_bc;
        i_txk_2 <= 4'b0001; // 第一个周期，标记最后一个字节为 Special Code-group
    end else begin
        i_txd_2 <= rec_data_m2;
        i_txk_2 <= 4'b0000; // 第二个周期，标记所有字节为 Data Code-groups
    end

    // 切换 toggle 信号
    toggle <= ~toggle;
end

///////////******************************///////////////
reset_dly delay_u0(
.clk       (sys_clk        ),
.rst_n     (rst_n ),
.rst_n_dly (phy_rst_n          )
);

util_gmii_to_rgmii util_gmii_to_rgmii_m0(
    .reset                             (1'b0                      ),
	
    .rgmii_td                          (rgmii_txd                 ),
    .rgmii_tx_ctl                      (rgmii_txctl               ),
    .rgmii_txc                         (rgmii_txc                 ),
    .rgmii_rd                          (rgmii_rxd                 ),
    .rgmii_rx_ctl                      (rgmii_rxctl               ),
    .gmii_rx_clk                       (gmii_rx_clk               ),
    .gmii_txd                          (gmii_txd                  ),
    .gmii_tx_en                        (gmii_tx_en                ),
    .gmii_tx_er                        (1'b0                      ),
    .gmii_tx_clk                       (gmii_tx_clk               ),
    .gmii_rxd                          (gmii_rxd                  ),
    .rgmii_rxc                         (rgmii_rxc                 ),//add
    .gmii_rx_dv                        (gmii_rx_dv                ),
    .speed_selection                   (2'b10                     ),
    .duplex_mode                       (1'b1                      ),
    .led                               (led                       ),
    .pll_phase_shft_lock               (                          ),
    .clk                               (                          ),
    .sys_clk                           (sys_clk                   ) 
	);


mac_test mac_test0
(
 .gmii_tx_clk            (gmii_tx_clk        ),
 .gmii_rx_clk            (gmii_rx_clk        ) ,
 .rst_n                  (rst_n              ),
 
 .cmos_vsync              (cmos_vsync        ),
 .cmos_href               (cmos_href         ),
 .fifo_data               (fifo_data         ),    
 .fifo_data_count         (fifo_data_count   ),      
 .fifo_rd_en              (fifo_rd_en        ),     
 
 
 .udp_send_data_length   (16'd1280           ), 
 .gmii_rx_dv             (gmii_rx_dv         ),
 .gmii_rxd               (gmii_rxd           ),
 .gmii_tx_en             (gmii_tx_en         ),
 .gmii_txd               (gmii_txd           )
 
);

endmodule