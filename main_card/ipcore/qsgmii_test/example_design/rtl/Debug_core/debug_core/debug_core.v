

module debug_core
  (
    //interface with jtag_hub
    drck_in,                  //jtag clock from jtag_hub module.
    hub_tdi,                  //tdi from jtag_hub module.
    id_i,                     //identify number from jtag_hub module,indicate select which sub module.    
    capt_i,
    shift_i,
    conf_sel,                 //indicate this debug_core is selected, from jtag_hub module.
    hub_tdo,                  //tdo to jtag_hub module.
    //interface with user logic                          
    clk,                      //the clock from user logic for trigger.
    
    trig0_i,                  //the trigger data for path 0, from user logic.
    
    resetn_i                  //the hw reset from user logic, it would be used for powerup trig.
  );

localparam FLA_VERSION       = 32'h9001F003;

localparam AREA_SPEED = 0; //@IPC int 0,3

localparam TRIG_PORT_NUM = 1; //@IPC int 1,16

localparam MAX_SEQ_LEVEL = 1; //@IPC int 1,16

localparam EN_TRIG_OUT = 0; //@IPC bool

localparam EN_WINDOWS = 0; //@IPC bool

localparam CLK_EDGE = 1; //@IPC enum 0,1

localparam MEM_STYLE = 1; //@IPC enum 0,1,2,3

localparam DATA_DEPTH = 9; //@IPC enum 6,7,8,9,10,11,12,13,14,15,16,17

localparam EN_STOR_QUAL = 0; //@IPC bool

localparam DATA_SAME_AS_TRIG = 1; //@IPC bool

localparam DATA_WIDTH = 1; //@IPC int 1,4096

localparam TRIG0_PORT_WIDTH = 128; //@IPC int 1,256

localparam TRIG0_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG0_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG0_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG0_EXCLUDE = 0; //@IPC bool

localparam TRIG1_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG1_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG1_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG1_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG1_EXCLUDE = 0; //@IPC bool

localparam TRIG2_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG2_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG2_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG2_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG2_EXCLUDE = 0; //@IPC bool

localparam TRIG3_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG3_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG3_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG3_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG3_EXCLUDE = 0; //@IPC bool

localparam TRIG4_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG4_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG4_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG4_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG4_EXCLUDE = 0; //@IPC bool

localparam TRIG5_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG5_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG5_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG5_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG5_EXCLUDE = 0; //@IPC bool

localparam TRIG6_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG6_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG6_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG6_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG6_EXCLUDE = 0; //@IPC bool

localparam TRIG7_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG7_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG7_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG7_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG7_EXCLUDE = 0; //@IPC bool

localparam TRIG8_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG8_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG8_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG8_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG8_EXCLUDE = 0; //@IPC bool

localparam TRIG9_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG9_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG9_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG9_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG9_EXCLUDE = 0; //@IPC bool

localparam TRIG10_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG10_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG10_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG10_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG10_EXCLUDE = 0; //@IPC bool

localparam TRIG11_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG11_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG11_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG11_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG11_EXCLUDE = 0; //@IPC bool

localparam TRIG12_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG12_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG12_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG12_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG12_EXCLUDE = 0; //@IPC bool

localparam TRIG13_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG13_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG13_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG13_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG13_EXCLUDE = 0; //@IPC bool

localparam TRIG14_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG14_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG14_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG14_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG14_EXCLUDE = 0; //@IPC bool

localparam TRIG15_PORT_WIDTH = 8; //@IPC int 1,256

localparam TRIG15_MATCH_UNIT = 1; //@IPC int 1,16

localparam TRIG15_CNT_WIDTH = 0; //@IPC int 0,32

localparam TRIG15_MATCH_TYPE = 1; //@IPC enum 0,1,2,3,4,5

localparam TRIG15_EXCLUDE = 0; //@IPC bool


  //   Initial Configuration

localparam INIT_ENABLE = 0; //@IPC bool

localparam INIT_TRIG_COND = 3'b000; //@IPC string @H trigger condition


  // match unit config

localparam INIT_M0_CONFIG = 385'b0010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010010; //@IPC string @H

localparam INIT_M1_CONFIG = 0; //@IPC string @H

localparam INIT_M2_CONFIG = 0; //@IPC string @H

localparam INIT_M3_CONFIG = 0; //@IPC string @H

localparam INIT_M4_CONFIG = 0; //@IPC string @H

localparam INIT_M5_CONFIG = 0; //@IPC string @H

