//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
// hub_data_decode module, to get the config info from jtag_hub module
// Called by     :  debug_core
// Modification history
//
//----------------------------------------------------------------------
//
//
 module ips_dbc_hub_decode_v1_2 
 #(
   parameter  NEW_JTAG_IF      = 1,
   parameter INIT_ENABLE       = 0
  )
 (
  input                       h_rstn,
  //interface for JTAG serial configuration
  input                       clk_conf,
  //common configuration interface each user unit
  input                       conf_sel,
  input                       hub_tdi,
  input   [4:0]               id_i,
  input                       capt_i,
  input                       shift_i,
  //interface with sub module unit
  output                      conf_tdi,
  output reg                  conf_rst,
  output reg                  start,  
  output reg  [22:0]          conf_sel_int,
  output reg  [19:0]          conf_rden,
  output [4:0]                conf_id_o,  
  output                      conf_sel_o,   
  output [4:0]                conf_reg_rbo
 )/* synthesis syn_preserve = 1 */;
`pragma protect begin_protected
`pragma protect version=1
`pragma protect author="default"
`pragma protect author_info="default"
`pragma protect encrypt_agent="Synplify encryptP1735.pl"
`pragma protect encrypt_agent_info="Synplify encryptP1735.pl Version 1.1"

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect key_block
2HLSCySotYkfFnrOkOSYmxdRun83UipLUW00BFqOVleNz0haIIpeI1rbZF4gcNk1S1VVYf2NQk/n
ZuHRr33zsIFOlqQ0VwfdhWTI/zT88FvcipNxuiL0xUwEBr9MJW0bjP+LfoBkKFZwfClFhk8N/3Wh
7GeZVH3ND7DMx13ZgeOiir3wCp23Y5yqrBlQ5TvMMkQgOqW0rK7yS1vWspTX11SKjlth3G73GwYk
RNYMx/5lcuk86RAoZlYcDOfKkpJLJzH1FsFG/HOXUIZadAomikNtdMn5XxOYKXKKO5X8g20HGytJ
lw7r+QbZlS/3oYOxGL3T9BK7hRyzrplnVQP+ow==

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Pango Microsystems", key_keyname="PANGO_V1.1", key_method="rsa"
`pragma protect key_block
QfL++T0mj3TG8lMorZMS0DrizNqOlSVKSJK0opmSB4rGnrvpSqZsLFaRsXMuc+rNUOBSGYEt+8ql
4K87ypGRHIxdeQ4a5mbjTMwOqXaCOQVWFelv5qGr2bDaNy21dj4WYWyDG2JerN4J2giqu7xPCMaq
dtGVF3ULwMGre61upwjGXlRdtD03E5KsJR1KlSayeG8e+aktcfNrfjBbyPDsU4eG5YkY6ne/Xv04
9YUhXJRJfjPWa1zUEzYg8Lely+KGcGfH/OtB0Qcdk8+X22hPA/7Lfno50w4aQ5OIdZtg6UItcK/L
ka7nanm4R0trX5Cnnxdex9zeurxiFg3H11rjOw==

`pragma protect data_method="aes128-cbc"
`pragma protect encoding=(enctype="base64", line_length=76, bytes=11136)
`pragma protect data_block
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
2cweJuYci3uGLYJcc6ealsNY2gc3

`pragma protect end_protected
endmodule      