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

module ips_dbc_data_capture_mem_v1_1
#(
 parameter  MEM_STYLE  = 0,
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
iy4G/Hut6O8/2gjTdinVv6XTWRmBGzLmDsmNJP2zSI+PreVqV74eGkdls4MWt6trIK+Ddnm0Iq6A
AaKu11HVqAEuaBqlRL3/NONyvznAByW6JlVzS1UZEkMP6VmajxnzGBd+8bYD1KxzYewtYS+Z+j4H
TJqPIcV1Q3BEjUl9AvWRfiML0Kb/EZUcCVt0hsPdf5/oxFWzBh03TOHqQnHJ0teTWfrdjSOxG429
+qgo/RjPo0sr8UKf2nym8WipNKEWD9WDPwWbW3xxHyoubHuafko5Sojke8v/0/FYybt6iwCkIHwy
knwUXQ0QqYl4KNpRf4SDZnYP+dKCHNRS9WRpjw==

`pragma protect encoding=(enctype="base64", line_length=76, bytes=256)
`pragma protect key_keyowner="Pango Microsystems", key_keyname="PANGO_V1.1", key_method="rsa"
`pragma protect key_block
HB5L9ygkHZrUC9te23+/a6Gc00w2TtOBI6KixaRsm90lDDJz87j7o333f9Fz2nYJuPG3DEaXej1u
sO/E6AqHdHWrxUs6jeq/6/rp1ngywnMAxpe0JIm33T5Vn0oPE17rIIMwh7I2fEofds2f+kUILGmX
da8NgYCQvCz3Chc5vFDwICVEwVfYwYJq+1m3qZIf4w+LgVjQq/ELohZyS2W5ofy5bp02xAcT53ZW
94+hBmFZt/V539lCOHfiorV2vnTcOtEgaVOBtpu3eoMK0AdwQe6rmwZ0XcI0a9rnzOXQI118Cz6q
T8C2pYseItfQmW+EW7GdeZ5maT8sLTaP0cD3fg==

`pragma protect data_method="aes128-cbc"
`pragma protect encoding=(enctype="base64", line_length=76, bytes=1360)
`pragma protect data_block
PwS2TSyqYi31L+hA8SS7rNzRC4A/kg2nxeiHe9K3popS22jx3waZ5u/Dd3tRoo9ZL+v7xK/qlmMz
6bgy73YCx1T39GiYZr8G7oyR3rXjweIav/K38PH620/lsTa5rN948x57+nM8fbdZizxs4Er1n9ow
C3GncCiXcMgnKLaux59he6R5kuTykbebOfPXiVfgodquvcponKDv0TmtNI0o783TX5yGxWvp/PBK
pAE0apZJbW+Q4rohfr7RgYmh8Tu1peGbp3BYtyKddD177GfuB9pgOwpYX3onSmyi10ucNwmeCvol
Vj0ifVr9qsBMqY370VC6v1UV4m1jgzDo7apUU+fq0AyFdypeddNUhFnqOI2U1dCVWaPqPsO31BjD
fsM2vZpxtMndukDzEHagxv1WAuNyb69FYP+69vGJWE/QcRGlhZRhvy60r0sKC07ZD4i4ZUm0luiT
RUZ/8l0aOJ6Wc8A1H9aalRGDgZLs8UkbvhmlF1dusYLe1OVVDhl1WzPgzgRtb8yNu3RduY18LvYO
POOD9yqPG6oHkQHv39mWRkxGpCWIQuqiBSPpxKZW8f4Z5MTW0tOg1w+6U3r4tN6YUoPjM4cn3PjQ
OdplwkBdZiG5x9Hvx4gghTS6rR6fWUav6TS8Ywnv1dzPbW3avhLLHgYV41FXZJwQ8Dllmb8Xae47
8ubXdjr4Ujge0knpe5WG4IOqUREgkBrwy9d9dLIGpfOTPdLt/1WM05wlnlqofSkPvgdUkHNmsHgp
kZVahUhwJHQwj4DQS77Jarnm7w9/iR4mth+kPA2us5T/EGFc6hiCaTHtcoWy/1Sho8vu0P/VQKYy
W48Np32asTLv35zX4Dg5ylgzOC+5mTylErm31URrZ95ogi51gpPsui3woypcB+ISsEuB/ginHM2y
aqBDeKfpOHDQKkALwmPCw4SOFscNB1bBFOLzlbKWf3FaygJVAkRXLqK5EaYwYypw3MN77aDvZwEF
dWG17Vz2T54Ftthn3foL7MXkJgRLfR3uEDPeicQ+GnA79Ev54z+m8vSdS47NvE/9zU+ewABiwnB7
wqRM6wCjpmVRg4aiZPKUogX6rdq1KR1rwOADK30+eBUXLcXJfJGHgGqzqk96utE+gGKHxfPOUoGK
gIOveRlp/DWlyPH0RjexewC1do2FO//yJ4FiWl6JUazY+GA7XeeLn16TFnlEIpBZySMHlUD7/yP1
YfaPlwYtli2hH3OxmcoX76thXt5fEZ7nWCbg9ZXSR8UXtpRXD6xZv+HfZpqpDZ1HE3WvuJ7XA+k+
RGlwIbBM5TSVMPBmw3tbelbOF7VK8ZQlceKXHIbiLJ3LfPlJ4XsT7sA9/ciqD4iM3maO4OUn1qJ2
5DoQUStu8KBuMEBYCgyO8ahXjszT36GxhjBW1fOZ/vtbjdm43R1mHrSxF92MkUTD7+CsrVUb/ucG
rmJ4+sVbiPbNIPUHTO8Sk5N7qUnGihi0lJxbHKiWqDAVG52bEtxwCWT7tZ1OkkamI2/wN3irdrUy
6VrBCKCJjGnelrN3c0enpZDJHdYTT/yd0mWU11lBO5ZlyHYvw1W9I4cK984W3tuC7p/QmbHeWIw/
BqyQ5Poy/kGWRrHPbVhfh6X+MDpQSWcdo2JsZHuH2L//dr0ANGky6Aa6QI5ATbJpqL2sijAM5wBM
61BlKHg8e65Hd0/9s2hUYuBLwcxlTQyvUNfe3WnVb/7eALmbKm2ZQBjeUWsZ1g4AzRigTZwXikHg
hdeDjC+0D9ovBIHYmFN6P0lUqw7QNTOwjANX9fMqRlz/H/qSxlzav+K79hXibJmlJQ==

`pragma protect end_protected
endmodule