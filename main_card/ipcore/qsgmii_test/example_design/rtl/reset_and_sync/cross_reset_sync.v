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
//Functional description: cross_reset_sync

`timescale 1ns/1ps

module  cross_reset_sync(
    // Reset and Clock
    input       free_clk_pll,
    input       external_rstn,

    output  reg     rst_n
);



//****************************************************************************//
//                      Parameter and Define                                  //
//****************************************************************************//
    //
    //
//****************************************************************************//
//                      Internal Signal                                       //
//****************************************************************************//

    reg rs1;
    reg rs2;

    wire            rst_n_inner;
    reg     [3:0]   rst_n_inner_d;
    reg             rst_n_sync;
    reg     [15:0]  cnt_rst;

//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//

    always@(posedge free_clk_pll or negedge external_rstn)
        begin
            if(!external_rstn)
            begin
                rs1<=0;
                rs2<=0;
            end
            else
            begin
                rs1<=1;
                rs2<=rs1;
            end
        end


    assign rst_n_inner = rs2;

    `ifdef IPS_SGMII_SPEEDUP_SIM
        initial begin
            rst_n_inner_d = 4'hf; //CLM reg default value is 1
            rst_n_sync    = 1'b1;
            cnt_rst       = 16'hffff;
            rst_n         = 1'b1;
        end
    `endif

    always @(posedge free_clk_pll or negedge rst_n_inner)
        if (!rst_n_inner) begin
            rst_n_inner_d <= 4'h0; //CLM reg default value is 1
            rst_n_sync    <= 1'b0;
            cnt_rst       <= 16'hffff;
            rst_n         <= 1'b0;
        end
        else begin
            rst_n_inner_d <= {rst_n_inner_d[2:0], rst_n_inner};

            if (rst_n_inner_d[3:2] == 2'd0)
                rst_n_sync <= 1'b0;
            else
                rst_n_sync <= 1'b1;

            if (~rst_n_sync) begin
                cnt_rst <= 16'hffff;
                rst_n   <= 1'b0;
            end
        `ifdef IPS_SGMII_SPEEDUP_SIM
            else if (cnt_rst == 16'h00C0)
                rst_n <= 1'b1;
        `else
            else if (cnt_rst == 16'hC000)
                rst_n <= 1'b1;
        `endif
            else begin
                rst_n <= 1'b0;
                cnt_rst <= cnt_rst + 1;
            end
        end

endmodule