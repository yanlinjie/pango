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
//Functional description: rand_gen

`timescale 1ns/1ps
module rand_gen #(
    parameter WIDTH = 32
)
(
    clk                    ,
    rst_n                  ,
    out_en                 ,
    min                    ,
    max                    ,
    rand_vld               ,
    rand_out
);

input               clk                    ;
input               rst_n                  ;
input               out_en                 ;
input  [WIDTH-1:0]  min                    ;
input  [WIDTH-1:0]  max                    ;
output              rand_vld               ;
output [WIDTH-1:0]  rand_out               ;

wire [WIDTH-1:0]    rand_max               ;
wire [WIDTH-1:0]    out                    ;
reg  [WIDTH-1:0]    out_lck                ;
reg  [WIDTH-1:0]    rand_rg                ;
reg                 rand_cal               ;
reg                 rand_cal_ff0           ;
wire                rand_cal_neg           ;
reg                 out_en_ff0             ;

assign rand_max = max - min;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        out_en_ff0 <= 0;
    else
        out_en_ff0 <= out_en;
end

lfsr #(
    .WIDTH        (WIDTH)
) u0_lfsr (
    .clk          (clk),
    .rst_n        (rst_n),
    .out_en       (out_en),
    .out          (out)
);

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        out_lck <= 0;
    else if(out_en_ff0)
        out_lck <= out;
    else if(rand_cal)
        out_lck <= out_lck - rand_max;
    else
        out_lck <= out_lck;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rand_cal <= 0;
    else if(out_en_ff0 && (out > rand_max))
        rand_cal <= 1;
    else if((out_lck - rand_max) <= rand_max)
        rand_cal <= 0;
    else;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rand_cal_ff0 <= 0;
    else
        rand_cal_ff0 <= rand_cal;
end

assign rand_cal_neg = ~rand_cal & rand_cal_ff0;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rand_rg <= 0;
    else if(out_en_ff0 && (out <= rand_max))
        rand_rg <= out;
    else if(rand_cal_neg)
        rand_rg <= out_lck;
    else;
end

assign rand_vld = (out_en_ff0 && (out <= rand_max)) || rand_cal_neg;
assign rand_out = rand_rg + min;

endmodule