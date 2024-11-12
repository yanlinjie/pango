
//图像处理数据流：缩放→亮度→色度
//缩放分辨率：改时钟，改ddr3帧地址大小
module hdmi_data_in (

    input                               pix_clk                    ,// 输入像素时钟信号
    input                                rst_n,
    input                               resize_out                 ,

    input                               ctr                        ,//缩放控制
    input [7:0]brightness_ctr,
    input [7:0]hue_ctr,

    input                               vs_in/*synthesis PAP_MARK_DEBUG="1"*/                      ,// 输入垂直同步信号
    input                               hs_in                      ,// 输入水平同步信号
    input                               de_in/*synthesis PAP_MARK_DEBUG="1"*/                      ,// 输入数据使能信号
    input              [   7:0]         r_in/*synthesis PAP_MARK_DEBUG="1"*/                       ,
    input              [   7:0]         g_in                       ,
    input              [   7:0]         b_in                       ,

    output                              clk_out                    ,   
    output                              vs_out                     ,// 输出垂直同步信号
    output                              de_out                     ,// 输出数据使能信号
    output          [  15:0]         rgb565_out,

    input [15:0] Width_in,//输入视频分辨率
    input [15:0] Height_in,
    input [15:0] Width_out,//输出视频分辨率
    input [15:0] Height_out
);

wire  resize_de_out;
wire  [23:0] resize_data_out;
wire  [15:0] resize_data_out_1;


wire [7:0]brightness_ctr;
wire [7:0]hue_ctr;

wire resize_vs_out;
wire [15:0]img_data;
wire [23:0] img_data_888;
assign img_data = {r_in[7:3], g_in[7:2], b_in[7:3]};
assign img_data_888 = {r_in, g_in, b_in};

assign resize_data_out_1 = {resize_data_out[23:19],resize_data_out[15:10],resize_data_out[7:3]};
assign clk_out=(ctr == 1) ? pix_clk : pix_clk;
assign vs_out=(ctr == 1) ? vs_in : resize_vs_out;
assign rgb565_out = (ctr == 1) ? img_data : resize_data_out_1;
assign de_out=(ctr == 1) ? de_in : resize_de_out;

wire [15:0] Width_in;//输入视频分辨率
wire [15:0] Height_in;
wire [15:0] Width_out;//输出视频分辨率
wire [15:0] Height_out;


video_scale_down_near  u_video_scale_down (
    .vin_clk                           (pix_clk                   ),// 输入时钟信号
    .rst_n                             (rst_n                     ),// 复位信号，低有效
    .frame_vs                      (vs_in                     ),// 输入视频帧同步复位信号
    .vin_dat                           (img_data_888              ),// 输入视频数据
    .vin_valid                         (de_in                     ),// 输入视频数据有效信号
    .vin_ready                         (vin_ready                 ),// 输入准备好信号//out
    .vout_dat                          (vout_dat                  ),// 输出视频数据
    .vout_valid                        (post_img_href                ),// 输出视频数据有效信号
    .vout_ready                        (1'b1                      ),// 输出准备好信号
    .vin_xres                          (Width_in                 ),// 输入视频水平分辨率 1024  //in
    .vin_yres                          (Height_in                   ),// 输入视频垂直分辨率 768  //in
    .vout_xres                         (Width_out                   ),// 输出视频水平分辨率 640 //in
    .vout_yres                         (Height_out                   ) // 输出视频垂直分辨率 480  //in
);

// video_scale_near_v2  u_video_scale_down (
//     .vout_clk(pix_clk),
//     .vin_clk                           (pix_clk                   ),// 输入时钟信号
//     .rst_n                             (rst_n                     ),// 复位信号，低有效
//     .frame_vs                      (vs_in                     ),// 输入视频帧同步复位信号
//     .vin_dat                           (img_data_888              ),// 输入视频数据
//     .vin_valid                         (de_in                     ),// 输入视频数据有效信号
//     .vin_ready                         (vin_ready                 ),// 输入准备好信号//out
//     .vout_dat                          (vout_dat                  ),// 输出视频数据
//     .vout_valid                        (post_img_href                ),// 输出视频数据有效信号
//     .vout_ready                        (1'b1                      ),// 输出准备好信号
//     .vin_xres                          (Width_in                 ),// 输入视频水平分辨率 1024  //in
//     .vin_yres                          (Height_in                   ),// 输入视频垂直分辨率 768  //in
//     .vout_xres                         (Width_out                   ),// 输出视频水平分辨率 640 //in
//     .vout_yres                         (Height_out                   ) // 输出视频垂直分辨率 480  //in
// );

wire                            post_img1_vsync;
wire                            post_img1_href;
wire            [15:0]           post_img1_gray;



wire post_img_vsync;
wire post_img_href;
wire [23:0] vout_dat;

//亮度增强
image_brightness image_brightness_inst
(
    .clk                               (pix_clk                ),//时钟输入
    .rst_n                             (rst_n                     ),//复位

    .brightness_cnt                    (brightness_ctr                   ),//100为原值

    .i_vs                              (vs_in            ),
    .i_de                              (post_img_href             ),//图像有效显示区域
    .i_data                            (vout_dat             ),//输入RGB图像


    .o_vs                              (brightness_vs             ),
    .o_de                              (brightness_de             ),//图像有效显示区域 
    .o_data                            (brightness_data           ) //输出8bits的灰度图像
);


wire brightness_vs;
wire brightness_de;
wire [23:0] brightness_data;


//色度增强
image_contrast image_contrast_inst
(
    .i_clk                             (pix_clk                ),//时钟输入
    .i_rst_n                           (rst_n                     ),//复位

    .hue_cnt                           (hue_ctr                   ),//100为原值

    .i_vs                              (brightness_vs             ),
    .i_de                              (brightness_de             ),//图像有效显示区域
    .i_data                            (brightness_data           ),//输入RGB图像


    .o_vs                              (resize_vs_out                    ),
    .o_de                              (resize_de_out             ),//图像有效显示区域 
    .o_data                            (resize_data_out           ) //输出8bits的灰度图像
);


endmodule