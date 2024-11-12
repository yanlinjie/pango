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
// trigger_output module, set the trigger out
// Called by     :  debug_core
// Modification history
//----------------------------------------------------------------------

module ips_dbc_trigger_output_v1_2
#(
 parameter NEW_JTAG_IF     = 1,
 parameter  AREA_SPEED = 0,                      //0~5, EXPERIMENTAL
 parameter  TRIG_OUT_CHAIN_BIT = 3,	             //{trig_out_mode}
 parameter INIT_TRIG_OUT = 0 
 )
(
  input                         h_rstn ,
  input                         clk_conf,
  input                         rst_conf,
  input                         conf_sel,
  input                         conf_tdi,
  input                         clk_trig,
  input                         rst_trig,
  input                         trigger ,
  input                         shift_i,  
  output  reg                   trig_out,
  input                         conf_rden,
	input [4:0]                   conf_id,
	input                         conf_sel_rd,
  output                        conf_rdlast,
  output                        conf_rdata   
);

`pragma protect begin_protected
`pragma protect version=1
`pragma protect author="default"
`pragma protect author_info="default"
`pragma protect encrypt_agent="Synplify encryptP1735.pl"
`pragma protect encrypt_agent_info="Synplify encryptP1735.pl Version 1.1"

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect key_block
heIudDQFcladZh0ZXyCL9YsqCLbr8Mn2jIWBvb6Yt6vx3jrsgkEstNKNn7HUNgIxgrYmDHuIEr/c
bucOrADKXaxAxPOkIE/4VOrXc5vsHcQjFGv+XbYqwklU6O9ZcJUn2LetenX/DzlIcV/7RNlneNfa
hrZIxdGnHS/QV4aQ/ds+mzKcG/vTJmg538M4Fzupzs9ozUcrzPZJb/SZymwbbKqVtSCjLppxeCuj
WlDtidTtFwsrQzRTYy4kwQMGZCUbAQqbThWBPXuCrkYEnjvbE8dxrM2i+faw8cTpjY/0x2XB211e
CvrAATSTx3FrursrFaegDD4UOAbNrSOxvoeZvg==

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Pango Microsystems", key_keyname="PANGO_V1.1", key_method="rsa"
`pragma protect key_block
piisy9Wl3ju3083eqzvF6I0ORrOF+R9L2OWdB1RClIM/x8LoIx2aBcZ5k5x1Ra3EO22Ox0dIXqUF
Pc+79M1KmM1b7wauKmbew1lbQ6CQ1GcUydssf5LW7YdwOLCMZ2+XNvciiS3+rBW+oWKBiDoKo7/2
j0VplzEG17XCdj8DrgVNAS1aGmfujS79xdXlBam5u856Ck78ww9bD/DXiNKm7CaOSPWW+9tj5VFI
AvfTgyelItqy2z/QrJo71YEHrHWlsBcVZ8/NraCQIe04Voiy3n98rj6ZAhVtG60CyzbW7qr6pwRm
iWpNC6y4YZSnhVejqXR0PpJ/9Sb5QSuUM7MHGQ==

`pragma protect data_method="aes128-cbc"
`pragma protect encoding=(enctype="base64", line_length=76, bytes=3968)
`pragma protect data_block
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

`pragma protect end_protected
endmodule