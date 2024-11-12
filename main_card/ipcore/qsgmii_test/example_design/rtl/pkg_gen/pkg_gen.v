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
//Functional description: pkg_gen
`timescale 1ns/1ps
module pkg_gen
(
   clk                   ,
   rst_n                 ,
   mode                  ,
   rg_start_test         ,
   rg_pkg_send_clr       ,
   rg_length_cfg_en      ,
   rg_length_num         ,
   rg_ipg_cfg_en         ,
   rg_ipg_num            ,
   rg_pre_cfg_en         ,
   rg_pre_num            ,
   rg_pld_max_sel        ,
   rg_ipg_max_sel        ,
   rg_pre_max_sel        ,
   rg_burst_tx_en        ,
   phy_speed             ,
   pkg_cnt               ,
   tx_clken              ,
   txd                   ,
   tx_en                 ,
   tx_er                 ,
   tx_cnt
);

input         clk                   ;
input         rst_n                 ;
input         mode                  ;
input         rg_start_test         ;
input         rg_pkg_send_clr       ;
input         tx_clken              ;
input         rg_length_cfg_en      ;
input  [18:0] rg_length_num         ;
input         rg_ipg_cfg_en         ;
input  [7:0]  rg_ipg_num            ;
input         rg_pre_cfg_en         ;
input  [3:0]  rg_pre_num            ;
input         rg_pld_max_sel        ;
input         rg_ipg_max_sel        ;
input         rg_pre_max_sel        ;
input         rg_burst_tx_en        ;
input  [1:0]  phy_speed             ;
output [31:0] pkg_cnt               ;
output [7:0]  txd                   ;
output        tx_en                 ;
output        tx_er                 ;
output [31:0] tx_cnt                ;

localparam E_IDLE     = 3'd0;
localparam E_PREAMBLE = 3'd1;
localparam E_SFD      = 3'd2;
localparam E_DATA     = 3'd3;
localparam E_CRC      = 3'd4;
localparam E_IPG      = 3'd5;

reg    [2:0]  pg_cs                 ;
reg    [2:0]  pg_ns                 ;

reg    [7:0]  tx_data               ;
reg           tx_en                 ;
reg           tx_er                 ;
reg    [7:0]  pkg_id                ;
reg           compute_crc           ;
reg           init_crc              ;
reg    [19:0] random_num            ;
wire          data_valid_8bit       ;
wire          data_valid_4bit       ;
wire          data_valid            ;
wire   [7:0]  crc_out_8bit          ;
wire   [3:0]  crc_out_4bit          ;
wire   [7:0]  crc_out               ;
reg    [31:0] pkg_cnt               ;
reg    [18:0] byte_cnt              ;
wire   [7:0]  pld_data              ;

wire   [18:0] pld_max               ;
wire   [7:0]  ipg_max               ;
wire   [3:0]  pre_max               ;
wire   [18:0] rand_pld_1g           ;
wire   [14:0] rand_pld_100m         ;
wire   [11:0] rand_pld_10m          ;
wire   [7:0]  rand_ipg              ;
wire   [3:0]  rand_pre              ;
wire          rand_pld_en_1g        ;
wire          rand_pld_en_100m      ;
wire          rand_pld_en_10m       ;
wire          rand_ipg_en           ;
wire          rand_pre_en           ;

wire   [7:0]  ipg_num_sel           ;
wire   [18:0] length_num_sel        ;
wire   [3:0]  pre_num_sel           ;

reg    [7:0]  ipg_num_syn           ;
reg    [18:0] length_num_syn        ;
reg    [3:0]  pre_num_syn           ;

wire          rg_pkg_send_clr_pos   ;
reg           rg_pkg_send_clr_ff0   ;
reg           rg_pkg_send_clr_ff1   ;
reg           rg_pkg_send_clr_ff2   ;

reg           rand_sta              ;
reg           rand_sta_ff0          ;
reg           rand_sta_ff1          ;
wire          rand_sta_pos          ;

reg    [1:0]  phy_speed_ff0         ;
reg    [1:0]  phy_speed_ff1         ;

wire   [7:0]  tx_sfd_data           ;
wire   [7:0]  tx_process_data       ;

reg           brust_tx_vld          ;

reg           pkg_cnt_carry         ;

assign length_num_sel = rg_length_cfg_en ? rg_length_num :
                        phy_speed == 2'b10 ? rand_pld_1g :
                        phy_speed == 2'b01 ? {4'b0,rand_pld_100m} : {7'b0,rand_pld_10m};

assign ipg_num_sel    = rg_ipg_cfg_en    ? rg_ipg_num    : rand_ipg;
assign pre_num_sel    = rg_pre_cfg_en    ? rg_pre_num    : rand_pre;

assign tx_sfd_data      = (mode && (phy_speed != 2'b10)) ? 8'hdd : 8'hd5;
assign tx_process_data  = byte_cnt == 19'd0 ? pkg_id : pld_data;

always @(negedge rst_n or posedge clk)
begin
    if (!rst_n)
    begin
        length_num_syn <= 19'd0;
        ipg_num_syn    <= 8'd0;
        pre_num_syn    <= 4'd0;
    end
    else if(tx_clken)
    begin
        length_num_syn <= length_num_sel;
        ipg_num_syn    <= ipg_num_sel;
        pre_num_syn    <= pre_num_sel;
    end
end

always @(negedge rst_n or posedge clk)
begin
    if (!rst_n)
    begin
        rg_pkg_send_clr_ff0 <= 1'b0;
        rg_pkg_send_clr_ff1 <= 1'b0;
        rg_pkg_send_clr_ff2 <= 1'b0;
        phy_speed_ff0       <= 2'b0;
        phy_speed_ff1       <= 2'b0;
    end
    else
    begin
        rg_pkg_send_clr_ff0 <= rg_pkg_send_clr;
        rg_pkg_send_clr_ff1 <= rg_pkg_send_clr_ff0;
        rg_pkg_send_clr_ff2 <= rg_pkg_send_clr_ff1;
        phy_speed_ff0       <= phy_speed;
        phy_speed_ff1       <= phy_speed_ff0;
    end
end

assign rg_pkg_send_clr_pos = rg_pkg_send_clr_ff1 && ~rg_pkg_send_clr_ff2;

always @(negedge rst_n or posedge clk)
begin
    if (!rst_n)
        pg_cs <= E_IPG;
    else if(tx_clken)
        pg_cs <= pg_ns;
    else
        pg_cs <= pg_cs;
end

always @(*)
begin
    case(pg_cs)
        E_IPG: begin
            if((byte_cnt[7:0] == ipg_num_syn) && rg_start_test)
                pg_ns = E_PREAMBLE;
            else
                pg_ns = E_IPG;
        end
        E_PREAMBLE: begin
            if(byte_cnt[3:0] == pre_num_syn)
                pg_ns = E_SFD;
            else
                pg_ns = E_PREAMBLE;
        end
        E_SFD: begin
            pg_ns = E_DATA;
        end
        E_DATA: begin
            if(byte_cnt == length_num_syn)
                pg_ns = E_CRC;
            else
                pg_ns = E_DATA;
        end
        E_CRC: begin
            if (mode && (phy_speed != 2'b10)) begin
                if(byte_cnt == 19'd7) begin
                    pg_ns = E_IPG;
                end
                else
                    pg_ns = E_CRC;
            end
            else begin
                if(byte_cnt == 19'd3)
                    pg_ns = E_IPG;
                else
                    pg_ns = E_CRC;
            end
        end
        default: begin
            pg_ns = E_IPG;
        end
    endcase
end

always @(negedge rst_n or posedge clk)
begin
   if (!rst_n)
   begin
      tx_en     <= 1'b0;
      tx_er     <= 1'b0;
      tx_data   <= 8'h00;
   end
   else if(tx_clken)
   begin
      case(pg_cs)
         E_IPG: begin
            if( brust_tx_vld == 1'b1 )
            begin
                tx_data <= 8'h0f;
                tx_en <= 1'b0;
                tx_er <= 1'b1;
            end
            else
            begin
                tx_data  <= 8'b0;
                tx_en    <= 1'b0;
                tx_er    <= 1'b0;
            end
         end
         E_PREAMBLE:
         begin
            tx_en    <= 1'b1;
            tx_er    <= 1'b0;
            tx_data  <= 8'h55;
         end
         E_SFD:
         begin
            tx_en   <= 1'b1;
            tx_er   <= 1'b0;
            tx_data <= tx_sfd_data;
         end
         E_DATA:
         begin
            tx_en   <= 1'b1;
            tx_er   <= 1'b0;
            tx_data <= tx_process_data;
         end
         E_CRC:
         begin
            tx_en   <= 1'b1;
            tx_er   <= 1'b0;
            tx_data <= 8'h00;
         end
         default:
         begin
            tx_data  <= 0;
            tx_en    <= 0;
            tx_er    <= 0;
         end
      endcase
   end
   else
   begin
      tx_en     <= tx_en   ;
      tx_er     <= tx_er   ;
      tx_data   <= tx_data ;
   end
end

always @(negedge rst_n or posedge clk)
begin
    if(!rst_n)
    begin
        brust_tx_vld <= 1'b0;
    end
    else if((pg_ns == E_IPG && pg_cs == E_CRC) && rg_burst_tx_en == 1'b1)
    begin
        brust_tx_vld <= 1'b1;
    end
    else if(pg_ns == E_PREAMBLE)
    begin
        brust_tx_vld <= 1'b0;
    end
end

always @(negedge rst_n or posedge clk)
begin
    if (!rst_n)
        byte_cnt <= 19'd0;
    else if(tx_clken)
        if((pg_cs != pg_ns) || ((pg_cs == E_IPG) && ~rg_start_test))
            byte_cnt <= 19'd0;
        else
            byte_cnt <= byte_cnt + 19'd1;
    else;
end

always @(negedge rst_n or posedge clk)
begin
    if (!rst_n)
        pkg_id <= 8'd0;
    else if(tx_clken)
        if(pg_cs == E_CRC && pg_ns == E_IPG)
            pkg_id <= pkg_id + 8'd1;
        else;
    else;
end
//32-bit counter
always @(negedge rst_n or posedge clk)
begin
    if (!rst_n)
        pkg_cnt[15:0] <= 16'd0;
    else if(rg_pkg_send_clr_pos)
        pkg_cnt[15:0] <= 16'd0;
    else if(tx_clken)
        if(pg_cs == E_CRC && pg_ns == E_IPG)
            pkg_cnt[15:0] <= pkg_cnt[15:0] + 16'd1;
        else;
    else;
end

always @(negedge rst_n or posedge clk)
begin
    if(!rst_n)
        pkg_cnt_carry <= 1'b0;
    else if(rg_pkg_send_clr_pos)
        pkg_cnt_carry <= 1'b0;
    else if(tx_clken)
        if(pg_cs == E_CRC && pg_ns == E_IPG)
            if(pkg_cnt[15:0] == 16'hFFFE)
                pkg_cnt_carry <= 1'b1;
            else
                pkg_cnt_carry <= 1'b0;
        else;
    else;
end

always @(negedge rst_n or posedge clk)
begin
    if(!rst_n)
        pkg_cnt[31:16] <= 16'd0;
    else if (rg_pkg_send_clr_pos)
        pkg_cnt[31:16] <= 16'd0;
    else if (tx_clken)
        if(pg_cs == E_CRC && pg_ns == E_IPG)
            if(pkg_cnt_carry == 1'b1)
                pkg_cnt[31:16] <= pkg_cnt[31:16] + 16'd1;
            else
                pkg_cnt[31:16] <= pkg_cnt[31:16];
        else;
    else;
end

always @(negedge rst_n or posedge clk)
begin
    if (!rst_n)
        compute_crc <= 1'b0;
    else if(tx_clken)
        if(pg_cs == E_DATA)
            compute_crc <= 1'b1;
        else
            compute_crc <= 1'b0;
    else;
end
//**************************************************************
assign crc_out    = (mode && (phy_speed != 2'b10)) ? {crc_out_4bit,crc_out_4bit} : crc_out_8bit;
assign data_valid = (mode && (phy_speed != 2'b10)) ? data_valid_4bit : data_valid_8bit;
assign txd        = data_valid ? crc_out : tx_data;

//*****************************************************************************************
//generate random number for test
//*****************************************************************************************

always @(negedge rst_n or posedge clk)
begin
    if (!rst_n)
    begin
        rand_sta     <= 1'b0;
        rand_sta_ff0 <= 1'b0;
        rand_sta_ff1 <= 1'b0;
    end
    else
    begin
        rand_sta     <= 1'b1;
        rand_sta_ff0 <= rand_sta;
        rand_sta_ff1 <= rand_sta_ff0;
    end
end

assign rand_sta_pos = rand_sta_ff0 && !rand_sta_ff1;

assign rand_pld_en_1g   = (rand_sta_pos || (pg_cs == E_DATA && pg_ns == E_CRC) || (phy_speed_ff0 != phy_speed_ff1)) && (phy_speed == 2'b10);
assign rand_pld_en_100m = (rand_sta_pos || (pg_cs == E_DATA && pg_ns == E_CRC) || (phy_speed_ff0 != phy_speed_ff1)) && (phy_speed == 2'b01);
assign rand_pld_en_10m  = (rand_sta_pos || (pg_cs == E_DATA && pg_ns == E_CRC) || (phy_speed_ff0 != phy_speed_ff1)) && (phy_speed == 2'b00);
assign rand_ipg_en = rand_sta_pos || (pg_cs == E_SFD && pg_ns == E_DATA);
assign rand_pre_en = rand_sta_pos || (pg_cs == E_SFD && pg_ns == E_DATA);

assign pld_max = rg_pld_max_sel ? rg_length_num :
                 phy_speed == 2'b10 ? 19'd20000 : 19'd1518 ;

rand_gen #(
    .WIDTH        (19)
)
u0_rand_pld_1g
(
    .clk          (clk           ),
    .rst_n        (rst_n         ),
    .out_en       (rand_pld_en_1g),
    .max          (pld_max       ),
    .min          (19'd46        ),
    .rand_vld     (              ),
    .rand_out     (rand_pld_1g   )
);

rand_gen #(
    .WIDTH        (15)
)
u0_rand_pld_100m
(
    .clk          (clk           ),
    .rst_n        (rst_n         ),
    .out_en       (rand_pld_en_100m),
    .max          (pld_max[14:0] ),
    .min          (15'd46        ),
    .rand_vld     (              ),
    .rand_out     (rand_pld_100m )
);

rand_gen #(
    .WIDTH        (12)
)
u0_rand_pld_10m
(
    .clk          (clk           ),
    .rst_n        (rst_n         ),
    .out_en       (rand_pld_en_10m),
    .max          (pld_max[11:0] ),
    .min          (12'd46        ),
    .rand_vld     (              ),
    .rand_out     (rand_pld_10m  )
);

assign ipg_max = rg_ipg_max_sel ? rg_ipg_num : 8'd255;

rand_gen #(
    .WIDTH        (8)
)
u1_rand_ipg
(
    .clk          (clk           ),
    .rst_n        (rst_n         ),
    .out_en       (rand_ipg_en   ),
    .max          (ipg_max       ),
    .min          (8'd11         ),
    .rand_vld     (              ),
    .rand_out     (rand_ipg      )
);

assign pre_max = rg_pre_max_sel ? rg_pre_num : 4'd6;

rand_gen #(
    .WIDTH        (4)
)
u1_rand_pre
(
    .clk          (clk           ),
    .rst_n        (rst_n         ),
    .out_en       (rand_pre_en   ),
    .max          (pre_max       ),
    .min          (4'd6          ),
    .rand_vld     (              ),
    .rand_out     (rand_pre      )
);

lfsr #(
    .WIDTH        (8)
)
u1_lfsr_data
(
    .clk          (clk           ),
    .rst_n        (rst_n         ),
    .out_en       (1'b1          ),
    .out          (pld_data      )
);

crc32_8bit I_crc32_8bit(
   .reset         (~rst_n          ),
   .clk           (clk             ),
   .tx_clken      (tx_clken        ),
   .din           (tx_data         ),
   .compute_crc   (compute_crc     ),
   .dout          (crc_out_8bit    ),
   .data_valid    (data_valid_8bit ),
   .crc_ok        (                )
);

crc32_4bit I_crc32_4bit(
  .reset         (~rst_n          ),
  .clk           (clk             ),
  .tx_clken      (tx_clken        ),
  .din           (tx_data[3:0]    ),
  .compute_crc   (compute_crc     ),
  .dout          (crc_out_4bit    ),
  .data_valid    (data_valid_4bit ),
  .crc_ok        (                )
);

endmodule