localparam INIT_M6_CONFIG = 0; //@IPC string @H

localparam INIT_M7_CONFIG = 0; //@IPC string @H

localparam INIT_M8_CONFIG = 0; //@IPC string @H

localparam INIT_M9_CONFIG = 0; //@IPC string @H

localparam INIT_M10_CONFIG = 0; //@IPC string @H

localparam INIT_M11_CONFIG = 0; //@IPC string @H

localparam INIT_M12_CONFIG = 0; //@IPC string @H

localparam INIT_M13_CONFIG = 0; //@IPC string @H

localparam INIT_M14_CONFIG = 0; //@IPC string @H

localparam INIT_M15_CONFIG = 0; //@IPC string @H

localparam TU0_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU1_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU2_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU3_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU4_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU5_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU6_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU7_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU8_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU9_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU10_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU11_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU12_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU13_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU14_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU15_FUNCTION = "000"; //@IPC enum 000,001,010,011,110,111

localparam TU0_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU1_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU2_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU3_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU4_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU5_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU6_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU7_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU8_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU9_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU10_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU11_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU12_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU13_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU14_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU15_CNT_MODE = "00"; //@IPC enum 00,01,10,11

localparam TU0_CNT_VALUE = 1; //@IPC string

localparam TU1_CNT_VALUE = 1; //@IPC string

localparam TU2_CNT_VALUE = 1; //@IPC string

localparam TU3_CNT_VALUE = 1; //@IPC string

localparam TU4_CNT_VALUE = 1; //@IPC string

localparam TU5_CNT_VALUE = 1; //@IPC string

localparam TU6_CNT_VALUE = 1; //@IPC string

localparam TU7_CNT_VALUE = 1; //@IPC string

localparam TU8_CNT_VALUE = 1; //@IPC string

localparam TU9_CNT_VALUE = 1; //@IPC string

localparam TU10_CNT_VALUE = 1; //@IPC string

localparam TU11_CNT_VALUE = 1; //@IPC string

localparam TU12_CNT_VALUE = 1; //@IPC string

localparam TU13_CNT_VALUE = 1; //@IPC string

localparam TU14_CNT_VALUE = 1; //@IPC string

localparam TU15_CNT_VALUE = 1; //@IPC string

//localparam VALUE0 = 0; //@IPC string

localparam VALUE0_1 = 0; //@IPC string

localparam VALUE0_2 = 0; //@IPC string

localparam VALUE1 = 0; //@IPC string

localparam VALUE1_1 = 0; //@IPC string

localparam VALUE1_2 = 0; //@IPC string

localparam VALUE2 = 0; //@IPC string

localparam VALUE2_1 = 0; //@IPC string

localparam VALUE2_2 = 0; //@IPC string

localparam VALUE3 = 0; //@IPC string

localparam VALUE3_1 = 0; //@IPC string

localparam VALUE3_2 = 0; //@IPC string

localparam VALUE4 = 0; //@IPC string

localparam VALUE4_1 = 0; //@IPC string

localparam VALUE4_2 = 0; //@IPC string

localparam VALUE5 = 0; //@IPC string

localparam VALUE5_1 = 0; //@IPC string

localparam VALUE5_2 = 0; //@IPC string

localparam VALUE6 = 0; //@IPC string

localparam VALUE6_1 = 0; //@IPC string

localparam VALUE6_2 = 0; //@IPC string

localparam VALUE7 = 0; //@IPC string

localparam VALUE7_1 = 0; //@IPC string

localparam VALUE7_2 = 0; //@IPC string

localparam VALUE8 = 0; //@IPC string

localparam VALUE8_1 = 0; //@IPC string

localparam VALUE8_2 = 0; //@IPC string

localparam VALUE9 = 0; //@IPC string

localparam VALUE9_1 = 0; //@IPC string

localparam VALUE9_2 = 0; //@IPC string

localparam VALUE10 = 0; //@IPC string

localparam VALUE10_1 = 0; //@IPC string

localparam VALUE10_2 = 0; //@IPC string

localparam VALUE11 = 0; //@IPC string

localparam VALUE11_1 = 0; //@IPC string

localparam VALUE11_2 = 0; //@IPC string

localparam VALUE12 = 0; //@IPC string

localparam VALUE12_1 = 0; //@IPC string

localparam VALUE12_2 = 0; //@IPC string

localparam VALUE13 = 0; //@IPC string

localparam VALUE13_1 = 0; //@IPC string

