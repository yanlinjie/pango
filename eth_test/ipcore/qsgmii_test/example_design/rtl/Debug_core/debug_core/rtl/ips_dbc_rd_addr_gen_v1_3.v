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
//the rd_addr_gen module, it contains tdo_mux_s function 
//
//

module ips_dbc_rd_addr_gen_v1_3
 #(
   parameter  NEW_JTAG_IF = 1,
   parameter  INFO_CHAIN_BIT = 81,                       //the total bit number of information  
   parameter  INFO_CHAIN  = 0,      //the information data
   parameter  DATA_DEPTH     = 9,	                       //the range is 9~17
   parameter  DATA_BIT       = 1,	                       //1~4096   
   parameter  DATA_CHAIN_BIT       = 2,	                 //DATA_BIT+1
   parameter  STATUS_CHAIN_BIT     = 10                  //	DATA_DEPTH +1    
 )
 (
   input                       h_rstn,          //hw resetn from user logic              
   input                       clk_conf,        //jtag clk            
   input                       rst_conf,        //sw rst from jtag_hub            
   input                       clk_trig,   
   input                       info_en,         //sw select to read the info data to tdo ,control[4]            
   input                       status_en,       //sw select to read the status data to tdo, control[5]          
   input                       ramdata_en,      //sw select to read the ram data to tdo,control[6]          
   output reg [DATA_DEPTH-1:0] ram_radr,            
   input  [DATA_DEPTH:0]       status,              
   input  [DATA_BIT:0]         ram_rdata,           
  //add others tdo             
   input  [19:0]               conf_rdlast,
   input  [19:0]               conf_rdata,
   input                       conf_sel,   
   input  [4:0]                conf_id,
   input  [4:0]                conf_reg_rb,
   input                       operation_ind,      
   output reg                  tdo_mux             
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
tDQyrpR949vcLs95iLV6MKbD10DMSuYwXNlnkFZvhf2eevUWtrIfWhQUDsnjnFPTpEpAoHyGsszK
+rGLTi4W9ovFWj0GY5YddpFI4vbtQAGZh6OdxtvOm6FPJ+xoBRt23ys9OdvEgFBZ00LZrzvIPbPw
7Nv24x4u/DAVkrEgwrVDHIB21o0H2dDk6IJKDqvM6ti+iqAJ+FRbFvUzInI198Ri3QCb4OqQKy3H
Z5C+Vvv7QvbUnSUMbtGYGRWAQusAYwZ9Cc+/KQ7YpzTHkOAZCsZhpQpReG7ZyqGCWYEUneF/DSOG
piLrvawYLR7aJIafC6n/OfG9jJ8yiD0/ayDybw==

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Pango Microsystems", key_keyname="PANGO_V1.1", key_method="rsa"
`pragma protect key_block
IEl86CmP5vbY0ms8Ius550vr+IhGtKYzJWvlOoNmxRhPPDfHVuOa+u7r3zfpqeHejAnG76x13KEA
oaNmexzxCD1RD3dBBHVkaE3ZH0hJxSvukSCkleqW1UAeIEedEoI/c7fTqniOg/GggRlo1v5OqrWV
Gx3HIXUGI/xfLaTR2AZY7uTaN6Mf5Tr+wDD+x7LN0nWIQSsHqDS71iNhvhBWNkzm7K80e/CjgCu3
HBengnr23YMLrfYA6CD9KcLFeziEDe8ZqiPCUlsPXoJjdaLq6FgZtgDRIgPuHcI4PPW6cwWYdZTE
7buToZqxdStpA38R9uybjhRzHGZcbTgPyS+i+g==

`pragma protect data_method="aes128-cbc"
`pragma protect encoding=(enctype="base64", line_length=76, bytes=9552)
`pragma protect data_block
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

`pragma protect end_protected
endmodule