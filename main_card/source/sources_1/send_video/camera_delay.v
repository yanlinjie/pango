module camera_delay 
(
   input                cmos_pclk,              // CMOS pixel clock
   input                cmos_href,              // CMOS hsync reference
   input                cmos_vsync,             // CMOS vsync
   input      [15:0]    cmos_data,              // CMOS data

   output               cmos_href_delay,        // CMOS hsync reference delay
   output     [15:0]    cmos_data_delay,        // CMOS data delay
   output reg           vsync_pulse             // Output pulse on vsync rising edge
);

reg cmos_vsync_d0, cmos_vsync_d1;  // Registers to store delayed vsync signals
reg cmos_href_d0, cmos_href_d1;    // Registers to store delayed href signals
reg [15:0] cmos_data_d0;           // First stage delay for cmos_data
reg [15:0] cmos_data_d1;           // Second stage delay for cmos_data

// Buffer for delayed cmos_href
always @(posedge cmos_pclk) begin
  cmos_href_d0 <= cmos_href;  // First stage delay
  cmos_href_d1 <= cmos_href_d0;  // Second stage delay
end

// Detect cmos_vsync rising edge using a delayed version of cmos_vsync
always @(posedge cmos_pclk) begin
  cmos_vsync_d0 <= cmos_vsync;  // First stage delay
  cmos_vsync_d1 <= cmos_vsync_d0;  // Second stage delay
end

// Generate pulse on cmos_vsync rising edge
always @(posedge cmos_pclk) begin
  if (cmos_vsync_d0 == 1'b1 && cmos_vsync_d1 == 1'b0)  // Rising edge detected
    vsync_pulse <= 1'b1;
  else
    vsync_pulse <= 1'b0;
end

// Delay CMOS data through registers
always @(posedge cmos_pclk) begin
  cmos_data_d0 <= cmos_data;    // First stage delay
  cmos_data_d1 <= cmos_data_d0; // Second stage delay
end

// Output delayed signals
assign cmos_href_delay = cmos_href_d1;  // Output delayed href signal
assign cmos_data_delay = cmos_data_d1;  // Output delayed data signal

endmodule