localparam VALUE13_2 = 0; //@IPC string

localparam VALUE14 = 0; //@IPC string

localparam VALUE14_1 = 0; //@IPC string

localparam VALUE14_2 = 0; //@IPC string

localparam VALUE15 = 0; //@IPC string

localparam VALUE15_1 = 0; //@IPC string

localparam VALUE15_2 = 0; //@IPC string

localparam V0_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V0_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V0_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V1_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V1_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V1_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V2_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V2_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V2_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V3_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V3_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V3_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V4_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V4_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V4_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V5_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V5_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V5_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V6_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V6_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V6_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V7_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V7_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V7_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V8_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V8_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V8_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V9_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V9_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V9_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V10_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V10_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V10_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V11_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V11_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V11_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V12_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V12_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V12_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V13_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V13_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V13_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V14_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V14_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V14_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V15_RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V15_1RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam V15_2RADIX = "Bin"; //@IPC enum Bin,Oct,Dec,Hex

localparam TRIG_MODE = 0; //@IPC enum 0,1

localparam TRIG_NEG_WHOLE = 0; //@IPC bool

localparam TRIG_SEQ_LEVEL = 1; //@IPC int 1,16

localparam TRIG_CONTIGUOUS = 0; //@IPC bool

localparam TRIG_MU_EN0 = 0; //@IPC bool

localparam TRIG_MU_EN1 = 0; //@IPC bool

localparam TRIG_MU_EN2 = 0; //@IPC bool

localparam TRIG_MU_EN3 = 0; //@IPC bool

localparam TRIG_MU_EN4 = 0; //@IPC bool

localparam TRIG_MU_EN5 = 0; //@IPC bool

localparam TRIG_MU_EN6 = 0; //@IPC bool

localparam TRIG_MU_EN7 = 0; //@IPC bool

localparam TRIG_MU_EN8 = 0; //@IPC bool

localparam TRIG_MU_EN9 = 0; //@IPC bool

localparam TRIG_MU_EN10 = 0; //@IPC bool

localparam TRIG_MU_EN11 = 0; //@IPC bool

localparam TRIG_MU_EN12 = 0; //@IPC bool

localparam TRIG_MU_EN13 = 0; //@IPC bool

localparam TRIG_MU_EN14 = 0; //@IPC bool

localparam TRIG_MU_EN15 = 0; //@IPC bool

localparam TRIG_MU_NEG0 = 0; //@IPC bool

localparam TRIG_MU_NEG1 = 0; //@IPC bool

localparam TRIG_MU_NEG2 = 0; //@IPC bool

localparam TRIG_MU_NEG3 = 0; //@IPC bool

localparam TRIG_MU_NEG4 = 0; //@IPC bool

localparam TRIG_MU_NEG5 = 0; //@IPC bool

localparam TRIG_MU_NEG6 = 0; //@IPC bool

localparam TRIG_MU_NEG7 = 0; //@IPC bool

localparam TRIG_MU_NEG8 = 0; //@IPC bool

localparam TRIG_MU_NEG9 = 0; //@IPC bool

localparam TRIG_MU_NEG10 = 0; //@IPC bool

localparam TRIG_MU_NEG11 = 0; //@IPC bool

localparam TRIG_MU_NEG12 = 0; //@IPC bool

localparam TRIG_MU_NEG13 = 0; //@IPC bool

localparam TRIG_MU_NEG14 = 0; //@IPC bool

localparam TRIG_MU_NEG15 = 0; //@IPC bool

localparam TRIG_SEQ_SEL0 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL1 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL2 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL3 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL4 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL5 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL6 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL7 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL8 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL9 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL10 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL11 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL12 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL13 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL14 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_SEL15 = 0; //@IPC enum 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

localparam TRIG_SEQ_NEG0 = 0; //@IPC bool

localparam TRIG_SEQ_NEG1 = 0; //@IPC bool

localparam TRIG_SEQ_NEG2 = 0; //@IPC bool

localparam TRIG_SEQ_NEG3 = 0; //@IPC bool

localparam TRIG_SEQ_NEG4 = 0; //@IPC bool

localparam TRIG_SEQ_NEG5 = 0; //@IPC bool

localparam TRIG_SEQ_NEG6 = 0; //@IPC bool

localparam TRIG_SEQ_NEG7 = 0; //@IPC bool

localparam TRIG_SEQ_NEG8 = 0; //@IPC bool

localparam TRIG_SEQ_NEG9 = 0; //@IPC bool

