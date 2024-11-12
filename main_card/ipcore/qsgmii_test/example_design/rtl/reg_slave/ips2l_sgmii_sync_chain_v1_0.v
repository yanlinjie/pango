///////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
///////////////////////////////////////////////////////////////////////////////
//
`timescale 1ns/1ps
module ips2l_sgmii_sync_chain_v1_0 #(
parameter DATA_WIDTH = 1
)
(
    input  wire                    i_clk                ,
    input  wire [DATA_WIDTH-1:0]   i_sig_presync        ,
    output reg  [DATA_WIDTH-1:0]   o_sig_synced
);

reg [DATA_WIDTH-1:0]   sig_presync_ff       ;


always@(posedge i_clk)
begin
    sig_presync_ff <= i_sig_presync ;
    o_sig_synced   <= sig_presync_ff;
end

endmodule
