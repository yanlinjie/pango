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
//Functional description: pkg_chk

`timescale 1ns/1ps
module pkg_chk(
input  wire        clk                    ,
input  wire        clk_en                 ,
input  wire        rst_n                  ,
input  wire [3:0]  rg_pkg_chk_clr         ,
input  wire        mode                   ,
input  wire [1:0]  speed                  ,
input  wire [7:0]  rxd                    ,
input  wire        rx_dv                  ,
input  wire        rx_er                  ,
input  wire        mr_complete            ,
input  wire        burst_en               ,
input  wire        buffer_err             ,
output reg  [31:0] byte_cnt               ,
output reg         ok_led                 ,
output wire        crc_ok                 ,
output reg  [31:0] crc_ok_cnt             ,
output reg  [31:0] crc_err_cnt            ,
output reg  [31:0] rcving_cnt

);

localparam e_IDLE     = 3'd0           ;
localparam e_PREAMBLE = 3'd1           ;
localparam e_SFD      = 3'd2           ;
localparam e_DATA     = 3'd3           ;
localparam e_CRC      = 3'd4           ;
localparam e_HOLD     = 3'd5           ;
localparam LOG_NAME   = "macrx.log"    ;


reg            rcving_data            ;
reg  [2:0]     state                  ;
reg  [15:0]    count                  ;
wire           preamble_detected      ;
wire           sfd_detected           ;
wire           crc_ok_8bit            ;
wire           crc_ok_4bit            ;
wire           compute_crc            ;
reg  [1:0]     rcving_data_ff         ;
wire           rcving_data_pulse      ;
reg  [31:0]    rxd_byte_cnt           ;
reg            burst_cnt_en           ;
reg            buffer_err_lock        ;
reg            buffer_err_lock_ff     ;



reg  [3:0]     rg_pkg_chk_clr_ff0        ;
reg  [3:0]     rg_pkg_chk_clr_ff1        ;
reg  [3:0]     rg_pkg_chk_clr_ff2        ;
wire [3:0]     rg_pkg_chk_clr_pos        ;

assign preamble_detected = (mode && (speed != 2'b10)) ? ((rx_dv == 1'b1) && (rxd[3:0] == 4'd5)) :
                                                        ((rx_dv == 1'b1) && (rxd == 8'h55));
assign sfd_detected      = (mode && (speed != 2'b10)) ? ((rx_dv == 1'b1) && (rxd[3:0] == 4'hd)) :
                                                        ((rx_dv == 1'b1) && (rxd == 8'hd5));
assign crc_ok            = (mode && (speed != 2'b10)) ? crc_ok_4bit : crc_ok_8bit;
assign compute_crc       = rcving_data & rx_dv;
//for RTL simulation preambles number is equal to transmitted number
assign min_preambles     = mode ? 4'd15 : 4'd7;

//byte cnt
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        rxd_byte_cnt  <=  32'b0;
    end
    else if (burst_en == 1)
    begin
        if (rx_dv | rx_er)                        //burst mode byte cnt
        begin
            rxd_byte_cnt <= rxd_byte_cnt + 1'b1  ;
        end
        else
        begin
            rxd_byte_cnt <= rxd_byte_cnt  ;
        end
    end
    else
    begin
        if(rx_dv == 1)                            //common mode byte cnt
        begin
            rxd_byte_cnt <= rxd_byte_cnt + 1'b1  ;
        end
        else
        begin
            rxd_byte_cnt <= rxd_byte_cnt  ;
        end
    end
end

//buffer_err_lock
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        buffer_err_lock <= 1'b0  ;
    end
    else if (burst_en)
    begin
        if (buffer_err)
        begin
            buffer_err_lock <= 1'b1;
        end
        else
        begin
            buffer_err_lock <= buffer_err_lock  ;
        end
    end
    else
    begin
        buffer_err_lock <= buffer_err_lock  ;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        buffer_err_lock_ff <= 1'b0  ;
    end
    else
    begin
        buffer_err_lock_ff <= buffer_err_lock  ;
    end
end

//burst mode byte cnt
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        byte_cnt <= 32'b0  ;
    end
    else if (burst_en)
    begin
        if (buffer_err_lock != buffer_err_lock_ff)
        begin
            byte_cnt <= rxd_byte_cnt - 1'b1 ;
        end
        else
        begin
            byte_cnt <= byte_cnt  ;
        end
    end
    else
    begin
        byte_cnt <= rxd_byte_cnt  ;
    end
end


`ifdef IPS_SGMII_SPEEDUP_SIM
integer logfile_fid ;
initial begin

  logfile_fid = $fopen( LOG_NAME );