localparam TRIG_SEQ_NEG10 = 0; //@IPC bool

localparam TRIG_SEQ_NEG11 = 0; //@IPC bool

localparam TRIG_SEQ_NEG12 = 0; //@IPC bool

localparam TRIG_SEQ_NEG13 = 0; //@IPC bool

localparam TRIG_SEQ_NEG14 = 0; //@IPC bool

localparam TRIG_SEQ_NEG15 = 0; //@IPC bool

localparam INIT_STOR_TYPE = 14'b00000000000000; //@IPC string @H

localparam INIT_TRIG_OUT = "3'b000"; //@IPC enum 3'b000,3'b001,3'b010,3'b011,3'b100

localparam STORE_TYPE = 0; //@IPC enum 0,1

localparam STORE_TYPE_DIV = 1; //@IPC int 1,131072 max 2^17

localparam STORE_POSITION = 0; //@IPC int 0,131072 max 2^17

localparam INIT_STOR_QUAL = 2'b0; //@IPC string @H

localparam ALL_DATA = 1; //@IPC enum 1,0

localparam STOR_NEG_WHOLE = 0; //@IPC bool

localparam STOR_MU_EN0 = 0; //@IPC bool

localparam STOR_MU_EN1 = 0; //@IPC bool

localparam STOR_MU_EN2 = 0; //@IPC bool

localparam STOR_MU_EN3 = 0; //@IPC bool

localparam STOR_MU_EN4 = 0; //@IPC bool

localparam STOR_MU_EN5 = 0; //@IPC bool

localparam STOR_MU_EN6 = 0; //@IPC bool

localparam STOR_MU_EN7 = 0; //@IPC bool

localparam STOR_MU_EN8 = 0; //@IPC bool

localparam STOR_MU_EN9 = 0; //@IPC bool

localparam STOR_MU_EN10 = 0; //@IPC bool

localparam STOR_MU_EN11 = 0; //@IPC bool

localparam STOR_MU_EN12 = 0; //@IPC bool

localparam STOR_MU_EN13 = 0; //@IPC bool

localparam STOR_MU_EN14 = 0; //@IPC bool

localparam STOR_MU_EN15 = 0; //@IPC bool

localparam STOR_MU_NEG0 = 0; //@IPC bool

localparam STOR_MU_NEG1 = 0; //@IPC bool

localparam STOR_MU_NEG2 = 0; //@IPC bool

localparam STOR_MU_NEG3 = 0; //@IPC bool

localparam STOR_MU_NEG4 = 0; //@IPC bool

localparam STOR_MU_NEG5 = 0; //@IPC bool

localparam STOR_MU_NEG6 = 0; //@IPC bool

localparam STOR_MU_NEG7 = 0; //@IPC bool

localparam STOR_MU_NEG8 = 0; //@IPC bool

localparam STOR_MU_NEG9 = 0; //@IPC bool

localparam STOR_MU_NEG10 = 0; //@IPC bool

localparam STOR_MU_NEG11 = 0; //@IPC bool

localparam STOR_MU_NEG12 = 0; //@IPC bool

localparam STOR_MU_NEG13 = 0; //@IPC bool

localparam STOR_MU_NEG14 = 0; //@IPC bool

localparam STOR_MU_NEG15 = 0; //@IPC bool

localparam c_Port0_EN = 1; //@IPC bool

localparam c_Port1_EN = 0; //@IPC bool

localparam c_Port2_EN = 0; //@IPC bool

localparam c_Port3_EN = 0; //@IPC bool

localparam c_Port4_EN = 0; //@IPC bool

localparam c_Port5_EN = 0; //@IPC bool

localparam c_Port6_EN = 0; //@IPC bool

localparam c_Port7_EN = 0; //@IPC bool

localparam c_Port8_EN = 0; //@IPC bool

localparam c_Port9_EN = 0; //@IPC bool

localparam c_Port10_EN = 0; //@IPC bool

localparam c_Port11_EN = 0; //@IPC bool

localparam c_Port12_EN = 0; //@IPC bool

localparam c_Port13_EN = 0; //@IPC bool

localparam c_Port14_EN = 0; //@IPC bool

