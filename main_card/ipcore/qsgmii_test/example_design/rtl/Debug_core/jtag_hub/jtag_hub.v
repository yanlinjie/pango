

module jtag_hub
 #(

parameter CTRL_PORT_NUM = 3, //@IPC int 1,15 //the number of usr_app connect with jtag_hub

parameter UJTAG_SEL = 0 //1:use jtagif ;0:use scanchain

 )
 (
   
   input              resetn_i ,                 //hw reset from user logic device, active low.    
  // for user_app interface(debug_core,etc)
   output             drck_o,                    //transfer TCK to each user_app
   output             hub_tdi,                   //transfer TDI to each user_app
   output             capt_o,                    //capture  
   output             shift_o,                   //shift
   output     [14:0]  conf_sel,                  //select config module which indicated by ID  
   output     [4:0]   id_o,                      //ID number indication
   input      [14:0]  hub_tdo                    //read back signal from each user_app
 );  
 

localparam PGT_DEVICE_30G = 0; //@IPC bool

localparam PGT_DEVICE = 0; //@IPC bool

localparam PGL_DEVICE = 0; //@IPC bool


wire capture,drck1,reset,sel1,shift,update,tdi1,tdo1; 

    
GTP_SCANCHAIN_E1 u_GTP_SCANCHAIN(
     
     .TCK(),
     .TDI(),
     .TMS(),
     .TDO(),
     .CAPDR(capture),
        
     .JCLK(), 
     .TCK_USER(drck1),                   //TCK_USER output clk, when device is pgl22g, 2017.11.14
     .TMS_USER(),
     .JRTI(),
     
     .RST(reset),
     .FLG_USER(sel1),
     .SHFTDR(shift),
     .TDI_USER(tdi1),             
     .UPDR(update),  
     .TDO_USER(tdo1)                                                            
)/* synthesis syn_noprune = 1 */;

wire [15:0] conf_sel_s;
wire [15:0] hub_tdo_s;
wire shift_d;

ips_jtag_hub_v1_3
 #(
 .CTRL_PORT_NUM  (CTRL_PORT_NUM),          //the number of usr_app connect with jtag_hub  
 .UJTAG_SEL      (UJTAG_SEL)              //1:use jtagif ;0:use scanchain
 )                               
 u_ips_jtag_hub(
   // for user jtagif 
   
  // for JTAG_interface
   
   .drck_in      (drck1),                //TCK for user data register
   .tdi_in       (tdi1),                 //TDI for user data register;
   
   .tdo_out      (tdo1),                 //TDO for user data register;
   .reset_dr     (reset),	               //active high reset when TAP state in e_TEST_LOGIC_RESET state
    
   .shift_in     (shift),	               //TAP state in e_SHIFT_DR, to shift when device is not pgt30g
        
   .update_in    (update),               //TAP state in e_UPDATE_DR
   .capture_in   (capture),              //TAP state in e_CAPTURE_DR
   .sel_in       (sel1),                 //user data register is selected
   .h_rstn       (resetn_i),
  
  // for user_app interface(debug_core,etc)
   .drck_o       (drck_o),               //transfer TCK to each user_app
   .conf_tdi     (hub_tdi),              //transfer TDI to each user_app
   .conf_sel     (conf_sel_s),           //select config module which indicated by ID  
   .id_o         (id_o),                 //ID number indication
   .capt_o       (capt_o),               //capture
   .shift_d      (shift_d),              //shift_in delay 1 clk
   .hub_tdo      (hub_tdo_s)             //read back signal from each user_app
 ); 
assign conf_sel  = conf_sel_s[14:0];
assign shift_o   = shift_d;
assign hub_tdo_s[14:0] = hub_tdo[14:0];
assign hub_tdo_s[15] = 1'b0;
            
endmodule
