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
// storage_qualification module, set the storage qualification, include parameter stor_neg_whole
// Called by     :  debug_core
// Modification history
//
//----------------------------------------------------------------------

module ips_dbc_storage_qualification_v1_2
#(
  parameter NEW_JTAG_IF     = 1,
  parameter  STOR_PIPELINE       = 0,    	//0~1, EXPERIMENTAL
  parameter  TRIG0_TO_15_MU      = 1,    	//1~16
  parameter  STOR_QUAL_CHAIN_BIT = 2,    	//{stor_m0_en,stor_m0_neg...stor_m15_en,stor_m15_neg,stor_neg_whole}
  parameter INIT_STOR_QUAL = 0 
 )
(
  input                         h_rstn ,
  input [1:0]                   clk_conf_trig ,
  input [1:0]                   rst_conf_trig ,
  input                         conf_sel      ,
  input                         conf_tdi      ,
  input                         shift_i      ,  
  input [TRIG0_TO_15_MU-1:0]    match         ,
  output                        stor_en       ,
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
DFWnPky5OwgQTSQ40202yZIMUF3eg6B/e4ELJ2u43r4CWa6TeTeSCmInbvhEesgT73v9UNWBZTSj
9VzhxuQqKsYX8oJQ2sjClNF8e4sQcJr2ZO/L3uJIlzdTfWuVoXnXqKxQFqGwKYLSVpw9WqYrpqsM
pbohB7VG82x1AYh3pnkeTJX6fndo+Z3hpembC1mrv87EHBzSWDzfcUgdYZOV6cIcWUGdQLx+hNzz
RlMqnAB2JT0x7iMdf2SMIGEOcZofT/BqYhnFkb9mijj9ZKAtxMH8ZDArHgA+1cgblWdfhnIp9Tl1
UgoeSzZgDughcij8MVGHBd3iwYp/E+ZVKmv3Ng==

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Pango Microsystems", key_keyname="PANGO_V1.1", key_method="rsa"
`pragma protect key_block
VDRcinrbjazjY2KEWCiC2c59YhKCw808UNpbYPgsnUGx4poQWWqoXAU96zCgordOsYOZN8mKFw3c
zDFewGbJxyAO4BYeVJH92/3mL1Euo6GnrXC6coG/Vjmg8Dn+s9PBNDIcGcZH8h5jUzh26mtbOon8
LOJ41/qOq6wnRYHEdHWdeYLzYd6TlmGA8FZP3aeD7m4/3uGPH9RGbuZ3xnisgt23Sj5BgSo3eU1r
n81cjrx9cxfLDZ9rIFWFTNkzuhjbPho8SLkS4q7o/9v7PSfGBnF0fb1QAGDEsGaxNiJVXcYoIJah
y0G2nqKQFAUowr/Nt/H7VMgkcCTqH2ekFcS4Vw==

`pragma protect data_method="aes128-cbc"
`pragma protect encoding=(enctype="base64", line_length=76, bytes=5792)
`pragma protect data_block
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

`pragma protect end_protected
endmodule