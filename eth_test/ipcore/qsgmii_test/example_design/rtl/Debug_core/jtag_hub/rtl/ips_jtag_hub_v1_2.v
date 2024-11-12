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
module ips_jtag_hub_v1_2
 #(
   parameter  CTRL_PORT_NUM = 1     //@IPC int 1,15           //the number of usr_app connect with jtag_hub  
 )
 (
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
YFjhIQZ9ZTR6MxdS5bN98zZlHVznlXvMHyMxdp7IZ9PXr6YMs4L9pAMbX/Ma0Pr/maVOXZF1eHJ/
tbZ0TxLTwPgBWP8v0CEBzIEtu3PuZfRAJ1Vma0f/Qz3HKiQQAGW6xRPYmGxoU07oLLsY7lX0eHc7
Z4uJ+0Wc6bb1uC6Ka0TDefq5mbzMq82UTZgf3aB49h/L/ezbUZbaXd2nV/RY6+O9BBM/gBaM+gR6
lbsP7boPdFFyqZ+GDns9qN0nwrebN1+rEyrGOcAxOQyXQ2UmKhS7mCMrnSiqUbeD0+yygy2j6tfE
7IzjWENwgAyEC0MVwX7u2qpnH19fcGe825Xz8w==

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Pango Microsystems", key_keyname="PANGO_21", key_method="rsa"
`pragma protect key_block
XlsTQmB6l0EMf0G1jJNbuSal+/bA12XhvPfPeRUlrDp8wgC+BGLLP1MUfYH5zdKCrHxyw3v+bv6A
Xr8oxFf3GVMdAsfCO0EY3NezFEgmMFqyFOfeZAXVkDSs2z84ZZogDce+U4LnJdV26wuvlFf7WCl7
6WKNNbplImx7vQc/TvDCcsQ9omxoICmoeLNWQrCoWEQCWjN/kaQm/gMufvFrdTU0h1dht6ZL34af
Rwu2n7uFRgR/wJjYveiee0LEemR2/f1+C+jWk1+DLW8054E0Wr27GsxV/Tsl9fyV7Mbr7JMff3uq
RcbQwMxniQg2SrNq+TiZ47ZVLXNbQaxIgrGeyw==

`pragma protect data_method="aes128-cbc"
`pragma protect encoding=(enctype="base64", line_length=76, bytes=10928)
`pragma protect data_block
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

`pragma protect end_protected

endmodule
