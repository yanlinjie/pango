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
//Functional description: crc32_8bit

`timescale 1ns/1ps
//      CRC Width = 32
//     Data Width = 8
//     CRC Init   = F
//     Polynomial = [0 -> 32]
//        1 1 1 0 1 1 0 1 1 0 1  1  1  0  0  0   1    0 0 0 0 0   1  1   0   0    1    0    0    0  0    0   1
//        0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15  16   1718192021  22 23  24  25   26   27   28   29 30   31  32
// Polynomial X^32 + X^26 + X^23 + X^22 + X^16 + X^12 + X^11 + X^10 + X^8 + X^7 + X^5 + X^4 + X^2 + X^1 + 1
 // LSB first for input data
module crc32_8bit(
   reset,
   clk,
   tx_clken,
   din,
   compute_crc,
   dout,
   data_valid,
   crc_ok
);

input         reset;
input         clk;
input         tx_clken;
input  [7:0]  din;
input         compute_crc;
output [7:0]  dout;
output        data_valid;
output        crc_ok;

//*********************************************************************************************************************
//                      _______________________________________________
//compute_crc   _______|                                               |_____________________
//                                                                      _____
//compute_crc_p _______________________________________________________|     |_________________
//data_out      ******************************************************* crc_0 crc_1 crc_2 crc_3*******
//                                                                      _______________________
//data_valid    _______________________________________________________|                       |_________
//                                                                            _____
//crc_ok        _____________________________________________________________|     |_________
//*********************************************************************************************************************
reg  [31:0] crc_buf;
wire [31:0] new_crc;
reg        crc_ok;
reg        crc_er;
reg [2:0]  crc_count;
reg        compute_crc_d;
wire       compute_crc_p;
reg  [7:0] dout;

assign compute_crc_p = (~ compute_crc) & compute_crc_d;
assign data_valid    = (~ compute_crc) & (~ crc_count[2]);

always @(posedge reset or posedge clk)
   if (reset) begin
      crc_buf <= 32'hFFFF_FFFF;
      crc_ok  <= 1'b0;
      crc_er  <= 1'b0;
      crc_count <= 3'd4;
      compute_crc_d <= 1'b0;
      dout    <= 0;
   end
   else if (tx_clken == 1'b1)begin
      compute_crc_d <= compute_crc;

      if (compute_crc)
         crc_count <= 0;
      else
         if (crc_count < 3'd4)
            crc_count <= crc_count + 1;

      if (compute_crc)
         crc_buf <= new_crc;
      else
         crc_buf <= {crc_buf[23:0], 8'hFF};


      if (compute_crc_p)
         if (crc_buf == 32'hc704dd7b) begin
            crc_ok <= 1'b1;
            crc_er <= 1'b0;
         end
         else begin
            crc_ok <= 1'b0;
            crc_er <= 1'b1;
         end
      else begin
         crc_ok <= 1'b0;
         crc_er <= 1'b0;
      end

      //crc data out
      if (compute_crc)
         dout <= ~ {new_crc[24], new_crc[25], new_crc[26], new_crc[27],
                    new_crc[28], new_crc[29], new_crc[30], new_crc[31]};
      else
         dout <= ~ {crc_buf[16], crc_buf[17], crc_buf[18], crc_buf[19],
                    crc_buf[20], crc_buf[21], crc_buf[22], crc_buf[23]};
   end

//*****************************************************************************************************************
assign new_crc[0] = crc_buf[30] ^ din[1] ^ crc_buf[24] ^ din[7];
assign new_crc[1] = din[6] ^ din[7] ^ din[0] ^ crc_buf[30] ^ crc_buf[31] ^ din[1] ^ crc_buf[24] ^ crc_buf[25];
assign new_crc[2] = crc_buf[26] ^ din[5] ^ din[6] ^ din[7] ^ crc_buf[30] ^ din[0] ^ din[1] ^ crc_buf[31] ^ crc_buf[24] ^ crc_buf[25];
assign new_crc[3] = din[4] ^ crc_buf[26] ^ din[5] ^ crc_buf[27] ^ din[6] ^ din[0] ^ crc_buf[31] ^ crc_buf[25];
assign new_crc[4] = din[4] ^ crc_buf[26] ^ din[5] ^ crc_buf[27] ^ crc_buf[28] ^ din[7] ^ crc_buf[30] ^ din[1] ^ crc_buf[24] ^ din[3];
assign new_crc[5] = din[4] ^ crc_buf[27] ^ din[6] ^ crc_buf[28] ^ din[7] ^ crc_buf[29] ^ crc_buf[30] ^ din[0] ^ din[1] ^ crc_buf[31] ^ din[2] ^ crc_buf[24] ^ din[3] ^ crc_buf[25];
assign new_crc[6] = crc_buf[26] ^ din[5] ^ din[6] ^ crc_buf[28] ^ crc_buf[29] ^ din[0] ^ crc_buf[30] ^ crc_buf[31] ^ din[1] ^ din[2] ^ din[3] ^ crc_buf[25];
assign new_crc[7] = din[4] ^ crc_buf[26] ^ din[5] ^ crc_buf[27] ^ din[7] ^ crc_buf[29] ^ din[0] ^ crc_buf[31] ^ din[2] ^ crc_buf[24];
assign new_crc[8] = din[4] ^ crc_buf[27] ^ din[6] ^ crc_buf[28] ^ din[7] ^ crc_buf[24] ^ crc_buf[0] ^ din[3] ^ crc_buf[25];
assign new_crc[9] = crc_buf[26] ^ din[5] ^ din[6] ^ crc_buf[28] ^ crc_buf[29] ^ din[2] ^ din[3] ^ crc_buf[25] ^ crc_buf[1];
assign new_crc[10] = din[4] ^ crc_buf[26] ^ crc_buf[2] ^ din[5] ^ crc_buf[27] ^ din[7] ^ crc_buf[29] ^ din[2] ^ crc_buf[24];
assign new_crc[11] = din[4] ^ crc_buf[27] ^ din[6] ^ crc_buf[3] ^ crc_buf[28] ^ din[7] ^ crc_buf[24] ^ din[3] ^ crc_buf[25];
assign new_crc[12] = crc_buf[26] ^ din[5] ^ din[6] ^ crc_buf[28] ^ din[7] ^ crc_buf[4] ^ crc_buf[29] ^ crc_buf[30] ^ din[1] ^ din[2] ^ crc_buf[24] ^ din[3] ^ crc_buf[25];
assign new_crc[13] = din[4] ^ crc_buf[26] ^ din[5] ^ crc_buf[27] ^ din[6] ^ crc_buf[29] ^ din[0] ^ crc_buf[30] ^ crc_buf[5] ^ crc_buf[31] ^ din[1] ^ din[2] ^ crc_buf[25];
assign new_crc[14] = din[4] ^ crc_buf[26] ^ din[5] ^ crc_buf[27] ^ crc_buf[28] ^ crc_buf[30] ^ din[0] ^ din[1] ^ crc_buf[31] ^ crc_buf[6] ^ din[3];
assign new_crc[15] = din[4] ^ crc_buf[27] ^ crc_buf[28] ^ crc_buf[29] ^ din[0] ^ crc_buf[31] ^ din[2] ^ crc_buf[7] ^ din[3];
assign new_crc[16] = crc_buf[28] ^ din[7] ^ crc_buf[29] ^ din[2] ^ crc_buf[24] ^ din[3] ^ crc_buf[8];
assign new_crc[17] = crc_buf[9] ^ din[6] ^ crc_buf[29] ^ crc_buf[30] ^ din[1] ^ din[2] ^ crc_buf[25];
assign new_crc[18] = crc_buf[26] ^ din[5] ^ crc_buf[10] ^ crc_buf[30] ^ din[0] ^ din[1] ^ crc_buf[31];
assign new_crc[19] = din[4] ^ crc_buf[27] ^ crc_buf[11] ^ din[0] ^ crc_buf[31];
assign new_crc[20] = crc_buf[28] ^ crc_buf[12] ^ din[3];
assign new_crc[21] = crc_buf[29] ^ crc_buf[13] ^ din[2];
assign new_crc[22] = din[7] ^ crc_buf[14] ^ crc_buf[24];
assign new_crc[23] = din[6] ^ din[7] ^ crc_buf[30] ^ din[1] ^ crc_buf[15] ^ crc_buf[24] ^ crc_buf[25];
assign new_crc[24] = crc_buf[26] ^ din[5] ^ din[6] ^ din[0] ^ crc_buf[31] ^ crc_buf[16] ^ crc_buf[25];
assign new_crc[25] = din[4] ^ crc_buf[17] ^ crc_buf[26] ^ din[5] ^ crc_buf[27];
assign new_crc[26] = din[4] ^ crc_buf[18] ^ crc_buf[27] ^ crc_buf[28] ^ din[7] ^ crc_buf[30] ^ din[1] ^ crc_buf[24] ^ din[3];
assign new_crc[27] = din[6] ^ crc_buf[19] ^ crc_buf[28] ^ crc_buf[29] ^ din[0] ^ crc_buf[31] ^ din[2] ^ din[3] ^ crc_buf[25];
assign new_crc[28] = crc_buf[26] ^ din[5] ^ crc_buf[20] ^ crc_buf[29] ^ crc_buf[30] ^ din[1] ^ din[2];
assign new_crc[29] = din[4] ^ crc_buf[27] ^ crc_buf[21] ^ crc_buf[30] ^ din[0] ^ din[1] ^ crc_buf[31];
assign new_crc[30] = crc_buf[28] ^ din[0] ^ crc_buf[22] ^ crc_buf[31] ^ din[3];
assign new_crc[31] = crc_buf[29] ^ crc_buf[23] ^ din[2];


endmodule