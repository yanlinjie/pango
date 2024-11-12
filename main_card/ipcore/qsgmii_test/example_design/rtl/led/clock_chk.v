
/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////Functional description: clock_chk

`timescale  1ns/1ps
module  clock_chk(
    // Reset and Clock
    input   clk1,
    input   clk2,
    input   rst1_n,
    input   rst2_n,

    output  reg         LED50M1S,   //LED0
    output  reg         LED125M1S   //LED1

);



//****************************************************************************//
//                      Parameter and Define                                  //
//****************************************************************************//


//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//
    // LED
    reg    [27:0]   led_50m1s_cnt;
    reg    [27:0]   led_125m1s_cnt;

//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//

    always @(posedge clk1 or negedge rst1_n)
    begin
        if (!rst1_n)
        begin
          led_50m1s_cnt  <= 28'h0;
          LED50M1S    <= 1'b0;
        end
        else if(led_50m1s_cnt == 28'h2faf080)
        begin
          led_50m1s_cnt  <= 28'h0000000;
          LED50M1S    <= ~LED50M1S;
        end
        else
          led_50m1s_cnt  <= led_50m1s_cnt + 1'b1;
    end

    always @(posedge clk2 or negedge rst2_n)
    begin
        if (!rst2_n)
        begin
          led_125m1s_cnt  <= 28'h0;
          LED125M1S       <= 1'b0;
        end
        else if(led_125m1s_cnt == 28'h7735940)
        begin
          led_125m1s_cnt  <= 28'h0000000;
          LED125M1S       <= ~LED125M1S;
        end
        else
          led_125m1s_cnt  <= led_125m1s_cnt + 1'b1;
    end

endmodule