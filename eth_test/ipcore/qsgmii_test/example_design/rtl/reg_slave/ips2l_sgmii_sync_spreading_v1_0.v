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
// Used for async signal witch is not enough width
module ips2l_sgmii_sync_spreading_v1_0 #(
  parameter  PIPE_NUMBER              = 5            ,  // pipe number and source clock domain; depending om src_clk/dec_clk
  parameter  SYNC_VALUE               = 1                // 1: high sync; 0: low sync
)(
    input  wire        i_src_clk            ,
    input  wire        i_dec_clk            ,
    input  wire        i_sig_presync        ,
    output wire        o_sig_sync
);

reg                     sig_presync_ff1           ;
reg                     sig_presync_ff2           ;
reg  [PIPE_NUMBER-1:0]  sig_presync_buf           ;
reg                     sig_presync_spreading     ;
reg                     sig_presync_spreading_ff1 ;
reg                     sig_presync_spreading_ff2 ;

// for reset domain crossing
always@(posedge i_src_clk)
begin
    sig_presync_ff1 <= i_sig_presync;
    sig_presync_ff2 <= sig_presync_ff1;
end

always@(posedge i_src_clk)
begin
    sig_presync_buf <= {sig_presync_buf[PIPE_NUMBER-2:0],sig_presync_ff2};
end

generate
if(SYNC_VALUE==1) begin : SYNC_HIGH
    always@(posedge i_src_clk)
    begin
        sig_presync_spreading <= |{sig_presync_buf,sig_presync_ff2};
    end
end
else begin : SYNC_LOW
    always@(posedge i_src_clk)
    begin
        sig_presync_spreading <= &{sig_presync_buf,sig_presync_ff2};
    end
end
endgenerate

always@(posedge i_dec_clk)
begin
    sig_presync_spreading_ff1 <= sig_presync_spreading    ;
    sig_presync_spreading_ff2 <= sig_presync_spreading_ff1;
end

assign o_sig_sync = sig_presync_spreading_ff2;

endmodule
