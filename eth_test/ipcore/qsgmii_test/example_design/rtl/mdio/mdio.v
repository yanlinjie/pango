
/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////Functional description: mdio

`timescale 1ns/1ps

module mdio(
input mdc,
input rst_n,
input [1:0] op,
input       mdio_load,
input [4:0] phyad,
input [4:0] regad,
input [15:0] data0,

input mdo,
input mdo_en,
output reg [15:0]   mdio_rd_shift,
output reg mdi,
output reg mdio_done
);

reg [15:0] mdio_cnt;
reg mdio_en;

reg [1:0]  op_ff;
reg [4:0]  phyad_ff;
reg [4:0]  regad_ff;
reg [15:0] data0_ff;

always @ (posedge mdc or negedge rst_n)
begin
    if(!rst_n) begin
    	mdio_cnt     <= 16'd0;
    	mdi          <= 1'b0;
    	mdio_done    <= 1'b0;
    	mdio_en      <= 1'b0;
    	op_ff        <= 'd0;
      phyad_ff     <= 'd0;
      regad_ff     <= 'd0;
      data0_ff     <= 'd0;
    end
    else if(mdio_load == 1'b1) begin
    	mdio_en      <= 1'b1;
      op_ff        <= op       ;
      phyad_ff     <= phyad    ;
      regad_ff     <= regad    ;
      data0_ff     <= data0    ;
    end
    else if(mdio_en == 1'b1) begin
    if(mdio_cnt <= 16'd31) begin        //32 bits PRE
    	mdi <= 1'b1;
    	mdio_cnt <= mdio_cnt + 1'b1;
    end
    else if(mdio_cnt <= 16'd32) begin   //ST
    	mdi <= 1'b0;
    	mdio_cnt <= mdio_cnt + 1'b1;
    end
    else if(mdio_cnt <= 16'd33) begin   //ST
    	mdi <= 1'b1;
    	mdio_cnt <= mdio_cnt + 1'b1;
    end
    else if(mdio_cnt <= 16'd34) begin   //OP
    	mdi <= op_ff[1];
    	mdio_cnt <= mdio_cnt + 1'b1;
    end
    else if(mdio_cnt <= 16'd35) begin   //OP
    	mdi <= op_ff[0];
    	mdio_cnt <= mdio_cnt + 1'b1;
    end
    else if(mdio_cnt <= 16'd40) begin   //PHYAD
    	mdi <= phyad_ff[40 - mdio_cnt];
    	mdio_cnt <= mdio_cnt + 1'b1;
    end
    else if(mdio_cnt <= 16'd45) begin   //REGAD
    	mdi <= regad_ff[45 - mdio_cnt];
    	mdio_cnt <= mdio_cnt + 1'b1;
    end
    else if(mdio_cnt <= 16'd46) begin   //TA
    	mdi <= 1'b1;
    	mdio_cnt <= mdio_cnt + 1'b1;
    end
    else if(mdio_cnt <= 16'd47) begin   //TA
    	mdi <= 1'b0;
    	mdio_cnt <= mdio_cnt + 1'b1;
    end
    else if(mdio_cnt <= 16'd63) begin   //WRITE DATA
    	mdi <= data0_ff[63 - mdio_cnt];
    	mdio_cnt <= mdio_cnt + 1'b1;
    end
    else if(mdio_cnt <= 16'd64) begin   //
    	mdi <= 1'b0;
    	mdio_cnt <= mdio_cnt + 1'b1;
    	mdio_done <= 1'b1;
    end
    else if(mdio_cnt <= 16'd65) begin   //
    	mdi <= 1'b0;
    	mdio_cnt <= 16'h0;
    	mdio_done <= 1'b0;
    	mdio_en <= 1'b0;
    end
    end
end

always @(posedge mdc or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        mdio_rd_shift <= 16'h0;
    end
    else if(mdo_en)begin
        mdio_rd_shift <= {mdio_rd_shift[14:0],mdo};
    end
end

endmodule