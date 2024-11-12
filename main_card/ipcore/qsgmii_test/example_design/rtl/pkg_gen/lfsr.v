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
//Functional description: lfsr

`timescale 1ns/1ps
module lfsr #(
    parameter WIDTH = 32
)
(
    clk                    ,
    rst_n                  ,
    out_en                 ,
    out
);

input               clk                    ;
input               rst_n                  ;
input               out_en                 ;
output [WIDTH-1:0]  out                    ;

reg  [WIDTH-1:0]    myreg                  ;
wire [WIDTH-1:0]    polynomial             ;
wire [WIDTH-1:0]    feedback               ;
wire [WIDTH-1:0]    data                   ;

assign polynomial = (WIDTH == 4 ) ? ( 4'hc         ) :
                    (WIDTH == 5 ) ? ( 5'h1b        ) :
                    (WIDTH == 6 ) ? ( 6'h33        ) :
                    (WIDTH == 7 ) ? ( 7'h65        ) :
                    (WIDTH == 8 ) ? ( 8'hc3        ) :
                    (WIDTH == 9 ) ? ( 9'h167       ) :
                    (WIDTH == 10) ? (10'h309       ) :
                    (WIDTH == 11) ? (11'h4ec       ) :
                    (WIDTH == 12) ? (12'hac9       ) :
                    (WIDTH == 13) ? (13'h124d      ) :
                    (WIDTH == 14) ? (14'h2367      ) :
                    (WIDTH == 15) ? (15'h42f9      ) :
                    (WIDTH == 16) ? (16'h847d      ) :
                    (WIDTH == 17) ? (17'h101f5     ) :
                    (WIDTH == 18) ? (18'h202c9     ) :
                    (WIDTH == 19) ? (19'h402fa     ) :
                    (WIDTH == 20) ? (20'h805c1     ) :
                    (WIDTH == 21) ? (21'h1003cb    ) :
                    (WIDTH == 22) ? (22'h20029f    ) :
                    (WIDTH == 23) ? (23'h4003da    ) :
                    (WIDTH == 24) ? (24'h800a23    ) :
                    (WIDTH == 25) ? (25'h10001a5   ) :
                    (WIDTH == 26) ? (26'h2000155   ) :
                    (WIDTH == 27) ? (27'h4000227   ) :
                    (WIDTH == 28) ? (28'h80007db   ) :
                    (WIDTH == 29) ? (29'h100004f3  ) :
                    (WIDTH == 30) ? (30'h200003ab  ) :
                    (WIDTH == 31) ? (31'h40000169  ) :
                    (WIDTH == 32) ? (32'h800007c3  ) : 0;
`ifdef IPS_SGMII_SPEEDUP_SIM
initial
begin
    //unsupported width, fatality.
    #100 if(polynomial == 0)
         begin
             $display("Illegal polynomial selected!");
             $stop;
         end
end
`else
`endif

assign feedback = {WIDTH{myreg[WIDTH-1]}} & polynomial;
assign data = myreg ^ feedback;

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n)
      myreg <= {WIDTH{1'b1}};
  else if(out_en)
      myreg <= {data[WIDTH-2:0],myreg[WIDTH-1]};
  else;
end

assign out = myreg;

endmodule