localparam c_Port15_EN = 0; //@IPC bool



  //interface with jtag_hub
   input                        drck_in;                  //jtag clock from jtag_hub module.
   input                        hub_tdi;                  //tdi from jtag_hub module.
   input                        id_i;                     //identify number from jtag_hub module,indicate select which sub module.    
   input                        capt_i;
   input                        shift_i;
   input                        conf_sel;                 //indicate this debug_core is selected, from jtag_hub module.
   output                       hub_tdo;                  //tdo to jtag_hub module.
  //interface with user logic                         
   input                        clk;                      //the clock from user logic for trigger.
   
   input                        trig0_i;                  //the trigger data for path 0, from user logic.
   
   input                        resetn_i;                 //the hw reset from user logic, it would be used for powerup trig.
   
   wire                         drck_in;                  
   wire                         hub_tdi;                  
   wire                   [4:0] id_i;                       
   wire                         capt_i;
   wire                         shift_i;   
   wire                         conf_sel;                 
   wire                         hub_tdo;                  
   wire                         clk;                      
   wire  [DATA_WIDTH-1:0]       data_i;                   
   wire  [TRIG0_PORT_WIDTH-1:0] trig0_i;                  
   wire  [TRIG1_PORT_WIDTH-1:0] trig1_i;                  
   wire  [TRIG2_PORT_WIDTH-1:0] trig2_i;                  
   wire  [TRIG3_PORT_WIDTH-1:0] trig3_i;                  
   wire  [TRIG4_PORT_WIDTH-1:0] trig4_i;                  
   wire  [TRIG5_PORT_WIDTH-1:0] trig5_i;                  
   wire  [TRIG6_PORT_WIDTH-1:0] trig6_i;                  
   wire  [TRIG7_PORT_WIDTH-1:0] trig7_i;                  
   wire  [TRIG8_PORT_WIDTH-1:0] trig8_i;                  
   wire  [TRIG9_PORT_WIDTH-1:0] trig9_i;                  
   wire [TRIG10_PORT_WIDTH-1:0] trig10_i;                 
   wire [TRIG11_PORT_WIDTH-1:0] trig11_i;                 
   wire [TRIG12_PORT_WIDTH-1:0] trig12_i;                 
   wire [TRIG13_PORT_WIDTH-1:0] trig13_i;                 
   wire [TRIG14_PORT_WIDTH-1:0] trig14_i;                 
   wire [TRIG15_PORT_WIDTH-1:0] trig15_i;                 
   wire                         trig_out;                 
   wire                         resetn_i;    
   wire  [DATA_WIDTH-1:0]       data_ii;                   
   wire  [TRIG0_PORT_WIDTH-1:0] trig0_ii;                  
   wire  [TRIG1_PORT_WIDTH-1:0] trig1_ii;                  
   wire  [TRIG2_PORT_WIDTH-1:0] trig2_ii;                  
   wire  [TRIG3_PORT_WIDTH-1:0] trig3_ii;                  
   wire  [TRIG4_PORT_WIDTH-1:0] trig4_ii;                  
   wire  [TRIG5_PORT_WIDTH-1:0] trig5_ii;                  
   wire  [TRIG6_PORT_WIDTH-1:0] trig6_ii;                  
   wire  [TRIG7_PORT_WIDTH-1:0] trig7_ii;                  
   wire  [TRIG8_PORT_WIDTH-1:0] trig8_ii;                  
   wire  [TRIG9_PORT_WIDTH-1:0] trig9_ii;                  
   wire [TRIG10_PORT_WIDTH-1:0] trig10_ii;                 
   wire [TRIG11_PORT_WIDTH-1:0] trig11_ii;                 
   wire [TRIG12_PORT_WIDTH-1:0] trig12_ii;                 
   wire [TRIG13_PORT_WIDTH-1:0] trig13_ii;                 
   wire [TRIG14_PORT_WIDTH-1:0] trig14_ii;                 
   wire [TRIG15_PORT_WIDTH-1:0] trig15_ii;

 assign data_ii   = (DATA_SAME_AS_TRIG == 1) ? 1'b0 : data_i;
 assign trig0_ii  = trig0_i;
 assign trig1_ii  = (c_Port1_EN == 1) ? trig1_i : 1'b0;
 assign trig2_ii  = (c_Port2_EN == 1) ? trig2_i : 1'b0;
 assign trig3_ii  = (c_Port3_EN == 1) ? trig3_i : 1'b0;
 assign trig4_ii  = (c_Port4_EN == 1) ? trig4_i : 1'b0;
 assign trig5_ii  = (c_Port5_EN == 1) ? trig5_i : 1'b0;
 assign trig6_ii  = (c_Port6_EN == 1) ? trig6_i : 1'b0;
 assign trig7_ii  = (c_Port7_EN == 1) ? trig7_i : 1'b0;
 assign trig8_ii  = (c_Port8_EN == 1) ? trig8_i : 1'b0;
 assign trig9_ii  = (c_Port9_EN == 1) ? trig9_i : 1'b0;
 assign trig10_ii = (c_Port10_EN == 1) ? trig10_i : 1'b0;
 assign trig11_ii = (c_Port11_EN == 1) ? trig11_i : 1'b0;
 assign trig12_ii = (c_Port12_EN == 1) ? trig12_i : 1'b0;
 assign trig13_ii = (c_Port13_EN == 1) ? trig13_i : 1'b0;
 assign trig14_ii = (c_Port14_EN == 1) ? trig14_i : 1'b0;
 assign trig15_ii = (c_Port15_EN == 1) ? trig15_i : 1'b0;


 ips_dbc_debug_core_v1_3
 #(
  .FLA_VERSION           (FLA_VERSION        ),
  .AREA_SPEED            (AREA_SPEED         ),
  .TRIG_PORT_NUM         (TRIG_PORT_NUM      ),
  .MAX_SEQ_LEVEL         (MAX_SEQ_LEVEL      ),
  .EN_TRIG_OUT           (EN_TRIG_OUT        ),
  .EN_WINDOWS            (EN_WINDOWS         ),  
  .CLK_EDGE              (CLK_EDGE           ),
  .MEM_STYLE             (MEM_STYLE          ),
  .DATA_DEPTH            (DATA_DEPTH         ),
  .EN_STOR_QUAL          (EN_STOR_QUAL       ),
  .DATA_SAME_AS_TRIG     (DATA_SAME_AS_TRIG  ),
  .DATA_WIDTH            (DATA_WIDTH         ),
  .TRIG0_PORT_WIDTH      (TRIG0_PORT_WIDTH   ),
  .TRIG0_MATCH_UNIT      (TRIG0_MATCH_UNIT   ),
  .TRIG0_CNT_WIDTH       (TRIG0_CNT_WIDTH    ),
  .TRIG0_MATCH_TYPE      (TRIG0_MATCH_TYPE   ),
  .TRIG0_EXCLUDE         (TRIG0_EXCLUDE      ),
  .TRIG1_PORT_WIDTH      (TRIG1_PORT_WIDTH   ),
  .TRIG1_MATCH_UNIT      (TRIG1_MATCH_UNIT   ),
  .TRIG1_CNT_WIDTH       (TRIG1_CNT_WIDTH    ),
  .TRIG1_MATCH_TYPE      (TRIG1_MATCH_TYPE   ),
  .TRIG1_EXCLUDE         (TRIG1_EXCLUDE      ),
  .TRIG2_PORT_WIDTH      (TRIG2_PORT_WIDTH   ),
  .TRIG2_MATCH_UNIT      (TRIG2_MATCH_UNIT   ),
  .TRIG2_CNT_WIDTH       (TRIG2_CNT_WIDTH    ),
  .TRIG2_MATCH_TYPE      (TRIG2_MATCH_TYPE   ),
  .TRIG2_EXCLUDE         (TRIG2_EXCLUDE      ),
  .TRIG3_PORT_WIDTH      (TRIG3_PORT_WIDTH   ),
  .TRIG3_MATCH_UNIT      (TRIG3_MATCH_UNIT   ),
  .TRIG3_CNT_WIDTH       (TRIG3_CNT_WIDTH    ),
  .TRIG3_MATCH_TYPE      (TRIG3_MATCH_TYPE   ),
  .TRIG3_EXCLUDE         (TRIG3_EXCLUDE      ),
  .TRIG4_PORT_WIDTH      (TRIG4_PORT_WIDTH   ),
  .TRIG4_MATCH_UNIT      (TRIG4_MATCH_UNIT   ),
  .TRIG4_CNT_WIDTH       (TRIG4_CNT_WIDTH    ),
  .TRIG4_MATCH_TYPE      (TRIG4_MATCH_TYPE   ),
  .TRIG4_EXCLUDE         (TRIG4_EXCLUDE      ),
  .TRIG5_PORT_WIDTH      (TRIG5_PORT_WIDTH   ),
  .TRIG5_MATCH_UNIT      (TRIG5_MATCH_UNIT   ),
  .TRIG5_CNT_WIDTH       (TRIG5_CNT_WIDTH    ),
  .TRIG5_MATCH_TYPE      (TRIG5_MATCH_TYPE   ),
  .TRIG5_EXCLUDE         (TRIG5_EXCLUDE      ),
  .TRIG6_PORT_WIDTH      (TRIG6_PORT_WIDTH   ),
  .TRIG6_MATCH_UNIT      (TRIG6_MATCH_UNIT   ),
  .TRIG6_CNT_WIDTH       (TRIG6_CNT_WIDTH    ),
  .TRIG6_MATCH_TYPE      (TRIG6_MATCH_TYPE   ),
  .TRIG6_EXCLUDE         (TRIG6_EXCLUDE      ),
  .TRIG7_PORT_WIDTH      (TRIG7_PORT_WIDTH   ),
  .TRIG7_MATCH_UNIT      (TRIG7_MATCH_UNIT   ),
  .TRIG7_CNT_WIDTH       (TRIG7_CNT_WIDTH    ),
  .TRIG7_MATCH_TYPE      (TRIG7_MATCH_TYPE   ),
  .TRIG7_EXCLUDE         (TRIG7_EXCLUDE      ),
  .TRIG8_PORT_WIDTH      (TRIG8_PORT_WIDTH   ),
  .TRIG8_MATCH_UNIT      (TRIG8_MATCH_UNIT   ),
  .TRIG8_CNT_WIDTH       (TRIG8_CNT_WIDTH    ),
  .TRIG8_MATCH_TYPE      (TRIG8_MATCH_TYPE   ),
  .TRIG8_EXCLUDE         (TRIG8_EXCLUDE      ),
  .TRIG9_PORT_WIDTH      (TRIG9_PORT_WIDTH   ),
  .TRIG9_MATCH_UNIT      (TRIG9_MATCH_UNIT   ),
  .TRIG9_CNT_WIDTH       (TRIG9_CNT_WIDTH    ),
  .TRIG9_MATCH_TYPE      (TRIG9_MATCH_TYPE   ),
  .TRIG9_EXCLUDE         (TRIG9_EXCLUDE      ),
  .TRIG10_PORT_WIDTH     (TRIG10_PORT_WIDTH  ),
  .TRIG10_MATCH_UNIT     (TRIG10_MATCH_UNIT  ),
  .TRIG10_CNT_WIDTH      (TRIG10_CNT_WIDTH   ),
  .TRIG10_MATCH_TYPE     (TRIG10_MATCH_TYPE  ),
  .TRIG10_EXCLUDE        (TRIG10_EXCLUDE     ),
  .TRIG11_PORT_WIDTH     (TRIG11_PORT_WIDTH  ),
  .TRIG11_MATCH_UNIT     (TRIG11_MATCH_UNIT  ),
  .TRIG11_CNT_WIDTH      (TRIG11_CNT_WIDTH   ),
  .TRIG11_MATCH_TYPE     (TRIG11_MATCH_TYPE  ),
  .TRIG11_EXCLUDE        (TRIG11_EXCLUDE     ),
  .TRIG12_PORT_WIDTH     (TRIG12_PORT_WIDTH  ),
  .TRIG12_MATCH_UNIT     (TRIG12_MATCH_UNIT  ),
  .TRIG12_CNT_WIDTH      (TRIG12_CNT_WIDTH   ),
  .TRIG12_MATCH_TYPE     (TRIG12_MATCH_TYPE  ),
  .TRIG12_EXCLUDE        (TRIG12_EXCLUDE     ),
  .TRIG13_PORT_WIDTH     (TRIG13_PORT_WIDTH  ),
  .TRIG13_MATCH_UNIT     (TRIG13_MATCH_UNIT  ),
  .TRIG13_CNT_WIDTH      (TRIG13_CNT_WIDTH   ),
  .TRIG13_MATCH_TYPE     (TRIG13_MATCH_TYPE  ),
  .TRIG13_EXCLUDE        (TRIG13_EXCLUDE     ),
  .TRIG14_PORT_WIDTH     (TRIG14_PORT_WIDTH  ),
  .TRIG14_MATCH_UNIT     (TRIG14_MATCH_UNIT  ),
  .TRIG14_CNT_WIDTH      (TRIG14_CNT_WIDTH   ),
  .TRIG14_MATCH_TYPE     (TRIG14_MATCH_TYPE  ),
  .TRIG14_EXCLUDE        (TRIG14_EXCLUDE     ),
  .TRIG15_PORT_WIDTH     (TRIG15_PORT_WIDTH  ),
  .TRIG15_MATCH_UNIT     (TRIG15_MATCH_UNIT  ),
  .TRIG15_CNT_WIDTH      (TRIG15_CNT_WIDTH   ),
  .TRIG15_MATCH_TYPE     (TRIG15_MATCH_TYPE  ),
  .TRIG15_EXCLUDE        (TRIG15_EXCLUDE     ),
  //   Initial Configuration
  .INIT_ENABLE           (INIT_ENABLE        ),  
  .INIT_TRIG_COND        (INIT_TRIG_COND     ),  
  .INIT_TRIG_OUT         (INIT_TRIG_OUT      ),  
  .INIT_STOR_TYPE        (INIT_STOR_TYPE     ),  
  .INIT_STOR_QUAL        (INIT_STOR_QUAL     ),  
  .INIT_M0_CONFIG        (INIT_M0_CONFIG     ),  
  .INIT_M1_CONFIG        (INIT_M1_CONFIG     ),  
  .INIT_M2_CONFIG        (INIT_M2_CONFIG     ),  
  .INIT_M3_CONFIG        (INIT_M3_CONFIG     ),  
  .INIT_M4_CONFIG        (INIT_M4_CONFIG     ),  
  .INIT_M5_CONFIG        (INIT_M5_CONFIG     ),  
  .INIT_M6_CONFIG        (INIT_M6_CONFIG     ),  
  .INIT_M7_CONFIG        (INIT_M7_CONFIG     ),  
  .INIT_M8_CONFIG        (INIT_M8_CONFIG     ),  
  .INIT_M9_CONFIG        (INIT_M9_CONFIG     ),  
  .INIT_M10_CONFIG       (INIT_M10_CONFIG    ),  
  .INIT_M11_CONFIG       (INIT_M11_CONFIG    ),  
  .INIT_M12_CONFIG       (INIT_M12_CONFIG    ),  
  .INIT_M13_CONFIG       (INIT_M13_CONFIG    ),  
  .INIT_M14_CONFIG       (INIT_M14_CONFIG    ),  
  .INIT_M15_CONFIG       (INIT_M15_CONFIG    ) 
  )
  u_ips_dbc_debug_core(
  //interface with jtag_hub
   .drck_in              (drck_in),                  //jtag clock from jtag_hub module.
   .hub_tdi              (hub_tdi),                  //tdi from jtag_hub module.
   .id_i                 (id_i),                     //identify number from jtag_hub module,indicate select which sub module.    
   .capt_i               (capt_i),
   .shift_i              (shift_i),
   .conf_sel             (conf_sel),                 //indicate this debug_core is selected, from jtag_hub module.
   .hub_tdo              (hub_tdo),                  //tdo to jtag_hub module.
  //interface with user logic                          
   .clk                  (clk),                      //the clock from user logic for trigger.
   .resetn_i             (resetn_i),                 //the hw reset from user logic, it would be used for powerup trig.
   .data_i               (data_ii),                   //the sample data from user logic.
   .trig0_i              (trig0_ii),                  //the trigger data for path 0, from user logic.
   .trig1_i              (trig1_ii),                  //the trigger data for path 1, from user logic.
   .trig2_i              (trig2_ii),                  //the trigger data for path 2, from user logic.
   .trig3_i              (trig3_ii),                  //the trigger data for path 3, from user logic.
   .trig4_i              (trig4_ii),                  //the trigger data for path 4, from user logic.
   .trig5_i              (trig5_ii),                  //the trigger data for path 5, from user logic.
   .trig6_i              (trig6_ii),                  //the trigger data for path 6, from user logic.   
   .trig7_i              (trig7_ii),                  //the trigger data for path 7, from user logic.   
   .trig8_i              (trig8_ii),                  //the trigger data for path 8, from user logic.   
   .trig9_i              (trig9_ii),                  //the trigger data for path 9, from user logic.
   .trig10_i             (trig10_ii),                 //the trigger data for path 10, from user logic.
   .trig11_i             (trig11_ii),                 //the trigger data for path 11, from user logic.
   .trig12_i             (trig12_ii),                 //the trigger data for path 12, from user logic.
   .trig13_i             (trig13_ii),                 //the trigger data for path 13, from user logic.
   .trig14_i             (trig14_ii),                 //the trigger data for path 14, from user logic.   
   .trig15_i             (trig15_ii),                 //the trigger data for path 15, from user logic.   
   .trig_out             (trig_out)                  //trigger out signal, to user logic. 
  );

endmodule

