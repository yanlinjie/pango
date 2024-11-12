/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////Functional description: mdio_drv

`timescale 1ns/1ps

module  mdio_drv(
    // Reset and Clock
    input   clk,
    input   rstn,
    input   mdio_done,

    output          [1:0]   op,
    output  reg     [4:0]   regad,
    output          [15:0]  data0,
    output  reg             mdio_load

);

    // MDIO MAC
    reg  [1:0]  op_ff;
    wire        op_ch;
    reg  [7:0]  mdio_load_trg_cnt;

    reg  [4:0]  reg_rd_cnt;


//****************************************************************************//
//                      Sequential and Logic                                  //
//****************************************************************************//

    assign op = 2'b10;//mac_op_1 ? 2'b01 : mac_op_0 ? 2'b10 : 2'b01;
    assign data0 = 16'hffff;

    assign op_ch = (op_ff != op);

    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            op_ff <= 2'b00;
        else
            op_ff <= op;
    end

    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            reg_rd_cnt <= 5'd0;
        else if (op_ch)
            reg_rd_cnt <= 5'd0;
        else
        begin
            if (&reg_rd_cnt)
                reg_rd_cnt <= reg_rd_cnt;
            else if (reg_rd_cnt == 5'd17)
                reg_rd_cnt <= reg_rd_cnt;
            else if (mdio_done)
                reg_rd_cnt <= reg_rd_cnt + 5'd1;
        end
    end

    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            mdio_load_trg_cnt <= 8'd0;
        else if (op_ch)
            mdio_load_trg_cnt <= 8'd0;
        else if (mdio_load_trg_cnt[7])
            mdio_load_trg_cnt <= mdio_load_trg_cnt;
        else
            mdio_load_trg_cnt <= mdio_load_trg_cnt + 8'd1;
    end

    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            mdio_load <= 1'b0;
        else if ((mdio_load_trg_cnt[7] & (~mdio_done)) || (reg_rd_cnt >= 5'd17))
            mdio_load <= 1'b0;
        else if (&mdio_load_trg_cnt[6:0] | mdio_done)
            mdio_load <= 1'b1;
        else
            mdio_load <= 1'b0;
    end

    always @( * )
    begin
    //    op = 2'b10;
        case(reg_rd_cnt)
        5'd0  : regad = 5'd0;
        5'd1  : regad = 5'd1;
        5'd2  : regad = 5'd2;
        5'd3  : regad = 5'd3;
        5'd4  : regad = 5'd4;
        5'd5  : regad = 5'd5;
        5'd6  : regad = 5'd6;
        5'd7  : regad = 5'd7;
        5'd8  : regad = 5'd8;
        5'd9  : regad = 5'd9;
        5'd10 : regad = 5'd10;
        5'd11 : regad = 5'd11;
        5'd12 : regad = 5'd12;
        5'd13 : regad = 5'd13;
        5'd14 : regad = 5'd14;
        5'd15 : regad = 5'd15;
        5'd16 : regad = 5'd16;
        default : regad = 5'd17;
        endcase
    end

endmodule