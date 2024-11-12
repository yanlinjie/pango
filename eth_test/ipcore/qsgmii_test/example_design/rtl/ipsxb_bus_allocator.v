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
//Functional description: ips2l_bus_allocator
`timescale 1ns/100ps
module ipsxb_bus_allocator    #(
    parameter  AW = 6'd20
)
(
//APB_IN
    input wire [AW:0]       paddr       ,
    input wire              pwrite      ,
    input wire              psel        ,
    input wire              penable     ,
    input wire [31:0]       pwdata      ,

    output reg [31:0]       prdata      ,
    output reg              pready      ,
//APB_core0
    output wire [18:0]      paddr_0     ,
    output reg              pwrite_0    ,
    output reg              psel_0      ,
    output reg              penable_0   ,
    output wire [31:0]      pwdata_0    ,

    input wire [31:0]       prdata_0    ,
    input wire              pready_0    ,
//APB_core1
    output wire [18:0]      paddr_1     ,
    output reg              pwrite_1    ,
    output reg              psel_1      ,
    output reg              penable_1   ,
    output wire [31:0]      pwdata_1    ,

    input wire [31:0]       prdata_1    ,
    input wire              pready_1    ,
//APB_core2
    output wire [18:0]      paddr_2     ,
    output reg              pwrite_2    ,
    output reg              psel_2      ,
    output reg              penable_2   ,
    output wire [31:0]      pwdata_2    ,

    input wire [31:0]       prdata_2    ,
    input wire              pready_2    ,
//APB_core3
    output wire [18:0]      paddr_3     ,
    output reg              pwrite_3    ,
    output reg              psel_3      ,
    output reg              penable_3   ,
    output wire [31:0]      pwdata_3    ,

    input wire [31:0]       prdata_3    ,
    input wire              pready_3    ,
//MDIO
    input wire              mdo_0       ,
    input wire              mdo_en_0    ,

    input wire              mdo_1       ,
    input wire              mdo_en_1    ,

    input wire              mdo_2       ,
    input wire              mdo_en_2    ,

    input wire              mdo_3       ,
    input wire              mdo_en_3    ,

    output wire             mdo         ,
    output wire             mdo_en
);

assign paddr_0      = paddr[18:0];
assign pwdata_0     = pwdata;
assign paddr_1      = paddr[18:0];
assign pwdata_1     = pwdata;
assign paddr_2      = paddr[18:0];
assign pwdata_2     = pwdata;
assign paddr_3      = paddr[18:0];
assign pwdata_3     = pwdata;

always@(*)
begin
    pwrite_0    = 1'b0;
    psel_0      = 1'b0;
    penable_0   = 1'b0;
    pwrite_1    = 1'b0;
    psel_1      = 1'b0;
    penable_1   = 1'b0;
    pwrite_2    = 1'b0;
    psel_2      = 1'b0;
    penable_2   = 1'b0;
    pwrite_3    = 1'b0;
    psel_3      = 1'b0;
    penable_3   = 1'b0;
    prdata      = 32'b0;
    pready      = 1'b0;
    if( paddr[18] == 1'b0 )begin
        pwrite_0    = pwrite;
        psel_0      = psel;
        penable_0   = penable;
        prdata      = prdata_0;
        pready      = pready_0;
    end
    else begin
        case(paddr[AW:(AW-1)])
            2'b00:begin
                pwrite_0    = pwrite;
                psel_0      = psel;
                penable_0   = penable;
                prdata      = prdata_0;
                pready      = pready_0;
            end
            2'b01:begin
                pwrite_1    = pwrite;
                psel_1      = psel;
                penable_1   = penable;
                prdata      = prdata_1;
                pready      = pready_1;
            end
            2'b10:begin
                pwrite_2    = pwrite;
                psel_2      = psel;
                penable_2   = penable;
                prdata      = prdata_2;
                pready      = pready_2;
            end
            2'b11:begin
                pwrite_3    = pwrite;
                psel_3      = psel;
                penable_3   = penable;
                prdata      = prdata_3;
                pready      = pready_3;
            end
            default:begin
                pwrite_0    = 1'b0;
                psel_0      = 1'b0;
                penable_0   = 1'b0;
                prdata      = 32'b0;
                pready      = 1'b0;
            end
        endcase
    end
end

assign mdo      = mdo_0 | mdo_1 | mdo_2 | mdo_3;
assign mdo_en   = mdo_en_0 | mdo_en_1 | mdo_en_2 | mdo_en_3;
endmodule
