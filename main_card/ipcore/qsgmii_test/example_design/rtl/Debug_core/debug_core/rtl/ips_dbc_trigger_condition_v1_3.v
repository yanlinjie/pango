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
// trigger_condition module, set the trigger condition
// Called by     :  debug_core
// Modification history
//change rst intitial value from parameter,2020/06/01
//----------------------------------------------------------------------

module ips_dbc_trigger_condition_v1_3
#(
  parameter NEW_JTAG_IF     = 1,
  parameter  TRIG_PIPELINE             = 0,	    //0~1, EXPERIMENTAL
  parameter  MU_PIPELINE               = 0,	    //0~4, EXPERIMENTAL
  parameter  TRIG0_TO_15_MU            = 1,	    //1~16
  parameter  MAX_SEQ_LEVEL             = 1,	    //1~16
  parameter  TRIG_COND_CHAIN_BIT       = 2,	    //{trig_m0_en,trig_m0_neg...trig_m15_en,trig_m15_neg,trig_neg_whole}
  parameter  INIT_TRIG_COND = 0 
 )
 (
  input                         h_rstn ,
  input [1:0]                   clk_conf_trig ,
  input [1:0]                   rst_conf_trig ,
  input                         conf_sel, 
  input                         conf_tdi, 
  input                         shift_i,
  input [TRIG0_TO_15_MU-1:0]    match,
  output [TRIG0_TO_15_MU-1:0]   trig_mu_neg,         
  output                        trigger,
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
j71uV1DN+bLY90TkAgI3sG4VQ3JSmgAiP0uJ4Vz6ZKRqJpWL0L8CWao4r3boQQVBkYJKlMkFEsB6
8t0SwH8JsmtxuBJurJTgNTHrPbq9pDALq9nqInTgWPnbUkls3h4eqA91qQ2Shb0UJuuk3WX7BAaV
Pa5VfBr5PG9EZqpxsjmqz+iIiKHVgHC/yJLotx8zOR/okuSgcLMbOXrQ/1eKnSTQMDpbNdazSiH1
1/+2E1tRUB4MIQyRtOyNi8kZ3+KrCu8AXIXDCEcEZgEdSHiiqk+3CWAwvFmKMy16l0mgcfCz+Zcn
JFFM6rct2JcncBRjKy+706kjmr6CE2oQsyqSFA==

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Pango Microsystems", key_keyname="PANGO_V1.1", key_method="rsa"
`pragma protect key_block
KLEpOAwXHUxs9ICFsPFz3dqbspyketTAmPVRK6Bf2RvjlZ+HcORwsHNrnyOpwS4NY6NfeqEaLZsZ
571vi2gct07h4BtXYkWwGb68oW/Zt6s7u5e3LG7uS0azxyAWIQEC3DqOY1bGHRGtdIC0GEvecO2j
bDYRJO8jmwtMsjWvwcnxFqAq6T+SQoxSyx5/W/l4P6cp+AonGV5TR8fbiqigzsGAFEkgd3npfVb+
hEZr5qnetkslH2ZEebm55v1rkz6PFPM/fZeIvaFT1W6a3w9eUwRCgkzRXssOgZpGqcf1ei2AbDge
oZpnGY20wph4IEuYxk1FlQVQGihhY6LcgiVEQQ==

`pragma protect data_method="aes128-cbc"
`pragma protect encoding=(enctype="base64", line_length=76, bytes=11360)
`pragma protect data_block
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
8jQAW+u+So74uQXhDa13TLg=

`pragma protect end_protected
endmodule