end
`else
`endif
always @(negedge rst_n or posedge clk) begin
   if (!rst_n) begin
      state       <= e_IDLE;
      rcving_data <= 1'b0;
      count       <= 0;
   end
   else if (clk_en) begin
//     else begin
        case (state)
           e_IDLE: begin
              count <= 0;
              if (preamble_detected) begin
                 state <= e_PREAMBLE;
              end
           end
           e_PREAMBLE: begin
              if (preamble_detected) begin
                 if (count != 15)
                    count <= count + 1;
              end
              else begin
                 if (sfd_detected) begin
                    rcving_data <= 1'b1;
                    state <= e_SFD;
`ifdef IPS_SGMII_SPEEDUP_SIM
                    if (count < min_preambles - 1)
                        $fdisplay(logfile_fid,">> Preamble is not enough");
`else
`endif
                 end
                 else begin
                    state <= e_IDLE;
                    rcving_data <= 1'b0;
`ifdef IPS_SGMII_SPEEDUP_SIM
                    if (mr_complete)
                      $fdisplay(logfile_fid,">> Invalid preamble segment detected");
                    else
                      $fdisplay(logfile_fid,">> AN is going");
`else
`endif
                 end
              end
           end
           e_SFD: begin
              if (rx_dv) begin
                 //recive and display special flag
                 state <= e_DATA;
                 count <= 0;
`ifdef IPS_SGMII_SPEEDUP_SIM
                 if (mode)
                    $fdisplay(logfile_fid,"sequece number is %d", rxd[3:0]);
                 else
                    $fdisplay(logfile_fid,"sequece number is %d", rxd);
`else
`endif
              end
              else begin
                 state <= e_IDLE;
                 rcving_data <= 1'b0;
`ifdef IPS_SGMII_SPEEDUP_SIM
                 if(mr_complete)
                   $fdisplay(logfile_fid,">> Invalid frame detected");
                 else
                   $fdisplay(logfile_fid,">> AN is going");
`else
`endif
              end
           end
           e_DATA: begin
//              if (count == 0)
//                 if (mode)
//                    $display(">> sequece number is %d", rxd[3:0]);
//                 else
//                    $display(">> sequece number is %d", rxd);
              if (rx_dv) begin
                 count <= count + 1;
              end
              else begin
                 rcving_data <= 1'b0;
                 state <= e_CRC;
              end
           end
           e_CRC: begin
              state <= e_HOLD;
`ifdef IPS_SGMII_SPEEDUP_SIM
              if (crc_ok)
                 $fdisplay(logfile_fid,">> CRC check passed,at time %d",$time);
              else begin
                 if(mr_complete)
                   $fdisplay(logfile_fid,">> CRC check failed,at time %d",$time);
                 else
                   $fdisplay(logfile_fid,">> AN is going");
              end
`else
`endif
           end
           e_HOLD: begin
              state <= e_IDLE;
`ifdef IPS_SGMII_SPEEDUP_SIM
              if (mode)
                 $fdisplay(logfile_fid,">> received client data nibbles length is %d", count + 1);
              else
                 $fdisplay(logfile_fid,">> received client data bytes length is %d", count + 1);
