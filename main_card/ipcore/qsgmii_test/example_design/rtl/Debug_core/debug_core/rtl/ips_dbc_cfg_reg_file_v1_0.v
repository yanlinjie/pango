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
//the cfg_reg_file module, which is register file of configuration 
//

  module ips_dbc_cfg_reg_file_v1_0 
  #(
   parameter NEW_JTAG_IF     = 1,
   parameter c_CFG_CHAIN_BIT = 256
   )
  (
   input   rstn,     
   input   cfg_clk,
   input   cfg_cs,
   input [4:0]  conf_id,
   input   [c_CFG_CHAIN_BIT-1:0] cfg_reg_data,
   input   cfg_rden,
   output  reg cfg_rdlast,
   output  reg cfg_rdata    //read latency is one clock cycle
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
QMK8R+fxA2KMv/62Sg2elfxD92J9r3JO2vEZfA8iyV7eATeaZh9n0muTt6m11mDVErSKrCJlY49q
+LA7e0FHx2m2OjA31o2BGwPmbzY9upvEdAU7bjQ8swBpsbvo6OOEVF4egTivtSkTrOB1ud85kS0m
axp1v6fRqcvigwRfBs64Uy5QtGUDR5GSAQTew3mnyCOm38qcEt+KUFpVdfbY8sl7/kQgmOsjnvYQ
DRt7Wdgc/5figRB1kAmAfsG7wFd6xszG+53i5ZYHBAiDZPB53FvL/E8XXpjllmP4aZfHjIQd2ls/
InA9kGo46r50/yeZN56HLN+iKdBpbLTB1v+TXQ==

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Pango Microsystems", key_keyname="PANGO_V1.1", key_method="rsa"
`pragma protect key_block
VVmMbQQQHhCc6YrLkudZjnlb3oguoLA48YP3FHcuFnBndwKb8rpdLJiXIPUNmMjRUoH05Z2IPOWR
LsKxtZG9BiZa1AUgoVPt/T0aTZCgfFxdw5QlNsTMvD1VDpBfzAH8QGKgbyvmydYQ3sAUrT7zLGn+
nfKErGPEfmjDRysOkU2XiaAG+Dy/8ktOVNDGfnxDcgt7Oz5iIEjVnsn/KuOaXXqdOw+GBukjxGOy
4n4cEFzGYYcErfo3Vg+iP1mM4gobCgKQATBtmrdWxXk3H6cpEBMUDbC2XWJOLyoQexTTWtLOlrXy
AKE7u/DaJUgpRB9ZadNUWsWtK75/h2lyqe6FpQ==

`pragma protect data_method="aes128-cbc"
`pragma protect encoding=(enctype="base64", line_length=76, bytes=1728)
`pragma protect data_block
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
N9ac/MRiNkq0bwV8ZsmvIrLJ

`pragma protect end_protected
  endmodule