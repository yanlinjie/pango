/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
////////////////////////////////////////////////////////////////////////////
//Functional description: ipsxb_qsgmii_reg_slave

`timescale 1ns/1ps
module ipsxb_qsgmii_reg_slave(
//Clock for sync
    input  wire        clk_tx                ,
    input  wire        clk_rx                ,
    input  wire        pcs_rx_clk            ,
//APB In
    input  wire        cfg_clk               ,
    input  wire        cfg_rstn              ,
    input  wire        cfg_psel              ,
    input  wire        cfg_enable            ,
    input  wire        cfg_write             ,
    input  wire [31:0] cfg_addr              ,
    input  wire [31:0] cfg_wdata             ,
    output wire [31:0] cfg_rdata             ,
    output wire        cfg_ready             ,
//To Core APB
    output wire        qsgmii_psel           ,
    output wire        qsgmii_write          ,
    output wire        qsgmii_enable         ,
    output wire [20:0] qsgmii_addr           ,
    output wire [31:0] qsgmii_wdata          ,
    input  wire [31:0] qsgmii_rdata          ,
    input  wire        qsgmii_ready          ,
//Ctrl Signals
    output wire [3:0]  pma_nearend_sloop     ,
    output wire [3:0]  pma_nearend_ploop     ,
    output wire [3:0]  pcs_farend_loop       ,
    output wire [3:0]  pcs_nearend_loop      ,
    output wire        rg_external_sof_rst_n ,
//Port0
    output wire [4:0]  p0_phy_addr           ,
    output wire        p0_pin_cfg_en         ,
    output wire        p0_phy_duplex         ,
    output wire        p0_phy_link           ,
    output wire        p0_unidir_en          ,
    output wire        p0_an_restart         ,
    output wire        p0_an_enable          ,
    output wire        p0_loopback           ,
    output wire [1:0]  p0_phy_speed          ,
    output wire        p0_rg_start_test      ,
    output wire        p0_rg_length_cfg_en   ,
    output wire [18:0] p0_rg_length_num      ,
    output wire        p0_rg_pld_max_sel     ,
    output wire        p0_rg_ipg_max_sel     ,
    output wire        p0_rg_pre_max_sel     ,
    output wire        p0_rg_burst_tx_en     ,
    output wire        p0_rg_pre_cfg_en      ,
    output wire [3:0]  p0_rg_pre_num         ,
    output wire        p0_rg_ipg_cfg_en      ,
    output wire [7:0]  p0_rg_ipg_num         ,
    output wire [3:0]  p0_rg_pkg_chk_clr     ,
    output wire        p0_rg_pkg_send_clr    ,
    input  wire [31:0] p0_pkg_gen_cnt        ,
    input  wire [31:0] p0_crc_ok_cnt         ,
    input  wire [31:0] p0_crc_err_cnt        ,
    input  wire [31:0] p0_rcving_cnt         ,
    input  wire [31:0] p0_byte_cnt           ,
    input  wire [15:0] p0_status_vector      ,
//Port1
    output wire [4:0]  p1_phy_addr           ,
    output wire        p1_pin_cfg_en         ,
    output wire        p1_phy_duplex         ,
    output wire        p1_phy_link           ,
    output wire        p1_unidir_en          ,
    output wire        p1_an_restart         ,
    output wire        p1_an_enable          ,
    output wire        p1_loopback           ,
    output wire [1:0]  p1_phy_speed          ,  
    output wire        p1_rg_start_test      ,
    output wire        p1_rg_length_cfg_en   ,
    output wire [18:0] p1_rg_length_num      ,
    output wire        p1_rg_pld_max_sel     ,
    output wire        p1_rg_ipg_max_sel     ,
    output wire        p1_rg_pre_max_sel     ,
    output wire        p1_rg_burst_tx_en     ,
    output wire        p1_rg_pre_cfg_en      ,
    output wire [3:0]  p1_rg_pre_num         ,
    output wire        p1_rg_ipg_cfg_en      ,
    output wire [7:0]  p1_rg_ipg_num         ,
    output wire [3:0]  p1_rg_pkg_chk_clr     ,
    output wire        p1_rg_pkg_send_clr    ,
    input  wire [31:0] p1_pkg_gen_cnt        ,
    input  wire [31:0] p1_crc_ok_cnt         ,
    input  wire [31:0] p1_crc_err_cnt        ,
    input  wire [31:0] p1_rcving_cnt         ,
    input  wire [31:0] p1_byte_cnt           ,
    input  wire [15:0] p1_status_vector      ,
//Port2
    output wire [4:0]  p2_phy_addr           ,
    output wire        p2_pin_cfg_en         ,
    output wire        p2_phy_duplex         ,
    output wire        p2_phy_link           ,
    output wire        p2_unidir_en          ,
    output wire        p2_an_restart         ,
    output wire        p2_an_enable          ,
    output wire        p2_loopback           ,
    output wire [1:0]  p2_phy_speed          ,
    output wire        p2_rg_start_test      ,
    output wire        p2_rg_length_cfg_en   ,
    output wire [18:0] p2_rg_length_num      ,
    output wire        p2_rg_pld_max_sel     ,
    output wire        p2_rg_ipg_max_sel     ,
    output wire        p2_rg_pre_max_sel     ,
    output wire        p2_rg_burst_tx_en     ,
    output wire        p2_rg_pre_cfg_en      ,
    output wire [3:0]  p2_rg_pre_num         ,
    output wire        p2_rg_ipg_cfg_en      ,
    output wire [7:0]  p2_rg_ipg_num         ,    
    output wire [3:0]  p2_rg_pkg_chk_clr     ,
    output wire        p2_rg_pkg_send_clr    ,
    input  wire [31:0] p2_pkg_gen_cnt        ,
    input  wire [31:0] p2_crc_ok_cnt         ,
    input  wire [31:0] p2_crc_err_cnt        ,
    input  wire [31:0] p2_rcving_cnt         ,
    input  wire [31:0] p2_byte_cnt           ,
    input  wire [15:0] p2_status_vector      ,
//Port3
    output wire [4:0]  p3_phy_addr           ,
    output wire        p3_pin_cfg_en         ,
    output wire        p3_phy_duplex         ,
    output wire        p3_phy_link           ,
    output wire        p3_unidir_en          ,
    output wire        p3_an_restart         ,
    output wire        p3_an_enable          ,
    output wire        p3_loopback           ,
    output wire [1:0]  p3_phy_speed          ,
    output wire        p3_rg_start_test      ,
    output wire        p3_rg_length_cfg_en   ,
    output wire [18:0] p3_rg_length_num      ,
    output wire        p3_rg_pld_max_sel     ,
    output wire        p3_rg_ipg_max_sel     ,
    output wire        p3_rg_pre_max_sel     ,
    output wire        p3_rg_burst_tx_en     ,
    output wire        p3_rg_pre_cfg_en      ,
    output wire [3:0]  p3_rg_pre_num         ,
    output wire        p3_rg_ipg_cfg_en      ,
    output wire [7:0]  p3_rg_ipg_num         ,
    output wire [3:0]  p3_rg_pkg_chk_clr     ,
    output wire        p3_rg_pkg_send_clr    ,
    input  wire [31:0] p3_pkg_gen_cnt        ,
    input  wire [31:0] p3_crc_ok_cnt         ,
    input  wire [31:0] p3_crc_err_cnt        ,
    input  wire [31:0] p3_rcving_cnt         ,
    input  wire [31:0] p3_byte_cnt           ,
    input  wire [15:0] p3_status_vector      ,

    output wire        rg_wtchdg_sof_clr     ,
    output wire [3:0]  rg_rx_lane_sof_rst_n  ,
    output wire [3:0]  rg_tx_lane_sof_rst_n  ,
    output wire        rg_tx_pll_sof_rst_n   ,
    output wire        rg_hsst_cfg_soft_rstn ,
    output wire        p0_rg_soft_rstn       ,
    output wire        p1_rg_soft_rstn       ,
    output wire        p2_rg_soft_rstn       ,
    output wire        p3_rg_soft_rstn       ,
    input  wire        rdispdec_er           ,
    input  wire        signal_loss           ,
    input  wire        cdr_align             ,
    input  wire        tx_pll_lock           ,
    input  wire        lsm_synced
);

localparam DFT_CTRL_BUS_0 = 32'h04_03_02_01;
localparam DFT_CTRL_BUS_1 = 32'h01_12_00_10;
localparam DFT_CTRL_BUS_2 = 32'h00_00_00_00;
localparam DFT_CTRL_BUS_3 = 32'h00_00_00_00;
localparam DFT_CTRL_BUS_4 = 32'h00_00_00_00;
localparam DFT_CTRL_BUS_5 = 32'h00_00_00_40;
localparam DFT_CTRL_BUS_6 = 32'h00_06_00_0b;
localparam DFT_CTRL_BUS_7 = 32'h00_f4_ff_ff;

wire            ver_psel                ;
wire            ver_enable              ;
wire [15:0]     ver_addr                ;
wire            ver_write               ;
wire [31:0]     ver_wdata               ;
reg  [31:0]     ver_rdata               ;
wire            ver_ready               ;
reg             ver_psel_ff1            ;
reg             ver_psel_ff2            ;

wire [31:0]     p0_pkg_gen_cnt_sync     ;
wire [31:0]     p0_crc_ok_cnt_sync      ;
wire [31:0]     p0_crc_err_cnt_sync     ;
wire [31:0]     p0_rcving_cnt_sync      ;
wire [31:0]     p0_byte_cnt_sync        ;

wire [31:0]     p1_pkg_gen_cnt_sync     ;
wire [31:0]     p1_crc_ok_cnt_sync      ;
wire [31:0]     p1_crc_err_cnt_sync     ;
wire [31:0]     p1_rcving_cnt_sync      ;
wire [31:0]     p1_byte_cnt_sync        ;

wire [31:0]     p2_pkg_gen_cnt_sync     ;
wire [31:0]     p2_crc_ok_cnt_sync      ;
wire [31:0]     p2_crc_err_cnt_sync     ;
wire [31:0]     p2_rcving_cnt_sync      ;
wire [31:0]     p2_byte_cnt_sync        ;

wire [31:0]     p3_pkg_gen_cnt_sync     ;
wire [31:0]     p3_crc_ok_cnt_sync      ;
wire [31:0]     p3_crc_err_cnt_sync     ;
wire [31:0]     p3_rcving_cnt_sync      ;
wire [31:0]     p3_byte_cnt_sync        ;

wire            pos_dispdec_err         ;
reg             ff_dispdec_err          ;
wire            dispdec_err_sync        ;
reg             lh_dispdec_err          ;
wire            pos_buf_err             ;
wire            buf_err_sync            ;
reg             lh_buf_err              ;
reg             ff_buf_err              ;
reg             rdispdec_er_ff1         ;
reg             rdispdec_er_ff2         ;
wire            rg_rdispdec_er          ;
wire            buffer_er               ;
reg             buffer_er_ff1           ;
reg             buffer_er_ff2           ;
wire            rg_buffer_er            ;
wire            lh_buf_dispdec_rc       ;
wire            signal_loss_sync        ;
wire            cdr_align_sync          ;
wire            tx_pll_lock_sync        ;
wire            lsm_synced_sync         ;
reg             ff_signal_loss          ;
reg             ff_cdr_align            ;
reg             ff_lsm_synced           ;
reg             ff_tx_pll_lock          ;
wire            pos_signal_loss         ;
wire            neg_cdr_align           ;
wire            neg_lsm_synced          ;
wire            neg_tx_pll_lock         ;
wire            rc_flag                 ;
reg             lh_signal_loss          ;
reg             ll_tx_pll_lock          ;
reg             ll_cdr_align            ;
reg             ll_lsm_synced           ;
//All Port
wire            pin_cfg_en              ;
wire            phy_duplex              ;
wire            phy_link                ;
wire            unidir_en               ;
wire            an_restart              ;
wire            an_enable               ;
wire            loopback                ;
wire [1:0]      phy_speed               ;
wire            start_test              ;
wire            length_cfg_en           ;
wire [18:0]     length_num              ;
wire            pld_max_sel             ;
wire            ipg_max_sel             ;
wire            pre_max_sel             ;
wire            burst_tx_en             ;
wire            pre_cfg_en              ;
wire [3:0]      pre_num                 ;
wire            ipg_cfg_en              ;
wire [7:0]      ipg_num                 ;
wire            wtchdg_sof_clr          ;
//Port0
wire            p0_start_test           ;
wire            p0_length_cfg_en        ;
wire [18:0]     p0_length_num           ;
wire            p0_pld_max_sel          ;
wire            p0_ipg_max_sel          ;
wire            p0_pre_max_sel          ;
wire            p0_burst_tx_en          ;
wire            p0_pre_cfg_en           ;
wire [3:0]      p0_pre_num              ;
wire            p0_ipg_cfg_en           ;
wire [7:0]      p0_ipg_num              ;
wire [3:0]      p0_pkg_chk_clr          ;
wire            p0_pkg_send_clr         ;
wire [15:0]     p0_status_vector_sync   ;
//Port1
wire            p1_start_test           ;
wire            p1_length_cfg_en        ;
wire [18:0]     p1_length_num           ;
wire            p1_pld_max_sel          ;
wire            p1_ipg_max_sel          ;
wire            p1_pre_max_sel          ;
wire            p1_burst_tx_en          ;
wire            p1_pre_cfg_en           ;
wire [3:0]      p1_pre_num              ;
wire            p1_ipg_cfg_en           ;
wire [7:0]      p1_ipg_num              ;
wire [3:0]      p1_pkg_chk_clr          ;
wire            p1_pkg_send_clr         ;
wire [15:0]     p1_status_vector_sync   ;
//Port2
wire            p2_start_test           ;
wire            p2_length_cfg_en        ;
wire [18:0]     p2_length_num           ;
wire            p2_pld_max_sel          ;
wire            p2_ipg_max_sel          ;
wire            p2_pre_max_sel          ;
wire            p2_burst_tx_en          ;
wire            p2_pre_cfg_en           ;
wire [3:0]      p2_pre_num              ;
wire            p2_ipg_cfg_en           ;
wire [7:0]      p2_ipg_num              ;
wire [3:0]      p2_pkg_chk_clr          ;
wire            p2_pkg_send_clr         ;
wire [15:0]     p2_status_vector_sync   ;
//Port3
wire            p3_start_test           ;
wire            p3_length_cfg_en        ;
wire [18:0]     p3_length_num           ;
wire            p3_pld_max_sel          ;
wire            p3_ipg_max_sel          ;
wire            p3_pre_max_sel          ;
wire            p3_burst_tx_en          ;
wire            p3_pre_cfg_en           ;
wire [3:0]      p3_pre_num              ;
wire            p3_ipg_cfg_en           ;
wire [7:0]      p3_ipg_num              ;
wire [3:0]      p3_pkg_chk_clr          ;
wire            p3_pkg_send_clr         ;
wire [15:0]     p3_status_vector_sync   ;

wire [31:0]     status_bus_00           ;
wire [31:0]     status_bus_10           ;
wire [31:0]     status_bus_20           ;
wire [31:0]     status_bus_30           ;
wire [31:0]     status_bus_01           ;
wire [31:0]     status_bus_11           ;
wire [31:0]     status_bus_21           ;
wire [31:0]     status_bus_31           ;
wire [31:0]     status_bus_02           ;
wire [31:0]     status_bus_12           ;
wire [31:0]     status_bus_22           ;
wire [31:0]     status_bus_32           ;
wire [31:0]     status_bus_03           ;
wire [31:0]     status_bus_13           ;
wire [31:0]     status_bus_23           ;
wire [31:0]     status_bus_33           ;
wire [31:0]     status_bus_04           ;
wire [31:0]     status_bus_05           ;
wire [31:0]     status_bus_06           ;
wire [31:0]     status_bus_07           ;
wire [31:0]     status_bus_08           ;
wire [31:0]     status_bus_09           ;
wire [31:0]     status_bus_0a           ;
wire [31:0]     status_bus_1a           ;
wire [31:0]     status_bus_2a           ;
wire [31:0]     status_bus_3a           ;
reg  [31:0]     ctrl_bus_00             ;
reg  [31:0]     ctrl_bus_01             ;
reg  [31:0]     ctrl_bus_11             ;
reg  [31:0]     ctrl_bus_21             ;
reg  [31:0]     ctrl_bus_31             ;
reg  [31:0]     ctrl_bus_41             ;
reg  [31:0]     ctrl_bus_02             ;
reg  [31:0]     ctrl_bus_03             ;
reg  [31:0]     ctrl_bus_04             ;
reg  [31:0]     ctrl_bus_05             ;
reg  [31:0]     ctrl_bus_15             ;
reg  [31:0]     ctrl_bus_25             ;
reg  [31:0]     ctrl_bus_35             ;
reg  [31:0]     ctrl_bus_45             ;
reg  [31:0]     ctrl_bus_06             ;
reg  [31:0]     ctrl_bus_16             ;
reg  [31:0]     ctrl_bus_26             ;
reg  [31:0]     ctrl_bus_36             ;
reg  [31:0]     ctrl_bus_46             ;
reg  [31:0]     ctrl_bus_07             ;

wire [127:0]    pkg_gen_cnt             ;
wire [127:0]    crc_ok_cnt              ;
wire [127:0]    crc_err_cnt             ;
wire [127:0]    rcving_cnt              ;
wire [127:0]    byte_cnt                ;
wire [127:0]    pkg_gen_cnt_sync        ;
wire [127:0]    crc_ok_cnt_sync         ;
wire [127:0]    crc_err_cnt_sync        ;
wire [127:0]    rcving_cnt_sync         ;
wire [127:0]    byte_cnt_sync           ;
wire [63:0]     status_vector           ;
wire [63:0]     status_vector_sync      ;
wire [3:0]      i_start_test            ;
wire [3:0]      i_pkg_send_clr          ;
wire [3:0]      i_length_cfg_en         ;
wire [75:0]     i_length_num            ;
wire [3:0]      i_ipg_cfg_en            ;
wire [31:0]     i_ipg_num               ;
wire [3:0]      i_pre_cfg_en            ;
wire [15:0]     i_pre_num               ;
wire [3:0]      i_pld_max_sel           ;
wire [3:0]      i_ipg_max_sel           ;
wire [3:0]      i_pre_max_sel           ;
wire [3:0]      i_burst_tx_en           ;
wire [3:0]      start_test_sync         ;
wire [3:0]      pkg_send_clr_sync       ;
wire [3:0]      length_cfg_en_sync      ;
wire [75:0]     length_num_sync         ;
wire [3:0]      ipg_cfg_en_sync         ;
wire [31:0]     ipg_num_sync            ;
wire [3:0]      pre_cfg_en_sync         ;
wire [15:0]     pre_num_sync            ;
wire [3:0]      pld_max_sel_sync        ;
wire [3:0]      ipg_max_sel_sync        ;
wire [3:0]      pre_max_sel_sync        ;
wire [3:0]      burst_tx_en_sync        ;
wire [15:0]     pkg_chk_clr             ;
wire [15:0]     rg_pkg_chk_clr          ;

//****************************************************************************//
//                       APB_SEL                                   //
//****************************************************************************//

always @ (posedge cfg_clk or negedge cfg_rstn) begin
    if(!cfg_rstn) begin
        ver_psel_ff1 <= 1'b0;
        ver_psel_ff2 <= 1'b0;
    end
    else begin
        ver_psel_ff1 <= ver_psel;
        ver_psel_ff2 <= ver_psel_ff1;
    end
end
assign ver_ready = ver_psel_ff1&(~ver_psel_ff2);

assign qsgmii_psel   = (cfg_addr[23] == 1'b1) ? cfg_psel : 1'b0;
assign qsgmii_write  = (cfg_addr[23] == 1'b1) ? cfg_write : 1'b0;
assign qsgmii_enable = (cfg_addr[23] == 1'b1) ? cfg_enable : 1'b0;
assign qsgmii_addr   = (cfg_addr[23] == 1'b1) ? cfg_addr[20:0] : 21'b0;
assign qsgmii_wdata  = (cfg_addr[23] == 1'b1) ? cfg_wdata : 32'b0;

assign ver_psel     = (cfg_addr[23] == 1'b0) ? cfg_psel : 1'b0;
assign ver_write    = (cfg_addr[23] == 1'b0) ? cfg_write : 1'b0;
assign ver_enable   = (cfg_addr[23] == 1'b0) ? cfg_enable : 1'b0;
assign ver_addr     = (cfg_addr[23] == 1'b0) ? cfg_addr[15:0] : 16'b0;
assign ver_wdata    = (cfg_addr[23] == 1'b0) ? cfg_wdata : 32'b0;

assign cfg_ready    = (cfg_addr[23] == 1'b1) ? qsgmii_ready : ver_ready;
assign cfg_rdata    = (cfg_addr[23] == 1'b1) ? qsgmii_rdata : ver_rdata;

//****************************************************************************//
//                       control and status                                   //
//****************************************************************************//
assign status_bus_00 = p0_pkg_gen_cnt_sync;
assign status_bus_10 = p1_pkg_gen_cnt_sync;
assign status_bus_20 = p2_pkg_gen_cnt_sync;
assign status_bus_30 = p3_pkg_gen_cnt_sync;
assign status_bus_01 = p0_crc_ok_cnt_sync ;
assign status_bus_11 = p1_crc_ok_cnt_sync ;
assign status_bus_21 = p2_crc_ok_cnt_sync ;
assign status_bus_31 = p3_crc_ok_cnt_sync ;
assign status_bus_02 = p0_crc_err_cnt_sync;
assign status_bus_12 = p1_crc_err_cnt_sync;
assign status_bus_22 = p2_crc_err_cnt_sync;
assign status_bus_32 = p3_crc_err_cnt_sync;
assign status_bus_03 = p0_rcving_cnt_sync ;
assign status_bus_13 = p1_rcving_cnt_sync ;
assign status_bus_23 = p2_rcving_cnt_sync ;
assign status_bus_33 = p3_rcving_cnt_sync ;
assign status_bus_04 = {16'b0,p0_status_vector_sync};
assign status_bus_05 = {16'b0,p1_status_vector_sync};
assign status_bus_06 = {16'b0,p2_status_vector_sync};
assign status_bus_07 = {16'b0,p3_status_vector_sync};
assign status_bus_08 = {16'b0,3'b0,signal_loss_sync,3'b0,cdr_align_sync,3'b0,tx_pll_lock_sync,3'b0,lsm_synced_sync};
assign status_bus_09 = {8'b0,3'b0,lh_dispdec_err,3'b0,lh_buf_err,3'b0,lh_signal_loss,3'b0,ll_cdr_align,3'b0,ll_tx_pll_lock,3'b0,ll_lsm_synced};
assign status_bus_0a = p0_byte_cnt_sync   ;
assign status_bus_1a = p1_byte_cnt_sync   ;
assign status_bus_2a = p2_byte_cnt_sync   ;
assign status_bus_3a = p3_byte_cnt_sync   ;

//MDIO Phy addr cfg
assign p0_phy_addr = ctrl_bus_00[4:0]  ;
assign p1_phy_addr = ctrl_bus_00[12:8] ;
assign p2_phy_addr = ctrl_bus_00[20:16];
assign p3_phy_addr = ctrl_bus_00[28:24];

//Port Control
//All Port
assign pin_cfg_en    = ctrl_bus_41[28];
assign phy_duplex    = ctrl_bus_41[24];
assign phy_link      = ctrl_bus_41[20];
assign phy_speed     = ctrl_bus_41[17:16];
assign unidir_en     = ctrl_bus_41[12];
assign loopback      = ctrl_bus_41[8];
assign an_enable     = ctrl_bus_41[4];
assign an_restart    = ctrl_bus_41[0];
//Port0
assign p0_pin_cfg_en = pin_cfg_en ? 1'b1 : ctrl_bus_01[28];
assign p0_phy_duplex = pin_cfg_en ? phy_duplex : ctrl_bus_01[24];
assign p0_phy_link   = pin_cfg_en ? phy_link : ctrl_bus_01[20];
assign p0_phy_speed  = pin_cfg_en ? phy_speed : ctrl_bus_01[17:16];
assign p0_unidir_en  = pin_cfg_en ? unidir_en : ctrl_bus_01[12];
assign p0_loopback   = pin_cfg_en ? loopback : ctrl_bus_01[8];
assign p0_an_enable  = pin_cfg_en ? an_enable : ctrl_bus_01[4];
assign p0_an_restart = pin_cfg_en ? an_restart : ctrl_bus_01[0];
//Port1
assign p1_pin_cfg_en = pin_cfg_en ? 1'b1 : ctrl_bus_11[28];
assign p1_phy_duplex = pin_cfg_en ? phy_duplex : ctrl_bus_11[24];
assign p1_phy_link   = pin_cfg_en ? phy_link : ctrl_bus_11[20];
assign p1_phy_speed  = pin_cfg_en ? phy_speed : ctrl_bus_11[17:16];
assign p1_unidir_en  = pin_cfg_en ? unidir_en : ctrl_bus_11[12];
assign p1_loopback   = pin_cfg_en ? loopback : ctrl_bus_11[8];
assign p1_an_enable  = pin_cfg_en ? an_enable : ctrl_bus_11[4];
assign p1_an_restart = pin_cfg_en ? an_restart : ctrl_bus_11[0];
//Port2
assign p2_pin_cfg_en = pin_cfg_en ? 1'b1 : ctrl_bus_21[28];
assign p2_phy_duplex = pin_cfg_en ? phy_duplex : ctrl_bus_21[24];
assign p2_phy_link   = pin_cfg_en ? phy_link : ctrl_bus_21[20];
assign p2_phy_speed  = pin_cfg_en ? phy_speed : ctrl_bus_21[17:16];
assign p2_unidir_en  = pin_cfg_en ? unidir_en : ctrl_bus_21[12];
assign p2_loopback   = pin_cfg_en ? loopback : ctrl_bus_21[8];
assign p2_an_enable  = pin_cfg_en ? an_enable : ctrl_bus_21[4];
assign p2_an_restart = pin_cfg_en ? an_restart : ctrl_bus_21[0];
//Port3
assign p3_pin_cfg_en = pin_cfg_en ? 1'b1 : ctrl_bus_31[28];
assign p3_phy_duplex = pin_cfg_en ? phy_duplex : ctrl_bus_31[24];
assign p3_phy_link   = pin_cfg_en ? phy_link : ctrl_bus_31[20];
assign p3_phy_speed  = pin_cfg_en ? phy_speed : ctrl_bus_31[17:16];
assign p3_unidir_en  = pin_cfg_en ? unidir_en : ctrl_bus_31[12];
assign p3_loopback   = pin_cfg_en ? loopback : ctrl_bus_31[8];
assign p3_an_enable  = pin_cfg_en ? an_enable : ctrl_bus_31[4];
assign p3_an_restart = pin_cfg_en ? an_restart : ctrl_bus_31[0];

//Pkg Test
assign start_test = ctrl_bus_02[0];
assign p0_start_test = start_test || ctrl_bus_02[4];
assign p1_start_test = start_test || ctrl_bus_02[8];
assign p2_start_test = start_test || ctrl_bus_02[12];
assign p3_start_test = start_test || ctrl_bus_02[16];

//Pkg Cnt Clr
assign p0_pkg_chk_clr  = ctrl_bus_03[3:0];
assign p0_pkg_send_clr = ctrl_bus_03[4];
assign p1_pkg_chk_clr  = ctrl_bus_03[11:8];
assign p1_pkg_send_clr = ctrl_bus_03[12];
assign p2_pkg_chk_clr  = ctrl_bus_03[19:16];
assign p2_pkg_send_clr = ctrl_bus_03[20];
assign p3_pkg_chk_clr  = ctrl_bus_03[27:24];
assign p3_pkg_send_clr = ctrl_bus_03[28];

//HSST Loopback
assign pcs_nearend_loop = ctrl_bus_04[3:0];
assign pcs_farend_loop  = ctrl_bus_04[7:4];
assign pma_nearend_ploop= ctrl_bus_04[11:8];
assign pma_nearend_sloop= ctrl_bus_04[15:12];

//Pkg Length
assign length_cfg_en = ctrl_bus_45[28];
assign length_num    = ctrl_bus_45[18:0];
assign p0_length_num = length_cfg_en ? length_num : ctrl_bus_05[18:0];
assign p0_length_cfg_en = length_cfg_en ? 1'b1 : ctrl_bus_05[28];
assign p1_length_num = length_cfg_en ? length_num : ctrl_bus_15[18:0];
assign p1_length_cfg_en = length_cfg_en ? 1'b1 : ctrl_bus_15[28];
assign p2_length_num = length_cfg_en ? length_num : ctrl_bus_25[18:0];
assign p2_length_cfg_en = length_cfg_en ? 1'b1 : ctrl_bus_25[28];
assign p3_length_num = length_cfg_en ? length_num : ctrl_bus_35[18:0];
assign p3_length_cfg_en = length_cfg_en ? 1'b1 : ctrl_bus_35[28];

//Pkg cfg
assign burst_tx_en = ctrl_bus_46[27];
assign pld_max_sel = ctrl_bus_46[26];
assign ipg_max_sel = ctrl_bus_46[25];
assign pre_max_sel = ctrl_bus_46[24];
assign pre_cfg_en  = ctrl_bus_46[20];
assign pre_num     = ctrl_bus_46[19:16];
assign ipg_cfg_en  = ctrl_bus_46[8];
assign ipg_num     = ctrl_bus_46[7:0];
//port0
assign p0_burst_tx_en = burst_tx_en ? 1'b1 : ctrl_bus_06[27];
assign p0_pld_max_sel = pld_max_sel ? 1'b1 : ctrl_bus_06[26];
assign p0_ipg_max_sel = ipg_max_sel ? 1'b1 : ctrl_bus_06[25];
assign p0_pre_max_sel = pre_max_sel ? 1'b1 : ctrl_bus_06[24];
assign p0_pre_cfg_en  = pre_cfg_en  ? 1'b1 : ctrl_bus_06[20];
assign p0_pre_num     = pre_cfg_en  ? pre_num : ctrl_bus_06[19:16];
assign p0_ipg_cfg_en  = ipg_cfg_en  ? 1'b1 : ctrl_bus_06[8];
assign p0_ipg_num     = ipg_cfg_en  ? ipg_num : ctrl_bus_06[7:0];
//Port1
assign p1_burst_tx_en = burst_tx_en ? 1'b1 : ctrl_bus_16[27];
assign p1_pld_max_sel = pld_max_sel ? 1'b1 : ctrl_bus_16[26];
assign p1_ipg_max_sel = ipg_max_sel ? 1'b1 : ctrl_bus_16[25];
assign p1_pre_max_sel = pre_max_sel ? 1'b1 : ctrl_bus_16[24];
assign p1_pre_cfg_en  = pre_cfg_en  ? 1'b1 : ctrl_bus_16[20];
assign p1_pre_num     = pre_cfg_en  ? pre_num : ctrl_bus_16[19:16];
assign p1_ipg_cfg_en  = ipg_cfg_en  ? 1'b1 : ctrl_bus_16[8];
assign p1_ipg_num     = ipg_cfg_en  ? ipg_num : ctrl_bus_16[7:0];
//Port2
assign p2_burst_tx_en = burst_tx_en ? 1'b1 : ctrl_bus_26[27];
assign p2_pld_max_sel = pld_max_sel ? 1'b1 : ctrl_bus_26[26];
assign p2_ipg_max_sel = ipg_max_sel ? 1'b1 : ctrl_bus_26[25];
assign p2_pre_max_sel = pre_max_sel ? 1'b1 : ctrl_bus_26[24];
assign p2_pre_cfg_en  = pre_cfg_en  ? 1'b1 : ctrl_bus_26[20];
assign p2_pre_num     = pre_cfg_en  ? pre_num : ctrl_bus_26[19:16];
assign p2_ipg_cfg_en  = ipg_cfg_en  ? 1'b1 : ctrl_bus_26[8];
assign p2_ipg_num     = ipg_cfg_en  ? ipg_num : ctrl_bus_26[7:0];
//Port3
assign p3_burst_tx_en = burst_tx_en ? 1'b1 : ctrl_bus_36[27];
assign p3_pld_max_sel = pld_max_sel ? 1'b1 : ctrl_bus_36[26];
assign p3_ipg_max_sel = ipg_max_sel ? 1'b1 : ctrl_bus_36[25];
assign p3_pre_max_sel = pre_max_sel ? 1'b1 : ctrl_bus_36[24];
assign p3_pre_cfg_en  = pre_cfg_en  ? 1'b1 : ctrl_bus_36[20];
assign p3_pre_num     = pre_cfg_en  ? pre_num : ctrl_bus_36[19:16];
assign p3_ipg_cfg_en  = ipg_cfg_en  ? 1'b1 : ctrl_bus_36[8];
assign p3_ipg_num     = ipg_cfg_en  ? ipg_num : ctrl_bus_36[7:0];

//Reset
assign rg_external_sof_rst_n = ctrl_bus_07[0];
assign rg_tx_pll_sof_rst_n   = ctrl_bus_07[4];
assign rg_tx_lane_sof_rst_n  = ctrl_bus_07[8];
assign rg_rx_lane_sof_rst_n  = ctrl_bus_07[15:12];
assign rg_wtchdg_sof_clr     = ctrl_bus_07[16];
assign rg_hsst_cfg_soft_rstn = ctrl_bus_07[18];
assign {p3_rg_soft_rstn,p2_rg_soft_rstn,p1_rg_soft_rstn,p0_rg_soft_rstn} = ctrl_bus_07[23:20];

////////////////////////////////////////////////////////////////////////////
//              Extend signal
///////////////////////////////////////////////////////////////////////////
always@(posedge pcs_rx_clk or negedge cfg_rstn)
begin
    if(!cfg_rstn)
    begin
        rdispdec_er_ff1<=    1'b0;
        rdispdec_er_ff2<=    1'b0;
    end
    else
    begin
        rdispdec_er_ff2<=    rdispdec_er_ff1;
        rdispdec_er_ff1<=    rdispdec_er    ;
    end
end

assign rg_rdispdec_er  =  rdispdec_er | rdispdec_er_ff1 | rdispdec_er_ff2;

assign buffer_er = p0_status_vector[6] | p1_status_vector[6] | p2_status_vector[6] | p3_status_vector[6];
always@(posedge clk_tx or negedge cfg_rstn)
begin
    if(!cfg_rstn)
    begin
        buffer_er_ff1  <=    1'b0;
        buffer_er_ff2  <=    1'b0;
    end
    else
    begin
        buffer_er_ff2  <=    buffer_er_ff1;
        buffer_er_ff1  <=    buffer_er;
    end
end

assign rg_buffer_er    =  buffer_er | buffer_er_ff1 | buffer_er_ff2;

// *************************************************************
// Synchronizer
// *************************************************************
ips2l_sgmii_sync_chain_v1_0  u_signal_loss (.i_clk(cfg_clk), .i_sig_presync(signal_loss ), .o_sig_synced(signal_loss_sync ));
ips2l_sgmii_sync_chain_v1_0  u_cdr_align (.i_clk(cfg_clk), .i_sig_presync(cdr_align ), .o_sig_synced(cdr_align_sync ));
ips2l_sgmii_sync_chain_v1_0  u_tx_pll_lock (.i_clk(cfg_clk), .i_sig_presync(tx_pll_lock ), .o_sig_synced(tx_pll_lock_sync ));
ips2l_sgmii_sync_chain_v1_0  u_lsm_synced (.i_clk(cfg_clk), .i_sig_presync(lsm_synced ), .o_sig_synced(lsm_synced_sync ));

ips2l_sgmii_sync_spreading_v1_0 #(.PIPE_NUMBER(5), .SYNC_VALUE(1)) U_synh_dispdec_err (.i_src_clk(pcs_rx_clk), .i_dec_clk(cfg_clk), .i_sig_presync(rg_rdispdec_er ), .o_sig_sync(dispdec_err_sync ));
ips2l_sgmii_sync_spreading_v1_0 #(.PIPE_NUMBER(5), .SYNC_VALUE(1)) U_synh_buf_err (.i_src_clk(clk_tx), .i_dec_clk(cfg_clk), .i_sig_presync(rg_buffer_er ), .o_sig_sync(buf_err_sync ));

assign pkg_gen_cnt = {p3_pkg_gen_cnt,p2_pkg_gen_cnt,p1_pkg_gen_cnt,p0_pkg_gen_cnt};
assign {p3_pkg_gen_cnt_sync,p2_pkg_gen_cnt_sync,p1_pkg_gen_cnt_sync,p0_pkg_gen_cnt_sync} = pkg_gen_cnt_sync;
assign crc_ok_cnt = {p3_crc_ok_cnt,p2_crc_ok_cnt,p1_crc_ok_cnt,p0_crc_ok_cnt};
assign {p3_crc_ok_cnt_sync,p2_crc_ok_cnt_sync,p1_crc_ok_cnt_sync,p0_crc_ok_cnt_sync} = crc_ok_cnt_sync;
assign crc_err_cnt = {p3_crc_err_cnt,p2_crc_err_cnt,p1_crc_err_cnt,p0_crc_err_cnt};
assign {p3_crc_err_cnt_sync,p2_crc_err_cnt_sync,p1_crc_err_cnt_sync,p0_crc_err_cnt_sync} = crc_err_cnt_sync;
assign rcving_cnt = {p3_rcving_cnt,p2_rcving_cnt,p1_rcving_cnt,p0_rcving_cnt};
assign {p3_rcving_cnt_sync,p2_rcving_cnt_sync,p1_rcving_cnt_sync,p0_rcving_cnt_sync} = rcving_cnt_sync;
assign byte_cnt   = {p3_byte_cnt,p2_byte_cnt,p1_byte_cnt,p0_byte_cnt};
assign {p3_byte_cnt_sync,p2_byte_cnt_sync,p1_byte_cnt_sync,p0_byte_cnt_sync} = byte_cnt_sync;

ips_sgmii_handshake_sync_v1_0 #(
    .DATA_WIDTH        (128                     ),
    .DFT_VALUE         (128'h0                  )
) u_pkg_gen_cnt (
    .src_clk           (clk_tx                 ),
    .src_rstn          (cfg_rstn               ),
    .src_data          (pkg_gen_cnt            ),
    .des_clk           (cfg_clk                ),
    .des_rstn          (cfg_rstn               ),
    .des_data          (pkg_gen_cnt_sync       )
);

ips_sgmii_handshake_sync_v1_0 #(
    .DATA_WIDTH        (512                    ),
    .DFT_VALUE         (512'h0                 )
) u_pkg_chk_cnt (
    .src_clk           (clk_rx                 ),
    .src_rstn          (cfg_rstn               ),
    .src_data          ({crc_ok_cnt           ,
                        crc_err_cnt           ,
                        rcving_cnt            ,
                        byte_cnt              }),
    .des_clk           (cfg_clk                ),
    .des_rstn          (cfg_rstn               ),
    .des_data          ({crc_ok_cnt_sync      ,
                        crc_err_cnt_sync      ,
                        rcving_cnt_sync       ,
                        byte_cnt_sync         })
);

assign status_vector = {p3_status_vector,p2_status_vector,p1_status_vector,p0_status_vector};
assign {p3_status_vector_sync,p2_status_vector_sync,p1_status_vector_sync,p0_status_vector_sync} = status_vector_sync;

ips_sgmii_handshake_sync_v1_0 #(
    .DATA_WIDTH        (64                     ),
    .DFT_VALUE         (64'h0                  )
) u_status_vector (
    .src_clk           (clk_tx                 ),
    .src_rstn          (cfg_rstn               ),
    .src_data          (status_vector          ),
    .des_clk           (cfg_clk                ),
    .des_rstn          (cfg_rstn               ),
    .des_data          (status_vector_sync     )
);

assign i_start_test = {p3_start_test,p2_start_test,p1_start_test,p0_start_test};
assign {p3_rg_start_test,p2_rg_start_test,p1_rg_start_test,p0_rg_start_test} = start_test_sync;
assign i_pkg_send_clr = {p3_pkg_send_clr,p2_pkg_send_clr,p1_pkg_send_clr,p0_pkg_send_clr};
assign {p3_rg_pkg_send_clr,p2_rg_pkg_send_clr,p1_rg_pkg_send_clr,p0_rg_pkg_send_clr} = pkg_send_clr_sync;
assign i_length_cfg_en = {p3_length_cfg_en,p2_length_cfg_en,p1_length_cfg_en,p0_length_cfg_en};
assign {p3_rg_length_cfg_en,p2_rg_length_cfg_en,p1_rg_length_cfg_en,p0_rg_length_cfg_en} = length_cfg_en_sync;
assign i_length_num = {p3_length_num,p2_length_num,p1_length_num,p0_length_num};
assign {p3_rg_length_num,p2_rg_length_num,p1_rg_length_num,p0_rg_length_num} = length_num_sync;
assign i_ipg_cfg_en = {p3_ipg_cfg_en,p2_ipg_cfg_en,p1_ipg_cfg_en,p0_ipg_cfg_en};
assign {p3_rg_ipg_cfg_en,p2_rg_ipg_cfg_en,p1_rg_ipg_cfg_en,p0_rg_ipg_cfg_en} = ipg_cfg_en_sync;
assign i_ipg_num = {p3_ipg_num,p2_ipg_num,p1_ipg_num,p0_ipg_num};
assign {p3_rg_ipg_num,p2_rg_ipg_num,p1_rg_ipg_num,p0_rg_ipg_num} = ipg_num_sync;
assign i_pre_cfg_en = {p3_pre_cfg_en,p2_pre_cfg_en,p1_pre_cfg_en,p0_pre_cfg_en};
assign {p3_rg_pre_cfg_en,p2_rg_pre_cfg_en,p1_rg_pre_cfg_en,p0_rg_pre_cfg_en} = pre_cfg_en_sync;
assign i_pre_num = {p3_pre_num,p2_pre_num,p1_pre_num,p0_pre_num};
assign {p3_rg_pre_num,p2_rg_pre_num,p1_rg_pre_num,p0_rg_pre_num} = pre_num_sync;
assign i_pld_max_sel = {p3_pld_max_sel,p2_pld_max_sel,p1_pld_max_sel,p0_pld_max_sel};
assign {p3_rg_pld_max_sel,p2_rg_pld_max_sel,p1_rg_pld_max_sel,p0_rg_pld_max_sel} = pld_max_sel_sync;
assign i_ipg_max_sel = {p3_ipg_max_sel,p2_ipg_max_sel,p1_ipg_max_sel,p0_ipg_max_sel};
assign {p3_rg_ipg_max_sel,p2_rg_ipg_max_sel,p1_rg_ipg_max_sel,p0_rg_ipg_max_sel} = ipg_max_sel_sync;
assign i_pre_max_sel = {p3_pre_max_sel,p2_pre_max_sel,p1_pre_max_sel,p0_pre_max_sel};
assign {p3_rg_pre_max_sel,p2_rg_pre_max_sel,p1_rg_pre_max_sel,p0_rg_pre_max_sel} = pre_max_sel_sync;
assign i_burst_tx_en = {p3_burst_tx_en,p2_burst_tx_en,p1_burst_tx_en,p0_burst_tx_en};
assign {p3_rg_burst_tx_en,p2_rg_burst_tx_en,p1_rg_burst_tx_en,p0_rg_burst_tx_en} = burst_tx_en_sync;

ips_sgmii_handshake_sync_v1_0 #(
    .DATA_WIDTH        (160                     ),
    .DFT_VALUE         ({4'b0                   ,
                        4'b0                    ,
                        4'b0                    ,
                        76'h0008000100002000040 ,
                        4'b0                    ,
                        32'h0c0c0c0c            ,
                        4'b0                    ,
                        16'h7777                ,
                        4'b0                    ,
                        4'b0                    ,
                        4'b0                    ,
                        4'b0                   })
) u_ver_ctrl(
    .src_clk           (cfg_clk                ),
    .src_rstn          (cfg_rstn               ),
    .src_data          ({i_start_test           ,
                        i_pkg_send_clr          ,
                        i_length_cfg_en         ,
                        i_length_num            ,
                        i_ipg_cfg_en            ,
                        i_ipg_num               ,
                        i_pre_cfg_en            ,
                        i_pre_num               ,
                        i_pld_max_sel           ,
                        i_ipg_max_sel           ,
                        i_pre_max_sel           ,
                        i_burst_tx_en           }),
    .des_clk           (clk_tx                 ),
    .des_rstn          (cfg_rstn               ),
    .des_data          ({start_test_sync        ,
                       pkg_send_clr_sync        ,
                       length_cfg_en_sync       ,
                       length_num_sync          ,
                       ipg_cfg_en_sync          ,
                       ipg_num_sync             ,
                       pre_cfg_en_sync          ,
                       pre_num_sync             ,
                       pld_max_sel_sync         ,
                       ipg_max_sel_sync         ,
                       pre_max_sel_sync         ,
                       burst_tx_en_sync         })
);

assign pkg_chk_clr = {p3_pkg_chk_clr,p2_pkg_chk_clr,p1_pkg_chk_clr,p0_pkg_chk_clr};
assign {p3_rg_pkg_chk_clr,p2_rg_pkg_chk_clr,p1_rg_pkg_chk_clr,p0_rg_pkg_chk_clr} = rg_pkg_chk_clr;

ips_sgmii_handshake_sync_v1_0 #(
    .DATA_WIDTH        (16                      ),
    .DFT_VALUE         (16'h0                   )
) u_pkg_chk_clr (
    .src_clk           (cfg_clk                 ),
    .src_rstn          (cfg_rstn                ),
    .src_data          (pkg_chk_clr             ),
    .des_clk           (clk_rx                  ),
    .des_rstn          (cfg_rstn                ),
    .des_data          (rg_pkg_chk_clr          )
);

////////////////////////////////////////////////////////////////////////////////////////////////
//                           lh and ll signals
///////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge cfg_clk or negedge cfg_rstn) begin
    if(!cfg_rstn)begin
        ff_signal_loss    <=    1'b0;
        ff_cdr_align      <=    1'b0;
        ff_lsm_synced     <=    1'b0;
        ff_tx_pll_lock    <=    1'b0;
        ff_buf_err        <=    1'b0;
        ff_dispdec_err    <=    1'b0;
    end
    else begin
        ff_signal_loss    <=    signal_loss_sync  ;
        ff_cdr_align      <=    cdr_align_sync    ;
        ff_lsm_synced     <=    lsm_synced_sync   ;
        ff_tx_pll_lock    <=    tx_pll_lock_sync  ;
        ff_buf_err        <=    buf_err_sync      ;
        ff_dispdec_err    <=    dispdec_err_sync  ;
    end
end

assign pos_signal_loss  =  signal_loss_sync    &  (~ff_signal_loss);
assign neg_cdr_align    =  (~cdr_align_sync)   &  ff_cdr_align     ;
assign neg_lsm_synced   =  (~lsm_synced_sync)  &  ff_lsm_synced    ;
assign neg_tx_pll_lock  =  (~tx_pll_lock_sync) &  ff_tx_pll_lock   ;
assign pos_buf_err      =  buf_err_sync        &  (~ff_buf_err)    ;
assign pos_dispdec_err  =  dispdec_err_sync    &  (~ff_dispdec_err);

assign rc_flag = (ver_psel == 1'b1) && (ver_write == 1'b0) &&(ver_enable == 1'b0) && (ver_addr == 16'h0009);

always @(posedge cfg_clk or negedge cfg_rstn)begin
    if(!cfg_rstn)begin
        lh_signal_loss     <=  1'b0;
        ll_cdr_align       <=  1'b0;
        ll_lsm_synced      <=  1'b0;
        ll_tx_pll_lock     <=  1'b0;
        lh_buf_err         <=  1'b0;
        lh_dispdec_err      <=  1'b0;
    end
    else begin
        lh_signal_loss     <=  pos_signal_loss ? 1'b1 : (rc_flag ? 1'b0 : lh_signal_loss    );
        ll_cdr_align       <=  neg_cdr_align   ? 1'b1 : (rc_flag ? 1'b0 : ll_cdr_align      );
        ll_lsm_synced      <=  neg_lsm_synced  ? 1'b1 : (rc_flag ? 1'b0 : ll_lsm_synced     );
        ll_tx_pll_lock     <=  neg_tx_pll_lock ? 1'b1 : (rc_flag ? 1'b0 : ll_tx_pll_lock    );
        lh_buf_err         <=  pos_buf_err     ? 1'b1 : (rc_flag ? 1'b0 : lh_buf_err        );
        lh_dispdec_err     <=  pos_dispdec_err ? 1'b1 : (rc_flag ? 1'b0 : lh_dispdec_err    );
    end
end
//Register Read
always @(posedge cfg_clk or negedge cfg_rstn)begin
    if(!cfg_rstn)begin
        ver_rdata <= 32'haaaaaaaa;
    end
    else if( (ver_psel==1'b1) && (ver_write==1'b0) && (ver_enable==1'b0) )begin
        case( ver_addr )
            16'h0000    :  ver_rdata  <=  status_bus_00;
            16'h0010    :  ver_rdata  <=  status_bus_10;
            16'h0020    :  ver_rdata  <=  status_bus_20;
            16'h0030    :  ver_rdata  <=  status_bus_30;
            16'h0001    :  ver_rdata  <=  status_bus_01;
            16'h0011    :  ver_rdata  <=  status_bus_11;
            16'h0021    :  ver_rdata  <=  status_bus_21;
            16'h0031    :  ver_rdata  <=  status_bus_31;
            16'h0002    :  ver_rdata  <=  status_bus_02;
            16'h0012    :  ver_rdata  <=  status_bus_12;
            16'h0022    :  ver_rdata  <=  status_bus_22;
            16'h0032    :  ver_rdata  <=  status_bus_32;
            16'h0003    :  ver_rdata  <=  status_bus_03;
            16'h0013    :  ver_rdata  <=  status_bus_13;
            16'h0023    :  ver_rdata  <=  status_bus_23;
            16'h0033    :  ver_rdata  <=  status_bus_33;
            16'h0004    :  ver_rdata  <=  status_bus_04;
            16'h0005    :  ver_rdata  <=  status_bus_05;
            16'h0006    :  ver_rdata  <=  status_bus_06;
            16'h0007    :  ver_rdata  <=  status_bus_07;
            16'h0008    :  ver_rdata  <=  status_bus_08;
            16'h0009    :  ver_rdata  <=  status_bus_09;
            16'h000a    :  ver_rdata  <=  status_bus_0a;
            16'h001a    :  ver_rdata  <=  status_bus_1a;
            16'h002a    :  ver_rdata  <=  status_bus_2a;
            16'h003a    :  ver_rdata  <=  status_bus_3a;
            default     :  ;
        endcase
    end
    else ;
end

//Register Write
always @(posedge cfg_clk or negedge cfg_rstn)begin
    if(!cfg_rstn)begin
        ctrl_bus_00    <= DFT_CTRL_BUS_0;
        ctrl_bus_01    <= DFT_CTRL_BUS_1;
        ctrl_bus_11    <= DFT_CTRL_BUS_1;
        ctrl_bus_21    <= DFT_CTRL_BUS_1;
        ctrl_bus_31    <= DFT_CTRL_BUS_1;
        ctrl_bus_41    <= DFT_CTRL_BUS_1;
        ctrl_bus_02    <= DFT_CTRL_BUS_2;
        ctrl_bus_03    <= DFT_CTRL_BUS_3;
        ctrl_bus_04    <= DFT_CTRL_BUS_4;
        ctrl_bus_05    <= DFT_CTRL_BUS_5;
        ctrl_bus_15    <= DFT_CTRL_BUS_5;
        ctrl_bus_25    <= DFT_CTRL_BUS_5;
        ctrl_bus_35    <= DFT_CTRL_BUS_5;
        ctrl_bus_45    <= DFT_CTRL_BUS_5;
        ctrl_bus_06    <= DFT_CTRL_BUS_6;
        ctrl_bus_16    <= DFT_CTRL_BUS_6;
        ctrl_bus_26    <= DFT_CTRL_BUS_6;
        ctrl_bus_36    <= DFT_CTRL_BUS_6;
        ctrl_bus_46    <= DFT_CTRL_BUS_6;
        ctrl_bus_07    <= DFT_CTRL_BUS_7;
    end
    else if ( (ver_psel==1'b1) && (ver_write==1'b1) && (ver_enable==1'b0) )begin
        case(ver_addr)
            16'h0000  :  ctrl_bus_00 <= ver_wdata;
            16'h0001  :  ctrl_bus_01 <= ver_wdata;
            16'h0011  :  ctrl_bus_11 <= ver_wdata;
            16'h0021  :  ctrl_bus_21 <= ver_wdata;
            16'h0031  :  ctrl_bus_31 <= ver_wdata;
            16'h0041  :  ctrl_bus_41 <= ver_wdata;
            16'h0002  :  ctrl_bus_02 <= ver_wdata;
            16'h0003  :  ctrl_bus_03 <= ver_wdata;
            16'h0004  :  ctrl_bus_04 <= ver_wdata;
            16'h0005  :  ctrl_bus_05 <= ver_wdata;
            16'h0015  :  ctrl_bus_15 <= ver_wdata;
            16'h0025  :  ctrl_bus_25 <= ver_wdata;
            16'h0035  :  ctrl_bus_35 <= ver_wdata;
            16'h0045  :  ctrl_bus_45 <= ver_wdata;
            16'h0006  :  ctrl_bus_06 <= ver_wdata;
            16'h0016  :  ctrl_bus_16 <= ver_wdata;
            16'h0026  :  ctrl_bus_26 <= ver_wdata;
            16'h0036  :  ctrl_bus_36 <= ver_wdata;
            16'h0046  :  ctrl_bus_46 <= ver_wdata;
            16'h0007  :  ctrl_bus_07 <= ver_wdata;
            default   :  ;
        endcase
    end
    else ;
end
endmodule
