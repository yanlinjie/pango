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
//the data_capture_memory module
// Called by     :  debug_core
// Modification history
//
//----------------------------------------------------------------------

module ips_dbc_data_capture_mem_v1_0
#(
 parameter  DATA_DEPTH = 9,
 parameter  DATA_WIDTH = 8
 )
(
 input                   rdclock  ,
 input                   wrclock  ,
 input  [DATA_DEPTH-1:0] rdaddress,
 output reg [DATA_WIDTH-1:0] q        ,
 input                   wren     ,
 input  [DATA_DEPTH-1:0] wraddress,
 input  [DATA_WIDTH-1:0] data     
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
1HwJy3u4WzyFazBhJe1biE37gEgAwdMwVOm0t6aD2HHL0Ax6E8lue0EAExp53wWQ4d18de4NIbE1
+LaMRqpiJ1F2Ey60GWgrdKjSCnFC6IHfWgxVp/754YfoJoc75AjObuAShTqYkqFrNtyRpU0VJc2t
LcV0akVq8n8qYaeA6BhT4ErXzTbmdaQTgNcoJzP0L/mpKlYF5F591hecFsHM0Cgyy5NvUS5TR8Qz
JRLIHgaUWoFUizNMHAsivXco04tTZVmtuoxEuCqARR2bUB0tyNV5xdwIznSOqAb5pPy3QhpwZhdK
AW1226XgL5MwikLjy9diITorWf8of9cGyjMXWg==

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Pango Microsystems", key_keyname="PANGO_21", key_method="rsa"
`pragma protect key_block
jKA4ScLn5x7W/gdE42oKVKUI6yX4IdKOZKfEv9XsFZ8CFVsegSLI6NsDqGWe6GpOLdyy0L2NF8/A
XX/NyZIyHMU4NGilmBPyQF4mR6pQSi+zGNqxnrcIRdZ2JV2NvYvzwAxLaPUIfvS2ME6eov3E2Y9e
I1yKCPgHWxWy/BZqhRrCQkLJxLVzgOGDG8VYMnqlI8DaPGOythsSK6YOqFjsf924kRi84/61cRbr
tGNrG9UUFnmt0fHVC1+hqlN4PBw940l1SUQc2Iw8uAPIdiKSVE7dM+eY7Ecp6wA33W2fUGFlPmpZ
+qhG0f8F/5EdvhSpzbjIqNOKeCe9Z0oFxLp72A==

`pragma protect data_method="aes128-cbc"
`pragma protect encoding=(enctype="base64", line_length=76, bytes=288)
`pragma protect data_block
9Z3Z4ZGXAUDMqLrpqfg6UNyT08JGfFSCGwJl4A8uTD9XuGgs7v2viixHc7oe4EVIbktCMSuNvVNb
/6fvi2oRPzaFFTCVUydyFs/iahFFCzUqmkKDQMYjVRJXSPZJxrquasSmi75Gcnn9bnnwe7TSduY3
tJCeMEoiytb3jrqccWo77xN2Fvm/UMrXhUpfVajtlIBi6yMfKKgmhIRHxTnrGG//nhG78y/rTo1h
e3muQW0qLCLsmKfUiiTHR35xJ/7A7z4EMPb8gOg1gYEoP0k8m0lRC+YgjkZXICSnOM2Cj01f8W/n
MMWwEbtSEfjl4R+fZvu7fdcX+f8FqolPrUlTa7+hVkoTzkBpqe96TZLhNxYQQHLPZHG3q3lsWjxo
jA7h

`pragma protect end_protected
endmodule