`else
`endif
           end
           default: begin
              state <= e_IDLE;
              rcving_data <= 1'b0;
           end
        endcase
   end
end

crc32_8bit I_crc32_8bit(
   .reset         (~rst_n          ),
   .clk           (clk             ),
   .tx_clken      (clk_en          ),
   .din           (rxd             ),
   .compute_crc   (compute_crc     ),
   .dout          (                ),
   .data_valid    (                ),
   .crc_ok        (crc_ok_8bit     )
);

crc32_4bit I_crc32_4bit(
   .reset         (~rst_n          ),
   .clk           (clk             ),
   .tx_clken      (clk_en          ),
   .din           (rxd[3:0]        ),
   .compute_crc   (compute_crc     ),
   .dout          (                ),
   .data_valid    (                ),
   .crc_ok        (crc_ok_4bit     )
);

assign rcving_data_pulse = ~rcving_data_ff[0] & rcving_data_ff[1];
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        rcving_data_ff <= 2'd0;
    else if (clk_en)
    begin
        rcving_data_ff[0]   <= rx_dv;
        rcving_data_ff[1] <= rcving_data_ff[0];
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        rg_pkg_chk_clr_ff0 <= 4'd0;
        rg_pkg_chk_clr_ff1 <= 4'd0;
        rg_pkg_chk_clr_ff2 <= 4'd0;
    end
    else
    begin
        rg_pkg_chk_clr_ff0 <= rg_pkg_chk_clr;
        rg_pkg_chk_clr_ff1 <= rg_pkg_chk_clr_ff0;
        rg_pkg_chk_clr_ff2 <= rg_pkg_chk_clr_ff1;
    end
end

assign rg_pkg_chk_clr_pos[0] = rg_pkg_chk_clr_ff1[0] && ~rg_pkg_chk_clr_ff2[0];
assign rg_pkg_chk_clr_pos[1] = rg_pkg_chk_clr_ff1[1] && ~rg_pkg_chk_clr_ff2[1];
assign rg_pkg_chk_clr_pos[2] = rg_pkg_chk_clr_ff1[2] && ~rg_pkg_chk_clr_ff2[2];
assign rg_pkg_chk_clr_pos[3] = rg_pkg_chk_clr_ff1[3] && ~rg_pkg_chk_clr_ff2[3];

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        rcving_cnt <= 32'd0;
    else if(rg_pkg_chk_clr_pos[0])
        rcving_cnt <= 32'd0;
    else if (&rcving_cnt & clk_en)
        rcving_cnt <= rcving_cnt;
    else if (rcving_data_pulse & clk_en)
        rcving_cnt <= rcving_cnt + 32'd1;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        crc_err_cnt <= 32'd0;
    else if(rg_pkg_chk_clr_pos[1])
        crc_err_cnt <= 32'd0;
    else if (&crc_err_cnt & clk_en)
        crc_err_cnt <= crc_err_cnt;
    else if (rcving_data_pulse & ~crc_ok & clk_en)
        crc_err_cnt <= crc_err_cnt + 32'd1;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        crc_ok_cnt <= 32'd0;
    else if(rg_pkg_chk_clr_pos[2])
        crc_ok_cnt <= 32'd0;
    else if (&crc_ok_cnt & clk_en)
        crc_ok_cnt <= crc_ok_cnt;
    else if (rcving_data_pulse & crc_ok & clk_en)
        crc_ok_cnt <= crc_ok_cnt + 32'd1;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        ok_led <= 1'b0;
    else if(rg_pkg_chk_clr_pos[3])
        ok_led <= 1'b0;
    else if(rcving_data_pulse & clk_en) begin
        if(rcving_cnt == crc_ok_cnt)
            ok_led <= 1'b1;
        else
            ok_led <= 1'b0;
    end
    else
        ok_led <= ok_led;
end

endmodule
