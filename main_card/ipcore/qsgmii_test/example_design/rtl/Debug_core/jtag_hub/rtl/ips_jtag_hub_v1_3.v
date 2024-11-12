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
//the jtag_hub module, it controls to select which debug_core and sub module
//note that one FPGA only support one jtag_hub
//
module ips_jtag_hub_v1_3
 #(
   parameter  CTRL_PORT_NUM = 1,     //@IPC int 1,15           //the number of usr_app connect with jtag_hub
   parameter  UJTAG_SEL     = 0      //1:use jtagif ;0:use scanchain
 )
 (
  //for user jtagif
   input            urck_in,
   input            utdi_in,
   // for JTAG_interface                        
   input            tdi_in,                    //TDI for user data register;
   output           tdo_out,                   //TDO for user data register 
   input            reset_dr,	                 //active high reset when TAP state in e_TEST_LOGIC_RESET state
   input            shift_in,	                 //TAP state in e_SHIFT_DR
   input            update_in,                 //TAP state in e_UPDATE_DR
   input            capture_in,                //TAP state in e_CAPTURE_DR
   input            sel_in,                    //user data register is selected
   input            drck_in,                   //TCK for user data register
   input            h_rstn ,                   //hw reset from user logic device, active low.    
  // for user_app interface(debug_core,etc)
   output           drck_o,                    //transfer TCK to each user_app
   output           conf_tdi,                  //transfer TDI to each user_app
   output reg [15:0]conf_sel,                  //select config module which indicated by ID  
   output reg [4:0] id_o,                      //ID number indication
   output           capt_o,                    //capture
   output           shift_d,                    //shift_in delay 1 clk
   input     [15:0] hub_tdo                    //read back signal from each user_app

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
PlPUn502lDwQw/qIvg+juWRyZPBFrFukMCIATrYhtx9OCDLx5pG7q00Gq5KAj9xuTgyqiaABQvLh
hNFgWZWY5L/peX2v7U9eGeM1RzmAl3WiM27u/15dwrcvnxHtv1MGg2cgyw8a9X4z2v4XVvcVBAoT
Ttj4OrM/pA39/suWQwuXnOMAszQDpqd+8NBXZhB0jX3Rgr/9xDVr3/wHCcIeqOXT++UmRyZdFiJw
y3cPXWoz1imv4cRg/Egjl1ztTJhyx3sl0R6VwzYruwCfp7O+IEjK/YVXJBXcaz1AKNIbEolzY9GA
4YxQdtiiBmOTrUK2/61R4fT/dRsqqrwO1d474g==

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Pango Microsystems", key_keyname="PANGO_V1.1", key_method="rsa"
`pragma protect key_block
hs+2gDdobx+s6VFSFC5wAjZXiXH86aFRS188EgnOy5aYSHNm0v+hy2V0WP5vVyjxuc7P5SBEWUFg
qXu2y2s1vcmduokAQMsU1laGmQdsyWg0/X7TnSO7oASaJtEQ8FgUoO4HHizEq/NfCEy7g7uceUHJ
PwU+Ep1fLUahwUJzDZDh/hPHPQyphdBgR2v5m1KKMj0/qV8Xh40qgrcIsCDowKy+EWSrTM616Iwr
Hn6vKZVVC10K2H4+YfbiZnhHCDkt/WlB5RMPM8Xvf4MDzH5sQz0h4nn4qF1B8N4xHU0FpAWeS3wM
V2Hzzskndx/kIwuoi1SGqU2ZfNUHkZXc2k5/1A==

`pragma protect data_method="aes128-cbc"
`pragma protect encoding=(enctype="base64", line_length=76, bytes=11296)
`pragma protect data_block
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
MkjBeAEptelfDg==

`pragma protect end_protected
endmodule
